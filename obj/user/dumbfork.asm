
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 2f 02 00 00       	call   800260 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 20             	sub    $0x20,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80004e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800055:	00 
  800056:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80005a:	89 34 24             	mov    %esi,(%esp)
  80005d:	e8 37 0f 00 00       	call   800f99 <sys_page_alloc>
  800062:	85 c0                	test   %eax,%eax
  800064:	79 20                	jns    800086 <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  800066:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80006a:	c7 44 24 08 a0 1e 80 	movl   $0x801ea0,0x8(%esp)
  800071:	00 
  800072:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800079:	00 
  80007a:	c7 04 24 b3 1e 80 00 	movl   $0x801eb3,(%esp)
  800081:	e8 46 02 00 00       	call   8002cc <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800086:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80008d:	00 
  80008e:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800095:	00 
  800096:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009d:	00 
  80009e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a2:	89 34 24             	mov    %esi,(%esp)
  8000a5:	e8 57 0f 00 00       	call   801001 <sys_page_map>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 c3 1e 80 	movl   $0x801ec3,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 b3 1e 80 00 	movl   $0x801eb3,(%esp)
  8000c9:	e8 fe 01 00 00       	call   8002cc <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000d5:	00 
  8000d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000da:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000e1:	e8 6d 0b 00 00       	call   800c53 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000e6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 6e 0f 00 00       	call   801068 <sys_page_unmap>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 d4 1e 80 	movl   $0x801ed4,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 b3 1e 80 00 	movl   $0x801eb3,(%esp)
  800119:	e8 ae 01 00 00       	call   8002cc <_panic>
}
  80011e:	83 c4 20             	add    $0x20,%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <dumbfork>:

envid_t
dumbfork(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80012d:	be 07 00 00 00       	mov    $0x7,%esi
  800132:	89 f0                	mov    %esi,%eax
  800134:	cd 30                	int    $0x30
  800136:	89 c6                	mov    %eax,%esi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800138:	85 c0                	test   %eax,%eax
  80013a:	79 20                	jns    80015c <dumbfork+0x37>
		panic("sys_exofork: %e", envid);
  80013c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800140:	c7 44 24 08 e7 1e 80 	movl   $0x801ee7,0x8(%esp)
  800147:	00 
  800148:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  80014f:	00 
  800150:	c7 04 24 b3 1e 80 00 	movl   $0x801eb3,(%esp)
  800157:	e8 70 01 00 00       	call   8002cc <_panic>
	if (envid == 0) {
  80015c:	85 c0                	test   %eax,%eax
  80015e:	75 1c                	jne    80017c <dumbfork+0x57>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800160:	e8 c2 0d 00 00       	call   800f27 <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 04 40 80 00       	mov    %eax,0x804004
  800177:	e9 82 00 00 00       	jmp    8001fe <dumbfork+0xd9>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80017c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800183:	b8 00 60 80 00       	mov    $0x806000,%eax
  800188:	3d 00 00 80 00       	cmp    $0x800000,%eax
  80018d:	76 27                	jbe    8001b6 <dumbfork+0x91>
  80018f:	89 f3                	mov    %esi,%ebx
  800191:	ba 00 00 80 00       	mov    $0x800000,%edx
		duppage(envid, addr);
  800196:	89 54 24 04          	mov    %edx,0x4(%esp)
  80019a:	89 1c 24             	mov    %ebx,(%esp)
  80019d:	e8 9e fe ff ff       	call   800040 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8001a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001a5:	81 c2 00 10 00 00    	add    $0x1000,%edx
  8001ab:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8001ae:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  8001b4:	72 e0                	jb     800196 <dumbfork+0x71>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c2:	89 34 24             	mov    %esi,(%esp)
  8001c5:	e8 76 fe ff ff       	call   800040 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001ca:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001d1:	00 
  8001d2:	89 34 24             	mov    %esi,(%esp)
  8001d5:	e8 f5 0e 00 00       	call   8010cf <sys_env_set_status>
  8001da:	85 c0                	test   %eax,%eax
  8001dc:	79 20                	jns    8001fe <dumbfork+0xd9>
		panic("sys_env_set_status: %e", r);
  8001de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e2:	c7 44 24 08 f7 1e 80 	movl   $0x801ef7,0x8(%esp)
  8001e9:	00 
  8001ea:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001f1:	00 
  8001f2:	c7 04 24 b3 1e 80 00 	movl   $0x801eb3,(%esp)
  8001f9:	e8 ce 00 00 00       	call   8002cc <_panic>

	return envid;
}
  8001fe:	89 f0                	mov    %esi,%eax
  800200:	83 c4 20             	add    $0x20,%esp
  800203:	5b                   	pop    %ebx
  800204:	5e                   	pop    %esi
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    

00800207 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80020f:	e8 11 ff ff ff       	call   800125 <dumbfork>
  800214:	89 c6                	mov    %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021b:	eb 28                	jmp    800245 <umain+0x3e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80021d:	b8 15 1f 80 00       	mov    $0x801f15,%eax
  800222:	eb 05                	jmp    800229 <umain+0x22>
  800224:	b8 0e 1f 80 00       	mov    $0x801f0e,%eax
  800229:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800231:	c7 04 24 1b 1f 80 00 	movl   $0x801f1b,(%esp)
  800238:	e8 8a 01 00 00       	call   8003c7 <cprintf>
		sys_yield();
  80023d:	e8 1e 0d 00 00       	call   800f60 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800242:	83 c3 01             	add    $0x1,%ebx
  800245:	85 f6                	test   %esi,%esi
  800247:	75 09                	jne    800252 <umain+0x4b>
  800249:	83 fb 13             	cmp    $0x13,%ebx
  80024c:	7e cf                	jle    80021d <umain+0x16>
  80024e:	66 90                	xchg   %ax,%ax
  800250:	eb 05                	jmp    800257 <umain+0x50>
  800252:	83 fb 09             	cmp    $0x9,%ebx
  800255:	7e cd                	jle    800224 <umain+0x1d>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800257:	83 c4 10             	add    $0x10,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    
  80025e:	66 90                	xchg   %ax,%ax

00800260 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 18             	sub    $0x18,%esp
  800266:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800269:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80026c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80026f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  800272:	e8 b0 0c 00 00       	call   800f27 <sys_getenvid>
  800277:	25 ff 03 00 00       	and    $0x3ff,%eax
  80027c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80027f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800284:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800289:	85 db                	test   %ebx,%ebx
  80028b:	7e 07                	jle    800294 <libmain+0x34>
		binaryname = argv[0];
  80028d:	8b 06                	mov    (%esi),%eax
  80028f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800294:	89 74 24 04          	mov    %esi,0x4(%esp)
  800298:	89 1c 24             	mov    %ebx,(%esp)
  80029b:	e8 67 ff ff ff       	call   800207 <umain>

	// exit gracefully
	exit();
  8002a0:	e8 0b 00 00 00       	call   8002b0 <exit>
}
  8002a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8002ab:	89 ec                	mov    %ebp,%esp
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    
  8002af:	90                   	nop

008002b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8002b6:	e8 f8 11 00 00       	call   8014b3 <close_all>
	sys_env_destroy(0);
  8002bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002c2:	e8 fa 0b 00 00       	call   800ec1 <sys_env_destroy>
}
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    
  8002c9:	66 90                	xchg   %ax,%ax
  8002cb:	90                   	nop

008002cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002dd:	e8 45 0c 00 00       	call   800f27 <sys_getenvid>
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f8:	c7 04 24 38 1f 80 00 	movl   $0x801f38,(%esp)
  8002ff:	e8 c3 00 00 00       	call   8003c7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800304:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800308:	8b 45 10             	mov    0x10(%ebp),%eax
  80030b:	89 04 24             	mov    %eax,(%esp)
  80030e:	e8 53 00 00 00       	call   800366 <vcprintf>
	cprintf("\n");
  800313:	c7 04 24 2b 1f 80 00 	movl   $0x801f2b,(%esp)
  80031a:	e8 a8 00 00 00       	call   8003c7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80031f:	cc                   	int3   
  800320:	eb fd                	jmp    80031f <_panic+0x53>
  800322:	66 90                	xchg   %ax,%ax

00800324 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	53                   	push   %ebx
  800328:	83 ec 14             	sub    $0x14,%esp
  80032b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80032e:	8b 03                	mov    (%ebx),%eax
  800330:	8b 55 08             	mov    0x8(%ebp),%edx
  800333:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800337:	83 c0 01             	add    $0x1,%eax
  80033a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80033c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800341:	75 19                	jne    80035c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800343:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80034a:	00 
  80034b:	8d 43 08             	lea    0x8(%ebx),%eax
  80034e:	89 04 24             	mov    %eax,(%esp)
  800351:	e8 fa 0a 00 00       	call   800e50 <sys_cputs>
		b->idx = 0;
  800356:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80035c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800360:	83 c4 14             	add    $0x14,%esp
  800363:	5b                   	pop    %ebx
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80036f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800376:	00 00 00 
	b.cnt = 0;
  800379:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800380:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800383:	8b 45 0c             	mov    0xc(%ebp),%eax
  800386:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800391:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800397:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039b:	c7 04 24 24 03 80 00 	movl   $0x800324,(%esp)
  8003a2:	e8 bb 01 00 00       	call   800562 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003a7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003b7:	89 04 24             	mov    %eax,(%esp)
  8003ba:	e8 91 0a 00 00       	call   800e50 <sys_cputs>

	return b.cnt;
}
  8003bf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003c5:	c9                   	leave  
  8003c6:	c3                   	ret    

008003c7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003cd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	e8 87 ff ff ff       	call   800366 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003df:	c9                   	leave  
  8003e0:	c3                   	ret    
  8003e1:	66 90                	xchg   %ax,%ax
  8003e3:	66 90                	xchg   %ax,%ax
  8003e5:	66 90                	xchg   %ax,%ax
  8003e7:	66 90                	xchg   %ax,%ax
  8003e9:	66 90                	xchg   %ax,%ax
  8003eb:	66 90                	xchg   %ax,%ax
  8003ed:	66 90                	xchg   %ax,%ax
  8003ef:	90                   	nop

008003f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	57                   	push   %edi
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
  8003f6:	83 ec 4c             	sub    $0x4c,%esp
  8003f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003fc:	89 d7                	mov    %edx,%edi
  8003fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800401:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800404:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800407:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040a:	b8 00 00 00 00       	mov    $0x0,%eax
  80040f:	39 d8                	cmp    %ebx,%eax
  800411:	72 17                	jb     80042a <printnum+0x3a>
  800413:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800416:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800419:	76 0f                	jbe    80042a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80041b:	8b 75 14             	mov    0x14(%ebp),%esi
  80041e:	83 ee 01             	sub    $0x1,%esi
  800421:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800424:	85 f6                	test   %esi,%esi
  800426:	7f 63                	jg     80048b <printnum+0x9b>
  800428:	eb 75                	jmp    80049f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80042d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	83 e8 01             	sub    $0x1,%eax
  800437:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80043e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800442:	8b 44 24 08          	mov    0x8(%esp),%eax
  800446:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80044a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800450:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800457:	00 
  800458:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80045b:	89 1c 24             	mov    %ebx,(%esp)
  80045e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800461:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800465:	e8 56 17 00 00       	call   801bc0 <__udivdi3>
  80046a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800470:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800474:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800478:	89 04 24             	mov    %eax,(%esp)
  80047b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80047f:	89 fa                	mov    %edi,%edx
  800481:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800484:	e8 67 ff ff ff       	call   8003f0 <printnum>
  800489:	eb 14                	jmp    80049f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80048b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048f:	8b 45 18             	mov    0x18(%ebp),%eax
  800492:	89 04 24             	mov    %eax,(%esp)
  800495:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800497:	83 ee 01             	sub    $0x1,%esi
  80049a:	75 ef                	jne    80048b <printnum+0x9b>
  80049c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004ae:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004b5:	00 
  8004b6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8004b9:	89 1c 24             	mov    %ebx,(%esp)
  8004bc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8004bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c3:	e8 48 18 00 00       	call   801d10 <__umoddi3>
  8004c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004cc:	0f be 80 5b 1f 80 00 	movsbl 0x801f5b(%eax),%eax
  8004d3:	89 04 24             	mov    %eax,(%esp)
  8004d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004d9:	ff d0                	call   *%eax
}
  8004db:	83 c4 4c             	add    $0x4c,%esp
  8004de:	5b                   	pop    %ebx
  8004df:	5e                   	pop    %esi
  8004e0:	5f                   	pop    %edi
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004e6:	83 fa 01             	cmp    $0x1,%edx
  8004e9:	7e 0e                	jle    8004f9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004eb:	8b 10                	mov    (%eax),%edx
  8004ed:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004f0:	89 08                	mov    %ecx,(%eax)
  8004f2:	8b 02                	mov    (%edx),%eax
  8004f4:	8b 52 04             	mov    0x4(%edx),%edx
  8004f7:	eb 22                	jmp    80051b <getuint+0x38>
	else if (lflag)
  8004f9:	85 d2                	test   %edx,%edx
  8004fb:	74 10                	je     80050d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004fd:	8b 10                	mov    (%eax),%edx
  8004ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800502:	89 08                	mov    %ecx,(%eax)
  800504:	8b 02                	mov    (%edx),%eax
  800506:	ba 00 00 00 00       	mov    $0x0,%edx
  80050b:	eb 0e                	jmp    80051b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80050d:	8b 10                	mov    (%eax),%edx
  80050f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800512:	89 08                	mov    %ecx,(%eax)
  800514:	8b 02                	mov    (%edx),%eax
  800516:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80051b:	5d                   	pop    %ebp
  80051c:	c3                   	ret    

0080051d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800523:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800527:	8b 10                	mov    (%eax),%edx
  800529:	3b 50 04             	cmp    0x4(%eax),%edx
  80052c:	73 0a                	jae    800538 <sprintputch+0x1b>
		*b->buf++ = ch;
  80052e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800531:	88 0a                	mov    %cl,(%edx)
  800533:	83 c2 01             	add    $0x1,%edx
  800536:	89 10                	mov    %edx,(%eax)
}
  800538:	5d                   	pop    %ebp
  800539:	c3                   	ret    

0080053a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80053a:	55                   	push   %ebp
  80053b:	89 e5                	mov    %esp,%ebp
  80053d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800540:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800543:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800547:	8b 45 10             	mov    0x10(%ebp),%eax
  80054a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800551:	89 44 24 04          	mov    %eax,0x4(%esp)
  800555:	8b 45 08             	mov    0x8(%ebp),%eax
  800558:	89 04 24             	mov    %eax,(%esp)
  80055b:	e8 02 00 00 00       	call   800562 <vprintfmt>
	va_end(ap);
}
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	57                   	push   %edi
  800566:	56                   	push   %esi
  800567:	53                   	push   %ebx
  800568:	83 ec 4c             	sub    $0x4c,%esp
  80056b:	8b 75 08             	mov    0x8(%ebp),%esi
  80056e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800571:	8b 7d 10             	mov    0x10(%ebp),%edi
  800574:	eb 11                	jmp    800587 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800576:	85 c0                	test   %eax,%eax
  800578:	0f 84 db 03 00 00    	je     800959 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80057e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800582:	89 04 24             	mov    %eax,(%esp)
  800585:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800587:	0f b6 07             	movzbl (%edi),%eax
  80058a:	83 c7 01             	add    $0x1,%edi
  80058d:	83 f8 25             	cmp    $0x25,%eax
  800590:	75 e4                	jne    800576 <vprintfmt+0x14>
  800592:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800596:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80059d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8005a4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b0:	eb 2b                	jmp    8005dd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005b5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  8005b9:	eb 22                	jmp    8005dd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005be:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8005c2:	eb 19                	jmp    8005dd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005c7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005ce:	eb 0d                	jmp    8005dd <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	0f b6 0f             	movzbl (%edi),%ecx
  8005e0:	8d 47 01             	lea    0x1(%edi),%eax
  8005e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e6:	0f b6 07             	movzbl (%edi),%eax
  8005e9:	83 e8 23             	sub    $0x23,%eax
  8005ec:	3c 55                	cmp    $0x55,%al
  8005ee:	0f 87 40 03 00 00    	ja     800934 <vprintfmt+0x3d2>
  8005f4:	0f b6 c0             	movzbl %al,%eax
  8005f7:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005fe:	83 e9 30             	sub    $0x30,%ecx
  800601:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800604:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800608:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80060b:	83 f9 09             	cmp    $0x9,%ecx
  80060e:	77 57                	ja     800667 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800610:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800613:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800616:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800619:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80061c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80061f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800623:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800626:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800629:	83 f9 09             	cmp    $0x9,%ecx
  80062c:	76 eb                	jbe    800619 <vprintfmt+0xb7>
  80062e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800631:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800634:	eb 34                	jmp    80066a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8d 48 04             	lea    0x4(%eax),%ecx
  80063c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80063f:	8b 00                	mov    (%eax),%eax
  800641:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800647:	eb 21                	jmp    80066a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800649:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064d:	0f 88 71 ff ff ff    	js     8005c4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800653:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800656:	eb 85                	jmp    8005dd <vprintfmt+0x7b>
  800658:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80065b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800662:	e9 76 ff ff ff       	jmp    8005dd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80066a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80066e:	0f 89 69 ff ff ff    	jns    8005dd <vprintfmt+0x7b>
  800674:	e9 57 ff ff ff       	jmp    8005d0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800679:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80067f:	e9 59 ff ff ff       	jmp    8005dd <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)
  80068d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800691:	8b 00                	mov    (%eax),%eax
  800693:	89 04 24             	mov    %eax,(%esp)
  800696:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800698:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80069b:	e9 e7 fe ff ff       	jmp    800587 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	89 c2                	mov    %eax,%edx
  8006ad:	c1 fa 1f             	sar    $0x1f,%edx
  8006b0:	31 d0                	xor    %edx,%eax
  8006b2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006b4:	83 f8 0f             	cmp    $0xf,%eax
  8006b7:	7f 0b                	jg     8006c4 <vprintfmt+0x162>
  8006b9:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  8006c0:	85 d2                	test   %edx,%edx
  8006c2:	75 20                	jne    8006e4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8006c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c8:	c7 44 24 08 73 1f 80 	movl   $0x801f73,0x8(%esp)
  8006cf:	00 
  8006d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d4:	89 34 24             	mov    %esi,(%esp)
  8006d7:	e8 5e fe ff ff       	call   80053a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dc:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006df:	e9 a3 fe ff ff       	jmp    800587 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8006e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e8:	c7 44 24 08 7c 1f 80 	movl   $0x801f7c,0x8(%esp)
  8006ef:	00 
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	89 34 24             	mov    %esi,(%esp)
  8006f7:	e8 3e fe ff ff       	call   80053a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006ff:	e9 83 fe ff ff       	jmp    800587 <vprintfmt+0x25>
  800704:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800707:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80070a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8d 50 04             	lea    0x4(%eax),%edx
  800713:	89 55 14             	mov    %edx,0x14(%ebp)
  800716:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800718:	85 ff                	test   %edi,%edi
  80071a:	b8 6c 1f 80 00       	mov    $0x801f6c,%eax
  80071f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800722:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800726:	74 06                	je     80072e <vprintfmt+0x1cc>
  800728:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80072c:	7f 16                	jg     800744 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072e:	0f b6 17             	movzbl (%edi),%edx
  800731:	0f be c2             	movsbl %dl,%eax
  800734:	83 c7 01             	add    $0x1,%edi
  800737:	85 c0                	test   %eax,%eax
  800739:	0f 85 9f 00 00 00    	jne    8007de <vprintfmt+0x27c>
  80073f:	e9 8b 00 00 00       	jmp    8007cf <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800744:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800748:	89 3c 24             	mov    %edi,(%esp)
  80074b:	e8 c2 02 00 00       	call   800a12 <strnlen>
  800750:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800753:	29 c2                	sub    %eax,%edx
  800755:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800758:	85 d2                	test   %edx,%edx
  80075a:	7e d2                	jle    80072e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80075c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800760:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800763:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800766:	89 d7                	mov    %edx,%edi
  800768:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800774:	83 ef 01             	sub    $0x1,%edi
  800777:	75 ef                	jne    800768 <vprintfmt+0x206>
  800779:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80077c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80077f:	eb ad                	jmp    80072e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800781:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800785:	74 20                	je     8007a7 <vprintfmt+0x245>
  800787:	0f be d2             	movsbl %dl,%edx
  80078a:	83 ea 20             	sub    $0x20,%edx
  80078d:	83 fa 5e             	cmp    $0x5e,%edx
  800790:	76 15                	jbe    8007a7 <vprintfmt+0x245>
					putch('?', putdat);
  800792:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800795:	89 54 24 04          	mov    %edx,0x4(%esp)
  800799:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007a0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007a3:	ff d1                	call   *%ecx
  8007a5:	eb 0f                	jmp    8007b6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  8007a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ae:	89 04 24             	mov    %eax,(%esp)
  8007b1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007b4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b6:	83 eb 01             	sub    $0x1,%ebx
  8007b9:	0f b6 17             	movzbl (%edi),%edx
  8007bc:	0f be c2             	movsbl %dl,%eax
  8007bf:	83 c7 01             	add    $0x1,%edi
  8007c2:	85 c0                	test   %eax,%eax
  8007c4:	75 24                	jne    8007ea <vprintfmt+0x288>
  8007c6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007c9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007cc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cf:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007d6:	0f 8e ab fd ff ff    	jle    800587 <vprintfmt+0x25>
  8007dc:	eb 20                	jmp    8007fe <vprintfmt+0x29c>
  8007de:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8007e1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007e4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8007e7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ea:	85 f6                	test   %esi,%esi
  8007ec:	78 93                	js     800781 <vprintfmt+0x21f>
  8007ee:	83 ee 01             	sub    $0x1,%esi
  8007f1:	79 8e                	jns    800781 <vprintfmt+0x21f>
  8007f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007f6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007f9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8007fc:	eb d1                	jmp    8007cf <vprintfmt+0x26d>
  8007fe:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800801:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800805:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80080c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80080e:	83 ef 01             	sub    $0x1,%edi
  800811:	75 ee                	jne    800801 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800813:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800816:	e9 6c fd ff ff       	jmp    800587 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80081b:	83 fa 01             	cmp    $0x1,%edx
  80081e:	66 90                	xchg   %ax,%ax
  800820:	7e 16                	jle    800838 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8d 50 08             	lea    0x8(%eax),%edx
  800828:	89 55 14             	mov    %edx,0x14(%ebp)
  80082b:	8b 10                	mov    (%eax),%edx
  80082d:	8b 48 04             	mov    0x4(%eax),%ecx
  800830:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800833:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800836:	eb 32                	jmp    80086a <vprintfmt+0x308>
	else if (lflag)
  800838:	85 d2                	test   %edx,%edx
  80083a:	74 18                	je     800854 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 04             	lea    0x4(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)
  800845:	8b 00                	mov    (%eax),%eax
  800847:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80084a:	89 c1                	mov    %eax,%ecx
  80084c:	c1 f9 1f             	sar    $0x1f,%ecx
  80084f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800852:	eb 16                	jmp    80086a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8d 50 04             	lea    0x4(%eax),%edx
  80085a:	89 55 14             	mov    %edx,0x14(%ebp)
  80085d:	8b 00                	mov    (%eax),%eax
  80085f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800862:	89 c7                	mov    %eax,%edi
  800864:	c1 ff 1f             	sar    $0x1f,%edi
  800867:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80086a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80086d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800870:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800875:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800879:	79 7d                	jns    8008f8 <vprintfmt+0x396>
				putch('-', putdat);
  80087b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800886:	ff d6                	call   *%esi
				num = -(long long) num;
  800888:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80088b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80088e:	f7 d8                	neg    %eax
  800890:	83 d2 00             	adc    $0x0,%edx
  800893:	f7 da                	neg    %edx
			}
			base = 10;
  800895:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80089a:	eb 5c                	jmp    8008f8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80089c:	8d 45 14             	lea    0x14(%ebp),%eax
  80089f:	e8 3f fc ff ff       	call   8004e3 <getuint>
			base = 10;
  8008a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8008a9:	eb 4d                	jmp    8008f8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8008ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ae:	e8 30 fc ff ff       	call   8004e3 <getuint>
			base = 8;
  8008b3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8008b8:	eb 3e                	jmp    8008f8 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008be:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008c5:	ff d6                	call   *%esi
			putch('x', putdat);
  8008c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008d2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d7:	8d 50 04             	lea    0x4(%eax),%edx
  8008da:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008dd:	8b 00                	mov    (%eax),%eax
  8008df:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008e4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008e9:	eb 0d                	jmp    8008f8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ee:	e8 f0 fb ff ff       	call   8004e3 <getuint>
			base = 16;
  8008f3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008f8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8008fc:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800900:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800903:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800907:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80090b:	89 04 24             	mov    %eax,(%esp)
  80090e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800912:	89 da                	mov    %ebx,%edx
  800914:	89 f0                	mov    %esi,%eax
  800916:	e8 d5 fa ff ff       	call   8003f0 <printnum>
			break;
  80091b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80091e:	e9 64 fc ff ff       	jmp    800587 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800923:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800927:	89 0c 24             	mov    %ecx,(%esp)
  80092a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80092f:	e9 53 fc ff ff       	jmp    800587 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800934:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800938:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80093f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800941:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800945:	0f 84 3c fc ff ff    	je     800587 <vprintfmt+0x25>
  80094b:	83 ef 01             	sub    $0x1,%edi
  80094e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800952:	75 f7                	jne    80094b <vprintfmt+0x3e9>
  800954:	e9 2e fc ff ff       	jmp    800587 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800959:	83 c4 4c             	add    $0x4c,%esp
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 28             	sub    $0x28,%esp
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80096d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800970:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800974:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800977:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80097e:	85 d2                	test   %edx,%edx
  800980:	7e 30                	jle    8009b2 <vsnprintf+0x51>
  800982:	85 c0                	test   %eax,%eax
  800984:	74 2c                	je     8009b2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800986:	8b 45 14             	mov    0x14(%ebp),%eax
  800989:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098d:	8b 45 10             	mov    0x10(%ebp),%eax
  800990:	89 44 24 08          	mov    %eax,0x8(%esp)
  800994:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099b:	c7 04 24 1d 05 80 00 	movl   $0x80051d,(%esp)
  8009a2:	e8 bb fb ff ff       	call   800562 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b0:	eb 05                	jmp    8009b7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	89 04 24             	mov    %eax,(%esp)
  8009da:	e8 82 ff ff ff       	call   800961 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    
  8009e1:	66 90                	xchg   %ax,%ax
  8009e3:	66 90                	xchg   %ax,%ax
  8009e5:	66 90                	xchg   %ax,%ax
  8009e7:	66 90                	xchg   %ax,%ax
  8009e9:	66 90                	xchg   %ax,%ax
  8009eb:	66 90                	xchg   %ax,%ax
  8009ed:	66 90                	xchg   %ax,%ax
  8009ef:	90                   	nop

008009f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f6:	80 3a 00             	cmpb   $0x0,(%edx)
  8009f9:	74 10                	je     800a0b <strlen+0x1b>
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a00:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a07:	75 f7                	jne    800a00 <strlen+0x10>
  800a09:	eb 05                	jmp    800a10 <strlen+0x20>
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	53                   	push   %ebx
  800a16:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1c:	85 c9                	test   %ecx,%ecx
  800a1e:	74 1c                	je     800a3c <strnlen+0x2a>
  800a20:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a23:	74 1e                	je     800a43 <strnlen+0x31>
  800a25:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a2a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2c:	39 ca                	cmp    %ecx,%edx
  800a2e:	74 18                	je     800a48 <strnlen+0x36>
  800a30:	83 c2 01             	add    $0x1,%edx
  800a33:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a38:	75 f0                	jne    800a2a <strnlen+0x18>
  800a3a:	eb 0c                	jmp    800a48 <strnlen+0x36>
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a41:	eb 05                	jmp    800a48 <strnlen+0x36>
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a48:	5b                   	pop    %ebx
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	53                   	push   %ebx
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a55:	89 c2                	mov    %eax,%edx
  800a57:	0f b6 19             	movzbl (%ecx),%ebx
  800a5a:	88 1a                	mov    %bl,(%edx)
  800a5c:	83 c2 01             	add    $0x1,%edx
  800a5f:	83 c1 01             	add    $0x1,%ecx
  800a62:	84 db                	test   %bl,%bl
  800a64:	75 f1                	jne    800a57 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a66:	5b                   	pop    %ebx
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	53                   	push   %ebx
  800a6d:	83 ec 08             	sub    $0x8,%esp
  800a70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a73:	89 1c 24             	mov    %ebx,(%esp)
  800a76:	e8 75 ff ff ff       	call   8009f0 <strlen>
	strcpy(dst + len, src);
  800a7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a82:	01 d8                	add    %ebx,%eax
  800a84:	89 04 24             	mov    %eax,(%esp)
  800a87:	e8 bf ff ff ff       	call   800a4b <strcpy>
	return dst;
}
  800a8c:	89 d8                	mov    %ebx,%eax
  800a8e:	83 c4 08             	add    $0x8,%esp
  800a91:	5b                   	pop    %ebx
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	74 16                	je     800abc <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa6:	01 f3                	add    %esi,%ebx
  800aa8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800aaa:	0f b6 02             	movzbl (%edx),%eax
  800aad:	88 01                	mov    %al,(%ecx)
  800aaf:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ab2:	80 3a 01             	cmpb   $0x1,(%edx)
  800ab5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab8:	39 d9                	cmp    %ebx,%ecx
  800aba:	75 ee                	jne    800aaa <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800abc:	89 f0                	mov    %esi,%eax
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800acb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ace:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad1:	89 f8                	mov    %edi,%eax
  800ad3:	85 f6                	test   %esi,%esi
  800ad5:	74 33                	je     800b0a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800ad7:	83 fe 01             	cmp    $0x1,%esi
  800ada:	74 25                	je     800b01 <strlcpy+0x3f>
  800adc:	0f b6 0b             	movzbl (%ebx),%ecx
  800adf:	84 c9                	test   %cl,%cl
  800ae1:	74 22                	je     800b05 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800ae3:	83 ee 02             	sub    $0x2,%esi
  800ae6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aeb:	88 08                	mov    %cl,(%eax)
  800aed:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af0:	39 f2                	cmp    %esi,%edx
  800af2:	74 13                	je     800b07 <strlcpy+0x45>
  800af4:	83 c2 01             	add    $0x1,%edx
  800af7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800afb:	84 c9                	test   %cl,%cl
  800afd:	75 ec                	jne    800aeb <strlcpy+0x29>
  800aff:	eb 06                	jmp    800b07 <strlcpy+0x45>
  800b01:	89 f8                	mov    %edi,%eax
  800b03:	eb 02                	jmp    800b07 <strlcpy+0x45>
  800b05:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b07:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b0a:	29 f8                	sub    %edi,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b17:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b1a:	0f b6 01             	movzbl (%ecx),%eax
  800b1d:	84 c0                	test   %al,%al
  800b1f:	74 15                	je     800b36 <strcmp+0x25>
  800b21:	3a 02                	cmp    (%edx),%al
  800b23:	75 11                	jne    800b36 <strcmp+0x25>
		p++, q++;
  800b25:	83 c1 01             	add    $0x1,%ecx
  800b28:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b2b:	0f b6 01             	movzbl (%ecx),%eax
  800b2e:	84 c0                	test   %al,%al
  800b30:	74 04                	je     800b36 <strcmp+0x25>
  800b32:	3a 02                	cmp    (%edx),%al
  800b34:	74 ef                	je     800b25 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b36:	0f b6 c0             	movzbl %al,%eax
  800b39:	0f b6 12             	movzbl (%edx),%edx
  800b3c:	29 d0                	sub    %edx,%eax
}
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b4e:	85 f6                	test   %esi,%esi
  800b50:	74 29                	je     800b7b <strncmp+0x3b>
  800b52:	0f b6 03             	movzbl (%ebx),%eax
  800b55:	84 c0                	test   %al,%al
  800b57:	74 30                	je     800b89 <strncmp+0x49>
  800b59:	3a 02                	cmp    (%edx),%al
  800b5b:	75 2c                	jne    800b89 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800b5d:	8d 43 01             	lea    0x1(%ebx),%eax
  800b60:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800b62:	89 c3                	mov    %eax,%ebx
  800b64:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b67:	39 f0                	cmp    %esi,%eax
  800b69:	74 17                	je     800b82 <strncmp+0x42>
  800b6b:	0f b6 08             	movzbl (%eax),%ecx
  800b6e:	84 c9                	test   %cl,%cl
  800b70:	74 17                	je     800b89 <strncmp+0x49>
  800b72:	83 c0 01             	add    $0x1,%eax
  800b75:	3a 0a                	cmp    (%edx),%cl
  800b77:	74 e9                	je     800b62 <strncmp+0x22>
  800b79:	eb 0e                	jmp    800b89 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b80:	eb 0f                	jmp    800b91 <strncmp+0x51>
  800b82:	b8 00 00 00 00       	mov    $0x0,%eax
  800b87:	eb 08                	jmp    800b91 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b89:	0f b6 03             	movzbl (%ebx),%eax
  800b8c:	0f b6 12             	movzbl (%edx),%edx
  800b8f:	29 d0                	sub    %edx,%eax
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	53                   	push   %ebx
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b9f:	0f b6 18             	movzbl (%eax),%ebx
  800ba2:	84 db                	test   %bl,%bl
  800ba4:	74 1d                	je     800bc3 <strchr+0x2e>
  800ba6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800ba8:	38 d3                	cmp    %dl,%bl
  800baa:	75 06                	jne    800bb2 <strchr+0x1d>
  800bac:	eb 1a                	jmp    800bc8 <strchr+0x33>
  800bae:	38 ca                	cmp    %cl,%dl
  800bb0:	74 16                	je     800bc8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bb2:	83 c0 01             	add    $0x1,%eax
  800bb5:	0f b6 10             	movzbl (%eax),%edx
  800bb8:	84 d2                	test   %dl,%dl
  800bba:	75 f2                	jne    800bae <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	eb 05                	jmp    800bc8 <strchr+0x33>
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bd5:	0f b6 18             	movzbl (%eax),%ebx
  800bd8:	84 db                	test   %bl,%bl
  800bda:	74 16                	je     800bf2 <strfind+0x27>
  800bdc:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800bde:	38 d3                	cmp    %dl,%bl
  800be0:	75 06                	jne    800be8 <strfind+0x1d>
  800be2:	eb 0e                	jmp    800bf2 <strfind+0x27>
  800be4:	38 ca                	cmp    %cl,%dl
  800be6:	74 0a                	je     800bf2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800be8:	83 c0 01             	add    $0x1,%eax
  800beb:	0f b6 10             	movzbl (%eax),%edx
  800bee:	84 d2                	test   %dl,%dl
  800bf0:	75 f2                	jne    800be4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800bf2:	5b                   	pop    %ebx
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 0c             	sub    $0xc,%esp
  800bfb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bfe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c01:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c04:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c0a:	85 c9                	test   %ecx,%ecx
  800c0c:	74 36                	je     800c44 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c0e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c14:	75 28                	jne    800c3e <memset+0x49>
  800c16:	f6 c1 03             	test   $0x3,%cl
  800c19:	75 23                	jne    800c3e <memset+0x49>
		c &= 0xFF;
  800c1b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c1f:	89 d3                	mov    %edx,%ebx
  800c21:	c1 e3 08             	shl    $0x8,%ebx
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	c1 e6 18             	shl    $0x18,%esi
  800c29:	89 d0                	mov    %edx,%eax
  800c2b:	c1 e0 10             	shl    $0x10,%eax
  800c2e:	09 f0                	or     %esi,%eax
  800c30:	09 c2                	or     %eax,%edx
  800c32:	89 d0                	mov    %edx,%eax
  800c34:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c36:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c39:	fc                   	cld    
  800c3a:	f3 ab                	rep stos %eax,%es:(%edi)
  800c3c:	eb 06                	jmp    800c44 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c41:	fc                   	cld    
  800c42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  800c44:	89 f8                	mov    %edi,%eax
  800c46:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c49:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c4c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c4f:	89 ec                	mov    %ebp,%esp
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	83 ec 08             	sub    $0x8,%esp
  800c59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c68:	39 c6                	cmp    %eax,%esi
  800c6a:	73 36                	jae    800ca2 <memmove+0x4f>
  800c6c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c6f:	39 d0                	cmp    %edx,%eax
  800c71:	73 2f                	jae    800ca2 <memmove+0x4f>
		s += n;
		d += n;
  800c73:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c76:	f6 c2 03             	test   $0x3,%dl
  800c79:	75 1b                	jne    800c96 <memmove+0x43>
  800c7b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c81:	75 13                	jne    800c96 <memmove+0x43>
  800c83:	f6 c1 03             	test   $0x3,%cl
  800c86:	75 0e                	jne    800c96 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c88:	83 ef 04             	sub    $0x4,%edi
  800c8b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c8e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c91:	fd                   	std    
  800c92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c94:	eb 09                	jmp    800c9f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c96:	83 ef 01             	sub    $0x1,%edi
  800c99:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c9c:	fd                   	std    
  800c9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c9f:	fc                   	cld    
  800ca0:	eb 20                	jmp    800cc2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ca8:	75 13                	jne    800cbd <memmove+0x6a>
  800caa:	a8 03                	test   $0x3,%al
  800cac:	75 0f                	jne    800cbd <memmove+0x6a>
  800cae:	f6 c1 03             	test   $0x3,%cl
  800cb1:	75 0a                	jne    800cbd <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cb3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cb6:	89 c7                	mov    %eax,%edi
  800cb8:	fc                   	cld    
  800cb9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cbb:	eb 05                	jmp    800cc2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cbd:	89 c7                	mov    %eax,%edi
  800cbf:	fc                   	cld    
  800cc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc8:	89 ec                	mov    %ebp,%esp
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cd2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce3:	89 04 24             	mov    %eax,(%esp)
  800ce6:	e8 68 ff ff ff       	call   800c53 <memmove>
}
  800ceb:	c9                   	leave  
  800cec:	c3                   	ret    

00800ced <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cf6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cfc:	8d 78 ff             	lea    -0x1(%eax),%edi
  800cff:	85 c0                	test   %eax,%eax
  800d01:	74 36                	je     800d39 <memcmp+0x4c>
		if (*s1 != *s2)
  800d03:	0f b6 03             	movzbl (%ebx),%eax
  800d06:	0f b6 0e             	movzbl (%esi),%ecx
  800d09:	38 c8                	cmp    %cl,%al
  800d0b:	75 17                	jne    800d24 <memcmp+0x37>
  800d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d12:	eb 1a                	jmp    800d2e <memcmp+0x41>
  800d14:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800d19:	83 c2 01             	add    $0x1,%edx
  800d1c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800d20:	38 c8                	cmp    %cl,%al
  800d22:	74 0a                	je     800d2e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800d24:	0f b6 c0             	movzbl %al,%eax
  800d27:	0f b6 c9             	movzbl %cl,%ecx
  800d2a:	29 c8                	sub    %ecx,%eax
  800d2c:	eb 10                	jmp    800d3e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d2e:	39 fa                	cmp    %edi,%edx
  800d30:	75 e2                	jne    800d14 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d32:	b8 00 00 00 00       	mov    $0x0,%eax
  800d37:	eb 05                	jmp    800d3e <memcmp+0x51>
  800d39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	53                   	push   %ebx
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800d4d:	89 c2                	mov    %eax,%edx
  800d4f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d52:	39 d0                	cmp    %edx,%eax
  800d54:	73 13                	jae    800d69 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d56:	89 d9                	mov    %ebx,%ecx
  800d58:	38 18                	cmp    %bl,(%eax)
  800d5a:	75 06                	jne    800d62 <memfind+0x1f>
  800d5c:	eb 0b                	jmp    800d69 <memfind+0x26>
  800d5e:	38 08                	cmp    %cl,(%eax)
  800d60:	74 07                	je     800d69 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d62:	83 c0 01             	add    $0x1,%eax
  800d65:	39 d0                	cmp    %edx,%eax
  800d67:	75 f5                	jne    800d5e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 04             	sub    $0x4,%esp
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d7b:	0f b6 02             	movzbl (%edx),%eax
  800d7e:	3c 09                	cmp    $0x9,%al
  800d80:	74 04                	je     800d86 <strtol+0x1a>
  800d82:	3c 20                	cmp    $0x20,%al
  800d84:	75 0e                	jne    800d94 <strtol+0x28>
		s++;
  800d86:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d89:	0f b6 02             	movzbl (%edx),%eax
  800d8c:	3c 09                	cmp    $0x9,%al
  800d8e:	74 f6                	je     800d86 <strtol+0x1a>
  800d90:	3c 20                	cmp    $0x20,%al
  800d92:	74 f2                	je     800d86 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d94:	3c 2b                	cmp    $0x2b,%al
  800d96:	75 0a                	jne    800da2 <strtol+0x36>
		s++;
  800d98:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d9b:	bf 00 00 00 00       	mov    $0x0,%edi
  800da0:	eb 10                	jmp    800db2 <strtol+0x46>
  800da2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800da7:	3c 2d                	cmp    $0x2d,%al
  800da9:	75 07                	jne    800db2 <strtol+0x46>
		s++, neg = 1;
  800dab:	83 c2 01             	add    $0x1,%edx
  800dae:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800db2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800db8:	75 15                	jne    800dcf <strtol+0x63>
  800dba:	80 3a 30             	cmpb   $0x30,(%edx)
  800dbd:	75 10                	jne    800dcf <strtol+0x63>
  800dbf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dc3:	75 0a                	jne    800dcf <strtol+0x63>
		s += 2, base = 16;
  800dc5:	83 c2 02             	add    $0x2,%edx
  800dc8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dcd:	eb 10                	jmp    800ddf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800dcf:	85 db                	test   %ebx,%ebx
  800dd1:	75 0c                	jne    800ddf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dd3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dd5:	80 3a 30             	cmpb   $0x30,(%edx)
  800dd8:	75 05                	jne    800ddf <strtol+0x73>
		s++, base = 8;
  800dda:	83 c2 01             	add    $0x1,%edx
  800ddd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ddf:	b8 00 00 00 00       	mov    $0x0,%eax
  800de4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800de7:	0f b6 0a             	movzbl (%edx),%ecx
  800dea:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ded:	89 f3                	mov    %esi,%ebx
  800def:	80 fb 09             	cmp    $0x9,%bl
  800df2:	77 08                	ja     800dfc <strtol+0x90>
			dig = *s - '0';
  800df4:	0f be c9             	movsbl %cl,%ecx
  800df7:	83 e9 30             	sub    $0x30,%ecx
  800dfa:	eb 22                	jmp    800e1e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800dfc:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800dff:	89 f3                	mov    %esi,%ebx
  800e01:	80 fb 19             	cmp    $0x19,%bl
  800e04:	77 08                	ja     800e0e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800e06:	0f be c9             	movsbl %cl,%ecx
  800e09:	83 e9 57             	sub    $0x57,%ecx
  800e0c:	eb 10                	jmp    800e1e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800e0e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e11:	89 f3                	mov    %esi,%ebx
  800e13:	80 fb 19             	cmp    $0x19,%bl
  800e16:	77 16                	ja     800e2e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800e18:	0f be c9             	movsbl %cl,%ecx
  800e1b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e1e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800e21:	7d 0f                	jge    800e32 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800e23:	83 c2 01             	add    $0x1,%edx
  800e26:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800e2a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e2c:	eb b9                	jmp    800de7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e2e:	89 c1                	mov    %eax,%ecx
  800e30:	eb 02                	jmp    800e34 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e32:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e38:	74 05                	je     800e3f <strtol+0xd3>
		*endptr = (char *) s;
  800e3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e3d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e3f:	89 ca                	mov    %ecx,%edx
  800e41:	f7 da                	neg    %edx
  800e43:	85 ff                	test   %edi,%edi
  800e45:	0f 45 c2             	cmovne %edx,%eax
}
  800e48:	83 c4 04             	add    $0x4,%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800e5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e64:	0f a2                	cpuid  
  800e66:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e68:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	89 c3                	mov    %eax,%ebx
  800e75:	89 c7                	mov    %eax,%edi
  800e77:	89 c6                	mov    %eax,%esi
  800e79:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e7b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e7e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e81:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e84:	89 ec                	mov    %ebp,%esp
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	83 ec 0c             	sub    $0xc,%esp
  800e8e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e91:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e94:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e97:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9c:	0f a2                	cpuid  
  800e9e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea5:	b8 01 00 00 00       	mov    $0x1,%eax
  800eaa:	89 d1                	mov    %edx,%ecx
  800eac:	89 d3                	mov    %edx,%ebx
  800eae:	89 d7                	mov    %edx,%edi
  800eb0:	89 d6                	mov    %edx,%esi
  800eb2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800eb4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eba:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ebd:	89 ec                	mov    %ebp,%esp
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800ed9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ede:	b8 03 00 00 00       	mov    $0x3,%eax
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	89 cb                	mov    %ecx,%ebx
  800ee8:	89 cf                	mov    %ecx,%edi
  800eea:	89 ce                	mov    %ecx,%esi
  800eec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	7e 28                	jle    800f1a <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800efd:	00 
  800efe:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800f05:	00 
  800f06:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f0d:	00 
  800f0e:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800f15:	e8 b2 f3 ff ff       	call   8002cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f1a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f1d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f20:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f23:	89 ec                	mov    %ebp,%esp
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 0c             	sub    $0xc,%esp
  800f2d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f30:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f33:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f36:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3b:	0f a2                	cpuid  
  800f3d:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f44:	b8 02 00 00 00       	mov    $0x2,%eax
  800f49:	89 d1                	mov    %edx,%ecx
  800f4b:	89 d3                	mov    %edx,%ebx
  800f4d:	89 d7                	mov    %edx,%edi
  800f4f:	89 d6                	mov    %edx,%esi
  800f51:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f53:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f56:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f59:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f5c:	89 ec                	mov    %ebp,%esp
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <sys_yield>:

void
sys_yield(void)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 0c             	sub    $0xc,%esp
  800f66:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f69:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f6c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f6f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f74:	0f a2                	cpuid  
  800f76:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f78:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f82:	89 d1                	mov    %edx,%ecx
  800f84:	89 d3                	mov    %edx,%ebx
  800f86:	89 d7                	mov    %edx,%edi
  800f88:	89 d6                	mov    %edx,%esi
  800f8a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f8c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f8f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f92:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f95:	89 ec                	mov    %ebp,%esp
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	83 ec 38             	sub    $0x38,%esp
  800f9f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fa5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fa8:	b8 01 00 00 00       	mov    $0x1,%eax
  800fad:	0f a2                	cpuid  
  800faf:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb1:	be 00 00 00 00       	mov    $0x0,%esi
  800fb6:	b8 04 00 00 00       	mov    $0x4,%eax
  800fbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc4:	89 f7                	mov    %esi,%edi
  800fc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	7e 28                	jle    800ff4 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fd7:	00 
  800fd8:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800fdf:	00 
  800fe0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fe7:	00 
  800fe8:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800fef:	e8 d8 f2 ff ff       	call   8002cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ff4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ffa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ffd:	89 ec                	mov    %ebp,%esp
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	83 ec 38             	sub    $0x38,%esp
  801007:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80100a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80100d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801010:	b8 01 00 00 00       	mov    $0x1,%eax
  801015:	0f a2                	cpuid  
  801017:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801019:	b8 05 00 00 00       	mov    $0x5,%eax
  80101e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801021:	8b 55 08             	mov    0x8(%ebp),%edx
  801024:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801027:	8b 7d 14             	mov    0x14(%ebp),%edi
  80102a:	8b 75 18             	mov    0x18(%ebp),%esi
  80102d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102f:	85 c0                	test   %eax,%eax
  801031:	7e 28                	jle    80105b <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801033:	89 44 24 10          	mov    %eax,0x10(%esp)
  801037:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80103e:	00 
  80103f:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  801046:	00 
  801047:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80104e:	00 
  80104f:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  801056:	e8 71 f2 ff ff       	call   8002cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80105b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80105e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801061:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801064:	89 ec                	mov    %ebp,%esp
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    

00801068 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 38             	sub    $0x38,%esp
  80106e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801071:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801074:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801077:	b8 01 00 00 00       	mov    $0x1,%eax
  80107c:	0f a2                	cpuid  
  80107e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801080:	bb 00 00 00 00       	mov    $0x0,%ebx
  801085:	b8 06 00 00 00       	mov    $0x6,%eax
  80108a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108d:	8b 55 08             	mov    0x8(%ebp),%edx
  801090:	89 df                	mov    %ebx,%edi
  801092:	89 de                	mov    %ebx,%esi
  801094:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801096:	85 c0                	test   %eax,%eax
  801098:	7e 28                	jle    8010c2 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80109e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8010a5:	00 
  8010a6:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  8010ad:	00 
  8010ae:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8010b5:	00 
  8010b6:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  8010bd:	e8 0a f2 ff ff       	call   8002cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010cb:	89 ec                	mov    %ebp,%esp
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	83 ec 38             	sub    $0x38,%esp
  8010d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010db:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010de:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e3:	0f a2                	cpuid  
  8010e5:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ec:	b8 08 00 00 00       	mov    $0x8,%eax
  8010f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f7:	89 df                	mov    %ebx,%edi
  8010f9:	89 de                	mov    %ebx,%esi
  8010fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	7e 28                	jle    801129 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801101:	89 44 24 10          	mov    %eax,0x10(%esp)
  801105:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80110c:	00 
  80110d:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  801114:	00 
  801115:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80111c:	00 
  80111d:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  801124:	e8 a3 f1 ff ff       	call   8002cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801129:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80112c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80112f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801132:	89 ec                	mov    %ebp,%esp
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 38             	sub    $0x38,%esp
  80113c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80113f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801142:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801145:	b8 01 00 00 00       	mov    $0x1,%eax
  80114a:	0f a2                	cpuid  
  80114c:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801153:	b8 09 00 00 00       	mov    $0x9,%eax
  801158:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115b:	8b 55 08             	mov    0x8(%ebp),%edx
  80115e:	89 df                	mov    %ebx,%edi
  801160:	89 de                	mov    %ebx,%esi
  801162:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801164:	85 c0                	test   %eax,%eax
  801166:	7e 28                	jle    801190 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801168:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801173:	00 
  801174:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  80117b:	00 
  80117c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801183:	00 
  801184:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  80118b:	e8 3c f1 ff ff       	call   8002cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801190:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801193:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801196:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801199:	89 ec                	mov    %ebp,%esp
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	83 ec 38             	sub    $0x38,%esp
  8011a3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011a6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011a9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8011ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8011b1:	0f a2                	cpuid  
  8011b3:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c5:	89 df                	mov    %ebx,%edi
  8011c7:	89 de                	mov    %ebx,%esi
  8011c9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	7e 28                	jle    8011f7 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011d3:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011da:	00 
  8011db:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  8011e2:	00 
  8011e3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8011ea:	00 
  8011eb:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  8011f2:	e8 d5 f0 ff ff       	call   8002cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011f7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011fa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011fd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801200:	89 ec                	mov    %ebp,%esp
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80120d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801210:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801213:	b8 01 00 00 00       	mov    $0x1,%eax
  801218:	0f a2                	cpuid  
  80121a:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80121c:	be 00 00 00 00       	mov    $0x0,%esi
  801221:	b8 0c 00 00 00       	mov    $0xc,%eax
  801226:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801229:	8b 55 08             	mov    0x8(%ebp),%edx
  80122c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80122f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801232:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801234:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801237:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80123a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80123d:	89 ec                	mov    %ebp,%esp
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	83 ec 38             	sub    $0x38,%esp
  801247:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80124a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80124d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801250:	b8 01 00 00 00       	mov    $0x1,%eax
  801255:	0f a2                	cpuid  
  801257:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801259:	b9 00 00 00 00       	mov    $0x0,%ecx
  80125e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801263:	8b 55 08             	mov    0x8(%ebp),%edx
  801266:	89 cb                	mov    %ecx,%ebx
  801268:	89 cf                	mov    %ecx,%edi
  80126a:	89 ce                	mov    %ecx,%esi
  80126c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80126e:	85 c0                	test   %eax,%eax
  801270:	7e 28                	jle    80129a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801272:	89 44 24 10          	mov    %eax,0x10(%esp)
  801276:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80127d:	00 
  80127e:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  801285:	00 
  801286:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80128d:	00 
  80128e:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  801295:	e8 32 f0 ff ff       	call   8002cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80129a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80129d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012a0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012a3:	89 ec                	mov    %ebp,%esp
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    
  8012a7:	66 90                	xchg   %ax,%ax
  8012a9:	66 90                	xchg   %ax,%ax
  8012ab:	66 90                	xchg   %ax,%ax
  8012ad:	66 90                	xchg   %ax,%ax
  8012af:	90                   	nop

008012b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012bb:	c1 e8 0c             	shr    $0xc,%eax
}
  8012be:	5d                   	pop    %ebp
  8012bf:	c3                   	ret    

008012c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8012c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c9:	89 04 24             	mov    %eax,(%esp)
  8012cc:	e8 df ff ff ff       	call   8012b0 <fd2num>
  8012d1:	c1 e0 0c             	shl    $0xc,%eax
  8012d4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012d9:	c9                   	leave  
  8012da:	c3                   	ret    

008012db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8012de:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8012e3:	a8 01                	test   $0x1,%al
  8012e5:	74 34                	je     80131b <fd_alloc+0x40>
  8012e7:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8012ec:	a8 01                	test   $0x1,%al
  8012ee:	74 32                	je     801322 <fd_alloc+0x47>
  8012f0:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012f5:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8012f7:	89 c2                	mov    %eax,%edx
  8012f9:	c1 ea 16             	shr    $0x16,%edx
  8012fc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801303:	f6 c2 01             	test   $0x1,%dl
  801306:	74 1f                	je     801327 <fd_alloc+0x4c>
  801308:	89 c2                	mov    %eax,%edx
  80130a:	c1 ea 0c             	shr    $0xc,%edx
  80130d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801314:	f6 c2 01             	test   $0x1,%dl
  801317:	75 1a                	jne    801333 <fd_alloc+0x58>
  801319:	eb 0c                	jmp    801327 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80131b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801320:	eb 05                	jmp    801327 <fd_alloc+0x4c>
  801322:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801327:	8b 45 08             	mov    0x8(%ebp),%eax
  80132a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80132c:	b8 00 00 00 00       	mov    $0x0,%eax
  801331:	eb 1a                	jmp    80134d <fd_alloc+0x72>
  801333:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801338:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80133d:	75 b6                	jne    8012f5 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80133f:	8b 45 08             	mov    0x8(%ebp),%eax
  801342:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801348:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80134d:	5d                   	pop    %ebp
  80134e:	c3                   	ret    

0080134f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801355:	83 f8 1f             	cmp    $0x1f,%eax
  801358:	77 36                	ja     801390 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80135a:	c1 e0 0c             	shl    $0xc,%eax
  80135d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801362:	89 c2                	mov    %eax,%edx
  801364:	c1 ea 16             	shr    $0x16,%edx
  801367:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80136e:	f6 c2 01             	test   $0x1,%dl
  801371:	74 24                	je     801397 <fd_lookup+0x48>
  801373:	89 c2                	mov    %eax,%edx
  801375:	c1 ea 0c             	shr    $0xc,%edx
  801378:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80137f:	f6 c2 01             	test   $0x1,%dl
  801382:	74 1a                	je     80139e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801384:	8b 55 0c             	mov    0xc(%ebp),%edx
  801387:	89 02                	mov    %eax,(%edx)
	return 0;
  801389:	b8 00 00 00 00       	mov    $0x0,%eax
  80138e:	eb 13                	jmp    8013a3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801390:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801395:	eb 0c                	jmp    8013a3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801397:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139c:	eb 05                	jmp    8013a3 <fd_lookup+0x54>
  80139e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    

008013a5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	83 ec 18             	sub    $0x18,%esp
  8013ab:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8013ae:	39 05 04 30 80 00    	cmp    %eax,0x803004
  8013b4:	75 10                	jne    8013c6 <dev_lookup+0x21>
			*dev = devtab[i];
  8013b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b9:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  8013bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c4:	eb 2b                	jmp    8013f1 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013c6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8013cc:	8b 52 48             	mov    0x48(%edx),%edx
  8013cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013d7:	c7 04 24 8c 22 80 00 	movl   $0x80228c,(%esp)
  8013de:	e8 e4 ef ff ff       	call   8003c7 <cprintf>
	*dev = 0;
  8013e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e6:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  8013ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013f1:	c9                   	leave  
  8013f2:	c3                   	ret    

008013f3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	83 ec 38             	sub    $0x38,%esp
  8013f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801402:	8b 7d 08             	mov    0x8(%ebp),%edi
  801405:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801408:	89 3c 24             	mov    %edi,(%esp)
  80140b:	e8 a0 fe ff ff       	call   8012b0 <fd2num>
  801410:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801413:	89 54 24 04          	mov    %edx,0x4(%esp)
  801417:	89 04 24             	mov    %eax,(%esp)
  80141a:	e8 30 ff ff ff       	call   80134f <fd_lookup>
  80141f:	89 c3                	mov    %eax,%ebx
  801421:	85 c0                	test   %eax,%eax
  801423:	78 05                	js     80142a <fd_close+0x37>
	    || fd != fd2)
  801425:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801428:	74 0c                	je     801436 <fd_close+0x43>
		return (must_exist ? r : 0);
  80142a:	85 f6                	test   %esi,%esi
  80142c:	b8 00 00 00 00       	mov    $0x0,%eax
  801431:	0f 44 d8             	cmove  %eax,%ebx
  801434:	eb 3d                	jmp    801473 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801436:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143d:	8b 07                	mov    (%edi),%eax
  80143f:	89 04 24             	mov    %eax,(%esp)
  801442:	e8 5e ff ff ff       	call   8013a5 <dev_lookup>
  801447:	89 c3                	mov    %eax,%ebx
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 16                	js     801463 <fd_close+0x70>
		if (dev->dev_close)
  80144d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801450:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801453:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801458:	85 c0                	test   %eax,%eax
  80145a:	74 07                	je     801463 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80145c:	89 3c 24             	mov    %edi,(%esp)
  80145f:	ff d0                	call   *%eax
  801461:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801463:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801467:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80146e:	e8 f5 fb ff ff       	call   801068 <sys_page_unmap>
	return r;
}
  801473:	89 d8                	mov    %ebx,%eax
  801475:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801478:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80147b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80147e:	89 ec                	mov    %ebp,%esp
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    

00801482 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148f:	8b 45 08             	mov    0x8(%ebp),%eax
  801492:	89 04 24             	mov    %eax,(%esp)
  801495:	e8 b5 fe ff ff       	call   80134f <fd_lookup>
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 13                	js     8014b1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80149e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014a5:	00 
  8014a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a9:	89 04 24             	mov    %eax,(%esp)
  8014ac:	e8 42 ff ff ff       	call   8013f3 <fd_close>
}
  8014b1:	c9                   	leave  
  8014b2:	c3                   	ret    

008014b3 <close_all>:

void
close_all(void)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	53                   	push   %ebx
  8014b7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014bf:	89 1c 24             	mov    %ebx,(%esp)
  8014c2:	e8 bb ff ff ff       	call   801482 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014c7:	83 c3 01             	add    $0x1,%ebx
  8014ca:	83 fb 20             	cmp    $0x20,%ebx
  8014cd:	75 f0                	jne    8014bf <close_all+0xc>
		close(i);
}
  8014cf:	83 c4 14             	add    $0x14,%esp
  8014d2:	5b                   	pop    %ebx
  8014d3:	5d                   	pop    %ebp
  8014d4:	c3                   	ret    

008014d5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014d5:	55                   	push   %ebp
  8014d6:	89 e5                	mov    %esp,%ebp
  8014d8:	83 ec 58             	sub    $0x58,%esp
  8014db:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014de:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014e1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f1:	89 04 24             	mov    %eax,(%esp)
  8014f4:	e8 56 fe ff ff       	call   80134f <fd_lookup>
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	0f 88 e3 00 00 00    	js     8015e4 <dup+0x10f>
		return r;
	close(newfdnum);
  801501:	89 1c 24             	mov    %ebx,(%esp)
  801504:	e8 79 ff ff ff       	call   801482 <close>

	newfd = INDEX2FD(newfdnum);
  801509:	89 de                	mov    %ebx,%esi
  80150b:	c1 e6 0c             	shl    $0xc,%esi
  80150e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801514:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801517:	89 04 24             	mov    %eax,(%esp)
  80151a:	e8 a1 fd ff ff       	call   8012c0 <fd2data>
  80151f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801521:	89 34 24             	mov    %esi,(%esp)
  801524:	e8 97 fd ff ff       	call   8012c0 <fd2data>
  801529:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80152c:	89 f8                	mov    %edi,%eax
  80152e:	c1 e8 16             	shr    $0x16,%eax
  801531:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801538:	a8 01                	test   $0x1,%al
  80153a:	74 46                	je     801582 <dup+0xad>
  80153c:	89 f8                	mov    %edi,%eax
  80153e:	c1 e8 0c             	shr    $0xc,%eax
  801541:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801548:	f6 c2 01             	test   $0x1,%dl
  80154b:	74 35                	je     801582 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80154d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801554:	25 07 0e 00 00       	and    $0xe07,%eax
  801559:	89 44 24 10          	mov    %eax,0x10(%esp)
  80155d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801560:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801564:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80156b:	00 
  80156c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801577:	e8 85 fa ff ff       	call   801001 <sys_page_map>
  80157c:	89 c7                	mov    %eax,%edi
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 3b                	js     8015bd <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801582:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801585:	89 c2                	mov    %eax,%edx
  801587:	c1 ea 0c             	shr    $0xc,%edx
  80158a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801591:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801597:	89 54 24 10          	mov    %edx,0x10(%esp)
  80159b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80159f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015a6:	00 
  8015a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b2:	e8 4a fa ff ff       	call   801001 <sys_page_map>
  8015b7:	89 c7                	mov    %eax,%edi
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	79 29                	jns    8015e6 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c8:	e8 9b fa ff ff       	call   801068 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015db:	e8 88 fa ff ff       	call   801068 <sys_page_unmap>
	return r;
  8015e0:	89 fb                	mov    %edi,%ebx
  8015e2:	eb 02                	jmp    8015e6 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  8015e4:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015e6:	89 d8                	mov    %ebx,%eax
  8015e8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015eb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015ee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015f1:	89 ec                	mov    %ebp,%esp
  8015f3:	5d                   	pop    %ebp
  8015f4:	c3                   	ret    

008015f5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 24             	sub    $0x24,%esp
  8015fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801602:	89 44 24 04          	mov    %eax,0x4(%esp)
  801606:	89 1c 24             	mov    %ebx,(%esp)
  801609:	e8 41 fd ff ff       	call   80134f <fd_lookup>
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 6d                	js     80167f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801612:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801615:	89 44 24 04          	mov    %eax,0x4(%esp)
  801619:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161c:	8b 00                	mov    (%eax),%eax
  80161e:	89 04 24             	mov    %eax,(%esp)
  801621:	e8 7f fd ff ff       	call   8013a5 <dev_lookup>
  801626:	85 c0                	test   %eax,%eax
  801628:	78 55                	js     80167f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80162a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162d:	8b 50 08             	mov    0x8(%eax),%edx
  801630:	83 e2 03             	and    $0x3,%edx
  801633:	83 fa 01             	cmp    $0x1,%edx
  801636:	75 23                	jne    80165b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801638:	a1 04 40 80 00       	mov    0x804004,%eax
  80163d:	8b 40 48             	mov    0x48(%eax),%eax
  801640:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801644:	89 44 24 04          	mov    %eax,0x4(%esp)
  801648:	c7 04 24 d0 22 80 00 	movl   $0x8022d0,(%esp)
  80164f:	e8 73 ed ff ff       	call   8003c7 <cprintf>
		return -E_INVAL;
  801654:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801659:	eb 24                	jmp    80167f <read+0x8a>
	}
	if (!dev->dev_read)
  80165b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165e:	8b 52 08             	mov    0x8(%edx),%edx
  801661:	85 d2                	test   %edx,%edx
  801663:	74 15                	je     80167a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801665:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801668:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80166c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80166f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801673:	89 04 24             	mov    %eax,(%esp)
  801676:	ff d2                	call   *%edx
  801678:	eb 05                	jmp    80167f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80167a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80167f:	83 c4 24             	add    $0x24,%esp
  801682:	5b                   	pop    %ebx
  801683:	5d                   	pop    %ebp
  801684:	c3                   	ret    

00801685 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	57                   	push   %edi
  801689:	56                   	push   %esi
  80168a:	53                   	push   %ebx
  80168b:	83 ec 1c             	sub    $0x1c,%esp
  80168e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801691:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801694:	85 f6                	test   %esi,%esi
  801696:	74 33                	je     8016cb <readn+0x46>
  801698:	b8 00 00 00 00       	mov    $0x0,%eax
  80169d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016a2:	89 f2                	mov    %esi,%edx
  8016a4:	29 c2                	sub    %eax,%edx
  8016a6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016aa:	03 45 0c             	add    0xc(%ebp),%eax
  8016ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b1:	89 3c 24             	mov    %edi,(%esp)
  8016b4:	e8 3c ff ff ff       	call   8015f5 <read>
		if (m < 0)
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 17                	js     8016d4 <readn+0x4f>
			return m;
		if (m == 0)
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	74 11                	je     8016d2 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016c1:	01 c3                	add    %eax,%ebx
  8016c3:	89 d8                	mov    %ebx,%eax
  8016c5:	39 f3                	cmp    %esi,%ebx
  8016c7:	72 d9                	jb     8016a2 <readn+0x1d>
  8016c9:	eb 09                	jmp    8016d4 <readn+0x4f>
  8016cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d0:	eb 02                	jmp    8016d4 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8016d2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016d4:	83 c4 1c             	add    $0x1c,%esp
  8016d7:	5b                   	pop    %ebx
  8016d8:	5e                   	pop    %esi
  8016d9:	5f                   	pop    %edi
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	53                   	push   %ebx
  8016e0:	83 ec 24             	sub    $0x24,%esp
  8016e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ed:	89 1c 24             	mov    %ebx,(%esp)
  8016f0:	e8 5a fc ff ff       	call   80134f <fd_lookup>
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 68                	js     801761 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801700:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801703:	8b 00                	mov    (%eax),%eax
  801705:	89 04 24             	mov    %eax,(%esp)
  801708:	e8 98 fc ff ff       	call   8013a5 <dev_lookup>
  80170d:	85 c0                	test   %eax,%eax
  80170f:	78 50                	js     801761 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801711:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801714:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801718:	75 23                	jne    80173d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80171a:	a1 04 40 80 00       	mov    0x804004,%eax
  80171f:	8b 40 48             	mov    0x48(%eax),%eax
  801722:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801726:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172a:	c7 04 24 ec 22 80 00 	movl   $0x8022ec,(%esp)
  801731:	e8 91 ec ff ff       	call   8003c7 <cprintf>
		return -E_INVAL;
  801736:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80173b:	eb 24                	jmp    801761 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80173d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801740:	8b 52 0c             	mov    0xc(%edx),%edx
  801743:	85 d2                	test   %edx,%edx
  801745:	74 15                	je     80175c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801747:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80174a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80174e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801751:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801755:	89 04 24             	mov    %eax,(%esp)
  801758:	ff d2                	call   *%edx
  80175a:	eb 05                	jmp    801761 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80175c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801761:	83 c4 24             	add    $0x24,%esp
  801764:	5b                   	pop    %ebx
  801765:	5d                   	pop    %ebp
  801766:	c3                   	ret    

00801767 <seek>:

int
seek(int fdnum, off_t offset)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80176d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801770:	89 44 24 04          	mov    %eax,0x4(%esp)
  801774:	8b 45 08             	mov    0x8(%ebp),%eax
  801777:	89 04 24             	mov    %eax,(%esp)
  80177a:	e8 d0 fb ff ff       	call   80134f <fd_lookup>
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 0e                	js     801791 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801783:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801786:	8b 55 0c             	mov    0xc(%ebp),%edx
  801789:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80178c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	53                   	push   %ebx
  801797:	83 ec 24             	sub    $0x24,%esp
  80179a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a4:	89 1c 24             	mov    %ebx,(%esp)
  8017a7:	e8 a3 fb ff ff       	call   80134f <fd_lookup>
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 61                	js     801811 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ba:	8b 00                	mov    (%eax),%eax
  8017bc:	89 04 24             	mov    %eax,(%esp)
  8017bf:	e8 e1 fb ff ff       	call   8013a5 <dev_lookup>
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	78 49                	js     801811 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017cf:	75 23                	jne    8017f4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017d1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017d6:	8b 40 48             	mov    0x48(%eax),%eax
  8017d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e1:	c7 04 24 ac 22 80 00 	movl   $0x8022ac,(%esp)
  8017e8:	e8 da eb ff ff       	call   8003c7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017f2:	eb 1d                	jmp    801811 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8017f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f7:	8b 52 18             	mov    0x18(%edx),%edx
  8017fa:	85 d2                	test   %edx,%edx
  8017fc:	74 0e                	je     80180c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801801:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801805:	89 04 24             	mov    %eax,(%esp)
  801808:	ff d2                	call   *%edx
  80180a:	eb 05                	jmp    801811 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80180c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801811:	83 c4 24             	add    $0x24,%esp
  801814:	5b                   	pop    %ebx
  801815:	5d                   	pop    %ebp
  801816:	c3                   	ret    

00801817 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	53                   	push   %ebx
  80181b:	83 ec 24             	sub    $0x24,%esp
  80181e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801821:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801824:	89 44 24 04          	mov    %eax,0x4(%esp)
  801828:	8b 45 08             	mov    0x8(%ebp),%eax
  80182b:	89 04 24             	mov    %eax,(%esp)
  80182e:	e8 1c fb ff ff       	call   80134f <fd_lookup>
  801833:	85 c0                	test   %eax,%eax
  801835:	78 52                	js     801889 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801837:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801841:	8b 00                	mov    (%eax),%eax
  801843:	89 04 24             	mov    %eax,(%esp)
  801846:	e8 5a fb ff ff       	call   8013a5 <dev_lookup>
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 3a                	js     801889 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80184f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801852:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801856:	74 2c                	je     801884 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801858:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80185b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801862:	00 00 00 
	stat->st_isdir = 0;
  801865:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80186c:	00 00 00 
	stat->st_dev = dev;
  80186f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801875:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801879:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80187c:	89 14 24             	mov    %edx,(%esp)
  80187f:	ff 50 14             	call   *0x14(%eax)
  801882:	eb 05                	jmp    801889 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801884:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801889:	83 c4 24             	add    $0x24,%esp
  80188c:	5b                   	pop    %ebx
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    

0080188f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	83 ec 18             	sub    $0x18,%esp
  801895:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801898:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80189b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018a2:	00 
  8018a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a6:	89 04 24             	mov    %eax,(%esp)
  8018a9:	e8 84 01 00 00       	call   801a32 <open>
  8018ae:	89 c3                	mov    %eax,%ebx
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	78 1b                	js     8018cf <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8018b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bb:	89 1c 24             	mov    %ebx,(%esp)
  8018be:	e8 54 ff ff ff       	call   801817 <fstat>
  8018c3:	89 c6                	mov    %eax,%esi
	close(fd);
  8018c5:	89 1c 24             	mov    %ebx,(%esp)
  8018c8:	e8 b5 fb ff ff       	call   801482 <close>
	return r;
  8018cd:	89 f3                	mov    %esi,%ebx
}
  8018cf:	89 d8                	mov    %ebx,%eax
  8018d1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018d4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018d7:	89 ec                	mov    %ebp,%esp
  8018d9:	5d                   	pop    %ebp
  8018da:	c3                   	ret    
  8018db:	90                   	nop

008018dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	83 ec 18             	sub    $0x18,%esp
  8018e2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018e5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8018e8:	89 c6                	mov    %eax,%esi
  8018ea:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018ec:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018f3:	75 11                	jne    801906 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018f5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8018fc:	e8 72 02 00 00       	call   801b73 <ipc_find_env>
  801901:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801906:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80190d:	00 
  80190e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801915:	00 
  801916:	89 74 24 04          	mov    %esi,0x4(%esp)
  80191a:	a1 00 40 80 00       	mov    0x804000,%eax
  80191f:	89 04 24             	mov    %eax,(%esp)
  801922:	e8 e1 01 00 00       	call   801b08 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801927:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80192e:	00 
  80192f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801933:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80193a:	e8 71 01 00 00       	call   801ab0 <ipc_recv>
}
  80193f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801942:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801945:	89 ec                	mov    %ebp,%esp
  801947:	5d                   	pop    %ebp
  801948:	c3                   	ret    

00801949 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80194f:	8b 45 08             	mov    0x8(%ebp),%eax
  801952:	8b 40 0c             	mov    0xc(%eax),%eax
  801955:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80195a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801962:	ba 00 00 00 00       	mov    $0x0,%edx
  801967:	b8 02 00 00 00       	mov    $0x2,%eax
  80196c:	e8 6b ff ff ff       	call   8018dc <fsipc>
}
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801979:	8b 45 08             	mov    0x8(%ebp),%eax
  80197c:	8b 40 0c             	mov    0xc(%eax),%eax
  80197f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801984:	ba 00 00 00 00       	mov    $0x0,%edx
  801989:	b8 06 00 00 00       	mov    $0x6,%eax
  80198e:	e8 49 ff ff ff       	call   8018dc <fsipc>
}
  801993:	c9                   	leave  
  801994:	c3                   	ret    

00801995 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	53                   	push   %ebx
  801999:	83 ec 14             	sub    $0x14,%esp
  80199c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80199f:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8019af:	b8 05 00 00 00       	mov    $0x5,%eax
  8019b4:	e8 23 ff ff ff       	call   8018dc <fsipc>
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	78 2b                	js     8019e8 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019bd:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019c4:	00 
  8019c5:	89 1c 24             	mov    %ebx,(%esp)
  8019c8:	e8 7e f0 ff ff       	call   800a4b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019cd:	a1 80 50 80 00       	mov    0x805080,%eax
  8019d2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019d8:	a1 84 50 80 00       	mov    0x805084,%eax
  8019dd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019e8:	83 c4 14             	add    $0x14,%esp
  8019eb:	5b                   	pop    %ebx
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8019f4:	c7 44 24 08 09 23 80 	movl   $0x802309,0x8(%esp)
  8019fb:	00 
  8019fc:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  801a03:	00 
  801a04:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  801a0b:	e8 bc e8 ff ff       	call   8002cc <_panic>

00801a10 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  801a16:	c7 44 24 08 32 23 80 	movl   $0x802332,0x8(%esp)
  801a1d:	00 
  801a1e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801a25:	00 
  801a26:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  801a2d:	e8 9a e8 ff ff       	call   8002cc <_panic>

00801a32 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801a38:	c7 44 24 08 4f 23 80 	movl   $0x80234f,0x8(%esp)
  801a3f:	00 
  801a40:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801a47:	00 
  801a48:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  801a4f:	e8 78 e8 ff ff       	call   8002cc <_panic>

00801a54 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	53                   	push   %ebx
  801a58:	83 ec 14             	sub    $0x14,%esp
  801a5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801a5e:	89 1c 24             	mov    %ebx,(%esp)
  801a61:	e8 8a ef ff ff       	call   8009f0 <strlen>
  801a66:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a6b:	7f 21                	jg     801a8e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801a6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a71:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a78:	e8 ce ef ff ff       	call   800a4b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a82:	b8 07 00 00 00       	mov    $0x7,%eax
  801a87:	e8 50 fe ff ff       	call   8018dc <fsipc>
  801a8c:	eb 05                	jmp    801a93 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a8e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801a93:	83 c4 14             	add    $0x14,%esp
  801a96:	5b                   	pop    %ebx
  801a97:	5d                   	pop    %ebp
  801a98:	c3                   	ret    

00801a99 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa4:	b8 08 00 00 00       	mov    $0x8,%eax
  801aa9:	e8 2e fe ff ff       	call   8018dc <fsipc>
}
  801aae:	c9                   	leave  
  801aaf:	c3                   	ret    

00801ab0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	56                   	push   %esi
  801ab4:	53                   	push   %ebx
  801ab5:	83 ec 10             	sub    $0x10,%esp
  801ab8:	8b 75 08             	mov    0x8(%ebp),%esi
  801abb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  801abe:	85 db                	test   %ebx,%ebx
  801ac0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ac5:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  801ac8:	89 1c 24             	mov    %ebx,(%esp)
  801acb:	e8 71 f7 ff ff       	call   801241 <sys_ipc_recv>
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	78 2d                	js     801b01 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  801ad4:	85 f6                	test   %esi,%esi
  801ad6:	74 0a                	je     801ae2 <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  801ad8:	a1 04 40 80 00       	mov    0x804004,%eax
  801add:	8b 40 74             	mov    0x74(%eax),%eax
  801ae0:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  801ae2:	85 db                	test   %ebx,%ebx
  801ae4:	74 13                	je     801af9 <ipc_recv+0x49>
  801ae6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aea:	74 0d                	je     801af9 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  801aec:	a1 04 40 80 00       	mov    0x804004,%eax
  801af1:	8b 40 78             	mov    0x78(%eax),%eax
  801af4:	8b 55 10             	mov    0x10(%ebp),%edx
  801af7:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801af9:	a1 04 40 80 00       	mov    0x804004,%eax
  801afe:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	5b                   	pop    %ebx
  801b05:	5e                   	pop    %esi
  801b06:	5d                   	pop    %ebp
  801b07:	c3                   	ret    

00801b08 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	57                   	push   %edi
  801b0c:	56                   	push   %esi
  801b0d:	53                   	push   %ebx
  801b0e:	83 ec 1c             	sub    $0x1c,%esp
  801b11:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b14:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801b1a:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801b1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b21:	0f 44 d8             	cmove  %eax,%ebx
  801b24:	eb 2a                	jmp    801b50 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  801b26:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b29:	74 20                	je     801b4b <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801b2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b2f:	c7 44 24 08 64 23 80 	movl   $0x802364,0x8(%esp)
  801b36:	00 
  801b37:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801b3e:	00 
  801b3f:	c7 04 24 7b 23 80 00 	movl   $0x80237b,(%esp)
  801b46:	e8 81 e7 ff ff       	call   8002cc <_panic>
		sys_yield();
  801b4b:	e8 10 f4 ff ff       	call   800f60 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801b50:	8b 45 14             	mov    0x14(%ebp),%eax
  801b53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b57:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b5b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b5f:	89 3c 24             	mov    %edi,(%esp)
  801b62:	e8 9d f6 ff ff       	call   801204 <sys_ipc_try_send>
  801b67:	85 c0                	test   %eax,%eax
  801b69:	78 bb                	js     801b26 <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801b6b:	83 c4 1c             	add    $0x1c,%esp
  801b6e:	5b                   	pop    %ebx
  801b6f:	5e                   	pop    %esi
  801b70:	5f                   	pop    %edi
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b79:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b7e:	39 c8                	cmp    %ecx,%eax
  801b80:	74 17                	je     801b99 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b82:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b87:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b8a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b90:	8b 52 50             	mov    0x50(%edx),%edx
  801b93:	39 ca                	cmp    %ecx,%edx
  801b95:	75 14                	jne    801bab <ipc_find_env+0x38>
  801b97:	eb 05                	jmp    801b9e <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b99:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b9e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ba1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ba6:	8b 40 40             	mov    0x40(%eax),%eax
  801ba9:	eb 0e                	jmp    801bb9 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bab:	83 c0 01             	add    $0x1,%eax
  801bae:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bb3:	75 d2                	jne    801b87 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bb5:	66 b8 00 00          	mov    $0x0,%ax
}
  801bb9:	5d                   	pop    %ebp
  801bba:	c3                   	ret    
  801bbb:	66 90                	xchg   %ax,%ax
  801bbd:	66 90                	xchg   %ax,%ax
  801bbf:	90                   	nop

00801bc0 <__udivdi3>:
  801bc0:	83 ec 1c             	sub    $0x1c,%esp
  801bc3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801bc7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801bcb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801bcf:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801bd3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801bd7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	89 74 24 10          	mov    %esi,0x10(%esp)
  801be1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801be5:	89 ea                	mov    %ebp,%edx
  801be7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801beb:	75 33                	jne    801c20 <__udivdi3+0x60>
  801bed:	39 e9                	cmp    %ebp,%ecx
  801bef:	77 6f                	ja     801c60 <__udivdi3+0xa0>
  801bf1:	85 c9                	test   %ecx,%ecx
  801bf3:	89 ce                	mov    %ecx,%esi
  801bf5:	75 0b                	jne    801c02 <__udivdi3+0x42>
  801bf7:	b8 01 00 00 00       	mov    $0x1,%eax
  801bfc:	31 d2                	xor    %edx,%edx
  801bfe:	f7 f1                	div    %ecx
  801c00:	89 c6                	mov    %eax,%esi
  801c02:	31 d2                	xor    %edx,%edx
  801c04:	89 e8                	mov    %ebp,%eax
  801c06:	f7 f6                	div    %esi
  801c08:	89 c5                	mov    %eax,%ebp
  801c0a:	89 f8                	mov    %edi,%eax
  801c0c:	f7 f6                	div    %esi
  801c0e:	89 ea                	mov    %ebp,%edx
  801c10:	8b 74 24 10          	mov    0x10(%esp),%esi
  801c14:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801c18:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801c1c:	83 c4 1c             	add    $0x1c,%esp
  801c1f:	c3                   	ret    
  801c20:	39 e8                	cmp    %ebp,%eax
  801c22:	77 24                	ja     801c48 <__udivdi3+0x88>
  801c24:	0f bd c8             	bsr    %eax,%ecx
  801c27:	83 f1 1f             	xor    $0x1f,%ecx
  801c2a:	89 0c 24             	mov    %ecx,(%esp)
  801c2d:	75 49                	jne    801c78 <__udivdi3+0xb8>
  801c2f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c33:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801c37:	0f 86 ab 00 00 00    	jbe    801ce8 <__udivdi3+0x128>
  801c3d:	39 e8                	cmp    %ebp,%eax
  801c3f:	0f 82 a3 00 00 00    	jb     801ce8 <__udivdi3+0x128>
  801c45:	8d 76 00             	lea    0x0(%esi),%esi
  801c48:	31 d2                	xor    %edx,%edx
  801c4a:	31 c0                	xor    %eax,%eax
  801c4c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801c50:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801c54:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801c58:	83 c4 1c             	add    $0x1c,%esp
  801c5b:	c3                   	ret    
  801c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c60:	89 f8                	mov    %edi,%eax
  801c62:	f7 f1                	div    %ecx
  801c64:	31 d2                	xor    %edx,%edx
  801c66:	8b 74 24 10          	mov    0x10(%esp),%esi
  801c6a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801c6e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801c72:	83 c4 1c             	add    $0x1c,%esp
  801c75:	c3                   	ret    
  801c76:	66 90                	xchg   %ax,%ax
  801c78:	0f b6 0c 24          	movzbl (%esp),%ecx
  801c7c:	89 c6                	mov    %eax,%esi
  801c7e:	b8 20 00 00 00       	mov    $0x20,%eax
  801c83:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801c87:	2b 04 24             	sub    (%esp),%eax
  801c8a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801c8e:	d3 e6                	shl    %cl,%esi
  801c90:	89 c1                	mov    %eax,%ecx
  801c92:	d3 ed                	shr    %cl,%ebp
  801c94:	0f b6 0c 24          	movzbl (%esp),%ecx
  801c98:	09 f5                	or     %esi,%ebp
  801c9a:	8b 74 24 04          	mov    0x4(%esp),%esi
  801c9e:	d3 e6                	shl    %cl,%esi
  801ca0:	89 c1                	mov    %eax,%ecx
  801ca2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ca6:	89 d6                	mov    %edx,%esi
  801ca8:	d3 ee                	shr    %cl,%esi
  801caa:	0f b6 0c 24          	movzbl (%esp),%ecx
  801cae:	d3 e2                	shl    %cl,%edx
  801cb0:	89 c1                	mov    %eax,%ecx
  801cb2:	d3 ef                	shr    %cl,%edi
  801cb4:	09 d7                	or     %edx,%edi
  801cb6:	89 f2                	mov    %esi,%edx
  801cb8:	89 f8                	mov    %edi,%eax
  801cba:	f7 f5                	div    %ebp
  801cbc:	89 d6                	mov    %edx,%esi
  801cbe:	89 c7                	mov    %eax,%edi
  801cc0:	f7 64 24 04          	mull   0x4(%esp)
  801cc4:	39 d6                	cmp    %edx,%esi
  801cc6:	72 30                	jb     801cf8 <__udivdi3+0x138>
  801cc8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801ccc:	0f b6 0c 24          	movzbl (%esp),%ecx
  801cd0:	d3 e5                	shl    %cl,%ebp
  801cd2:	39 c5                	cmp    %eax,%ebp
  801cd4:	73 04                	jae    801cda <__udivdi3+0x11a>
  801cd6:	39 d6                	cmp    %edx,%esi
  801cd8:	74 1e                	je     801cf8 <__udivdi3+0x138>
  801cda:	89 f8                	mov    %edi,%eax
  801cdc:	31 d2                	xor    %edx,%edx
  801cde:	e9 69 ff ff ff       	jmp    801c4c <__udivdi3+0x8c>
  801ce3:	90                   	nop
  801ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce8:	31 d2                	xor    %edx,%edx
  801cea:	b8 01 00 00 00       	mov    $0x1,%eax
  801cef:	e9 58 ff ff ff       	jmp    801c4c <__udivdi3+0x8c>
  801cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	8b 74 24 10          	mov    0x10(%esp),%esi
  801d01:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801d05:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801d09:	83 c4 1c             	add    $0x1c,%esp
  801d0c:	c3                   	ret    
  801d0d:	66 90                	xchg   %ax,%ax
  801d0f:	90                   	nop

00801d10 <__umoddi3>:
  801d10:	83 ec 2c             	sub    $0x2c,%esp
  801d13:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d17:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d1b:	89 74 24 20          	mov    %esi,0x20(%esp)
  801d1f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801d23:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801d27:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	89 c2                	mov    %eax,%edx
  801d2f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801d33:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801d37:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d3b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801d3f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d43:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801d47:	75 1f                	jne    801d68 <__umoddi3+0x58>
  801d49:	39 fe                	cmp    %edi,%esi
  801d4b:	76 63                	jbe    801db0 <__umoddi3+0xa0>
  801d4d:	89 c8                	mov    %ecx,%eax
  801d4f:	89 fa                	mov    %edi,%edx
  801d51:	f7 f6                	div    %esi
  801d53:	89 d0                	mov    %edx,%eax
  801d55:	31 d2                	xor    %edx,%edx
  801d57:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d5b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d5f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801d63:	83 c4 2c             	add    $0x2c,%esp
  801d66:	c3                   	ret    
  801d67:	90                   	nop
  801d68:	39 f8                	cmp    %edi,%eax
  801d6a:	77 64                	ja     801dd0 <__umoddi3+0xc0>
  801d6c:	0f bd e8             	bsr    %eax,%ebp
  801d6f:	83 f5 1f             	xor    $0x1f,%ebp
  801d72:	75 74                	jne    801de8 <__umoddi3+0xd8>
  801d74:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801d78:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801d7c:	0f 87 0e 01 00 00    	ja     801e90 <__umoddi3+0x180>
  801d82:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801d86:	29 f1                	sub    %esi,%ecx
  801d88:	19 c7                	sbb    %eax,%edi
  801d8a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d8e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801d92:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d96:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d9a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d9e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801da2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801da6:	83 c4 2c             	add    $0x2c,%esp
  801da9:	c3                   	ret    
  801daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801db0:	85 f6                	test   %esi,%esi
  801db2:	89 f5                	mov    %esi,%ebp
  801db4:	75 0b                	jne    801dc1 <__umoddi3+0xb1>
  801db6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbb:	31 d2                	xor    %edx,%edx
  801dbd:	f7 f6                	div    %esi
  801dbf:	89 c5                	mov    %eax,%ebp
  801dc1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801dc5:	31 d2                	xor    %edx,%edx
  801dc7:	f7 f5                	div    %ebp
  801dc9:	89 c8                	mov    %ecx,%eax
  801dcb:	f7 f5                	div    %ebp
  801dcd:	eb 84                	jmp    801d53 <__umoddi3+0x43>
  801dcf:	90                   	nop
  801dd0:	89 c8                	mov    %ecx,%eax
  801dd2:	89 fa                	mov    %edi,%edx
  801dd4:	8b 74 24 20          	mov    0x20(%esp),%esi
  801dd8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801ddc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801de0:	83 c4 2c             	add    $0x2c,%esp
  801de3:	c3                   	ret    
  801de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801de8:	8b 44 24 10          	mov    0x10(%esp),%eax
  801dec:	be 20 00 00 00       	mov    $0x20,%esi
  801df1:	89 e9                	mov    %ebp,%ecx
  801df3:	29 ee                	sub    %ebp,%esi
  801df5:	d3 e2                	shl    %cl,%edx
  801df7:	89 f1                	mov    %esi,%ecx
  801df9:	d3 e8                	shr    %cl,%eax
  801dfb:	89 e9                	mov    %ebp,%ecx
  801dfd:	09 d0                	or     %edx,%eax
  801dff:	89 fa                	mov    %edi,%edx
  801e01:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e05:	8b 44 24 10          	mov    0x10(%esp),%eax
  801e09:	d3 e0                	shl    %cl,%eax
  801e0b:	89 f1                	mov    %esi,%ecx
  801e0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e11:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e15:	d3 ea                	shr    %cl,%edx
  801e17:	89 e9                	mov    %ebp,%ecx
  801e19:	d3 e7                	shl    %cl,%edi
  801e1b:	89 f1                	mov    %esi,%ecx
  801e1d:	d3 e8                	shr    %cl,%eax
  801e1f:	89 e9                	mov    %ebp,%ecx
  801e21:	09 f8                	or     %edi,%eax
  801e23:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801e27:	f7 74 24 0c          	divl   0xc(%esp)
  801e2b:	d3 e7                	shl    %cl,%edi
  801e2d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801e31:	89 d7                	mov    %edx,%edi
  801e33:	f7 64 24 10          	mull   0x10(%esp)
  801e37:	39 d7                	cmp    %edx,%edi
  801e39:	89 c1                	mov    %eax,%ecx
  801e3b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801e3f:	72 3b                	jb     801e7c <__umoddi3+0x16c>
  801e41:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801e45:	72 31                	jb     801e78 <__umoddi3+0x168>
  801e47:	8b 44 24 18          	mov    0x18(%esp),%eax
  801e4b:	29 c8                	sub    %ecx,%eax
  801e4d:	19 d7                	sbb    %edx,%edi
  801e4f:	89 e9                	mov    %ebp,%ecx
  801e51:	89 fa                	mov    %edi,%edx
  801e53:	d3 e8                	shr    %cl,%eax
  801e55:	89 f1                	mov    %esi,%ecx
  801e57:	d3 e2                	shl    %cl,%edx
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	09 d0                	or     %edx,%eax
  801e5d:	89 fa                	mov    %edi,%edx
  801e5f:	d3 ea                	shr    %cl,%edx
  801e61:	8b 74 24 20          	mov    0x20(%esp),%esi
  801e65:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801e69:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801e6d:	83 c4 2c             	add    $0x2c,%esp
  801e70:	c3                   	ret    
  801e71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e78:	39 d7                	cmp    %edx,%edi
  801e7a:	75 cb                	jne    801e47 <__umoddi3+0x137>
  801e7c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801e80:	89 c1                	mov    %eax,%ecx
  801e82:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801e86:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801e8a:	eb bb                	jmp    801e47 <__umoddi3+0x137>
  801e8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e90:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801e94:	0f 82 e8 fe ff ff    	jb     801d82 <__umoddi3+0x72>
  801e9a:	e9 f3 fe ff ff       	jmp    801d92 <__umoddi3+0x82>
