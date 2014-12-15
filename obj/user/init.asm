
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 57 01 00 00       	call   800188 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
	for (i = 0; i < n; i++)
  80003f:	85 db                	test   %ebx,%ebx
  800041:	7e 1c                	jle    80005f <sum+0x2b>
char bss[6000];

int
sum(const char *s, int n)
{
	int i, tot = 0;
  800043:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800048:	ba 00 00 00 00       	mov    $0x0,%edx
		tot ^= i * s[i];
  80004d:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  800051:	0f af ca             	imul   %edx,%ecx
  800054:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800056:	83 c2 01             	add    $0x1,%edx
  800059:	39 da                	cmp    %ebx,%edx
  80005b:	75 f0                	jne    80004d <sum+0x19>
  80005d:	eb 05                	jmp    800064 <sum+0x30>
char bss[6000];

int
sum(const char *s, int n)
{
	int i, tot = 0;
  80005f:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
		tot ^= i * s[i];
	return tot;
}
  800064:	5b                   	pop    %ebx
  800065:	5e                   	pop    %esi
  800066:	5d                   	pop    %ebp
  800067:	c3                   	ret    

00800068 <umain>:

void
umain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	57                   	push   %edi
  80006c:	56                   	push   %esi
  80006d:	53                   	push   %ebx
  80006e:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  800074:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  800077:	c7 04 24 e0 1d 80 00 	movl   $0x801de0,(%esp)
  80007e:	e8 14 02 00 00       	call   800297 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800083:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800092:	e8 9d ff ff ff       	call   800034 <sum>
  800097:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  80009c:	74 1a                	je     8000b8 <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  80009e:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  8000a5:	00 
  8000a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000aa:	c7 04 24 40 1e 80 00 	movl   $0x801e40,(%esp)
  8000b1:	e8 e1 01 00 00       	call   800297 <cprintf>
  8000b6:	eb 0c                	jmp    8000c4 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000b8:	c7 04 24 ef 1d 80 00 	movl   $0x801def,(%esp)
  8000bf:	e8 d3 01 00 00       	call   800297 <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000c4:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000cb:	00 
  8000cc:	c7 04 24 20 50 80 00 	movl   $0x805020,(%esp)
  8000d3:	e8 5c ff ff ff       	call   800034 <sum>
  8000d8:	85 c0                	test   %eax,%eax
  8000da:	74 12                	je     8000ee <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e0:	c7 04 24 7c 1e 80 00 	movl   $0x801e7c,(%esp)
  8000e7:	e8 ab 01 00 00       	call   800297 <cprintf>
  8000ec:	eb 0c                	jmp    8000fa <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000ee:	c7 04 24 06 1e 80 00 	movl   $0x801e06,(%esp)
  8000f5:	e8 9d 01 00 00       	call   800297 <cprintf>

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000fa:	c7 44 24 04 1c 1e 80 	movl   $0x801e1c,0x4(%esp)
  800101:	00 
  800102:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800108:	89 04 24             	mov    %eax,(%esp)
  80010b:	e8 29 08 00 00       	call   800939 <strcat>
	for (i = 0; i < argc; i++) {
  800110:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800114:	7e 42                	jle    800158 <umain+0xf0>
  800116:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  80011b:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800121:	c7 44 24 04 28 1e 80 	movl   $0x801e28,0x4(%esp)
  800128:	00 
  800129:	89 34 24             	mov    %esi,(%esp)
  80012c:	e8 08 08 00 00       	call   800939 <strcat>
		strcat(args, argv[i]);
  800131:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800134:	89 44 24 04          	mov    %eax,0x4(%esp)
  800138:	89 34 24             	mov    %esi,(%esp)
  80013b:	e8 f9 07 00 00       	call   800939 <strcat>
		strcat(args, "'");
  800140:	c7 44 24 04 29 1e 80 	movl   $0x801e29,0x4(%esp)
  800147:	00 
  800148:	89 34 24             	mov    %esi,(%esp)
  80014b:	e8 e9 07 00 00       	call   800939 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800150:	83 c3 01             	add    $0x1,%ebx
  800153:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800156:	75 c9                	jne    800121 <umain+0xb9>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  800158:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80015e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800162:	c7 04 24 2b 1e 80 00 	movl   $0x801e2b,(%esp)
  800169:	e8 29 01 00 00       	call   800297 <cprintf>

	cprintf("init: exiting\n");
  80016e:	c7 04 24 2f 1e 80 00 	movl   $0x801e2f,(%esp)
  800175:	e8 1d 01 00 00       	call   800297 <cprintf>
}
  80017a:	81 c4 1c 01 00 00    	add    $0x11c,%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    
  800185:	66 90                	xchg   %ax,%ax
  800187:	90                   	nop

00800188 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 18             	sub    $0x18,%esp
  80018e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800191:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800194:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800197:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  80019a:	e8 58 0c 00 00       	call   800df7 <sys_getenvid>
  80019f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001a4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001a7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ac:	a3 90 67 80 00       	mov    %eax,0x806790
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001b1:	85 db                	test   %ebx,%ebx
  8001b3:	7e 07                	jle    8001bc <libmain+0x34>
		binaryname = argv[0];
  8001b5:	8b 06                	mov    (%esi),%eax
  8001b7:	a3 70 47 80 00       	mov    %eax,0x804770

	// call user main routine
	umain(argc, argv);
  8001bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c0:	89 1c 24             	mov    %ebx,(%esp)
  8001c3:	e8 a0 fe ff ff       	call   800068 <umain>

	// exit gracefully
	exit();
  8001c8:	e8 0b 00 00 00       	call   8001d8 <exit>
}
  8001cd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001d0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001d3:	89 ec                	mov    %ebp,%esp
  8001d5:	5d                   	pop    %ebp
  8001d6:	c3                   	ret    
  8001d7:	90                   	nop

008001d8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001de:	e8 a0 11 00 00       	call   801383 <close_all>
	sys_env_destroy(0);
  8001e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ea:	e8 a2 0b 00 00       	call   800d91 <sys_env_destroy>
}
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    
  8001f1:	66 90                	xchg   %ax,%ax
  8001f3:	90                   	nop

008001f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	53                   	push   %ebx
  8001f8:	83 ec 14             	sub    $0x14,%esp
  8001fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fe:	8b 03                	mov    (%ebx),%eax
  800200:	8b 55 08             	mov    0x8(%ebp),%edx
  800203:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800207:	83 c0 01             	add    $0x1,%eax
  80020a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80020c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800211:	75 19                	jne    80022c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800213:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80021a:	00 
  80021b:	8d 43 08             	lea    0x8(%ebx),%eax
  80021e:	89 04 24             	mov    %eax,(%esp)
  800221:	e8 fa 0a 00 00       	call   800d20 <sys_cputs>
		b->idx = 0;
  800226:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80022c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800230:	83 c4 14             	add    $0x14,%esp
  800233:	5b                   	pop    %ebx
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80023f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800246:	00 00 00 
	b.cnt = 0;
  800249:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800250:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800253:	8b 45 0c             	mov    0xc(%ebp),%eax
  800256:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800261:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026b:	c7 04 24 f4 01 80 00 	movl   $0x8001f4,(%esp)
  800272:	e8 bb 01 00 00       	call   800432 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800277:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80027d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800281:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800287:	89 04 24             	mov    %eax,(%esp)
  80028a:	e8 91 0a 00 00       	call   800d20 <sys_cputs>

	return b.cnt;
}
  80028f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80029d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a7:	89 04 24             	mov    %eax,(%esp)
  8002aa:	e8 87 ff ff ff       	call   800236 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    
  8002b1:	66 90                	xchg   %ax,%ax
  8002b3:	66 90                	xchg   %ax,%ax
  8002b5:	66 90                	xchg   %ax,%ax
  8002b7:	66 90                	xchg   %ax,%ax
  8002b9:	66 90                	xchg   %ax,%ax
  8002bb:	66 90                	xchg   %ax,%ax
  8002bd:	66 90                	xchg   %ax,%ax
  8002bf:	90                   	nop

008002c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 4c             	sub    $0x4c,%esp
  8002c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002cc:	89 d7                	mov    %edx,%edi
  8002ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002d1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8002d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002da:	b8 00 00 00 00       	mov    $0x0,%eax
  8002df:	39 d8                	cmp    %ebx,%eax
  8002e1:	72 17                	jb     8002fa <printnum+0x3a>
  8002e3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002e6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8002e9:	76 0f                	jbe    8002fa <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002eb:	8b 75 14             	mov    0x14(%ebp),%esi
  8002ee:	83 ee 01             	sub    $0x1,%esi
  8002f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002f4:	85 f6                	test   %esi,%esi
  8002f6:	7f 63                	jg     80035b <printnum+0x9b>
  8002f8:	eb 75                	jmp    80036f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002fa:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8002fd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800301:	8b 45 14             	mov    0x14(%ebp),%eax
  800304:	83 e8 01             	sub    $0x1,%eax
  800307:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80030b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800312:	8b 44 24 08          	mov    0x8(%esp),%eax
  800316:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80031a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800320:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800327:	00 
  800328:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80032b:	89 1c 24             	mov    %ebx,(%esp)
  80032e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800331:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800335:	e8 b6 17 00 00       	call   801af0 <__udivdi3>
  80033a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80033d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800340:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800344:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800348:	89 04 24             	mov    %eax,(%esp)
  80034b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80034f:	89 fa                	mov    %edi,%edx
  800351:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800354:	e8 67 ff ff ff       	call   8002c0 <printnum>
  800359:	eb 14                	jmp    80036f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80035b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80035f:	8b 45 18             	mov    0x18(%ebp),%eax
  800362:	89 04 24             	mov    %eax,(%esp)
  800365:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800367:	83 ee 01             	sub    $0x1,%esi
  80036a:	75 ef                	jne    80035b <printnum+0x9b>
  80036c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80036f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800373:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800377:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80037a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80037e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800385:	00 
  800386:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800389:	89 1c 24             	mov    %ebx,(%esp)
  80038c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80038f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800393:	e8 a8 18 00 00       	call   801c40 <__umoddi3>
  800398:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039c:	0f be 80 b5 1e 80 00 	movsbl 0x801eb5(%eax),%eax
  8003a3:	89 04 24             	mov    %eax,(%esp)
  8003a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003a9:	ff d0                	call   *%eax
}
  8003ab:	83 c4 4c             	add    $0x4c,%esp
  8003ae:	5b                   	pop    %ebx
  8003af:	5e                   	pop    %esi
  8003b0:	5f                   	pop    %edi
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b6:	83 fa 01             	cmp    $0x1,%edx
  8003b9:	7e 0e                	jle    8003c9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003bb:	8b 10                	mov    (%eax),%edx
  8003bd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c0:	89 08                	mov    %ecx,(%eax)
  8003c2:	8b 02                	mov    (%edx),%eax
  8003c4:	8b 52 04             	mov    0x4(%edx),%edx
  8003c7:	eb 22                	jmp    8003eb <getuint+0x38>
	else if (lflag)
  8003c9:	85 d2                	test   %edx,%edx
  8003cb:	74 10                	je     8003dd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003cd:	8b 10                	mov    (%eax),%edx
  8003cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d2:	89 08                	mov    %ecx,(%eax)
  8003d4:	8b 02                	mov    (%edx),%eax
  8003d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003db:	eb 0e                	jmp    8003eb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003dd:	8b 10                	mov    (%eax),%edx
  8003df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e2:	89 08                	mov    %ecx,(%eax)
  8003e4:	8b 02                	mov    (%edx),%eax
  8003e6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003eb:	5d                   	pop    %ebp
  8003ec:	c3                   	ret    

008003ed <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
  8003f0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f7:	8b 10                	mov    (%eax),%edx
  8003f9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fc:	73 0a                	jae    800408 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800401:	88 0a                	mov    %cl,(%edx)
  800403:	83 c2 01             	add    $0x1,%edx
  800406:	89 10                	mov    %edx,(%eax)
}
  800408:	5d                   	pop    %ebp
  800409:	c3                   	ret    

0080040a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
  80040d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800410:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800413:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800417:	8b 45 10             	mov    0x10(%ebp),%eax
  80041a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800421:	89 44 24 04          	mov    %eax,0x4(%esp)
  800425:	8b 45 08             	mov    0x8(%ebp),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	e8 02 00 00 00       	call   800432 <vprintfmt>
	va_end(ap);
}
  800430:	c9                   	leave  
  800431:	c3                   	ret    

00800432 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	57                   	push   %edi
  800436:	56                   	push   %esi
  800437:	53                   	push   %ebx
  800438:	83 ec 4c             	sub    $0x4c,%esp
  80043b:	8b 75 08             	mov    0x8(%ebp),%esi
  80043e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800441:	8b 7d 10             	mov    0x10(%ebp),%edi
  800444:	eb 11                	jmp    800457 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800446:	85 c0                	test   %eax,%eax
  800448:	0f 84 db 03 00 00    	je     800829 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80044e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800452:	89 04 24             	mov    %eax,(%esp)
  800455:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800457:	0f b6 07             	movzbl (%edi),%eax
  80045a:	83 c7 01             	add    $0x1,%edi
  80045d:	83 f8 25             	cmp    $0x25,%eax
  800460:	75 e4                	jne    800446 <vprintfmt+0x14>
  800462:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800466:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80046d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800474:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80047b:	ba 00 00 00 00       	mov    $0x0,%edx
  800480:	eb 2b                	jmp    8004ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800485:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800489:	eb 22                	jmp    8004ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80048e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800492:	eb 19                	jmp    8004ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800497:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80049e:	eb 0d                	jmp    8004ad <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	0f b6 0f             	movzbl (%edi),%ecx
  8004b0:	8d 47 01             	lea    0x1(%edi),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	0f b6 07             	movzbl (%edi),%eax
  8004b9:	83 e8 23             	sub    $0x23,%eax
  8004bc:	3c 55                	cmp    $0x55,%al
  8004be:	0f 87 40 03 00 00    	ja     800804 <vprintfmt+0x3d2>
  8004c4:	0f b6 c0             	movzbl %al,%eax
  8004c7:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ce:	83 e9 30             	sub    $0x30,%ecx
  8004d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8004d4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8004d8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004db:	83 f9 09             	cmp    $0x9,%ecx
  8004de:	77 57                	ja     800537 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004ec:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004ef:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004f3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004f6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004f9:	83 f9 09             	cmp    $0x9,%ecx
  8004fc:	76 eb                	jbe    8004e9 <vprintfmt+0xb7>
  8004fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800501:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800504:	eb 34                	jmp    80053a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 48 04             	lea    0x4(%eax),%ecx
  80050c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800514:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800517:	eb 21                	jmp    80053a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800519:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051d:	0f 88 71 ff ff ff    	js     800494 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800526:	eb 85                	jmp    8004ad <vprintfmt+0x7b>
  800528:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80052b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800532:	e9 76 ff ff ff       	jmp    8004ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800537:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80053a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053e:	0f 89 69 ff ff ff    	jns    8004ad <vprintfmt+0x7b>
  800544:	e9 57 ff ff ff       	jmp    8004a0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800549:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80054f:	e9 59 ff ff ff       	jmp    8004ad <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 04             	lea    0x4(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800561:	8b 00                	mov    (%eax),%eax
  800563:	89 04 24             	mov    %eax,(%esp)
  800566:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80056b:	e9 e7 fe ff ff       	jmp    800457 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 50 04             	lea    0x4(%eax),%edx
  800576:	89 55 14             	mov    %edx,0x14(%ebp)
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 c2                	mov    %eax,%edx
  80057d:	c1 fa 1f             	sar    $0x1f,%edx
  800580:	31 d0                	xor    %edx,%eax
  800582:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800584:	83 f8 0f             	cmp    $0xf,%eax
  800587:	7f 0b                	jg     800594 <vprintfmt+0x162>
  800589:	8b 14 85 60 21 80 00 	mov    0x802160(,%eax,4),%edx
  800590:	85 d2                	test   %edx,%edx
  800592:	75 20                	jne    8005b4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800594:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800598:	c7 44 24 08 cd 1e 80 	movl   $0x801ecd,0x8(%esp)
  80059f:	00 
  8005a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a4:	89 34 24             	mov    %esi,(%esp)
  8005a7:	e8 5e fe ff ff       	call   80040a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005af:	e9 a3 fe ff ff       	jmp    800457 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b8:	c7 44 24 08 d6 1e 80 	movl   $0x801ed6,0x8(%esp)
  8005bf:	00 
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	89 34 24             	mov    %esi,(%esp)
  8005c7:	e8 3e fe ff ff       	call   80040a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005cf:	e9 83 fe ff ff       	jmp    800457 <vprintfmt+0x25>
  8005d4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005da:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005e8:	85 ff                	test   %edi,%edi
  8005ea:	b8 c6 1e 80 00       	mov    $0x801ec6,%eax
  8005ef:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005f2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8005f6:	74 06                	je     8005fe <vprintfmt+0x1cc>
  8005f8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005fc:	7f 16                	jg     800614 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fe:	0f b6 17             	movzbl (%edi),%edx
  800601:	0f be c2             	movsbl %dl,%eax
  800604:	83 c7 01             	add    $0x1,%edi
  800607:	85 c0                	test   %eax,%eax
  800609:	0f 85 9f 00 00 00    	jne    8006ae <vprintfmt+0x27c>
  80060f:	e9 8b 00 00 00       	jmp    80069f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800614:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800618:	89 3c 24             	mov    %edi,(%esp)
  80061b:	e8 c2 02 00 00       	call   8008e2 <strnlen>
  800620:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800623:	29 c2                	sub    %eax,%edx
  800625:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800628:	85 d2                	test   %edx,%edx
  80062a:	7e d2                	jle    8005fe <vprintfmt+0x1cc>
					putch(padc, putdat);
  80062c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800630:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800633:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800636:	89 d7                	mov    %edx,%edi
  800638:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80063f:	89 04 24             	mov    %eax,(%esp)
  800642:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800644:	83 ef 01             	sub    $0x1,%edi
  800647:	75 ef                	jne    800638 <vprintfmt+0x206>
  800649:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80064c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80064f:	eb ad                	jmp    8005fe <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800651:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800655:	74 20                	je     800677 <vprintfmt+0x245>
  800657:	0f be d2             	movsbl %dl,%edx
  80065a:	83 ea 20             	sub    $0x20,%edx
  80065d:	83 fa 5e             	cmp    $0x5e,%edx
  800660:	76 15                	jbe    800677 <vprintfmt+0x245>
					putch('?', putdat);
  800662:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800665:	89 54 24 04          	mov    %edx,0x4(%esp)
  800669:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800670:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800673:	ff d1                	call   *%ecx
  800675:	eb 0f                	jmp    800686 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800677:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80067a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80067e:	89 04 24             	mov    %eax,(%esp)
  800681:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800684:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800686:	83 eb 01             	sub    $0x1,%ebx
  800689:	0f b6 17             	movzbl (%edi),%edx
  80068c:	0f be c2             	movsbl %dl,%eax
  80068f:	83 c7 01             	add    $0x1,%edi
  800692:	85 c0                	test   %eax,%eax
  800694:	75 24                	jne    8006ba <vprintfmt+0x288>
  800696:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800699:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80069c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006a6:	0f 8e ab fd ff ff    	jle    800457 <vprintfmt+0x25>
  8006ac:	eb 20                	jmp    8006ce <vprintfmt+0x29c>
  8006ae:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8006b1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006b4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8006b7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ba:	85 f6                	test   %esi,%esi
  8006bc:	78 93                	js     800651 <vprintfmt+0x21f>
  8006be:	83 ee 01             	sub    $0x1,%esi
  8006c1:	79 8e                	jns    800651 <vprintfmt+0x21f>
  8006c3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006c6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006c9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006cc:	eb d1                	jmp    80069f <vprintfmt+0x26d>
  8006ce:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006dc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006de:	83 ef 01             	sub    $0x1,%edi
  8006e1:	75 ee                	jne    8006d1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006e6:	e9 6c fd ff ff       	jmp    800457 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006eb:	83 fa 01             	cmp    $0x1,%edx
  8006ee:	66 90                	xchg   %ax,%ax
  8006f0:	7e 16                	jle    800708 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 08             	lea    0x8(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fb:	8b 10                	mov    (%eax),%edx
  8006fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800700:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800703:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800706:	eb 32                	jmp    80073a <vprintfmt+0x308>
	else if (lflag)
  800708:	85 d2                	test   %edx,%edx
  80070a:	74 18                	je     800724 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8d 50 04             	lea    0x4(%eax),%edx
  800712:	89 55 14             	mov    %edx,0x14(%ebp)
  800715:	8b 00                	mov    (%eax),%eax
  800717:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80071a:	89 c1                	mov    %eax,%ecx
  80071c:	c1 f9 1f             	sar    $0x1f,%ecx
  80071f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800722:	eb 16                	jmp    80073a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8d 50 04             	lea    0x4(%eax),%edx
  80072a:	89 55 14             	mov    %edx,0x14(%ebp)
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800732:	89 c7                	mov    %eax,%edi
  800734:	c1 ff 1f             	sar    $0x1f,%edi
  800737:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80073a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80073d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800740:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800745:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800749:	79 7d                	jns    8007c8 <vprintfmt+0x396>
				putch('-', putdat);
  80074b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800756:	ff d6                	call   *%esi
				num = -(long long) num;
  800758:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80075b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80075e:	f7 d8                	neg    %eax
  800760:	83 d2 00             	adc    $0x0,%edx
  800763:	f7 da                	neg    %edx
			}
			base = 10;
  800765:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80076a:	eb 5c                	jmp    8007c8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
  80076f:	e8 3f fc ff ff       	call   8003b3 <getuint>
			base = 10;
  800774:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800779:	eb 4d                	jmp    8007c8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
  80077e:	e8 30 fc ff ff       	call   8003b3 <getuint>
			base = 8;
  800783:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800788:	eb 3e                	jmp    8007c8 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80078a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800795:	ff d6                	call   *%esi
			putch('x', putdat);
  800797:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007a2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8d 50 04             	lea    0x4(%eax),%edx
  8007aa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ad:	8b 00                	mov    (%eax),%eax
  8007af:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007b9:	eb 0d                	jmp    8007c8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007be:	e8 f0 fb ff ff       	call   8003b3 <getuint>
			base = 16;
  8007c3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8007cc:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8007d0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007d3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007db:	89 04 24             	mov    %eax,(%esp)
  8007de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e2:	89 da                	mov    %ebx,%edx
  8007e4:	89 f0                	mov    %esi,%eax
  8007e6:	e8 d5 fa ff ff       	call   8002c0 <printnum>
			break;
  8007eb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007ee:	e9 64 fc ff ff       	jmp    800457 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f7:	89 0c 24             	mov    %ecx,(%esp)
  8007fa:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ff:	e9 53 fc ff ff       	jmp    800457 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800804:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800808:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80080f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800811:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800815:	0f 84 3c fc ff ff    	je     800457 <vprintfmt+0x25>
  80081b:	83 ef 01             	sub    $0x1,%edi
  80081e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800822:	75 f7                	jne    80081b <vprintfmt+0x3e9>
  800824:	e9 2e fc ff ff       	jmp    800457 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800829:	83 c4 4c             	add    $0x4c,%esp
  80082c:	5b                   	pop    %ebx
  80082d:	5e                   	pop    %esi
  80082e:	5f                   	pop    %edi
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	83 ec 28             	sub    $0x28,%esp
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80083d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800840:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800844:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800847:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80084e:	85 d2                	test   %edx,%edx
  800850:	7e 30                	jle    800882 <vsnprintf+0x51>
  800852:	85 c0                	test   %eax,%eax
  800854:	74 2c                	je     800882 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800856:	8b 45 14             	mov    0x14(%ebp),%eax
  800859:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085d:	8b 45 10             	mov    0x10(%ebp),%eax
  800860:	89 44 24 08          	mov    %eax,0x8(%esp)
  800864:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086b:	c7 04 24 ed 03 80 00 	movl   $0x8003ed,(%esp)
  800872:	e8 bb fb ff ff       	call   800432 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800877:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800880:	eb 05                	jmp    800887 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800882:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80088f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800892:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800896:	8b 45 10             	mov    0x10(%ebp),%eax
  800899:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	89 04 24             	mov    %eax,(%esp)
  8008aa:	e8 82 ff ff ff       	call   800831 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    
  8008b1:	66 90                	xchg   %ax,%ax
  8008b3:	66 90                	xchg   %ax,%ax
  8008b5:	66 90                	xchg   %ax,%ax
  8008b7:	66 90                	xchg   %ax,%ax
  8008b9:	66 90                	xchg   %ax,%ax
  8008bb:	66 90                	xchg   %ax,%ax
  8008bd:	66 90                	xchg   %ax,%ax
  8008bf:	90                   	nop

008008c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c6:	80 3a 00             	cmpb   $0x0,(%edx)
  8008c9:	74 10                	je     8008db <strlen+0x1b>
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d7:	75 f7                	jne    8008d0 <strlen+0x10>
  8008d9:	eb 05                	jmp    8008e0 <strlen+0x20>
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ec:	85 c9                	test   %ecx,%ecx
  8008ee:	74 1c                	je     80090c <strnlen+0x2a>
  8008f0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008f3:	74 1e                	je     800913 <strnlen+0x31>
  8008f5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008fa:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fc:	39 ca                	cmp    %ecx,%edx
  8008fe:	74 18                	je     800918 <strnlen+0x36>
  800900:	83 c2 01             	add    $0x1,%edx
  800903:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800908:	75 f0                	jne    8008fa <strnlen+0x18>
  80090a:	eb 0c                	jmp    800918 <strnlen+0x36>
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
  800911:	eb 05                	jmp    800918 <strnlen+0x36>
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800918:	5b                   	pop    %ebx
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800925:	89 c2                	mov    %eax,%edx
  800927:	0f b6 19             	movzbl (%ecx),%ebx
  80092a:	88 1a                	mov    %bl,(%edx)
  80092c:	83 c2 01             	add    $0x1,%edx
  80092f:	83 c1 01             	add    $0x1,%ecx
  800932:	84 db                	test   %bl,%bl
  800934:	75 f1                	jne    800927 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800936:	5b                   	pop    %ebx
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	53                   	push   %ebx
  80093d:	83 ec 08             	sub    $0x8,%esp
  800940:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800943:	89 1c 24             	mov    %ebx,(%esp)
  800946:	e8 75 ff ff ff       	call   8008c0 <strlen>
	strcpy(dst + len, src);
  80094b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800952:	01 d8                	add    %ebx,%eax
  800954:	89 04 24             	mov    %eax,(%esp)
  800957:	e8 bf ff ff ff       	call   80091b <strcpy>
	return dst;
}
  80095c:	89 d8                	mov    %ebx,%eax
  80095e:	83 c4 08             	add    $0x8,%esp
  800961:	5b                   	pop    %ebx
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 75 08             	mov    0x8(%ebp),%esi
  80096c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800972:	85 db                	test   %ebx,%ebx
  800974:	74 16                	je     80098c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800976:	01 f3                	add    %esi,%ebx
  800978:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80097a:	0f b6 02             	movzbl (%edx),%eax
  80097d:	88 01                	mov    %al,(%ecx)
  80097f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800982:	80 3a 01             	cmpb   $0x1,(%edx)
  800985:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800988:	39 d9                	cmp    %ebx,%ecx
  80098a:	75 ee                	jne    80097a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80098c:	89 f0                	mov    %esi,%eax
  80098e:	5b                   	pop    %ebx
  80098f:	5e                   	pop    %esi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	57                   	push   %edi
  800996:	56                   	push   %esi
  800997:	53                   	push   %ebx
  800998:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80099e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a1:	89 f8                	mov    %edi,%eax
  8009a3:	85 f6                	test   %esi,%esi
  8009a5:	74 33                	je     8009da <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  8009a7:	83 fe 01             	cmp    $0x1,%esi
  8009aa:	74 25                	je     8009d1 <strlcpy+0x3f>
  8009ac:	0f b6 0b             	movzbl (%ebx),%ecx
  8009af:	84 c9                	test   %cl,%cl
  8009b1:	74 22                	je     8009d5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009b3:	83 ee 02             	sub    $0x2,%esi
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009bb:	88 08                	mov    %cl,(%eax)
  8009bd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009c0:	39 f2                	cmp    %esi,%edx
  8009c2:	74 13                	je     8009d7 <strlcpy+0x45>
  8009c4:	83 c2 01             	add    $0x1,%edx
  8009c7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009cb:	84 c9                	test   %cl,%cl
  8009cd:	75 ec                	jne    8009bb <strlcpy+0x29>
  8009cf:	eb 06                	jmp    8009d7 <strlcpy+0x45>
  8009d1:	89 f8                	mov    %edi,%eax
  8009d3:	eb 02                	jmp    8009d7 <strlcpy+0x45>
  8009d5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009da:	29 f8                	sub    %edi,%eax
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5e                   	pop    %esi
  8009de:	5f                   	pop    %edi
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ea:	0f b6 01             	movzbl (%ecx),%eax
  8009ed:	84 c0                	test   %al,%al
  8009ef:	74 15                	je     800a06 <strcmp+0x25>
  8009f1:	3a 02                	cmp    (%edx),%al
  8009f3:	75 11                	jne    800a06 <strcmp+0x25>
		p++, q++;
  8009f5:	83 c1 01             	add    $0x1,%ecx
  8009f8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009fb:	0f b6 01             	movzbl (%ecx),%eax
  8009fe:	84 c0                	test   %al,%al
  800a00:	74 04                	je     800a06 <strcmp+0x25>
  800a02:	3a 02                	cmp    (%edx),%al
  800a04:	74 ef                	je     8009f5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a06:	0f b6 c0             	movzbl %al,%eax
  800a09:	0f b6 12             	movzbl (%edx),%edx
  800a0c:	29 d0                	sub    %edx,%eax
}
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a1e:	85 f6                	test   %esi,%esi
  800a20:	74 29                	je     800a4b <strncmp+0x3b>
  800a22:	0f b6 03             	movzbl (%ebx),%eax
  800a25:	84 c0                	test   %al,%al
  800a27:	74 30                	je     800a59 <strncmp+0x49>
  800a29:	3a 02                	cmp    (%edx),%al
  800a2b:	75 2c                	jne    800a59 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800a2d:	8d 43 01             	lea    0x1(%ebx),%eax
  800a30:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a32:	89 c3                	mov    %eax,%ebx
  800a34:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a37:	39 f0                	cmp    %esi,%eax
  800a39:	74 17                	je     800a52 <strncmp+0x42>
  800a3b:	0f b6 08             	movzbl (%eax),%ecx
  800a3e:	84 c9                	test   %cl,%cl
  800a40:	74 17                	je     800a59 <strncmp+0x49>
  800a42:	83 c0 01             	add    $0x1,%eax
  800a45:	3a 0a                	cmp    (%edx),%cl
  800a47:	74 e9                	je     800a32 <strncmp+0x22>
  800a49:	eb 0e                	jmp    800a59 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a50:	eb 0f                	jmp    800a61 <strncmp+0x51>
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
  800a57:	eb 08                	jmp    800a61 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a59:	0f b6 03             	movzbl (%ebx),%eax
  800a5c:	0f b6 12             	movzbl (%edx),%edx
  800a5f:	29 d0                	sub    %edx,%eax
}
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	53                   	push   %ebx
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a6f:	0f b6 18             	movzbl (%eax),%ebx
  800a72:	84 db                	test   %bl,%bl
  800a74:	74 1d                	je     800a93 <strchr+0x2e>
  800a76:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a78:	38 d3                	cmp    %dl,%bl
  800a7a:	75 06                	jne    800a82 <strchr+0x1d>
  800a7c:	eb 1a                	jmp    800a98 <strchr+0x33>
  800a7e:	38 ca                	cmp    %cl,%dl
  800a80:	74 16                	je     800a98 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a82:	83 c0 01             	add    $0x1,%eax
  800a85:	0f b6 10             	movzbl (%eax),%edx
  800a88:	84 d2                	test   %dl,%dl
  800a8a:	75 f2                	jne    800a7e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a91:	eb 05                	jmp    800a98 <strchr+0x33>
  800a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a98:	5b                   	pop    %ebx
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	53                   	push   %ebx
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800aa5:	0f b6 18             	movzbl (%eax),%ebx
  800aa8:	84 db                	test   %bl,%bl
  800aaa:	74 16                	je     800ac2 <strfind+0x27>
  800aac:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800aae:	38 d3                	cmp    %dl,%bl
  800ab0:	75 06                	jne    800ab8 <strfind+0x1d>
  800ab2:	eb 0e                	jmp    800ac2 <strfind+0x27>
  800ab4:	38 ca                	cmp    %cl,%dl
  800ab6:	74 0a                	je     800ac2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ab8:	83 c0 01             	add    $0x1,%eax
  800abb:	0f b6 10             	movzbl (%eax),%edx
  800abe:	84 d2                	test   %dl,%dl
  800ac0:	75 f2                	jne    800ab4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	83 ec 0c             	sub    $0xc,%esp
  800acb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ace:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ad1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ad4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ada:	85 c9                	test   %ecx,%ecx
  800adc:	74 36                	je     800b14 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ade:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae4:	75 28                	jne    800b0e <memset+0x49>
  800ae6:	f6 c1 03             	test   $0x3,%cl
  800ae9:	75 23                	jne    800b0e <memset+0x49>
		c &= 0xFF;
  800aeb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aef:	89 d3                	mov    %edx,%ebx
  800af1:	c1 e3 08             	shl    $0x8,%ebx
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	c1 e6 18             	shl    $0x18,%esi
  800af9:	89 d0                	mov    %edx,%eax
  800afb:	c1 e0 10             	shl    $0x10,%eax
  800afe:	09 f0                	or     %esi,%eax
  800b00:	09 c2                	or     %eax,%edx
  800b02:	89 d0                	mov    %edx,%eax
  800b04:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b06:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b09:	fc                   	cld    
  800b0a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b0c:	eb 06                	jmp    800b14 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b11:	fc                   	cld    
  800b12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  800b14:	89 f8                	mov    %edi,%eax
  800b16:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b19:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b1c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b1f:	89 ec                	mov    %ebp,%esp
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	83 ec 08             	sub    $0x8,%esp
  800b29:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b2c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b38:	39 c6                	cmp    %eax,%esi
  800b3a:	73 36                	jae    800b72 <memmove+0x4f>
  800b3c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b3f:	39 d0                	cmp    %edx,%eax
  800b41:	73 2f                	jae    800b72 <memmove+0x4f>
		s += n;
		d += n;
  800b43:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b46:	f6 c2 03             	test   $0x3,%dl
  800b49:	75 1b                	jne    800b66 <memmove+0x43>
  800b4b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b51:	75 13                	jne    800b66 <memmove+0x43>
  800b53:	f6 c1 03             	test   $0x3,%cl
  800b56:	75 0e                	jne    800b66 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b58:	83 ef 04             	sub    $0x4,%edi
  800b5b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b5e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b61:	fd                   	std    
  800b62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b64:	eb 09                	jmp    800b6f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b66:	83 ef 01             	sub    $0x1,%edi
  800b69:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b6c:	fd                   	std    
  800b6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b6f:	fc                   	cld    
  800b70:	eb 20                	jmp    800b92 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b72:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b78:	75 13                	jne    800b8d <memmove+0x6a>
  800b7a:	a8 03                	test   $0x3,%al
  800b7c:	75 0f                	jne    800b8d <memmove+0x6a>
  800b7e:	f6 c1 03             	test   $0x3,%cl
  800b81:	75 0a                	jne    800b8d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b83:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b86:	89 c7                	mov    %eax,%edi
  800b88:	fc                   	cld    
  800b89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8b:	eb 05                	jmp    800b92 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b8d:	89 c7                	mov    %eax,%edi
  800b8f:	fc                   	cld    
  800b90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b98:	89 ec                	mov    %ebp,%esp
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ba2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb3:	89 04 24             	mov    %eax,(%esp)
  800bb6:	e8 68 ff ff ff       	call   800b23 <memmove>
}
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bc6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcc:	8d 78 ff             	lea    -0x1(%eax),%edi
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	74 36                	je     800c09 <memcmp+0x4c>
		if (*s1 != *s2)
  800bd3:	0f b6 03             	movzbl (%ebx),%eax
  800bd6:	0f b6 0e             	movzbl (%esi),%ecx
  800bd9:	38 c8                	cmp    %cl,%al
  800bdb:	75 17                	jne    800bf4 <memcmp+0x37>
  800bdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800be2:	eb 1a                	jmp    800bfe <memcmp+0x41>
  800be4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800be9:	83 c2 01             	add    $0x1,%edx
  800bec:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800bf0:	38 c8                	cmp    %cl,%al
  800bf2:	74 0a                	je     800bfe <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800bf4:	0f b6 c0             	movzbl %al,%eax
  800bf7:	0f b6 c9             	movzbl %cl,%ecx
  800bfa:	29 c8                	sub    %ecx,%eax
  800bfc:	eb 10                	jmp    800c0e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bfe:	39 fa                	cmp    %edi,%edx
  800c00:	75 e2                	jne    800be4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
  800c07:	eb 05                	jmp    800c0e <memcmp+0x51>
  800c09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	53                   	push   %ebx
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800c1d:	89 c2                	mov    %eax,%edx
  800c1f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c22:	39 d0                	cmp    %edx,%eax
  800c24:	73 13                	jae    800c39 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c26:	89 d9                	mov    %ebx,%ecx
  800c28:	38 18                	cmp    %bl,(%eax)
  800c2a:	75 06                	jne    800c32 <memfind+0x1f>
  800c2c:	eb 0b                	jmp    800c39 <memfind+0x26>
  800c2e:	38 08                	cmp    %cl,(%eax)
  800c30:	74 07                	je     800c39 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c32:	83 c0 01             	add    $0x1,%eax
  800c35:	39 d0                	cmp    %edx,%eax
  800c37:	75 f5                	jne    800c2e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
  800c42:	83 ec 04             	sub    $0x4,%esp
  800c45:	8b 55 08             	mov    0x8(%ebp),%edx
  800c48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4b:	0f b6 02             	movzbl (%edx),%eax
  800c4e:	3c 09                	cmp    $0x9,%al
  800c50:	74 04                	je     800c56 <strtol+0x1a>
  800c52:	3c 20                	cmp    $0x20,%al
  800c54:	75 0e                	jne    800c64 <strtol+0x28>
		s++;
  800c56:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c59:	0f b6 02             	movzbl (%edx),%eax
  800c5c:	3c 09                	cmp    $0x9,%al
  800c5e:	74 f6                	je     800c56 <strtol+0x1a>
  800c60:	3c 20                	cmp    $0x20,%al
  800c62:	74 f2                	je     800c56 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c64:	3c 2b                	cmp    $0x2b,%al
  800c66:	75 0a                	jne    800c72 <strtol+0x36>
		s++;
  800c68:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c70:	eb 10                	jmp    800c82 <strtol+0x46>
  800c72:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c77:	3c 2d                	cmp    $0x2d,%al
  800c79:	75 07                	jne    800c82 <strtol+0x46>
		s++, neg = 1;
  800c7b:	83 c2 01             	add    $0x1,%edx
  800c7e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c82:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c88:	75 15                	jne    800c9f <strtol+0x63>
  800c8a:	80 3a 30             	cmpb   $0x30,(%edx)
  800c8d:	75 10                	jne    800c9f <strtol+0x63>
  800c8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c93:	75 0a                	jne    800c9f <strtol+0x63>
		s += 2, base = 16;
  800c95:	83 c2 02             	add    $0x2,%edx
  800c98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c9d:	eb 10                	jmp    800caf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c9f:	85 db                	test   %ebx,%ebx
  800ca1:	75 0c                	jne    800caf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ca3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca5:	80 3a 30             	cmpb   $0x30,(%edx)
  800ca8:	75 05                	jne    800caf <strtol+0x73>
		s++, base = 8;
  800caa:	83 c2 01             	add    $0x1,%edx
  800cad:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800caf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb7:	0f b6 0a             	movzbl (%edx),%ecx
  800cba:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800cbd:	89 f3                	mov    %esi,%ebx
  800cbf:	80 fb 09             	cmp    $0x9,%bl
  800cc2:	77 08                	ja     800ccc <strtol+0x90>
			dig = *s - '0';
  800cc4:	0f be c9             	movsbl %cl,%ecx
  800cc7:	83 e9 30             	sub    $0x30,%ecx
  800cca:	eb 22                	jmp    800cee <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800ccc:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800ccf:	89 f3                	mov    %esi,%ebx
  800cd1:	80 fb 19             	cmp    $0x19,%bl
  800cd4:	77 08                	ja     800cde <strtol+0xa2>
			dig = *s - 'a' + 10;
  800cd6:	0f be c9             	movsbl %cl,%ecx
  800cd9:	83 e9 57             	sub    $0x57,%ecx
  800cdc:	eb 10                	jmp    800cee <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800cde:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ce1:	89 f3                	mov    %esi,%ebx
  800ce3:	80 fb 19             	cmp    $0x19,%bl
  800ce6:	77 16                	ja     800cfe <strtol+0xc2>
			dig = *s - 'A' + 10;
  800ce8:	0f be c9             	movsbl %cl,%ecx
  800ceb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cee:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800cf1:	7d 0f                	jge    800d02 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800cf3:	83 c2 01             	add    $0x1,%edx
  800cf6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800cfa:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cfc:	eb b9                	jmp    800cb7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cfe:	89 c1                	mov    %eax,%ecx
  800d00:	eb 02                	jmp    800d04 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d02:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d08:	74 05                	je     800d0f <strtol+0xd3>
		*endptr = (char *) s;
  800d0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d0d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d0f:	89 ca                	mov    %ecx,%edx
  800d11:	f7 da                	neg    %edx
  800d13:	85 ff                	test   %edi,%edi
  800d15:	0f 45 c2             	cmovne %edx,%eax
}
  800d18:	83 c4 04             	add    $0x4,%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d29:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d2c:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800d2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d34:	0f a2                	cpuid  
  800d36:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d38:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 c3                	mov    %eax,%ebx
  800d45:	89 c7                	mov    %eax,%edi
  800d47:	89 c6                	mov    %eax,%esi
  800d49:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d4b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d4e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d51:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d54:	89 ec                	mov    %ebp,%esp
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	83 ec 0c             	sub    $0xc,%esp
  800d5e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d61:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d64:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d67:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6c:	0f a2                	cpuid  
  800d6e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	ba 00 00 00 00       	mov    $0x0,%edx
  800d75:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7a:	89 d1                	mov    %edx,%ecx
  800d7c:	89 d3                	mov    %edx,%ebx
  800d7e:	89 d7                	mov    %edx,%edi
  800d80:	89 d6                	mov    %edx,%esi
  800d82:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d84:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d87:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d8a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d8d:	89 ec                	mov    %ebp,%esp
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 38             	sub    $0x38,%esp
  800d97:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d9a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d9d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800da0:	b8 01 00 00 00       	mov    $0x1,%eax
  800da5:	0f a2                	cpuid  
  800da7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dae:	b8 03 00 00 00       	mov    $0x3,%eax
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	89 cb                	mov    %ecx,%ebx
  800db8:	89 cf                	mov    %ecx,%edi
  800dba:	89 ce                	mov    %ecx,%esi
  800dbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7e 28                	jle    800dea <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dcd:	00 
  800dce:	c7 44 24 08 bf 21 80 	movl   $0x8021bf,0x8(%esp)
  800dd5:	00 
  800dd6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800ddd:	00 
  800dde:	c7 04 24 dc 21 80 00 	movl   $0x8021dc,(%esp)
  800de5:	e8 96 0b 00 00       	call   801980 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ded:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df3:	89 ec                	mov    %ebp,%esp
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	83 ec 0c             	sub    $0xc,%esp
  800dfd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e00:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e03:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e06:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0b:	0f a2                	cpuid  
  800e0d:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e14:	b8 02 00 00 00       	mov    $0x2,%eax
  800e19:	89 d1                	mov    %edx,%ecx
  800e1b:	89 d3                	mov    %edx,%ebx
  800e1d:	89 d7                	mov    %edx,%edi
  800e1f:	89 d6                	mov    %edx,%esi
  800e21:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e23:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e26:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e29:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e2c:	89 ec                	mov    %ebp,%esp
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <sys_yield>:

void
sys_yield(void)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e44:	0f a2                	cpuid  
  800e46:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e48:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e52:	89 d1                	mov    %edx,%ecx
  800e54:	89 d3                	mov    %edx,%ebx
  800e56:	89 d7                	mov    %edx,%edi
  800e58:	89 d6                	mov    %edx,%esi
  800e5a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e5c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e5f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e62:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e65:	89 ec                	mov    %ebp,%esp
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	83 ec 38             	sub    $0x38,%esp
  800e6f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e72:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e75:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e78:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7d:	0f a2                	cpuid  
  800e7f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e81:	be 00 00 00 00       	mov    $0x0,%esi
  800e86:	b8 04 00 00 00       	mov    $0x4,%eax
  800e8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e94:	89 f7                	mov    %esi,%edi
  800e96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	7e 28                	jle    800ec4 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ea7:	00 
  800ea8:	c7 44 24 08 bf 21 80 	movl   $0x8021bf,0x8(%esp)
  800eaf:	00 
  800eb0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800eb7:	00 
  800eb8:	c7 04 24 dc 21 80 00 	movl   $0x8021dc,(%esp)
  800ebf:	e8 bc 0a 00 00       	call   801980 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ec4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ec7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ecd:	89 ec                	mov    %ebp,%esp
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	83 ec 38             	sub    $0x38,%esp
  800ed7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eda:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800edd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ee0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee5:	0f a2                	cpuid  
  800ee7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee9:	b8 05 00 00 00       	mov    $0x5,%eax
  800eee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800efa:	8b 75 18             	mov    0x18(%ebp),%esi
  800efd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eff:	85 c0                	test   %eax,%eax
  800f01:	7e 28                	jle    800f2b <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f07:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f0e:	00 
  800f0f:	c7 44 24 08 bf 21 80 	movl   $0x8021bf,0x8(%esp)
  800f16:	00 
  800f17:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f1e:	00 
  800f1f:	c7 04 24 dc 21 80 00 	movl   $0x8021dc,(%esp)
  800f26:	e8 55 0a 00 00       	call   801980 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f2b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f2e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f31:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f34:	89 ec                	mov    %ebp,%esp
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 38             	sub    $0x38,%esp
  800f3e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f41:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f44:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f47:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4c:	0f a2                	cpuid  
  800f4e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f55:	b8 06 00 00 00       	mov    $0x6,%eax
  800f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f60:	89 df                	mov    %ebx,%edi
  800f62:	89 de                	mov    %ebx,%esi
  800f64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	7e 28                	jle    800f92 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f75:	00 
  800f76:	c7 44 24 08 bf 21 80 	movl   $0x8021bf,0x8(%esp)
  800f7d:	00 
  800f7e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f85:	00 
  800f86:	c7 04 24 dc 21 80 00 	movl   $0x8021dc,(%esp)
  800f8d:	e8 ee 09 00 00       	call   801980 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f92:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f95:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f98:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f9b:	89 ec                	mov    %ebp,%esp
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    

00800f9f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	83 ec 38             	sub    $0x38,%esp
  800fa5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fab:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fae:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb3:	0f a2                	cpuid  
  800fb5:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbc:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc7:	89 df                	mov    %ebx,%edi
  800fc9:	89 de                	mov    %ebx,%esi
  800fcb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	7e 28                	jle    800ff9 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fdc:	00 
  800fdd:	c7 44 24 08 bf 21 80 	movl   $0x8021bf,0x8(%esp)
  800fe4:	00 
  800fe5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fec:	00 
  800fed:	c7 04 24 dc 21 80 00 	movl   $0x8021dc,(%esp)
  800ff4:	e8 87 09 00 00       	call   801980 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ff9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ffc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fff:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801002:	89 ec                	mov    %ebp,%esp
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	83 ec 38             	sub    $0x38,%esp
  80100c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80100f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801012:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801015:	b8 01 00 00 00       	mov    $0x1,%eax
  80101a:	0f a2                	cpuid  
  80101c:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801023:	b8 09 00 00 00       	mov    $0x9,%eax
  801028:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102b:	8b 55 08             	mov    0x8(%ebp),%edx
  80102e:	89 df                	mov    %ebx,%edi
  801030:	89 de                	mov    %ebx,%esi
  801032:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801034:	85 c0                	test   %eax,%eax
  801036:	7e 28                	jle    801060 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801038:	89 44 24 10          	mov    %eax,0x10(%esp)
  80103c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801043:	00 
  801044:	c7 44 24 08 bf 21 80 	movl   $0x8021bf,0x8(%esp)
  80104b:	00 
  80104c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801053:	00 
  801054:	c7 04 24 dc 21 80 00 	movl   $0x8021dc,(%esp)
  80105b:	e8 20 09 00 00       	call   801980 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801060:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801063:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801066:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801069:	89 ec                	mov    %ebp,%esp
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 38             	sub    $0x38,%esp
  801073:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801076:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801079:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80107c:	b8 01 00 00 00       	mov    $0x1,%eax
  801081:	0f a2                	cpuid  
  801083:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801085:	bb 00 00 00 00       	mov    $0x0,%ebx
  80108a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80108f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801092:	8b 55 08             	mov    0x8(%ebp),%edx
  801095:	89 df                	mov    %ebx,%edi
  801097:	89 de                	mov    %ebx,%esi
  801099:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80109b:	85 c0                	test   %eax,%eax
  80109d:	7e 28                	jle    8010c7 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a3:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010aa:	00 
  8010ab:	c7 44 24 08 bf 21 80 	movl   $0x8021bf,0x8(%esp)
  8010b2:	00 
  8010b3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8010ba:	00 
  8010bb:	c7 04 24 dc 21 80 00 	movl   $0x8021dc,(%esp)
  8010c2:	e8 b9 08 00 00       	call   801980 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010c7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010ca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010cd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010d0:	89 ec                	mov    %ebp,%esp
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	83 ec 0c             	sub    $0xc,%esp
  8010da:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010dd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010e0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e8:	0f a2                	cpuid  
  8010ea:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ec:	be 00 00 00 00       	mov    $0x0,%esi
  8010f1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ff:	8b 7d 14             	mov    0x14(%ebp),%edi
  801102:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801104:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801107:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80110a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80110d:	89 ec                	mov    %ebp,%esp
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	83 ec 38             	sub    $0x38,%esp
  801117:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80111a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80111d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801120:	b8 01 00 00 00       	mov    $0x1,%eax
  801125:	0f a2                	cpuid  
  801127:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801129:	b9 00 00 00 00       	mov    $0x0,%ecx
  80112e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801133:	8b 55 08             	mov    0x8(%ebp),%edx
  801136:	89 cb                	mov    %ecx,%ebx
  801138:	89 cf                	mov    %ecx,%edi
  80113a:	89 ce                	mov    %ecx,%esi
  80113c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80113e:	85 c0                	test   %eax,%eax
  801140:	7e 28                	jle    80116a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801142:	89 44 24 10          	mov    %eax,0x10(%esp)
  801146:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80114d:	00 
  80114e:	c7 44 24 08 bf 21 80 	movl   $0x8021bf,0x8(%esp)
  801155:	00 
  801156:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80115d:	00 
  80115e:	c7 04 24 dc 21 80 00 	movl   $0x8021dc,(%esp)
  801165:	e8 16 08 00 00       	call   801980 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80116a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80116d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801170:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801173:	89 ec                	mov    %ebp,%esp
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    
  801177:	66 90                	xchg   %ax,%ax
  801179:	66 90                	xchg   %ax,%ax
  80117b:	66 90                	xchg   %ax,%ax
  80117d:	66 90                	xchg   %ax,%ax
  80117f:	90                   	nop

00801180 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801183:	8b 45 08             	mov    0x8(%ebp),%eax
  801186:	05 00 00 00 30       	add    $0x30000000,%eax
  80118b:	c1 e8 0c             	shr    $0xc,%eax
}
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801196:	8b 45 08             	mov    0x8(%ebp),%eax
  801199:	89 04 24             	mov    %eax,(%esp)
  80119c:	e8 df ff ff ff       	call   801180 <fd2num>
  8011a1:	c1 e0 0c             	shl    $0xc,%eax
  8011a4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a9:	c9                   	leave  
  8011aa:	c3                   	ret    

008011ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ae:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011b3:	a8 01                	test   $0x1,%al
  8011b5:	74 34                	je     8011eb <fd_alloc+0x40>
  8011b7:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011bc:	a8 01                	test   $0x1,%al
  8011be:	74 32                	je     8011f2 <fd_alloc+0x47>
  8011c0:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011c5:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c7:	89 c2                	mov    %eax,%edx
  8011c9:	c1 ea 16             	shr    $0x16,%edx
  8011cc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d3:	f6 c2 01             	test   $0x1,%dl
  8011d6:	74 1f                	je     8011f7 <fd_alloc+0x4c>
  8011d8:	89 c2                	mov    %eax,%edx
  8011da:	c1 ea 0c             	shr    $0xc,%edx
  8011dd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e4:	f6 c2 01             	test   $0x1,%dl
  8011e7:	75 1a                	jne    801203 <fd_alloc+0x58>
  8011e9:	eb 0c                	jmp    8011f7 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011eb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011f0:	eb 05                	jmp    8011f7 <fd_alloc+0x4c>
  8011f2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8011f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fa:	89 08                	mov    %ecx,(%eax)
			return 0;
  8011fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801201:	eb 1a                	jmp    80121d <fd_alloc+0x72>
  801203:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801208:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80120d:	75 b6                	jne    8011c5 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80120f:	8b 45 08             	mov    0x8(%ebp),%eax
  801212:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801218:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801225:	83 f8 1f             	cmp    $0x1f,%eax
  801228:	77 36                	ja     801260 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80122a:	c1 e0 0c             	shl    $0xc,%eax
  80122d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801232:	89 c2                	mov    %eax,%edx
  801234:	c1 ea 16             	shr    $0x16,%edx
  801237:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80123e:	f6 c2 01             	test   $0x1,%dl
  801241:	74 24                	je     801267 <fd_lookup+0x48>
  801243:	89 c2                	mov    %eax,%edx
  801245:	c1 ea 0c             	shr    $0xc,%edx
  801248:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124f:	f6 c2 01             	test   $0x1,%dl
  801252:	74 1a                	je     80126e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801254:	8b 55 0c             	mov    0xc(%ebp),%edx
  801257:	89 02                	mov    %eax,(%edx)
	return 0;
  801259:	b8 00 00 00 00       	mov    $0x0,%eax
  80125e:	eb 13                	jmp    801273 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801260:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801265:	eb 0c                	jmp    801273 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801267:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126c:	eb 05                	jmp    801273 <fd_lookup+0x54>
  80126e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	83 ec 18             	sub    $0x18,%esp
  80127b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80127e:	39 05 74 47 80 00    	cmp    %eax,0x804774
  801284:	75 10                	jne    801296 <dev_lookup+0x21>
			*dev = devtab[i];
  801286:	8b 45 0c             	mov    0xc(%ebp),%eax
  801289:	c7 00 74 47 80 00    	movl   $0x804774,(%eax)
			return 0;
  80128f:	b8 00 00 00 00       	mov    $0x0,%eax
  801294:	eb 2b                	jmp    8012c1 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801296:	8b 15 90 67 80 00    	mov    0x806790,%edx
  80129c:	8b 52 48             	mov    0x48(%edx),%edx
  80129f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012a7:	c7 04 24 ec 21 80 00 	movl   $0x8021ec,(%esp)
  8012ae:	e8 e4 ef ff ff       	call   800297 <cprintf>
	*dev = 0;
  8012b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b6:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  8012bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	83 ec 38             	sub    $0x38,%esp
  8012c9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012cc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012cf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8012d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012d5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012d8:	89 3c 24             	mov    %edi,(%esp)
  8012db:	e8 a0 fe ff ff       	call   801180 <fd2num>
  8012e0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8012e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012e7:	89 04 24             	mov    %eax,(%esp)
  8012ea:	e8 30 ff ff ff       	call   80121f <fd_lookup>
  8012ef:	89 c3                	mov    %eax,%ebx
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 05                	js     8012fa <fd_close+0x37>
	    || fd != fd2)
  8012f5:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8012f8:	74 0c                	je     801306 <fd_close+0x43>
		return (must_exist ? r : 0);
  8012fa:	85 f6                	test   %esi,%esi
  8012fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801301:	0f 44 d8             	cmove  %eax,%ebx
  801304:	eb 3d                	jmp    801343 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801306:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801309:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130d:	8b 07                	mov    (%edi),%eax
  80130f:	89 04 24             	mov    %eax,(%esp)
  801312:	e8 5e ff ff ff       	call   801275 <dev_lookup>
  801317:	89 c3                	mov    %eax,%ebx
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 16                	js     801333 <fd_close+0x70>
		if (dev->dev_close)
  80131d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801320:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801323:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801328:	85 c0                	test   %eax,%eax
  80132a:	74 07                	je     801333 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80132c:	89 3c 24             	mov    %edi,(%esp)
  80132f:	ff d0                	call   *%eax
  801331:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801333:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801337:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80133e:	e8 f5 fb ff ff       	call   800f38 <sys_page_unmap>
	return r;
}
  801343:	89 d8                	mov    %ebx,%eax
  801345:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801348:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80134b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80134e:	89 ec                	mov    %ebp,%esp
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    

00801352 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801358:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135f:	8b 45 08             	mov    0x8(%ebp),%eax
  801362:	89 04 24             	mov    %eax,(%esp)
  801365:	e8 b5 fe ff ff       	call   80121f <fd_lookup>
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 13                	js     801381 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80136e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801375:	00 
  801376:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801379:	89 04 24             	mov    %eax,(%esp)
  80137c:	e8 42 ff ff ff       	call   8012c3 <fd_close>
}
  801381:	c9                   	leave  
  801382:	c3                   	ret    

00801383 <close_all>:

void
close_all(void)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	53                   	push   %ebx
  801387:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80138a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80138f:	89 1c 24             	mov    %ebx,(%esp)
  801392:	e8 bb ff ff ff       	call   801352 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801397:	83 c3 01             	add    $0x1,%ebx
  80139a:	83 fb 20             	cmp    $0x20,%ebx
  80139d:	75 f0                	jne    80138f <close_all+0xc>
		close(i);
}
  80139f:	83 c4 14             	add    $0x14,%esp
  8013a2:	5b                   	pop    %ebx
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    

008013a5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	83 ec 58             	sub    $0x58,%esp
  8013ab:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013ae:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013b1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013be:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c1:	89 04 24             	mov    %eax,(%esp)
  8013c4:	e8 56 fe ff ff       	call   80121f <fd_lookup>
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	0f 88 e3 00 00 00    	js     8014b4 <dup+0x10f>
		return r;
	close(newfdnum);
  8013d1:	89 1c 24             	mov    %ebx,(%esp)
  8013d4:	e8 79 ff ff ff       	call   801352 <close>

	newfd = INDEX2FD(newfdnum);
  8013d9:	89 de                	mov    %ebx,%esi
  8013db:	c1 e6 0c             	shl    $0xc,%esi
  8013de:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013e7:	89 04 24             	mov    %eax,(%esp)
  8013ea:	e8 a1 fd ff ff       	call   801190 <fd2data>
  8013ef:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013f1:	89 34 24             	mov    %esi,(%esp)
  8013f4:	e8 97 fd ff ff       	call   801190 <fd2data>
  8013f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8013fc:	89 f8                	mov    %edi,%eax
  8013fe:	c1 e8 16             	shr    $0x16,%eax
  801401:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801408:	a8 01                	test   $0x1,%al
  80140a:	74 46                	je     801452 <dup+0xad>
  80140c:	89 f8                	mov    %edi,%eax
  80140e:	c1 e8 0c             	shr    $0xc,%eax
  801411:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801418:	f6 c2 01             	test   $0x1,%dl
  80141b:	74 35                	je     801452 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80141d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801424:	25 07 0e 00 00       	and    $0xe07,%eax
  801429:	89 44 24 10          	mov    %eax,0x10(%esp)
  80142d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801430:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801434:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80143b:	00 
  80143c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801440:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801447:	e8 85 fa ff ff       	call   800ed1 <sys_page_map>
  80144c:	89 c7                	mov    %eax,%edi
  80144e:	85 c0                	test   %eax,%eax
  801450:	78 3b                	js     80148d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801452:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801455:	89 c2                	mov    %eax,%edx
  801457:	c1 ea 0c             	shr    $0xc,%edx
  80145a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801461:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801467:	89 54 24 10          	mov    %edx,0x10(%esp)
  80146b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80146f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801476:	00 
  801477:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801482:	e8 4a fa ff ff       	call   800ed1 <sys_page_map>
  801487:	89 c7                	mov    %eax,%edi
  801489:	85 c0                	test   %eax,%eax
  80148b:	79 29                	jns    8014b6 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80148d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801491:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801498:	e8 9b fa ff ff       	call   800f38 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80149d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ab:	e8 88 fa ff ff       	call   800f38 <sys_page_unmap>
	return r;
  8014b0:	89 fb                	mov    %edi,%ebx
  8014b2:	eb 02                	jmp    8014b6 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  8014b4:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014b6:	89 d8                	mov    %ebx,%eax
  8014b8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014bb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014be:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014c1:	89 ec                	mov    %ebp,%esp
  8014c3:	5d                   	pop    %ebp
  8014c4:	c3                   	ret    

008014c5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	53                   	push   %ebx
  8014c9:	83 ec 24             	sub    $0x24,%esp
  8014cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d6:	89 1c 24             	mov    %ebx,(%esp)
  8014d9:	e8 41 fd ff ff       	call   80121f <fd_lookup>
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 6d                	js     80154f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ec:	8b 00                	mov    (%eax),%eax
  8014ee:	89 04 24             	mov    %eax,(%esp)
  8014f1:	e8 7f fd ff ff       	call   801275 <dev_lookup>
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	78 55                	js     80154f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fd:	8b 50 08             	mov    0x8(%eax),%edx
  801500:	83 e2 03             	and    $0x3,%edx
  801503:	83 fa 01             	cmp    $0x1,%edx
  801506:	75 23                	jne    80152b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801508:	a1 90 67 80 00       	mov    0x806790,%eax
  80150d:	8b 40 48             	mov    0x48(%eax),%eax
  801510:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801514:	89 44 24 04          	mov    %eax,0x4(%esp)
  801518:	c7 04 24 2d 22 80 00 	movl   $0x80222d,(%esp)
  80151f:	e8 73 ed ff ff       	call   800297 <cprintf>
		return -E_INVAL;
  801524:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801529:	eb 24                	jmp    80154f <read+0x8a>
	}
	if (!dev->dev_read)
  80152b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80152e:	8b 52 08             	mov    0x8(%edx),%edx
  801531:	85 d2                	test   %edx,%edx
  801533:	74 15                	je     80154a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801535:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801538:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80153c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80153f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801543:	89 04 24             	mov    %eax,(%esp)
  801546:	ff d2                	call   *%edx
  801548:	eb 05                	jmp    80154f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80154a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80154f:	83 c4 24             	add    $0x24,%esp
  801552:	5b                   	pop    %ebx
  801553:	5d                   	pop    %ebp
  801554:	c3                   	ret    

00801555 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	57                   	push   %edi
  801559:	56                   	push   %esi
  80155a:	53                   	push   %ebx
  80155b:	83 ec 1c             	sub    $0x1c,%esp
  80155e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801561:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801564:	85 f6                	test   %esi,%esi
  801566:	74 33                	je     80159b <readn+0x46>
  801568:	b8 00 00 00 00       	mov    $0x0,%eax
  80156d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801572:	89 f2                	mov    %esi,%edx
  801574:	29 c2                	sub    %eax,%edx
  801576:	89 54 24 08          	mov    %edx,0x8(%esp)
  80157a:	03 45 0c             	add    0xc(%ebp),%eax
  80157d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801581:	89 3c 24             	mov    %edi,(%esp)
  801584:	e8 3c ff ff ff       	call   8014c5 <read>
		if (m < 0)
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 17                	js     8015a4 <readn+0x4f>
			return m;
		if (m == 0)
  80158d:	85 c0                	test   %eax,%eax
  80158f:	74 11                	je     8015a2 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801591:	01 c3                	add    %eax,%ebx
  801593:	89 d8                	mov    %ebx,%eax
  801595:	39 f3                	cmp    %esi,%ebx
  801597:	72 d9                	jb     801572 <readn+0x1d>
  801599:	eb 09                	jmp    8015a4 <readn+0x4f>
  80159b:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a0:	eb 02                	jmp    8015a4 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015a2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015a4:	83 c4 1c             	add    $0x1c,%esp
  8015a7:	5b                   	pop    %ebx
  8015a8:	5e                   	pop    %esi
  8015a9:	5f                   	pop    %edi
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    

008015ac <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	53                   	push   %ebx
  8015b0:	83 ec 24             	sub    $0x24,%esp
  8015b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bd:	89 1c 24             	mov    %ebx,(%esp)
  8015c0:	e8 5a fc ff ff       	call   80121f <fd_lookup>
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 68                	js     801631 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d3:	8b 00                	mov    (%eax),%eax
  8015d5:	89 04 24             	mov    %eax,(%esp)
  8015d8:	e8 98 fc ff ff       	call   801275 <dev_lookup>
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 50                	js     801631 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e8:	75 23                	jne    80160d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ea:	a1 90 67 80 00       	mov    0x806790,%eax
  8015ef:	8b 40 48             	mov    0x48(%eax),%eax
  8015f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fa:	c7 04 24 49 22 80 00 	movl   $0x802249,(%esp)
  801601:	e8 91 ec ff ff       	call   800297 <cprintf>
		return -E_INVAL;
  801606:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80160b:	eb 24                	jmp    801631 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80160d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801610:	8b 52 0c             	mov    0xc(%edx),%edx
  801613:	85 d2                	test   %edx,%edx
  801615:	74 15                	je     80162c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801617:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80161a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80161e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801621:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801625:	89 04 24             	mov    %eax,(%esp)
  801628:	ff d2                	call   *%edx
  80162a:	eb 05                	jmp    801631 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80162c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801631:	83 c4 24             	add    $0x24,%esp
  801634:	5b                   	pop    %ebx
  801635:	5d                   	pop    %ebp
  801636:	c3                   	ret    

00801637 <seek>:

int
seek(int fdnum, off_t offset)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80163d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801640:	89 44 24 04          	mov    %eax,0x4(%esp)
  801644:	8b 45 08             	mov    0x8(%ebp),%eax
  801647:	89 04 24             	mov    %eax,(%esp)
  80164a:	e8 d0 fb ff ff       	call   80121f <fd_lookup>
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 0e                	js     801661 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801653:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801656:	8b 55 0c             	mov    0xc(%ebp),%edx
  801659:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80165c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801661:	c9                   	leave  
  801662:	c3                   	ret    

00801663 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	53                   	push   %ebx
  801667:	83 ec 24             	sub    $0x24,%esp
  80166a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801670:	89 44 24 04          	mov    %eax,0x4(%esp)
  801674:	89 1c 24             	mov    %ebx,(%esp)
  801677:	e8 a3 fb ff ff       	call   80121f <fd_lookup>
  80167c:	85 c0                	test   %eax,%eax
  80167e:	78 61                	js     8016e1 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801680:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801683:	89 44 24 04          	mov    %eax,0x4(%esp)
  801687:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168a:	8b 00                	mov    (%eax),%eax
  80168c:	89 04 24             	mov    %eax,(%esp)
  80168f:	e8 e1 fb ff ff       	call   801275 <dev_lookup>
  801694:	85 c0                	test   %eax,%eax
  801696:	78 49                	js     8016e1 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801698:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80169f:	75 23                	jne    8016c4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016a1:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a6:	8b 40 48             	mov    0x48(%eax),%eax
  8016a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b1:	c7 04 24 0c 22 80 00 	movl   $0x80220c,(%esp)
  8016b8:	e8 da eb ff ff       	call   800297 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c2:	eb 1d                	jmp    8016e1 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8016c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c7:	8b 52 18             	mov    0x18(%edx),%edx
  8016ca:	85 d2                	test   %edx,%edx
  8016cc:	74 0e                	je     8016dc <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016d5:	89 04 24             	mov    %eax,(%esp)
  8016d8:	ff d2                	call   *%edx
  8016da:	eb 05                	jmp    8016e1 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016dc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016e1:	83 c4 24             	add    $0x24,%esp
  8016e4:	5b                   	pop    %ebx
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	53                   	push   %ebx
  8016eb:	83 ec 24             	sub    $0x24,%esp
  8016ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fb:	89 04 24             	mov    %eax,(%esp)
  8016fe:	e8 1c fb ff ff       	call   80121f <fd_lookup>
  801703:	85 c0                	test   %eax,%eax
  801705:	78 52                	js     801759 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801707:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801711:	8b 00                	mov    (%eax),%eax
  801713:	89 04 24             	mov    %eax,(%esp)
  801716:	e8 5a fb ff ff       	call   801275 <dev_lookup>
  80171b:	85 c0                	test   %eax,%eax
  80171d:	78 3a                	js     801759 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80171f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801722:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801726:	74 2c                	je     801754 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801728:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80172b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801732:	00 00 00 
	stat->st_isdir = 0;
  801735:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80173c:	00 00 00 
	stat->st_dev = dev;
  80173f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801745:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801749:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80174c:	89 14 24             	mov    %edx,(%esp)
  80174f:	ff 50 14             	call   *0x14(%eax)
  801752:	eb 05                	jmp    801759 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801754:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801759:	83 c4 24             	add    $0x24,%esp
  80175c:	5b                   	pop    %ebx
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    

0080175f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	83 ec 18             	sub    $0x18,%esp
  801765:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801768:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80176b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801772:	00 
  801773:	8b 45 08             	mov    0x8(%ebp),%eax
  801776:	89 04 24             	mov    %eax,(%esp)
  801779:	e8 84 01 00 00       	call   801902 <open>
  80177e:	89 c3                	mov    %eax,%ebx
  801780:	85 c0                	test   %eax,%eax
  801782:	78 1b                	js     80179f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801784:	8b 45 0c             	mov    0xc(%ebp),%eax
  801787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178b:	89 1c 24             	mov    %ebx,(%esp)
  80178e:	e8 54 ff ff ff       	call   8016e7 <fstat>
  801793:	89 c6                	mov    %eax,%esi
	close(fd);
  801795:	89 1c 24             	mov    %ebx,(%esp)
  801798:	e8 b5 fb ff ff       	call   801352 <close>
	return r;
  80179d:	89 f3                	mov    %esi,%ebx
}
  80179f:	89 d8                	mov    %ebx,%eax
  8017a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8017a7:	89 ec                	mov    %ebp,%esp
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    
  8017ab:	90                   	nop

008017ac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	83 ec 18             	sub    $0x18,%esp
  8017b2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017b5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8017b8:	89 c6                	mov    %eax,%esi
  8017ba:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017bc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8017c3:	75 11                	jne    8017d6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8017cc:	e8 ca 02 00 00       	call   801a9b <ipc_find_env>
  8017d1:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017dd:	00 
  8017de:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8017e5:	00 
  8017e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017ea:	a1 00 50 80 00       	mov    0x805000,%eax
  8017ef:	89 04 24             	mov    %eax,(%esp)
  8017f2:	e8 39 02 00 00       	call   801a30 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017fe:	00 
  8017ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801803:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80180a:	e8 c9 01 00 00       	call   8019d8 <ipc_recv>
}
  80180f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801812:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801815:	89 ec                	mov    %ebp,%esp
  801817:	5d                   	pop    %ebp
  801818:	c3                   	ret    

00801819 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80181f:	8b 45 08             	mov    0x8(%ebp),%eax
  801822:	8b 40 0c             	mov    0xc(%eax),%eax
  801825:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80182a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182d:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801832:	ba 00 00 00 00       	mov    $0x0,%edx
  801837:	b8 02 00 00 00       	mov    $0x2,%eax
  80183c:	e8 6b ff ff ff       	call   8017ac <fsipc>
}
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801849:	8b 45 08             	mov    0x8(%ebp),%eax
  80184c:	8b 40 0c             	mov    0xc(%eax),%eax
  80184f:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801854:	ba 00 00 00 00       	mov    $0x0,%edx
  801859:	b8 06 00 00 00       	mov    $0x6,%eax
  80185e:	e8 49 ff ff ff       	call   8017ac <fsipc>
}
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	53                   	push   %ebx
  801869:	83 ec 14             	sub    $0x14,%esp
  80186c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80186f:	8b 45 08             	mov    0x8(%ebp),%eax
  801872:	8b 40 0c             	mov    0xc(%eax),%eax
  801875:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80187a:	ba 00 00 00 00       	mov    $0x0,%edx
  80187f:	b8 05 00 00 00       	mov    $0x5,%eax
  801884:	e8 23 ff ff ff       	call   8017ac <fsipc>
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 2b                	js     8018b8 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80188d:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801894:	00 
  801895:	89 1c 24             	mov    %ebx,(%esp)
  801898:	e8 7e f0 ff ff       	call   80091b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80189d:	a1 80 70 80 00       	mov    0x807080,%eax
  8018a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a8:	a1 84 70 80 00       	mov    0x807084,%eax
  8018ad:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b8:	83 c4 14             	add    $0x14,%esp
  8018bb:	5b                   	pop    %ebx
  8018bc:	5d                   	pop    %ebp
  8018bd:	c3                   	ret    

008018be <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8018c4:	c7 44 24 08 66 22 80 	movl   $0x802266,0x8(%esp)
  8018cb:	00 
  8018cc:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  8018d3:	00 
  8018d4:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  8018db:	e8 a0 00 00 00       	call   801980 <_panic>

008018e0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  8018e6:	c7 44 24 08 8f 22 80 	movl   $0x80228f,0x8(%esp)
  8018ed:	00 
  8018ee:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8018f5:	00 
  8018f6:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  8018fd:	e8 7e 00 00 00       	call   801980 <_panic>

00801902 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801908:	c7 44 24 08 ac 22 80 	movl   $0x8022ac,0x8(%esp)
  80190f:	00 
  801910:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801917:	00 
  801918:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  80191f:	e8 5c 00 00 00       	call   801980 <_panic>

00801924 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	53                   	push   %ebx
  801928:	83 ec 14             	sub    $0x14,%esp
  80192b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80192e:	89 1c 24             	mov    %ebx,(%esp)
  801931:	e8 8a ef ff ff       	call   8008c0 <strlen>
  801936:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80193b:	7f 21                	jg     80195e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80193d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801941:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  801948:	e8 ce ef ff ff       	call   80091b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80194d:	ba 00 00 00 00       	mov    $0x0,%edx
  801952:	b8 07 00 00 00       	mov    $0x7,%eax
  801957:	e8 50 fe ff ff       	call   8017ac <fsipc>
  80195c:	eb 05                	jmp    801963 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80195e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801963:	83 c4 14             	add    $0x14,%esp
  801966:	5b                   	pop    %ebx
  801967:	5d                   	pop    %ebp
  801968:	c3                   	ret    

00801969 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80196f:	ba 00 00 00 00       	mov    $0x0,%edx
  801974:	b8 08 00 00 00       	mov    $0x8,%eax
  801979:	e8 2e fe ff ff       	call   8017ac <fsipc>
}
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	56                   	push   %esi
  801984:	53                   	push   %ebx
  801985:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801988:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80198b:	8b 35 70 47 80 00    	mov    0x804770,%esi
  801991:	e8 61 f4 ff ff       	call   800df7 <sys_getenvid>
  801996:	8b 55 0c             	mov    0xc(%ebp),%edx
  801999:	89 54 24 10          	mov    %edx,0x10(%esp)
  80199d:	8b 55 08             	mov    0x8(%ebp),%edx
  8019a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8019a4:	89 74 24 08          	mov    %esi,0x8(%esp)
  8019a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ac:	c7 04 24 c4 22 80 00 	movl   $0x8022c4,(%esp)
  8019b3:	e8 df e8 ff ff       	call   800297 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8019bf:	89 04 24             	mov    %eax,(%esp)
  8019c2:	e8 6f e8 ff ff       	call   800236 <vcprintf>
	cprintf("\n");
  8019c7:	c7 04 24 fd 22 80 00 	movl   $0x8022fd,(%esp)
  8019ce:	e8 c4 e8 ff ff       	call   800297 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019d3:	cc                   	int3   
  8019d4:	eb fd                	jmp    8019d3 <_panic+0x53>
  8019d6:	66 90                	xchg   %ax,%ax

008019d8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	56                   	push   %esi
  8019dc:	53                   	push   %ebx
  8019dd:	83 ec 10             	sub    $0x10,%esp
  8019e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  8019e6:	85 db                	test   %ebx,%ebx
  8019e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8019ed:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  8019f0:	89 1c 24             	mov    %ebx,(%esp)
  8019f3:	e8 19 f7 ff ff       	call   801111 <sys_ipc_recv>
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	78 2d                	js     801a29 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  8019fc:	85 f6                	test   %esi,%esi
  8019fe:	74 0a                	je     801a0a <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  801a00:	a1 90 67 80 00       	mov    0x806790,%eax
  801a05:	8b 40 74             	mov    0x74(%eax),%eax
  801a08:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  801a0a:	85 db                	test   %ebx,%ebx
  801a0c:	74 13                	je     801a21 <ipc_recv+0x49>
  801a0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a12:	74 0d                	je     801a21 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  801a14:	a1 90 67 80 00       	mov    0x806790,%eax
  801a19:	8b 40 78             	mov    0x78(%eax),%eax
  801a1c:	8b 55 10             	mov    0x10(%ebp),%edx
  801a1f:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801a21:	a1 90 67 80 00       	mov    0x806790,%eax
  801a26:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	5b                   	pop    %ebx
  801a2d:	5e                   	pop    %esi
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    

00801a30 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	57                   	push   %edi
  801a34:	56                   	push   %esi
  801a35:	53                   	push   %ebx
  801a36:	83 ec 1c             	sub    $0x1c,%esp
  801a39:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801a42:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801a44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801a49:	0f 44 d8             	cmove  %eax,%ebx
  801a4c:	eb 2a                	jmp    801a78 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  801a4e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a51:	74 20                	je     801a73 <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801a53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a57:	c7 44 24 08 e8 22 80 	movl   $0x8022e8,0x8(%esp)
  801a5e:	00 
  801a5f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801a66:	00 
  801a67:	c7 04 24 ff 22 80 00 	movl   $0x8022ff,(%esp)
  801a6e:	e8 0d ff ff ff       	call   801980 <_panic>
		sys_yield();
  801a73:	e8 b8 f3 ff ff       	call   800e30 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801a78:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a7f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a83:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a87:	89 3c 24             	mov    %edi,(%esp)
  801a8a:	e8 45 f6 ff ff       	call   8010d4 <sys_ipc_try_send>
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	78 bb                	js     801a4e <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801a93:	83 c4 1c             	add    $0x1c,%esp
  801a96:	5b                   	pop    %ebx
  801a97:	5e                   	pop    %esi
  801a98:	5f                   	pop    %edi
  801a99:	5d                   	pop    %ebp
  801a9a:	c3                   	ret    

00801a9b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801aa1:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801aa6:	39 c8                	cmp    %ecx,%eax
  801aa8:	74 17                	je     801ac1 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aaa:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801aaf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ab2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ab8:	8b 52 50             	mov    0x50(%edx),%edx
  801abb:	39 ca                	cmp    %ecx,%edx
  801abd:	75 14                	jne    801ad3 <ipc_find_env+0x38>
  801abf:	eb 05                	jmp    801ac6 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ac1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ac6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ac9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ace:	8b 40 40             	mov    0x40(%eax),%eax
  801ad1:	eb 0e                	jmp    801ae1 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad3:	83 c0 01             	add    $0x1,%eax
  801ad6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801adb:	75 d2                	jne    801aaf <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801add:	66 b8 00 00          	mov    $0x0,%ax
}
  801ae1:	5d                   	pop    %ebp
  801ae2:	c3                   	ret    
  801ae3:	66 90                	xchg   %ax,%ax
  801ae5:	66 90                	xchg   %ax,%ax
  801ae7:	66 90                	xchg   %ax,%ax
  801ae9:	66 90                	xchg   %ax,%ax
  801aeb:	66 90                	xchg   %ax,%ax
  801aed:	66 90                	xchg   %ax,%ax
  801aef:	90                   	nop

00801af0 <__udivdi3>:
  801af0:	83 ec 1c             	sub    $0x1c,%esp
  801af3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801af7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801afb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801aff:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801b03:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b07:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801b11:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801b15:	89 ea                	mov    %ebp,%edx
  801b17:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b1b:	75 33                	jne    801b50 <__udivdi3+0x60>
  801b1d:	39 e9                	cmp    %ebp,%ecx
  801b1f:	77 6f                	ja     801b90 <__udivdi3+0xa0>
  801b21:	85 c9                	test   %ecx,%ecx
  801b23:	89 ce                	mov    %ecx,%esi
  801b25:	75 0b                	jne    801b32 <__udivdi3+0x42>
  801b27:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2c:	31 d2                	xor    %edx,%edx
  801b2e:	f7 f1                	div    %ecx
  801b30:	89 c6                	mov    %eax,%esi
  801b32:	31 d2                	xor    %edx,%edx
  801b34:	89 e8                	mov    %ebp,%eax
  801b36:	f7 f6                	div    %esi
  801b38:	89 c5                	mov    %eax,%ebp
  801b3a:	89 f8                	mov    %edi,%eax
  801b3c:	f7 f6                	div    %esi
  801b3e:	89 ea                	mov    %ebp,%edx
  801b40:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b44:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b48:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b4c:	83 c4 1c             	add    $0x1c,%esp
  801b4f:	c3                   	ret    
  801b50:	39 e8                	cmp    %ebp,%eax
  801b52:	77 24                	ja     801b78 <__udivdi3+0x88>
  801b54:	0f bd c8             	bsr    %eax,%ecx
  801b57:	83 f1 1f             	xor    $0x1f,%ecx
  801b5a:	89 0c 24             	mov    %ecx,(%esp)
  801b5d:	75 49                	jne    801ba8 <__udivdi3+0xb8>
  801b5f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801b63:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801b67:	0f 86 ab 00 00 00    	jbe    801c18 <__udivdi3+0x128>
  801b6d:	39 e8                	cmp    %ebp,%eax
  801b6f:	0f 82 a3 00 00 00    	jb     801c18 <__udivdi3+0x128>
  801b75:	8d 76 00             	lea    0x0(%esi),%esi
  801b78:	31 d2                	xor    %edx,%edx
  801b7a:	31 c0                	xor    %eax,%eax
  801b7c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b80:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b84:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b88:	83 c4 1c             	add    $0x1c,%esp
  801b8b:	c3                   	ret    
  801b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b90:	89 f8                	mov    %edi,%eax
  801b92:	f7 f1                	div    %ecx
  801b94:	31 d2                	xor    %edx,%edx
  801b96:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b9a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b9e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801ba2:	83 c4 1c             	add    $0x1c,%esp
  801ba5:	c3                   	ret    
  801ba6:	66 90                	xchg   %ax,%ax
  801ba8:	0f b6 0c 24          	movzbl (%esp),%ecx
  801bac:	89 c6                	mov    %eax,%esi
  801bae:	b8 20 00 00 00       	mov    $0x20,%eax
  801bb3:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801bb7:	2b 04 24             	sub    (%esp),%eax
  801bba:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801bbe:	d3 e6                	shl    %cl,%esi
  801bc0:	89 c1                	mov    %eax,%ecx
  801bc2:	d3 ed                	shr    %cl,%ebp
  801bc4:	0f b6 0c 24          	movzbl (%esp),%ecx
  801bc8:	09 f5                	or     %esi,%ebp
  801bca:	8b 74 24 04          	mov    0x4(%esp),%esi
  801bce:	d3 e6                	shl    %cl,%esi
  801bd0:	89 c1                	mov    %eax,%ecx
  801bd2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bd6:	89 d6                	mov    %edx,%esi
  801bd8:	d3 ee                	shr    %cl,%esi
  801bda:	0f b6 0c 24          	movzbl (%esp),%ecx
  801bde:	d3 e2                	shl    %cl,%edx
  801be0:	89 c1                	mov    %eax,%ecx
  801be2:	d3 ef                	shr    %cl,%edi
  801be4:	09 d7                	or     %edx,%edi
  801be6:	89 f2                	mov    %esi,%edx
  801be8:	89 f8                	mov    %edi,%eax
  801bea:	f7 f5                	div    %ebp
  801bec:	89 d6                	mov    %edx,%esi
  801bee:	89 c7                	mov    %eax,%edi
  801bf0:	f7 64 24 04          	mull   0x4(%esp)
  801bf4:	39 d6                	cmp    %edx,%esi
  801bf6:	72 30                	jb     801c28 <__udivdi3+0x138>
  801bf8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801bfc:	0f b6 0c 24          	movzbl (%esp),%ecx
  801c00:	d3 e5                	shl    %cl,%ebp
  801c02:	39 c5                	cmp    %eax,%ebp
  801c04:	73 04                	jae    801c0a <__udivdi3+0x11a>
  801c06:	39 d6                	cmp    %edx,%esi
  801c08:	74 1e                	je     801c28 <__udivdi3+0x138>
  801c0a:	89 f8                	mov    %edi,%eax
  801c0c:	31 d2                	xor    %edx,%edx
  801c0e:	e9 69 ff ff ff       	jmp    801b7c <__udivdi3+0x8c>
  801c13:	90                   	nop
  801c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c18:	31 d2                	xor    %edx,%edx
  801c1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c1f:	e9 58 ff ff ff       	jmp    801b7c <__udivdi3+0x8c>
  801c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c28:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c2b:	31 d2                	xor    %edx,%edx
  801c2d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801c31:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801c35:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801c39:	83 c4 1c             	add    $0x1c,%esp
  801c3c:	c3                   	ret    
  801c3d:	66 90                	xchg   %ax,%ax
  801c3f:	90                   	nop

00801c40 <__umoddi3>:
  801c40:	83 ec 2c             	sub    $0x2c,%esp
  801c43:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c47:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c4b:	89 74 24 20          	mov    %esi,0x20(%esp)
  801c4f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801c53:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801c57:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	89 c2                	mov    %eax,%edx
  801c5f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801c63:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801c67:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c6b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801c6f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801c73:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c77:	75 1f                	jne    801c98 <__umoddi3+0x58>
  801c79:	39 fe                	cmp    %edi,%esi
  801c7b:	76 63                	jbe    801ce0 <__umoddi3+0xa0>
  801c7d:	89 c8                	mov    %ecx,%eax
  801c7f:	89 fa                	mov    %edi,%edx
  801c81:	f7 f6                	div    %esi
  801c83:	89 d0                	mov    %edx,%eax
  801c85:	31 d2                	xor    %edx,%edx
  801c87:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c8b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c8f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c93:	83 c4 2c             	add    $0x2c,%esp
  801c96:	c3                   	ret    
  801c97:	90                   	nop
  801c98:	39 f8                	cmp    %edi,%eax
  801c9a:	77 64                	ja     801d00 <__umoddi3+0xc0>
  801c9c:	0f bd e8             	bsr    %eax,%ebp
  801c9f:	83 f5 1f             	xor    $0x1f,%ebp
  801ca2:	75 74                	jne    801d18 <__umoddi3+0xd8>
  801ca4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801ca8:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801cac:	0f 87 0e 01 00 00    	ja     801dc0 <__umoddi3+0x180>
  801cb2:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801cb6:	29 f1                	sub    %esi,%ecx
  801cb8:	19 c7                	sbb    %eax,%edi
  801cba:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801cbe:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801cc2:	8b 44 24 14          	mov    0x14(%esp),%eax
  801cc6:	8b 54 24 18          	mov    0x18(%esp),%edx
  801cca:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cce:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cd2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801cd6:	83 c4 2c             	add    $0x2c,%esp
  801cd9:	c3                   	ret    
  801cda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce0:	85 f6                	test   %esi,%esi
  801ce2:	89 f5                	mov    %esi,%ebp
  801ce4:	75 0b                	jne    801cf1 <__umoddi3+0xb1>
  801ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ceb:	31 d2                	xor    %edx,%edx
  801ced:	f7 f6                	div    %esi
  801cef:	89 c5                	mov    %eax,%ebp
  801cf1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801cf5:	31 d2                	xor    %edx,%edx
  801cf7:	f7 f5                	div    %ebp
  801cf9:	89 c8                	mov    %ecx,%eax
  801cfb:	f7 f5                	div    %ebp
  801cfd:	eb 84                	jmp    801c83 <__umoddi3+0x43>
  801cff:	90                   	nop
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 fa                	mov    %edi,%edx
  801d04:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d08:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d0c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801d10:	83 c4 2c             	add    $0x2c,%esp
  801d13:	c3                   	ret    
  801d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d18:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d1c:	be 20 00 00 00       	mov    $0x20,%esi
  801d21:	89 e9                	mov    %ebp,%ecx
  801d23:	29 ee                	sub    %ebp,%esi
  801d25:	d3 e2                	shl    %cl,%edx
  801d27:	89 f1                	mov    %esi,%ecx
  801d29:	d3 e8                	shr    %cl,%eax
  801d2b:	89 e9                	mov    %ebp,%ecx
  801d2d:	09 d0                	or     %edx,%eax
  801d2f:	89 fa                	mov    %edi,%edx
  801d31:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d35:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d39:	d3 e0                	shl    %cl,%eax
  801d3b:	89 f1                	mov    %esi,%ecx
  801d3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d41:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d45:	d3 ea                	shr    %cl,%edx
  801d47:	89 e9                	mov    %ebp,%ecx
  801d49:	d3 e7                	shl    %cl,%edi
  801d4b:	89 f1                	mov    %esi,%ecx
  801d4d:	d3 e8                	shr    %cl,%eax
  801d4f:	89 e9                	mov    %ebp,%ecx
  801d51:	09 f8                	or     %edi,%eax
  801d53:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d57:	f7 74 24 0c          	divl   0xc(%esp)
  801d5b:	d3 e7                	shl    %cl,%edi
  801d5d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801d61:	89 d7                	mov    %edx,%edi
  801d63:	f7 64 24 10          	mull   0x10(%esp)
  801d67:	39 d7                	cmp    %edx,%edi
  801d69:	89 c1                	mov    %eax,%ecx
  801d6b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801d6f:	72 3b                	jb     801dac <__umoddi3+0x16c>
  801d71:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801d75:	72 31                	jb     801da8 <__umoddi3+0x168>
  801d77:	8b 44 24 18          	mov    0x18(%esp),%eax
  801d7b:	29 c8                	sub    %ecx,%eax
  801d7d:	19 d7                	sbb    %edx,%edi
  801d7f:	89 e9                	mov    %ebp,%ecx
  801d81:	89 fa                	mov    %edi,%edx
  801d83:	d3 e8                	shr    %cl,%eax
  801d85:	89 f1                	mov    %esi,%ecx
  801d87:	d3 e2                	shl    %cl,%edx
  801d89:	89 e9                	mov    %ebp,%ecx
  801d8b:	09 d0                	or     %edx,%eax
  801d8d:	89 fa                	mov    %edi,%edx
  801d8f:	d3 ea                	shr    %cl,%edx
  801d91:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d95:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d99:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801d9d:	83 c4 2c             	add    $0x2c,%esp
  801da0:	c3                   	ret    
  801da1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da8:	39 d7                	cmp    %edx,%edi
  801daa:	75 cb                	jne    801d77 <__umoddi3+0x137>
  801dac:	8b 54 24 14          	mov    0x14(%esp),%edx
  801db0:	89 c1                	mov    %eax,%ecx
  801db2:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801db6:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801dba:	eb bb                	jmp    801d77 <__umoddi3+0x137>
  801dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801dc4:	0f 82 e8 fe ff ff    	jb     801cb2 <__umoddi3+0x72>
  801dca:	e9 f3 fe ff ff       	jmp    801cc2 <__umoddi3+0x82>
