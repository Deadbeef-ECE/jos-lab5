
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 d7 01 00 00       	call   80022d <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800056:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005d:	f0 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 c7 03 00 00       	call   800431 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
  800076:	66 90                	xchg   %ax,%ax

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800087:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  80008a:	e8 2c 01 00 00       	call   8001bb <sys_getenvid>
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009c:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a1:	85 db                	test   %ebx,%ebx
  8000a3:	7e 07                	jle    8000ac <libmain+0x34>
		binaryname = argv[0];
  8000a5:	8b 06                	mov    (%esi),%eax
  8000a7:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000b0:	89 1c 24             	mov    %ebx,(%esp)
  8000b3:	e8 7c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0b 00 00 00       	call   8000c8 <exit>
}
  8000bd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c3:	89 ec                	mov    %ebp,%esp
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
  8000c7:	90                   	nop

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ce:	e8 70 06 00 00       	call   800743 <close_all>
	sys_env_destroy(0);
  8000d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000da:	e8 76 00 00 00       	call   800155 <sys_env_destroy>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	66 90                	xchg   %ax,%ax
  8000e3:	90                   	nop

008000e4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000ed:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000f0:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  8000f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f8:	0f a2                	cpuid  
  8000fa:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800101:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 c3                	mov    %eax,%ebx
  800109:	89 c7                	mov    %eax,%edi
  80010b:	89 c6                	mov    %eax,%esi
  80010d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80010f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800112:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800115:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800118:	89 ec                	mov    %ebp,%esp
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_cgetc>:

int
sys_cgetc(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 0c             	sub    $0xc,%esp
  800122:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800125:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800128:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80012b:	b8 01 00 00 00       	mov    $0x1,%eax
  800130:	0f a2                	cpuid  
  800132:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 01 00 00 00       	mov    $0x1,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	89 d6                	mov    %edx,%esi
  800146:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800148:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80014b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80014e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800151:	89 ec                	mov    %ebp,%esp
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 38             	sub    $0x38,%esp
  80015b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80015e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800161:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800164:	b8 01 00 00 00       	mov    $0x1,%eax
  800169:	0f a2                	cpuid  
  80016b:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800172:	b8 03 00 00 00       	mov    $0x3,%eax
  800177:	8b 55 08             	mov    0x8(%ebp),%edx
  80017a:	89 cb                	mov    %ecx,%ebx
  80017c:	89 cf                	mov    %ecx,%edi
  80017e:	89 ce                	mov    %ecx,%esi
  800180:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7e 28                	jle    8001ae <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	89 44 24 10          	mov    %eax,0x10(%esp)
  80018a:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800191:	00 
  800192:	c7 44 24 08 ca 1c 80 	movl   $0x801cca,0x8(%esp)
  800199:	00 
  80019a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8001a1:	00 
  8001a2:	c7 04 24 e7 1c 80 00 	movl   $0x801ce7,(%esp)
  8001a9:	e8 92 0b 00 00       	call   800d40 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8001ae:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001b1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001b4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001b7:	89 ec                	mov    %ebp,%esp
  8001b9:	5d                   	pop    %ebp
  8001ba:	c3                   	ret    

008001bb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 0c             	sub    $0xc,%esp
  8001c1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001c4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001c7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8001ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8001cf:	0f a2                	cpuid  
  8001d1:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8001d8:	b8 02 00 00 00       	mov    $0x2,%eax
  8001dd:	89 d1                	mov    %edx,%ecx
  8001df:	89 d3                	mov    %edx,%ebx
  8001e1:	89 d7                	mov    %edx,%edi
  8001e3:	89 d6                	mov    %edx,%esi
  8001e5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001e7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ea:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001ed:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001f0:	89 ec                	mov    %ebp,%esp
  8001f2:	5d                   	pop    %ebp
  8001f3:	c3                   	ret    

008001f4 <sys_yield>:

void
sys_yield(void)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	83 ec 0c             	sub    $0xc,%esp
  8001fa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001fd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800200:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800203:	b8 01 00 00 00       	mov    $0x1,%eax
  800208:	0f a2                	cpuid  
  80020a:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020c:	ba 00 00 00 00       	mov    $0x0,%edx
  800211:	b8 0b 00 00 00       	mov    $0xb,%eax
  800216:	89 d1                	mov    %edx,%ecx
  800218:	89 d3                	mov    %edx,%ebx
  80021a:	89 d7                	mov    %edx,%edi
  80021c:	89 d6                	mov    %edx,%esi
  80021e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800220:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800223:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800226:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800229:	89 ec                	mov    %ebp,%esp
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	83 ec 38             	sub    $0x38,%esp
  800233:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800236:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800239:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80023c:	b8 01 00 00 00       	mov    $0x1,%eax
  800241:	0f a2                	cpuid  
  800243:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800245:	be 00 00 00 00       	mov    $0x0,%esi
  80024a:	b8 04 00 00 00       	mov    $0x4,%eax
  80024f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800252:	8b 55 08             	mov    0x8(%ebp),%edx
  800255:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800258:	89 f7                	mov    %esi,%edi
  80025a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80025c:	85 c0                	test   %eax,%eax
  80025e:	7e 28                	jle    800288 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800260:	89 44 24 10          	mov    %eax,0x10(%esp)
  800264:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80026b:	00 
  80026c:	c7 44 24 08 ca 1c 80 	movl   $0x801cca,0x8(%esp)
  800273:	00 
  800274:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80027b:	00 
  80027c:	c7 04 24 e7 1c 80 00 	movl   $0x801ce7,(%esp)
  800283:	e8 b8 0a 00 00       	call   800d40 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800288:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80028b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80028e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800291:	89 ec                	mov    %ebp,%esp
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 38             	sub    $0x38,%esp
  80029b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80029e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002a1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8002a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002a9:	0f a2                	cpuid  
  8002ab:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002be:	8b 75 18             	mov    0x18(%ebp),%esi
  8002c1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c3:	85 c0                	test   %eax,%eax
  8002c5:	7e 28                	jle    8002ef <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002cb:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8002d2:	00 
  8002d3:	c7 44 24 08 ca 1c 80 	movl   $0x801cca,0x8(%esp)
  8002da:	00 
  8002db:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8002e2:	00 
  8002e3:	c7 04 24 e7 1c 80 00 	movl   $0x801ce7,(%esp)
  8002ea:	e8 51 0a 00 00       	call   800d40 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002ef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002f2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002f5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002f8:	89 ec                	mov    %ebp,%esp
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	83 ec 38             	sub    $0x38,%esp
  800302:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800305:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800308:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80030b:	b8 01 00 00 00       	mov    $0x1,%eax
  800310:	0f a2                	cpuid  
  800312:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	bb 00 00 00 00       	mov    $0x0,%ebx
  800319:	b8 06 00 00 00       	mov    $0x6,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 df                	mov    %ebx,%edi
  800326:	89 de                	mov    %ebx,%esi
  800328:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032a:	85 c0                	test   %eax,%eax
  80032c:	7e 28                	jle    800356 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800332:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800339:	00 
  80033a:	c7 44 24 08 ca 1c 80 	movl   $0x801cca,0x8(%esp)
  800341:	00 
  800342:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800349:	00 
  80034a:	c7 04 24 e7 1c 80 00 	movl   $0x801ce7,(%esp)
  800351:	e8 ea 09 00 00       	call   800d40 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800356:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800359:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80035c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80035f:	89 ec                	mov    %ebp,%esp
  800361:	5d                   	pop    %ebp
  800362:	c3                   	ret    

00800363 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	83 ec 38             	sub    $0x38,%esp
  800369:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80036c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80036f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800372:	b8 01 00 00 00       	mov    $0x1,%eax
  800377:	0f a2                	cpuid  
  800379:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800380:	b8 08 00 00 00       	mov    $0x8,%eax
  800385:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800388:	8b 55 08             	mov    0x8(%ebp),%edx
  80038b:	89 df                	mov    %ebx,%edi
  80038d:	89 de                	mov    %ebx,%esi
  80038f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800391:	85 c0                	test   %eax,%eax
  800393:	7e 28                	jle    8003bd <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800395:	89 44 24 10          	mov    %eax,0x10(%esp)
  800399:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8003a0:	00 
  8003a1:	c7 44 24 08 ca 1c 80 	movl   $0x801cca,0x8(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8003b0:	00 
  8003b1:	c7 04 24 e7 1c 80 00 	movl   $0x801ce7,(%esp)
  8003b8:	e8 83 09 00 00       	call   800d40 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8003bd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003c0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003c3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003c6:	89 ec                	mov    %ebp,%esp
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	83 ec 38             	sub    $0x38,%esp
  8003d0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003d3:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003d6:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8003d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003de:	0f a2                	cpuid  
  8003e0:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003e7:	b8 09 00 00 00       	mov    $0x9,%eax
  8003ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f2:	89 df                	mov    %ebx,%edi
  8003f4:	89 de                	mov    %ebx,%esi
  8003f6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	7e 28                	jle    800424 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800400:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800407:	00 
  800408:	c7 44 24 08 ca 1c 80 	movl   $0x801cca,0x8(%esp)
  80040f:	00 
  800410:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800417:	00 
  800418:	c7 04 24 e7 1c 80 00 	movl   $0x801ce7,(%esp)
  80041f:	e8 1c 09 00 00       	call   800d40 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800424:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800427:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80042a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80042d:	89 ec                	mov    %ebp,%esp
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    

00800431 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	83 ec 38             	sub    $0x38,%esp
  800437:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80043a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80043d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800440:	b8 01 00 00 00       	mov    $0x1,%eax
  800445:	0f a2                	cpuid  
  800447:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800449:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800453:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800456:	8b 55 08             	mov    0x8(%ebp),%edx
  800459:	89 df                	mov    %ebx,%edi
  80045b:	89 de                	mov    %ebx,%esi
  80045d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80045f:	85 c0                	test   %eax,%eax
  800461:	7e 28                	jle    80048b <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800463:	89 44 24 10          	mov    %eax,0x10(%esp)
  800467:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80046e:	00 
  80046f:	c7 44 24 08 ca 1c 80 	movl   $0x801cca,0x8(%esp)
  800476:	00 
  800477:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80047e:	00 
  80047f:	c7 04 24 e7 1c 80 00 	movl   $0x801ce7,(%esp)
  800486:	e8 b5 08 00 00       	call   800d40 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80048b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80048e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800491:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800494:	89 ec                	mov    %ebp,%esp
  800496:	5d                   	pop    %ebp
  800497:	c3                   	ret    

00800498 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
  80049b:	83 ec 0c             	sub    $0xc,%esp
  80049e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8004a1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8004a4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8004a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8004ac:	0f a2                	cpuid  
  8004ae:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004b0:	be 00 00 00 00       	mov    $0x0,%esi
  8004b5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8004ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004c3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8004c6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8004c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8004cb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8004ce:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004d1:	89 ec                	mov    %ebp,%esp
  8004d3:	5d                   	pop    %ebp
  8004d4:	c3                   	ret    

008004d5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	83 ec 38             	sub    $0x38,%esp
  8004db:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8004de:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8004e1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8004e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8004e9:	0f a2                	cpuid  
  8004eb:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f2:	b8 0d 00 00 00       	mov    $0xd,%eax
  8004f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8004fa:	89 cb                	mov    %ecx,%ebx
  8004fc:	89 cf                	mov    %ecx,%edi
  8004fe:	89 ce                	mov    %ecx,%esi
  800500:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800502:	85 c0                	test   %eax,%eax
  800504:	7e 28                	jle    80052e <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800506:	89 44 24 10          	mov    %eax,0x10(%esp)
  80050a:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800511:	00 
  800512:	c7 44 24 08 ca 1c 80 	movl   $0x801cca,0x8(%esp)
  800519:	00 
  80051a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800521:	00 
  800522:	c7 04 24 e7 1c 80 00 	movl   $0x801ce7,(%esp)
  800529:	e8 12 08 00 00       	call   800d40 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80052e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800531:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800534:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800537:	89 ec                	mov    %ebp,%esp
  800539:	5d                   	pop    %ebp
  80053a:	c3                   	ret    
  80053b:	66 90                	xchg   %ax,%ax
  80053d:	66 90                	xchg   %ax,%ax
  80053f:	90                   	nop

00800540 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800540:	55                   	push   %ebp
  800541:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800543:	8b 45 08             	mov    0x8(%ebp),%eax
  800546:	05 00 00 00 30       	add    $0x30000000,%eax
  80054b:	c1 e8 0c             	shr    $0xc,%eax
}
  80054e:	5d                   	pop    %ebp
  80054f:	c3                   	ret    

00800550 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800556:	8b 45 08             	mov    0x8(%ebp),%eax
  800559:	89 04 24             	mov    %eax,(%esp)
  80055c:	e8 df ff ff ff       	call   800540 <fd2num>
  800561:	c1 e0 0c             	shl    $0xc,%eax
  800564:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800569:	c9                   	leave  
  80056a:	c3                   	ret    

0080056b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80056b:	55                   	push   %ebp
  80056c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80056e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800573:	a8 01                	test   $0x1,%al
  800575:	74 34                	je     8005ab <fd_alloc+0x40>
  800577:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80057c:	a8 01                	test   $0x1,%al
  80057e:	74 32                	je     8005b2 <fd_alloc+0x47>
  800580:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800585:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800587:	89 c2                	mov    %eax,%edx
  800589:	c1 ea 16             	shr    $0x16,%edx
  80058c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800593:	f6 c2 01             	test   $0x1,%dl
  800596:	74 1f                	je     8005b7 <fd_alloc+0x4c>
  800598:	89 c2                	mov    %eax,%edx
  80059a:	c1 ea 0c             	shr    $0xc,%edx
  80059d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005a4:	f6 c2 01             	test   $0x1,%dl
  8005a7:	75 1a                	jne    8005c3 <fd_alloc+0x58>
  8005a9:	eb 0c                	jmp    8005b7 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8005ab:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8005b0:	eb 05                	jmp    8005b7 <fd_alloc+0x4c>
  8005b2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8005b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ba:	89 08                	mov    %ecx,(%eax)
			return 0;
  8005bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c1:	eb 1a                	jmp    8005dd <fd_alloc+0x72>
  8005c3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8005c8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8005cd:	75 b6                	jne    800585 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8005cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8005d8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8005dd:	5d                   	pop    %ebp
  8005de:	c3                   	ret    

008005df <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8005e5:	83 f8 1f             	cmp    $0x1f,%eax
  8005e8:	77 36                	ja     800620 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8005ea:	c1 e0 0c             	shl    $0xc,%eax
  8005ed:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8005f2:	89 c2                	mov    %eax,%edx
  8005f4:	c1 ea 16             	shr    $0x16,%edx
  8005f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8005fe:	f6 c2 01             	test   $0x1,%dl
  800601:	74 24                	je     800627 <fd_lookup+0x48>
  800603:	89 c2                	mov    %eax,%edx
  800605:	c1 ea 0c             	shr    $0xc,%edx
  800608:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80060f:	f6 c2 01             	test   $0x1,%dl
  800612:	74 1a                	je     80062e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800614:	8b 55 0c             	mov    0xc(%ebp),%edx
  800617:	89 02                	mov    %eax,(%edx)
	return 0;
  800619:	b8 00 00 00 00       	mov    $0x0,%eax
  80061e:	eb 13                	jmp    800633 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  800620:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800625:	eb 0c                	jmp    800633 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  800627:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80062c:	eb 05                	jmp    800633 <fd_lookup+0x54>
  80062e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800633:	5d                   	pop    %ebp
  800634:	c3                   	ret    

00800635 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800635:	55                   	push   %ebp
  800636:	89 e5                	mov    %esp,%ebp
  800638:	83 ec 18             	sub    $0x18,%esp
  80063b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80063e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  800644:	75 10                	jne    800656 <dev_lookup+0x21>
			*dev = devtab[i];
  800646:	8b 45 0c             	mov    0xc(%ebp),%eax
  800649:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80064f:	b8 00 00 00 00       	mov    $0x0,%eax
  800654:	eb 2b                	jmp    800681 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800656:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80065c:	8b 52 48             	mov    0x48(%edx),%edx
  80065f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800663:	89 54 24 04          	mov    %edx,0x4(%esp)
  800667:	c7 04 24 f8 1c 80 00 	movl   $0x801cf8,(%esp)
  80066e:	e8 c8 07 00 00       	call   800e3b <cprintf>
	*dev = 0;
  800673:	8b 55 0c             	mov    0xc(%ebp),%edx
  800676:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80067c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800681:	c9                   	leave  
  800682:	c3                   	ret    

00800683 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	83 ec 38             	sub    $0x38,%esp
  800689:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80068c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80068f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800692:	8b 7d 08             	mov    0x8(%ebp),%edi
  800695:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800698:	89 3c 24             	mov    %edi,(%esp)
  80069b:	e8 a0 fe ff ff       	call   800540 <fd2num>
  8006a0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8006a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a7:	89 04 24             	mov    %eax,(%esp)
  8006aa:	e8 30 ff ff ff       	call   8005df <fd_lookup>
  8006af:	89 c3                	mov    %eax,%ebx
  8006b1:	85 c0                	test   %eax,%eax
  8006b3:	78 05                	js     8006ba <fd_close+0x37>
	    || fd != fd2)
  8006b5:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8006b8:	74 0c                	je     8006c6 <fd_close+0x43>
		return (must_exist ? r : 0);
  8006ba:	85 f6                	test   %esi,%esi
  8006bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c1:	0f 44 d8             	cmove  %eax,%ebx
  8006c4:	eb 3d                	jmp    800703 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8006c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8006c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cd:	8b 07                	mov    (%edi),%eax
  8006cf:	89 04 24             	mov    %eax,(%esp)
  8006d2:	e8 5e ff ff ff       	call   800635 <dev_lookup>
  8006d7:	89 c3                	mov    %eax,%ebx
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	78 16                	js     8006f3 <fd_close+0x70>
		if (dev->dev_close)
  8006dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006e0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8006e3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 07                	je     8006f3 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  8006ec:	89 3c 24             	mov    %edi,(%esp)
  8006ef:	ff d0                	call   *%eax
  8006f1:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8006f3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006fe:	e8 f9 fb ff ff       	call   8002fc <sys_page_unmap>
	return r;
}
  800703:	89 d8                	mov    %ebx,%eax
  800705:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800708:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80070b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80070e:	89 ec                	mov    %ebp,%esp
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    

00800712 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800718:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	89 04 24             	mov    %eax,(%esp)
  800725:	e8 b5 fe ff ff       	call   8005df <fd_lookup>
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 13                	js     800741 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80072e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800735:	00 
  800736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800739:	89 04 24             	mov    %eax,(%esp)
  80073c:	e8 42 ff ff ff       	call   800683 <fd_close>
}
  800741:	c9                   	leave  
  800742:	c3                   	ret    

00800743 <close_all>:

void
close_all(void)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	53                   	push   %ebx
  800747:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80074a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80074f:	89 1c 24             	mov    %ebx,(%esp)
  800752:	e8 bb ff ff ff       	call   800712 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800757:	83 c3 01             	add    $0x1,%ebx
  80075a:	83 fb 20             	cmp    $0x20,%ebx
  80075d:	75 f0                	jne    80074f <close_all+0xc>
		close(i);
}
  80075f:	83 c4 14             	add    $0x14,%esp
  800762:	5b                   	pop    %ebx
  800763:	5d                   	pop    %ebp
  800764:	c3                   	ret    

00800765 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 58             	sub    $0x58,%esp
  80076b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80076e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800771:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800774:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800777:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80077a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	89 04 24             	mov    %eax,(%esp)
  800784:	e8 56 fe ff ff       	call   8005df <fd_lookup>
  800789:	85 c0                	test   %eax,%eax
  80078b:	0f 88 e3 00 00 00    	js     800874 <dup+0x10f>
		return r;
	close(newfdnum);
  800791:	89 1c 24             	mov    %ebx,(%esp)
  800794:	e8 79 ff ff ff       	call   800712 <close>

	newfd = INDEX2FD(newfdnum);
  800799:	89 de                	mov    %ebx,%esi
  80079b:	c1 e6 0c             	shl    $0xc,%esi
  80079e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8007a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007a7:	89 04 24             	mov    %eax,(%esp)
  8007aa:	e8 a1 fd ff ff       	call   800550 <fd2data>
  8007af:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8007b1:	89 34 24             	mov    %esi,(%esp)
  8007b4:	e8 97 fd ff ff       	call   800550 <fd2data>
  8007b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8007bc:	89 f8                	mov    %edi,%eax
  8007be:	c1 e8 16             	shr    $0x16,%eax
  8007c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8007c8:	a8 01                	test   $0x1,%al
  8007ca:	74 46                	je     800812 <dup+0xad>
  8007cc:	89 f8                	mov    %edi,%eax
  8007ce:	c1 e8 0c             	shr    $0xc,%eax
  8007d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8007d8:	f6 c2 01             	test   $0x1,%dl
  8007db:	74 35                	je     800812 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8007dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8007e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8007e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8007fb:	00 
  8007fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800800:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800807:	e8 89 fa ff ff       	call   800295 <sys_page_map>
  80080c:	89 c7                	mov    %eax,%edi
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 3b                	js     80084d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800812:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800815:	89 c2                	mov    %eax,%edx
  800817:	c1 ea 0c             	shr    $0xc,%edx
  80081a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800821:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800827:	89 54 24 10          	mov    %edx,0x10(%esp)
  80082b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80082f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800836:	00 
  800837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800842:	e8 4e fa ff ff       	call   800295 <sys_page_map>
  800847:	89 c7                	mov    %eax,%edi
  800849:	85 c0                	test   %eax,%eax
  80084b:	79 29                	jns    800876 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80084d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800851:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800858:	e8 9f fa ff ff       	call   8002fc <sys_page_unmap>
	sys_page_unmap(0, nva);
  80085d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800860:	89 44 24 04          	mov    %eax,0x4(%esp)
  800864:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80086b:	e8 8c fa ff ff       	call   8002fc <sys_page_unmap>
	return r;
  800870:	89 fb                	mov    %edi,%ebx
  800872:	eb 02                	jmp    800876 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  800874:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800876:	89 d8                	mov    %ebx,%eax
  800878:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80087b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80087e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800881:	89 ec                	mov    %ebp,%esp
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	83 ec 24             	sub    $0x24,%esp
  80088c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800892:	89 44 24 04          	mov    %eax,0x4(%esp)
  800896:	89 1c 24             	mov    %ebx,(%esp)
  800899:	e8 41 fd ff ff       	call   8005df <fd_lookup>
  80089e:	85 c0                	test   %eax,%eax
  8008a0:	78 6d                	js     80090f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ac:	8b 00                	mov    (%eax),%eax
  8008ae:	89 04 24             	mov    %eax,(%esp)
  8008b1:	e8 7f fd ff ff       	call   800635 <dev_lookup>
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	78 55                	js     80090f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8008ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008bd:	8b 50 08             	mov    0x8(%eax),%edx
  8008c0:	83 e2 03             	and    $0x3,%edx
  8008c3:	83 fa 01             	cmp    $0x1,%edx
  8008c6:	75 23                	jne    8008eb <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8008c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8008cd:	8b 40 48             	mov    0x48(%eax),%eax
  8008d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d8:	c7 04 24 39 1d 80 00 	movl   $0x801d39,(%esp)
  8008df:	e8 57 05 00 00       	call   800e3b <cprintf>
		return -E_INVAL;
  8008e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e9:	eb 24                	jmp    80090f <read+0x8a>
	}
	if (!dev->dev_read)
  8008eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008ee:	8b 52 08             	mov    0x8(%edx),%edx
  8008f1:	85 d2                	test   %edx,%edx
  8008f3:	74 15                	je     80090a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8008f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800903:	89 04 24             	mov    %eax,(%esp)
  800906:	ff d2                	call   *%edx
  800908:	eb 05                	jmp    80090f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80090a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80090f:	83 c4 24             	add    $0x24,%esp
  800912:	5b                   	pop    %ebx
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	83 ec 1c             	sub    $0x1c,%esp
  80091e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800921:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800924:	85 f6                	test   %esi,%esi
  800926:	74 33                	je     80095b <readn+0x46>
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
  80092d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800932:	89 f2                	mov    %esi,%edx
  800934:	29 c2                	sub    %eax,%edx
  800936:	89 54 24 08          	mov    %edx,0x8(%esp)
  80093a:	03 45 0c             	add    0xc(%ebp),%eax
  80093d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800941:	89 3c 24             	mov    %edi,(%esp)
  800944:	e8 3c ff ff ff       	call   800885 <read>
		if (m < 0)
  800949:	85 c0                	test   %eax,%eax
  80094b:	78 17                	js     800964 <readn+0x4f>
			return m;
		if (m == 0)
  80094d:	85 c0                	test   %eax,%eax
  80094f:	74 11                	je     800962 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800951:	01 c3                	add    %eax,%ebx
  800953:	89 d8                	mov    %ebx,%eax
  800955:	39 f3                	cmp    %esi,%ebx
  800957:	72 d9                	jb     800932 <readn+0x1d>
  800959:	eb 09                	jmp    800964 <readn+0x4f>
  80095b:	b8 00 00 00 00       	mov    $0x0,%eax
  800960:	eb 02                	jmp    800964 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800962:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800964:	83 c4 1c             	add    $0x1c,%esp
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5f                   	pop    %edi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	53                   	push   %ebx
  800970:	83 ec 24             	sub    $0x24,%esp
  800973:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800976:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800979:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097d:	89 1c 24             	mov    %ebx,(%esp)
  800980:	e8 5a fc ff ff       	call   8005df <fd_lookup>
  800985:	85 c0                	test   %eax,%eax
  800987:	78 68                	js     8009f1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800989:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80098c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800990:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800993:	8b 00                	mov    (%eax),%eax
  800995:	89 04 24             	mov    %eax,(%esp)
  800998:	e8 98 fc ff ff       	call   800635 <dev_lookup>
  80099d:	85 c0                	test   %eax,%eax
  80099f:	78 50                	js     8009f1 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8009a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8009a8:	75 23                	jne    8009cd <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8009aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8009af:	8b 40 48             	mov    0x48(%eax),%eax
  8009b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ba:	c7 04 24 55 1d 80 00 	movl   $0x801d55,(%esp)
  8009c1:	e8 75 04 00 00       	call   800e3b <cprintf>
		return -E_INVAL;
  8009c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009cb:	eb 24                	jmp    8009f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8009cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8009d3:	85 d2                	test   %edx,%edx
  8009d5:	74 15                	je     8009ec <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8009d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009e5:	89 04 24             	mov    %eax,(%esp)
  8009e8:	ff d2                	call   *%edx
  8009ea:	eb 05                	jmp    8009f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8009ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8009f1:	83 c4 24             	add    $0x24,%esp
  8009f4:	5b                   	pop    %ebx
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009fd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800a00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	89 04 24             	mov    %eax,(%esp)
  800a0a:	e8 d0 fb ff ff       	call   8005df <fd_lookup>
  800a0f:	85 c0                	test   %eax,%eax
  800a11:	78 0e                	js     800a21 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800a13:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a19:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	53                   	push   %ebx
  800a27:	83 ec 24             	sub    $0x24,%esp
  800a2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a34:	89 1c 24             	mov    %ebx,(%esp)
  800a37:	e8 a3 fb ff ff       	call   8005df <fd_lookup>
  800a3c:	85 c0                	test   %eax,%eax
  800a3e:	78 61                	js     800aa1 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a43:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a4a:	8b 00                	mov    (%eax),%eax
  800a4c:	89 04 24             	mov    %eax,(%esp)
  800a4f:	e8 e1 fb ff ff       	call   800635 <dev_lookup>
  800a54:	85 c0                	test   %eax,%eax
  800a56:	78 49                	js     800aa1 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a5b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a5f:	75 23                	jne    800a84 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800a61:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800a66:	8b 40 48             	mov    0x48(%eax),%eax
  800a69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a71:	c7 04 24 18 1d 80 00 	movl   $0x801d18,(%esp)
  800a78:	e8 be 03 00 00       	call   800e3b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800a7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a82:	eb 1d                	jmp    800aa1 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800a84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a87:	8b 52 18             	mov    0x18(%edx),%edx
  800a8a:	85 d2                	test   %edx,%edx
  800a8c:	74 0e                	je     800a9c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800a8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a91:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a95:	89 04 24             	mov    %eax,(%esp)
  800a98:	ff d2                	call   *%edx
  800a9a:	eb 05                	jmp    800aa1 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800a9c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800aa1:	83 c4 24             	add    $0x24,%esp
  800aa4:	5b                   	pop    %ebx
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	53                   	push   %ebx
  800aab:	83 ec 24             	sub    $0x24,%esp
  800aae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ab1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	89 04 24             	mov    %eax,(%esp)
  800abe:	e8 1c fb ff ff       	call   8005df <fd_lookup>
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	78 52                	js     800b19 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ac7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ace:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ad1:	8b 00                	mov    (%eax),%eax
  800ad3:	89 04 24             	mov    %eax,(%esp)
  800ad6:	e8 5a fb ff ff       	call   800635 <dev_lookup>
  800adb:	85 c0                	test   %eax,%eax
  800add:	78 3a                	js     800b19 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800ae6:	74 2c                	je     800b14 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800ae8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800aeb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800af2:	00 00 00 
	stat->st_isdir = 0;
  800af5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800afc:	00 00 00 
	stat->st_dev = dev;
  800aff:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800b05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b09:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b0c:	89 14 24             	mov    %edx,(%esp)
  800b0f:	ff 50 14             	call   *0x14(%eax)
  800b12:	eb 05                	jmp    800b19 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800b14:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800b19:	83 c4 24             	add    $0x24,%esp
  800b1c:	5b                   	pop    %ebx
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	83 ec 18             	sub    $0x18,%esp
  800b25:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b28:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800b2b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800b32:	00 
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	89 04 24             	mov    %eax,(%esp)
  800b39:	e8 84 01 00 00       	call   800cc2 <open>
  800b3e:	89 c3                	mov    %eax,%ebx
  800b40:	85 c0                	test   %eax,%eax
  800b42:	78 1b                	js     800b5f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800b44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4b:	89 1c 24             	mov    %ebx,(%esp)
  800b4e:	e8 54 ff ff ff       	call   800aa7 <fstat>
  800b53:	89 c6                	mov    %eax,%esi
	close(fd);
  800b55:	89 1c 24             	mov    %ebx,(%esp)
  800b58:	e8 b5 fb ff ff       	call   800712 <close>
	return r;
  800b5d:	89 f3                	mov    %esi,%ebx
}
  800b5f:	89 d8                	mov    %ebx,%eax
  800b61:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b64:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b67:	89 ec                	mov    %ebp,%esp
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    
  800b6b:	90                   	nop

00800b6c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 18             	sub    $0x18,%esp
  800b72:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b75:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b78:	89 c6                	mov    %eax,%esi
  800b7a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800b7c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800b83:	75 11                	jne    800b96 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b85:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b8c:	e8 f2 0d 00 00       	call   801983 <ipc_find_env>
  800b91:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b96:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b9d:	00 
  800b9e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800ba5:	00 
  800ba6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800baa:	a1 00 40 80 00       	mov    0x804000,%eax
  800baf:	89 04 24             	mov    %eax,(%esp)
  800bb2:	e8 61 0d 00 00       	call   801918 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800bb7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800bbe:	00 
  800bbf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800bca:	e8 f1 0c 00 00       	call   8018c0 <ipc_recv>
}
  800bcf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800bd2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800bd5:	89 ec                	mov    %ebp,%esp
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800be2:	8b 40 0c             	mov    0xc(%eax),%eax
  800be5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bed:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bfc:	e8 6b ff ff ff       	call   800b6c <fsipc>
}
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800c09:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0c:	8b 40 0c             	mov    0xc(%eax),%eax
  800c0f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1e:	e8 49 ff ff ff       	call   800b6c <fsipc>
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	53                   	push   %ebx
  800c29:	83 ec 14             	sub    $0x14,%esp
  800c2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c32:	8b 40 0c             	mov    0xc(%eax),%eax
  800c35:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c44:	e8 23 ff ff ff       	call   800b6c <fsipc>
  800c49:	85 c0                	test   %eax,%eax
  800c4b:	78 2b                	js     800c78 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800c4d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c54:	00 
  800c55:	89 1c 24             	mov    %ebx,(%esp)
  800c58:	e8 5e 08 00 00       	call   8014bb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800c5d:	a1 80 50 80 00       	mov    0x805080,%eax
  800c62:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800c68:	a1 84 50 80 00       	mov    0x805084,%eax
  800c6d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800c73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c78:	83 c4 14             	add    $0x14,%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800c84:	c7 44 24 08 72 1d 80 	movl   $0x801d72,0x8(%esp)
  800c8b:	00 
  800c8c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  800c93:	00 
  800c94:	c7 04 24 90 1d 80 00 	movl   $0x801d90,(%esp)
  800c9b:	e8 a0 00 00 00       	call   800d40 <_panic>

00800ca0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  800ca6:	c7 44 24 08 9b 1d 80 	movl   $0x801d9b,0x8(%esp)
  800cad:	00 
  800cae:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  800cb5:	00 
  800cb6:	c7 04 24 90 1d 80 00 	movl   $0x801d90,(%esp)
  800cbd:	e8 7e 00 00 00       	call   800d40 <_panic>

00800cc2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  800cc8:	c7 44 24 08 b8 1d 80 	movl   $0x801db8,0x8(%esp)
  800ccf:	00 
  800cd0:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800cd7:	00 
  800cd8:	c7 04 24 90 1d 80 00 	movl   $0x801d90,(%esp)
  800cdf:	e8 5c 00 00 00       	call   800d40 <_panic>

00800ce4 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	53                   	push   %ebx
  800ce8:	83 ec 14             	sub    $0x14,%esp
  800ceb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800cee:	89 1c 24             	mov    %ebx,(%esp)
  800cf1:	e8 6a 07 00 00       	call   801460 <strlen>
  800cf6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800cfb:	7f 21                	jg     800d1e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800cfd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d01:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800d08:	e8 ae 07 00 00       	call   8014bb <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d12:	b8 07 00 00 00       	mov    $0x7,%eax
  800d17:	e8 50 fe ff ff       	call   800b6c <fsipc>
  800d1c:	eb 05                	jmp    800d23 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800d1e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  800d23:	83 c4 14             	add    $0x14,%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d34:	b8 08 00 00 00       	mov    $0x8,%eax
  800d39:	e8 2e fe ff ff       	call   800b6c <fsipc>
}
  800d3e:	c9                   	leave  
  800d3f:	c3                   	ret    

00800d40 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d48:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d4b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800d51:	e8 65 f4 ff ff       	call   8001bb <sys_getenvid>
  800d56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d59:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d64:	89 74 24 08          	mov    %esi,0x8(%esp)
  800d68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d6c:	c7 04 24 d0 1d 80 00 	movl   $0x801dd0,(%esp)
  800d73:	e8 c3 00 00 00       	call   800e3b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d78:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7f:	89 04 24             	mov    %eax,(%esp)
  800d82:	e8 53 00 00 00       	call   800dda <vcprintf>
	cprintf("\n");
  800d87:	c7 04 24 15 21 80 00 	movl   $0x802115,(%esp)
  800d8e:	e8 a8 00 00 00       	call   800e3b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d93:	cc                   	int3   
  800d94:	eb fd                	jmp    800d93 <_panic+0x53>
  800d96:	66 90                	xchg   %ax,%ax

00800d98 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	53                   	push   %ebx
  800d9c:	83 ec 14             	sub    $0x14,%esp
  800d9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800da2:	8b 03                	mov    (%ebx),%eax
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800dab:	83 c0 01             	add    $0x1,%eax
  800dae:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800db0:	3d ff 00 00 00       	cmp    $0xff,%eax
  800db5:	75 19                	jne    800dd0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800db7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800dbe:	00 
  800dbf:	8d 43 08             	lea    0x8(%ebx),%eax
  800dc2:	89 04 24             	mov    %eax,(%esp)
  800dc5:	e8 1a f3 ff ff       	call   8000e4 <sys_cputs>
		b->idx = 0;
  800dca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800dd0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800dd4:	83 c4 14             	add    $0x14,%esp
  800dd7:	5b                   	pop    %ebx
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800de3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800dea:	00 00 00 
	b.cnt = 0;
  800ded:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800df4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800df7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e05:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e0f:	c7 04 24 98 0d 80 00 	movl   $0x800d98,(%esp)
  800e16:	e8 b7 01 00 00       	call   800fd2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800e1b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800e21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e25:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800e2b:	89 04 24             	mov    %eax,(%esp)
  800e2e:	e8 b1 f2 ff ff       	call   8000e4 <sys_cputs>

	return b.cnt;
}
  800e33:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800e39:	c9                   	leave  
  800e3a:	c3                   	ret    

00800e3b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800e41:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800e44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e48:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4b:	89 04 24             	mov    %eax,(%esp)
  800e4e:	e8 87 ff ff ff       	call   800dda <vcprintf>
	va_end(ap);

	return cnt;
}
  800e53:	c9                   	leave  
  800e54:	c3                   	ret    
  800e55:	66 90                	xchg   %ax,%ax
  800e57:	66 90                	xchg   %ax,%ax
  800e59:	66 90                	xchg   %ax,%ax
  800e5b:	66 90                	xchg   %ax,%ax
  800e5d:	66 90                	xchg   %ax,%ax
  800e5f:	90                   	nop

00800e60 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 4c             	sub    $0x4c,%esp
  800e69:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e6c:	89 d7                	mov    %edx,%edi
  800e6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e71:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800e74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e77:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800e7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7f:	39 d8                	cmp    %ebx,%eax
  800e81:	72 17                	jb     800e9a <printnum+0x3a>
  800e83:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800e86:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800e89:	76 0f                	jbe    800e9a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800e8b:	8b 75 14             	mov    0x14(%ebp),%esi
  800e8e:	83 ee 01             	sub    $0x1,%esi
  800e91:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800e94:	85 f6                	test   %esi,%esi
  800e96:	7f 63                	jg     800efb <printnum+0x9b>
  800e98:	eb 75                	jmp    800f0f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800e9a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e9d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800ea1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea4:	83 e8 01             	sub    $0x1,%eax
  800ea7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800eb2:	8b 44 24 08          	mov    0x8(%esp),%eax
  800eb6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800eba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ebd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ec0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ec7:	00 
  800ec8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800ecb:	89 1c 24             	mov    %ebx,(%esp)
  800ece:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800ed1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ed5:	e8 f6 0a 00 00       	call   8019d0 <__udivdi3>
  800eda:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800edd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ee0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ee4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ee8:	89 04 24             	mov    %eax,(%esp)
  800eeb:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eef:	89 fa                	mov    %edi,%edx
  800ef1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ef4:	e8 67 ff ff ff       	call   800e60 <printnum>
  800ef9:	eb 14                	jmp    800f0f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800efb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800eff:	8b 45 18             	mov    0x18(%ebp),%eax
  800f02:	89 04 24             	mov    %eax,(%esp)
  800f05:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800f07:	83 ee 01             	sub    $0x1,%esi
  800f0a:	75 ef                	jne    800efb <printnum+0x9b>
  800f0c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800f0f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f13:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f1e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f25:	00 
  800f26:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800f29:	89 1c 24             	mov    %ebx,(%esp)
  800f2c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800f2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f33:	e8 e8 0b 00 00       	call   801b20 <__umoddi3>
  800f38:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f3c:	0f be 80 f3 1d 80 00 	movsbl 0x801df3(%eax),%eax
  800f43:	89 04 24             	mov    %eax,(%esp)
  800f46:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800f49:	ff d0                	call   *%eax
}
  800f4b:	83 c4 4c             	add    $0x4c,%esp
  800f4e:	5b                   	pop    %ebx
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    

00800f53 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800f56:	83 fa 01             	cmp    $0x1,%edx
  800f59:	7e 0e                	jle    800f69 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800f5b:	8b 10                	mov    (%eax),%edx
  800f5d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800f60:	89 08                	mov    %ecx,(%eax)
  800f62:	8b 02                	mov    (%edx),%eax
  800f64:	8b 52 04             	mov    0x4(%edx),%edx
  800f67:	eb 22                	jmp    800f8b <getuint+0x38>
	else if (lflag)
  800f69:	85 d2                	test   %edx,%edx
  800f6b:	74 10                	je     800f7d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800f6d:	8b 10                	mov    (%eax),%edx
  800f6f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f72:	89 08                	mov    %ecx,(%eax)
  800f74:	8b 02                	mov    (%edx),%eax
  800f76:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7b:	eb 0e                	jmp    800f8b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800f7d:	8b 10                	mov    (%eax),%edx
  800f7f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f82:	89 08                	mov    %ecx,(%eax)
  800f84:	8b 02                	mov    (%edx),%eax
  800f86:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800f93:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800f97:	8b 10                	mov    (%eax),%edx
  800f99:	3b 50 04             	cmp    0x4(%eax),%edx
  800f9c:	73 0a                	jae    800fa8 <sprintputch+0x1b>
		*b->buf++ = ch;
  800f9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa1:	88 0a                	mov    %cl,(%edx)
  800fa3:	83 c2 01             	add    $0x1,%edx
  800fa6:	89 10                	mov    %edx,(%eax)
}
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800fb0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800fb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fb7:	8b 45 10             	mov    0x10(%ebp),%eax
  800fba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc8:	89 04 24             	mov    %eax,(%esp)
  800fcb:	e8 02 00 00 00       	call   800fd2 <vprintfmt>
	va_end(ap);
}
  800fd0:	c9                   	leave  
  800fd1:	c3                   	ret    

00800fd2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	83 ec 4c             	sub    $0x4c,%esp
  800fdb:	8b 75 08             	mov    0x8(%ebp),%esi
  800fde:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fe1:	8b 7d 10             	mov    0x10(%ebp),%edi
  800fe4:	eb 11                	jmp    800ff7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	0f 84 db 03 00 00    	je     8013c9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  800fee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ff2:	89 04 24             	mov    %eax,(%esp)
  800ff5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ff7:	0f b6 07             	movzbl (%edi),%eax
  800ffa:	83 c7 01             	add    $0x1,%edi
  800ffd:	83 f8 25             	cmp    $0x25,%eax
  801000:	75 e4                	jne    800fe6 <vprintfmt+0x14>
  801002:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  801006:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80100d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801014:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80101b:	ba 00 00 00 00       	mov    $0x0,%edx
  801020:	eb 2b                	jmp    80104d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801022:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801025:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  801029:	eb 22                	jmp    80104d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80102b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80102e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  801032:	eb 19                	jmp    80104d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801034:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801037:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80103e:	eb 0d                	jmp    80104d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801040:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801043:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801046:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80104d:	0f b6 0f             	movzbl (%edi),%ecx
  801050:	8d 47 01             	lea    0x1(%edi),%eax
  801053:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801056:	0f b6 07             	movzbl (%edi),%eax
  801059:	83 e8 23             	sub    $0x23,%eax
  80105c:	3c 55                	cmp    $0x55,%al
  80105e:	0f 87 40 03 00 00    	ja     8013a4 <vprintfmt+0x3d2>
  801064:	0f b6 c0             	movzbl %al,%eax
  801067:	ff 24 85 40 1f 80 00 	jmp    *0x801f40(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80106e:	83 e9 30             	sub    $0x30,%ecx
  801071:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  801074:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  801078:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80107b:	83 f9 09             	cmp    $0x9,%ecx
  80107e:	77 57                	ja     8010d7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801080:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801083:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801086:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801089:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80108c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80108f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801093:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  801096:	8d 48 d0             	lea    -0x30(%eax),%ecx
  801099:	83 f9 09             	cmp    $0x9,%ecx
  80109c:	76 eb                	jbe    801089 <vprintfmt+0xb7>
  80109e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8010a4:	eb 34                	jmp    8010da <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8010a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8010a9:	8d 48 04             	lea    0x4(%eax),%ecx
  8010ac:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8010af:	8b 00                	mov    (%eax),%eax
  8010b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010b4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8010b7:	eb 21                	jmp    8010da <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8010b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8010bd:	0f 88 71 ff ff ff    	js     801034 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010c3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010c6:	eb 85                	jmp    80104d <vprintfmt+0x7b>
  8010c8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8010cb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8010d2:	e9 76 ff ff ff       	jmp    80104d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010d7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8010da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8010de:	0f 89 69 ff ff ff    	jns    80104d <vprintfmt+0x7b>
  8010e4:	e9 57 ff ff ff       	jmp    801040 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8010e9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010ec:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8010ef:	e9 59 ff ff ff       	jmp    80104d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8010f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8010f7:	8d 50 04             	lea    0x4(%eax),%edx
  8010fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8010fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801101:	8b 00                	mov    (%eax),%eax
  801103:	89 04 24             	mov    %eax,(%esp)
  801106:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801108:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80110b:	e9 e7 fe ff ff       	jmp    800ff7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801110:	8b 45 14             	mov    0x14(%ebp),%eax
  801113:	8d 50 04             	lea    0x4(%eax),%edx
  801116:	89 55 14             	mov    %edx,0x14(%ebp)
  801119:	8b 00                	mov    (%eax),%eax
  80111b:	89 c2                	mov    %eax,%edx
  80111d:	c1 fa 1f             	sar    $0x1f,%edx
  801120:	31 d0                	xor    %edx,%eax
  801122:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801124:	83 f8 0f             	cmp    $0xf,%eax
  801127:	7f 0b                	jg     801134 <vprintfmt+0x162>
  801129:	8b 14 85 a0 20 80 00 	mov    0x8020a0(,%eax,4),%edx
  801130:	85 d2                	test   %edx,%edx
  801132:	75 20                	jne    801154 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  801134:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801138:	c7 44 24 08 0b 1e 80 	movl   $0x801e0b,0x8(%esp)
  80113f:	00 
  801140:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801144:	89 34 24             	mov    %esi,(%esp)
  801147:	e8 5e fe ff ff       	call   800faa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80114c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80114f:	e9 a3 fe ff ff       	jmp    800ff7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  801154:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801158:	c7 44 24 08 14 1e 80 	movl   $0x801e14,0x8(%esp)
  80115f:	00 
  801160:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801164:	89 34 24             	mov    %esi,(%esp)
  801167:	e8 3e fe ff ff       	call   800faa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80116c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80116f:	e9 83 fe ff ff       	jmp    800ff7 <vprintfmt+0x25>
  801174:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801177:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80117a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80117d:	8b 45 14             	mov    0x14(%ebp),%eax
  801180:	8d 50 04             	lea    0x4(%eax),%edx
  801183:	89 55 14             	mov    %edx,0x14(%ebp)
  801186:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801188:	85 ff                	test   %edi,%edi
  80118a:	b8 04 1e 80 00       	mov    $0x801e04,%eax
  80118f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801192:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  801196:	74 06                	je     80119e <vprintfmt+0x1cc>
  801198:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80119c:	7f 16                	jg     8011b4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80119e:	0f b6 17             	movzbl (%edi),%edx
  8011a1:	0f be c2             	movsbl %dl,%eax
  8011a4:	83 c7 01             	add    $0x1,%edi
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	0f 85 9f 00 00 00    	jne    80124e <vprintfmt+0x27c>
  8011af:	e9 8b 00 00 00       	jmp    80123f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011b8:	89 3c 24             	mov    %edi,(%esp)
  8011bb:	e8 c2 02 00 00       	call   801482 <strnlen>
  8011c0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8011c3:	29 c2                	sub    %eax,%edx
  8011c5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8011c8:	85 d2                	test   %edx,%edx
  8011ca:	7e d2                	jle    80119e <vprintfmt+0x1cc>
					putch(padc, putdat);
  8011cc:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8011d0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8011d3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8011d6:	89 d7                	mov    %edx,%edi
  8011d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011df:	89 04 24             	mov    %eax,(%esp)
  8011e2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011e4:	83 ef 01             	sub    $0x1,%edi
  8011e7:	75 ef                	jne    8011d8 <vprintfmt+0x206>
  8011e9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8011ec:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8011ef:	eb ad                	jmp    80119e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8011f1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8011f5:	74 20                	je     801217 <vprintfmt+0x245>
  8011f7:	0f be d2             	movsbl %dl,%edx
  8011fa:	83 ea 20             	sub    $0x20,%edx
  8011fd:	83 fa 5e             	cmp    $0x5e,%edx
  801200:	76 15                	jbe    801217 <vprintfmt+0x245>
					putch('?', putdat);
  801202:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801205:	89 54 24 04          	mov    %edx,0x4(%esp)
  801209:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801210:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801213:	ff d1                	call   *%ecx
  801215:	eb 0f                	jmp    801226 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  801217:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80121a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80121e:	89 04 24             	mov    %eax,(%esp)
  801221:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801224:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801226:	83 eb 01             	sub    $0x1,%ebx
  801229:	0f b6 17             	movzbl (%edi),%edx
  80122c:	0f be c2             	movsbl %dl,%eax
  80122f:	83 c7 01             	add    $0x1,%edi
  801232:	85 c0                	test   %eax,%eax
  801234:	75 24                	jne    80125a <vprintfmt+0x288>
  801236:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801239:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80123c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80123f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801242:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801246:	0f 8e ab fd ff ff    	jle    800ff7 <vprintfmt+0x25>
  80124c:	eb 20                	jmp    80126e <vprintfmt+0x29c>
  80124e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801251:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801254:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801257:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80125a:	85 f6                	test   %esi,%esi
  80125c:	78 93                	js     8011f1 <vprintfmt+0x21f>
  80125e:	83 ee 01             	sub    $0x1,%esi
  801261:	79 8e                	jns    8011f1 <vprintfmt+0x21f>
  801263:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801266:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801269:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80126c:	eb d1                	jmp    80123f <vprintfmt+0x26d>
  80126e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801271:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801275:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80127c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80127e:	83 ef 01             	sub    $0x1,%edi
  801281:	75 ee                	jne    801271 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801283:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801286:	e9 6c fd ff ff       	jmp    800ff7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80128b:	83 fa 01             	cmp    $0x1,%edx
  80128e:	66 90                	xchg   %ax,%ax
  801290:	7e 16                	jle    8012a8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  801292:	8b 45 14             	mov    0x14(%ebp),%eax
  801295:	8d 50 08             	lea    0x8(%eax),%edx
  801298:	89 55 14             	mov    %edx,0x14(%ebp)
  80129b:	8b 10                	mov    (%eax),%edx
  80129d:	8b 48 04             	mov    0x4(%eax),%ecx
  8012a0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8012a3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8012a6:	eb 32                	jmp    8012da <vprintfmt+0x308>
	else if (lflag)
  8012a8:	85 d2                	test   %edx,%edx
  8012aa:	74 18                	je     8012c4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8012ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8012af:	8d 50 04             	lea    0x4(%eax),%edx
  8012b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8012b5:	8b 00                	mov    (%eax),%eax
  8012b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ba:	89 c1                	mov    %eax,%ecx
  8012bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8012bf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8012c2:	eb 16                	jmp    8012da <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8012c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c7:	8d 50 04             	lea    0x4(%eax),%edx
  8012ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8012cd:	8b 00                	mov    (%eax),%eax
  8012cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012d2:	89 c7                	mov    %eax,%edi
  8012d4:	c1 ff 1f             	sar    $0x1f,%edi
  8012d7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8012da:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012dd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8012e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8012e5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8012e9:	79 7d                	jns    801368 <vprintfmt+0x396>
				putch('-', putdat);
  8012eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012ef:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8012f6:	ff d6                	call   *%esi
				num = -(long long) num;
  8012f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012fb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8012fe:	f7 d8                	neg    %eax
  801300:	83 d2 00             	adc    $0x0,%edx
  801303:	f7 da                	neg    %edx
			}
			base = 10;
  801305:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80130a:	eb 5c                	jmp    801368 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80130c:	8d 45 14             	lea    0x14(%ebp),%eax
  80130f:	e8 3f fc ff ff       	call   800f53 <getuint>
			base = 10;
  801314:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801319:	eb 4d                	jmp    801368 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80131b:	8d 45 14             	lea    0x14(%ebp),%eax
  80131e:	e8 30 fc ff ff       	call   800f53 <getuint>
			base = 8;
  801323:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801328:	eb 3e                	jmp    801368 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80132a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80132e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801335:	ff d6                	call   *%esi
			putch('x', putdat);
  801337:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80133b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801342:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801344:	8b 45 14             	mov    0x14(%ebp),%eax
  801347:	8d 50 04             	lea    0x4(%eax),%edx
  80134a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80134d:	8b 00                	mov    (%eax),%eax
  80134f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801354:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801359:	eb 0d                	jmp    801368 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80135b:	8d 45 14             	lea    0x14(%ebp),%eax
  80135e:	e8 f0 fb ff ff       	call   800f53 <getuint>
			base = 16;
  801363:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801368:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80136c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801370:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801373:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801377:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80137b:	89 04 24             	mov    %eax,(%esp)
  80137e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801382:	89 da                	mov    %ebx,%edx
  801384:	89 f0                	mov    %esi,%eax
  801386:	e8 d5 fa ff ff       	call   800e60 <printnum>
			break;
  80138b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80138e:	e9 64 fc ff ff       	jmp    800ff7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801393:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801397:	89 0c 24             	mov    %ecx,(%esp)
  80139a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80139f:	e9 53 fc ff ff       	jmp    800ff7 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8013a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013a8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8013af:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8013b1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8013b5:	0f 84 3c fc ff ff    	je     800ff7 <vprintfmt+0x25>
  8013bb:	83 ef 01             	sub    $0x1,%edi
  8013be:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8013c2:	75 f7                	jne    8013bb <vprintfmt+0x3e9>
  8013c4:	e9 2e fc ff ff       	jmp    800ff7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8013c9:	83 c4 4c             	add    $0x4c,%esp
  8013cc:	5b                   	pop    %ebx
  8013cd:	5e                   	pop    %esi
  8013ce:	5f                   	pop    %edi
  8013cf:	5d                   	pop    %ebp
  8013d0:	c3                   	ret    

008013d1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	83 ec 28             	sub    $0x28,%esp
  8013d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013da:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8013dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8013e0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8013e4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8013e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8013ee:	85 d2                	test   %edx,%edx
  8013f0:	7e 30                	jle    801422 <vsnprintf+0x51>
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	74 2c                	je     801422 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8013f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013fd:	8b 45 10             	mov    0x10(%ebp),%eax
  801400:	89 44 24 08          	mov    %eax,0x8(%esp)
  801404:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801407:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140b:	c7 04 24 8d 0f 80 00 	movl   $0x800f8d,(%esp)
  801412:	e8 bb fb ff ff       	call   800fd2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801417:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80141a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80141d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801420:	eb 05                	jmp    801427 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801422:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80142f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801432:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801436:	8b 45 10             	mov    0x10(%ebp),%eax
  801439:	89 44 24 08          	mov    %eax,0x8(%esp)
  80143d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801440:	89 44 24 04          	mov    %eax,0x4(%esp)
  801444:	8b 45 08             	mov    0x8(%ebp),%eax
  801447:	89 04 24             	mov    %eax,(%esp)
  80144a:	e8 82 ff ff ff       	call   8013d1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80144f:	c9                   	leave  
  801450:	c3                   	ret    
  801451:	66 90                	xchg   %ax,%ax
  801453:	66 90                	xchg   %ax,%ax
  801455:	66 90                	xchg   %ax,%ax
  801457:	66 90                	xchg   %ax,%ax
  801459:	66 90                	xchg   %ax,%ax
  80145b:	66 90                	xchg   %ax,%ax
  80145d:	66 90                	xchg   %ax,%ax
  80145f:	90                   	nop

00801460 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801466:	80 3a 00             	cmpb   $0x0,(%edx)
  801469:	74 10                	je     80147b <strlen+0x1b>
  80146b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801470:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801473:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801477:	75 f7                	jne    801470 <strlen+0x10>
  801479:	eb 05                	jmp    801480 <strlen+0x20>
  80147b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    

00801482 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	53                   	push   %ebx
  801486:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801489:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80148c:	85 c9                	test   %ecx,%ecx
  80148e:	74 1c                	je     8014ac <strnlen+0x2a>
  801490:	80 3b 00             	cmpb   $0x0,(%ebx)
  801493:	74 1e                	je     8014b3 <strnlen+0x31>
  801495:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80149a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80149c:	39 ca                	cmp    %ecx,%edx
  80149e:	74 18                	je     8014b8 <strnlen+0x36>
  8014a0:	83 c2 01             	add    $0x1,%edx
  8014a3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8014a8:	75 f0                	jne    80149a <strnlen+0x18>
  8014aa:	eb 0c                	jmp    8014b8 <strnlen+0x36>
  8014ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b1:	eb 05                	jmp    8014b8 <strnlen+0x36>
  8014b3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8014b8:	5b                   	pop    %ebx
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	53                   	push   %ebx
  8014bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8014c5:	89 c2                	mov    %eax,%edx
  8014c7:	0f b6 19             	movzbl (%ecx),%ebx
  8014ca:	88 1a                	mov    %bl,(%edx)
  8014cc:	83 c2 01             	add    $0x1,%edx
  8014cf:	83 c1 01             	add    $0x1,%ecx
  8014d2:	84 db                	test   %bl,%bl
  8014d4:	75 f1                	jne    8014c7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8014d6:	5b                   	pop    %ebx
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    

008014d9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8014e3:	89 1c 24             	mov    %ebx,(%esp)
  8014e6:	e8 75 ff ff ff       	call   801460 <strlen>
	strcpy(dst + len, src);
  8014eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014f2:	01 d8                	add    %ebx,%eax
  8014f4:	89 04 24             	mov    %eax,(%esp)
  8014f7:	e8 bf ff ff ff       	call   8014bb <strcpy>
	return dst;
}
  8014fc:	89 d8                	mov    %ebx,%eax
  8014fe:	83 c4 08             	add    $0x8,%esp
  801501:	5b                   	pop    %ebx
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    

00801504 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	56                   	push   %esi
  801508:	53                   	push   %ebx
  801509:	8b 75 08             	mov    0x8(%ebp),%esi
  80150c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801512:	85 db                	test   %ebx,%ebx
  801514:	74 16                	je     80152c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  801516:	01 f3                	add    %esi,%ebx
  801518:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80151a:	0f b6 02             	movzbl (%edx),%eax
  80151d:	88 01                	mov    %al,(%ecx)
  80151f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801522:	80 3a 01             	cmpb   $0x1,(%edx)
  801525:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801528:	39 d9                	cmp    %ebx,%ecx
  80152a:	75 ee                	jne    80151a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80152c:	89 f0                	mov    %esi,%eax
  80152e:	5b                   	pop    %ebx
  80152f:	5e                   	pop    %esi
  801530:	5d                   	pop    %ebp
  801531:	c3                   	ret    

00801532 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	57                   	push   %edi
  801536:	56                   	push   %esi
  801537:	53                   	push   %ebx
  801538:	8b 7d 08             	mov    0x8(%ebp),%edi
  80153b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80153e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801541:	89 f8                	mov    %edi,%eax
  801543:	85 f6                	test   %esi,%esi
  801545:	74 33                	je     80157a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  801547:	83 fe 01             	cmp    $0x1,%esi
  80154a:	74 25                	je     801571 <strlcpy+0x3f>
  80154c:	0f b6 0b             	movzbl (%ebx),%ecx
  80154f:	84 c9                	test   %cl,%cl
  801551:	74 22                	je     801575 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801553:	83 ee 02             	sub    $0x2,%esi
  801556:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80155b:	88 08                	mov    %cl,(%eax)
  80155d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801560:	39 f2                	cmp    %esi,%edx
  801562:	74 13                	je     801577 <strlcpy+0x45>
  801564:	83 c2 01             	add    $0x1,%edx
  801567:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80156b:	84 c9                	test   %cl,%cl
  80156d:	75 ec                	jne    80155b <strlcpy+0x29>
  80156f:	eb 06                	jmp    801577 <strlcpy+0x45>
  801571:	89 f8                	mov    %edi,%eax
  801573:	eb 02                	jmp    801577 <strlcpy+0x45>
  801575:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801577:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80157a:	29 f8                	sub    %edi,%eax
}
  80157c:	5b                   	pop    %ebx
  80157d:	5e                   	pop    %esi
  80157e:	5f                   	pop    %edi
  80157f:	5d                   	pop    %ebp
  801580:	c3                   	ret    

00801581 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801587:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80158a:	0f b6 01             	movzbl (%ecx),%eax
  80158d:	84 c0                	test   %al,%al
  80158f:	74 15                	je     8015a6 <strcmp+0x25>
  801591:	3a 02                	cmp    (%edx),%al
  801593:	75 11                	jne    8015a6 <strcmp+0x25>
		p++, q++;
  801595:	83 c1 01             	add    $0x1,%ecx
  801598:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80159b:	0f b6 01             	movzbl (%ecx),%eax
  80159e:	84 c0                	test   %al,%al
  8015a0:	74 04                	je     8015a6 <strcmp+0x25>
  8015a2:	3a 02                	cmp    (%edx),%al
  8015a4:	74 ef                	je     801595 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8015a6:	0f b6 c0             	movzbl %al,%eax
  8015a9:	0f b6 12             	movzbl (%edx),%edx
  8015ac:	29 d0                	sub    %edx,%eax
}
  8015ae:	5d                   	pop    %ebp
  8015af:	c3                   	ret    

008015b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	56                   	push   %esi
  8015b4:	53                   	push   %ebx
  8015b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8015b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015bb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8015be:	85 f6                	test   %esi,%esi
  8015c0:	74 29                	je     8015eb <strncmp+0x3b>
  8015c2:	0f b6 03             	movzbl (%ebx),%eax
  8015c5:	84 c0                	test   %al,%al
  8015c7:	74 30                	je     8015f9 <strncmp+0x49>
  8015c9:	3a 02                	cmp    (%edx),%al
  8015cb:	75 2c                	jne    8015f9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8015cd:	8d 43 01             	lea    0x1(%ebx),%eax
  8015d0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8015d2:	89 c3                	mov    %eax,%ebx
  8015d4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8015d7:	39 f0                	cmp    %esi,%eax
  8015d9:	74 17                	je     8015f2 <strncmp+0x42>
  8015db:	0f b6 08             	movzbl (%eax),%ecx
  8015de:	84 c9                	test   %cl,%cl
  8015e0:	74 17                	je     8015f9 <strncmp+0x49>
  8015e2:	83 c0 01             	add    $0x1,%eax
  8015e5:	3a 0a                	cmp    (%edx),%cl
  8015e7:	74 e9                	je     8015d2 <strncmp+0x22>
  8015e9:	eb 0e                	jmp    8015f9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8015eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f0:	eb 0f                	jmp    801601 <strncmp+0x51>
  8015f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f7:	eb 08                	jmp    801601 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8015f9:	0f b6 03             	movzbl (%ebx),%eax
  8015fc:	0f b6 12             	movzbl (%edx),%edx
  8015ff:	29 d0                	sub    %edx,%eax
}
  801601:	5b                   	pop    %ebx
  801602:	5e                   	pop    %esi
  801603:	5d                   	pop    %ebp
  801604:	c3                   	ret    

00801605 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	53                   	push   %ebx
  801609:	8b 45 08             	mov    0x8(%ebp),%eax
  80160c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  80160f:	0f b6 18             	movzbl (%eax),%ebx
  801612:	84 db                	test   %bl,%bl
  801614:	74 1d                	je     801633 <strchr+0x2e>
  801616:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  801618:	38 d3                	cmp    %dl,%bl
  80161a:	75 06                	jne    801622 <strchr+0x1d>
  80161c:	eb 1a                	jmp    801638 <strchr+0x33>
  80161e:	38 ca                	cmp    %cl,%dl
  801620:	74 16                	je     801638 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801622:	83 c0 01             	add    $0x1,%eax
  801625:	0f b6 10             	movzbl (%eax),%edx
  801628:	84 d2                	test   %dl,%dl
  80162a:	75 f2                	jne    80161e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  80162c:	b8 00 00 00 00       	mov    $0x0,%eax
  801631:	eb 05                	jmp    801638 <strchr+0x33>
  801633:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801638:	5b                   	pop    %ebx
  801639:	5d                   	pop    %ebp
  80163a:	c3                   	ret    

0080163b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	53                   	push   %ebx
  80163f:	8b 45 08             	mov    0x8(%ebp),%eax
  801642:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801645:	0f b6 18             	movzbl (%eax),%ebx
  801648:	84 db                	test   %bl,%bl
  80164a:	74 16                	je     801662 <strfind+0x27>
  80164c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80164e:	38 d3                	cmp    %dl,%bl
  801650:	75 06                	jne    801658 <strfind+0x1d>
  801652:	eb 0e                	jmp    801662 <strfind+0x27>
  801654:	38 ca                	cmp    %cl,%dl
  801656:	74 0a                	je     801662 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801658:	83 c0 01             	add    $0x1,%eax
  80165b:	0f b6 10             	movzbl (%eax),%edx
  80165e:	84 d2                	test   %dl,%dl
  801660:	75 f2                	jne    801654 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  801662:	5b                   	pop    %ebx
  801663:	5d                   	pop    %ebp
  801664:	c3                   	ret    

00801665 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	83 ec 0c             	sub    $0xc,%esp
  80166b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80166e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801671:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801674:	8b 7d 08             	mov    0x8(%ebp),%edi
  801677:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80167a:	85 c9                	test   %ecx,%ecx
  80167c:	74 36                	je     8016b4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80167e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801684:	75 28                	jne    8016ae <memset+0x49>
  801686:	f6 c1 03             	test   $0x3,%cl
  801689:	75 23                	jne    8016ae <memset+0x49>
		c &= 0xFF;
  80168b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80168f:	89 d3                	mov    %edx,%ebx
  801691:	c1 e3 08             	shl    $0x8,%ebx
  801694:	89 d6                	mov    %edx,%esi
  801696:	c1 e6 18             	shl    $0x18,%esi
  801699:	89 d0                	mov    %edx,%eax
  80169b:	c1 e0 10             	shl    $0x10,%eax
  80169e:	09 f0                	or     %esi,%eax
  8016a0:	09 c2                	or     %eax,%edx
  8016a2:	89 d0                	mov    %edx,%eax
  8016a4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8016a6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8016a9:	fc                   	cld    
  8016aa:	f3 ab                	rep stos %eax,%es:(%edi)
  8016ac:	eb 06                	jmp    8016b4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8016ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b1:	fc                   	cld    
  8016b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  8016b4:	89 f8                	mov    %edi,%eax
  8016b6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016b9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016bc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016bf:	89 ec                	mov    %ebp,%esp
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8016cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8016d8:	39 c6                	cmp    %eax,%esi
  8016da:	73 36                	jae    801712 <memmove+0x4f>
  8016dc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8016df:	39 d0                	cmp    %edx,%eax
  8016e1:	73 2f                	jae    801712 <memmove+0x4f>
		s += n;
		d += n;
  8016e3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8016e6:	f6 c2 03             	test   $0x3,%dl
  8016e9:	75 1b                	jne    801706 <memmove+0x43>
  8016eb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8016f1:	75 13                	jne    801706 <memmove+0x43>
  8016f3:	f6 c1 03             	test   $0x3,%cl
  8016f6:	75 0e                	jne    801706 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8016f8:	83 ef 04             	sub    $0x4,%edi
  8016fb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8016fe:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801701:	fd                   	std    
  801702:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801704:	eb 09                	jmp    80170f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801706:	83 ef 01             	sub    $0x1,%edi
  801709:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80170c:	fd                   	std    
  80170d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80170f:	fc                   	cld    
  801710:	eb 20                	jmp    801732 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801712:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801718:	75 13                	jne    80172d <memmove+0x6a>
  80171a:	a8 03                	test   $0x3,%al
  80171c:	75 0f                	jne    80172d <memmove+0x6a>
  80171e:	f6 c1 03             	test   $0x3,%cl
  801721:	75 0a                	jne    80172d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801723:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801726:	89 c7                	mov    %eax,%edi
  801728:	fc                   	cld    
  801729:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80172b:	eb 05                	jmp    801732 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80172d:	89 c7                	mov    %eax,%edi
  80172f:	fc                   	cld    
  801730:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801732:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801735:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801738:	89 ec                	mov    %ebp,%esp
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    

0080173c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801742:	8b 45 10             	mov    0x10(%ebp),%eax
  801745:	89 44 24 08          	mov    %eax,0x8(%esp)
  801749:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801750:	8b 45 08             	mov    0x8(%ebp),%eax
  801753:	89 04 24             	mov    %eax,(%esp)
  801756:	e8 68 ff ff ff       	call   8016c3 <memmove>
}
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	57                   	push   %edi
  801761:	56                   	push   %esi
  801762:	53                   	push   %ebx
  801763:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801766:	8b 75 0c             	mov    0xc(%ebp),%esi
  801769:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80176c:	8d 78 ff             	lea    -0x1(%eax),%edi
  80176f:	85 c0                	test   %eax,%eax
  801771:	74 36                	je     8017a9 <memcmp+0x4c>
		if (*s1 != *s2)
  801773:	0f b6 03             	movzbl (%ebx),%eax
  801776:	0f b6 0e             	movzbl (%esi),%ecx
  801779:	38 c8                	cmp    %cl,%al
  80177b:	75 17                	jne    801794 <memcmp+0x37>
  80177d:	ba 00 00 00 00       	mov    $0x0,%edx
  801782:	eb 1a                	jmp    80179e <memcmp+0x41>
  801784:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801789:	83 c2 01             	add    $0x1,%edx
  80178c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801790:	38 c8                	cmp    %cl,%al
  801792:	74 0a                	je     80179e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801794:	0f b6 c0             	movzbl %al,%eax
  801797:	0f b6 c9             	movzbl %cl,%ecx
  80179a:	29 c8                	sub    %ecx,%eax
  80179c:	eb 10                	jmp    8017ae <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80179e:	39 fa                	cmp    %edi,%edx
  8017a0:	75 e2                	jne    801784 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8017a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a7:	eb 05                	jmp    8017ae <memcmp+0x51>
  8017a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ae:	5b                   	pop    %ebx
  8017af:	5e                   	pop    %esi
  8017b0:	5f                   	pop    %edi
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	53                   	push   %ebx
  8017b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  8017bd:	89 c2                	mov    %eax,%edx
  8017bf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8017c2:	39 d0                	cmp    %edx,%eax
  8017c4:	73 13                	jae    8017d9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  8017c6:	89 d9                	mov    %ebx,%ecx
  8017c8:	38 18                	cmp    %bl,(%eax)
  8017ca:	75 06                	jne    8017d2 <memfind+0x1f>
  8017cc:	eb 0b                	jmp    8017d9 <memfind+0x26>
  8017ce:	38 08                	cmp    %cl,(%eax)
  8017d0:	74 07                	je     8017d9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8017d2:	83 c0 01             	add    $0x1,%eax
  8017d5:	39 d0                	cmp    %edx,%eax
  8017d7:	75 f5                	jne    8017ce <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8017d9:	5b                   	pop    %ebx
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	57                   	push   %edi
  8017e0:	56                   	push   %esi
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 04             	sub    $0x4,%esp
  8017e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8017eb:	0f b6 02             	movzbl (%edx),%eax
  8017ee:	3c 09                	cmp    $0x9,%al
  8017f0:	74 04                	je     8017f6 <strtol+0x1a>
  8017f2:	3c 20                	cmp    $0x20,%al
  8017f4:	75 0e                	jne    801804 <strtol+0x28>
		s++;
  8017f6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8017f9:	0f b6 02             	movzbl (%edx),%eax
  8017fc:	3c 09                	cmp    $0x9,%al
  8017fe:	74 f6                	je     8017f6 <strtol+0x1a>
  801800:	3c 20                	cmp    $0x20,%al
  801802:	74 f2                	je     8017f6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801804:	3c 2b                	cmp    $0x2b,%al
  801806:	75 0a                	jne    801812 <strtol+0x36>
		s++;
  801808:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80180b:	bf 00 00 00 00       	mov    $0x0,%edi
  801810:	eb 10                	jmp    801822 <strtol+0x46>
  801812:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801817:	3c 2d                	cmp    $0x2d,%al
  801819:	75 07                	jne    801822 <strtol+0x46>
		s++, neg = 1;
  80181b:	83 c2 01             	add    $0x1,%edx
  80181e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801822:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801828:	75 15                	jne    80183f <strtol+0x63>
  80182a:	80 3a 30             	cmpb   $0x30,(%edx)
  80182d:	75 10                	jne    80183f <strtol+0x63>
  80182f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801833:	75 0a                	jne    80183f <strtol+0x63>
		s += 2, base = 16;
  801835:	83 c2 02             	add    $0x2,%edx
  801838:	bb 10 00 00 00       	mov    $0x10,%ebx
  80183d:	eb 10                	jmp    80184f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  80183f:	85 db                	test   %ebx,%ebx
  801841:	75 0c                	jne    80184f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801843:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801845:	80 3a 30             	cmpb   $0x30,(%edx)
  801848:	75 05                	jne    80184f <strtol+0x73>
		s++, base = 8;
  80184a:	83 c2 01             	add    $0x1,%edx
  80184d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80184f:	b8 00 00 00 00       	mov    $0x0,%eax
  801854:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801857:	0f b6 0a             	movzbl (%edx),%ecx
  80185a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80185d:	89 f3                	mov    %esi,%ebx
  80185f:	80 fb 09             	cmp    $0x9,%bl
  801862:	77 08                	ja     80186c <strtol+0x90>
			dig = *s - '0';
  801864:	0f be c9             	movsbl %cl,%ecx
  801867:	83 e9 30             	sub    $0x30,%ecx
  80186a:	eb 22                	jmp    80188e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  80186c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80186f:	89 f3                	mov    %esi,%ebx
  801871:	80 fb 19             	cmp    $0x19,%bl
  801874:	77 08                	ja     80187e <strtol+0xa2>
			dig = *s - 'a' + 10;
  801876:	0f be c9             	movsbl %cl,%ecx
  801879:	83 e9 57             	sub    $0x57,%ecx
  80187c:	eb 10                	jmp    80188e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  80187e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801881:	89 f3                	mov    %esi,%ebx
  801883:	80 fb 19             	cmp    $0x19,%bl
  801886:	77 16                	ja     80189e <strtol+0xc2>
			dig = *s - 'A' + 10;
  801888:	0f be c9             	movsbl %cl,%ecx
  80188b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80188e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801891:	7d 0f                	jge    8018a2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801893:	83 c2 01             	add    $0x1,%edx
  801896:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  80189a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80189c:	eb b9                	jmp    801857 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80189e:	89 c1                	mov    %eax,%ecx
  8018a0:	eb 02                	jmp    8018a4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8018a2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8018a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8018a8:	74 05                	je     8018af <strtol+0xd3>
		*endptr = (char *) s;
  8018aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018ad:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8018af:	89 ca                	mov    %ecx,%edx
  8018b1:	f7 da                	neg    %edx
  8018b3:	85 ff                	test   %edi,%edi
  8018b5:	0f 45 c2             	cmovne %edx,%eax
}
  8018b8:	83 c4 04             	add    $0x4,%esp
  8018bb:	5b                   	pop    %ebx
  8018bc:	5e                   	pop    %esi
  8018bd:	5f                   	pop    %edi
  8018be:	5d                   	pop    %ebp
  8018bf:	c3                   	ret    

008018c0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	56                   	push   %esi
  8018c4:	53                   	push   %ebx
  8018c5:	83 ec 10             	sub    $0x10,%esp
  8018c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8018cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  8018ce:	85 db                	test   %ebx,%ebx
  8018d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8018d5:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  8018d8:	89 1c 24             	mov    %ebx,(%esp)
  8018db:	e8 f5 eb ff ff       	call   8004d5 <sys_ipc_recv>
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 2d                	js     801911 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  8018e4:	85 f6                	test   %esi,%esi
  8018e6:	74 0a                	je     8018f2 <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  8018e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8018ed:	8b 40 74             	mov    0x74(%eax),%eax
  8018f0:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  8018f2:	85 db                	test   %ebx,%ebx
  8018f4:	74 13                	je     801909 <ipc_recv+0x49>
  8018f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018fa:	74 0d                	je     801909 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  8018fc:	a1 04 40 80 00       	mov    0x804004,%eax
  801901:	8b 40 78             	mov    0x78(%eax),%eax
  801904:	8b 55 10             	mov    0x10(%ebp),%edx
  801907:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801909:	a1 04 40 80 00       	mov    0x804004,%eax
  80190e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	5b                   	pop    %ebx
  801915:	5e                   	pop    %esi
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	57                   	push   %edi
  80191c:	56                   	push   %esi
  80191d:	53                   	push   %ebx
  80191e:	83 ec 1c             	sub    $0x1c,%esp
  801921:	8b 7d 08             	mov    0x8(%ebp),%edi
  801924:	8b 75 0c             	mov    0xc(%ebp),%esi
  801927:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  80192a:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  80192c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801931:	0f 44 d8             	cmove  %eax,%ebx
  801934:	eb 2a                	jmp    801960 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  801936:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801939:	74 20                	je     80195b <ipc_send+0x43>
            panic("Send message error %e\n",r);
  80193b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80193f:	c7 44 24 08 00 21 80 	movl   $0x802100,0x8(%esp)
  801946:	00 
  801947:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80194e:	00 
  80194f:	c7 04 24 17 21 80 00 	movl   $0x802117,(%esp)
  801956:	e8 e5 f3 ff ff       	call   800d40 <_panic>
		sys_yield();
  80195b:	e8 94 e8 ff ff       	call   8001f4 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801960:	8b 45 14             	mov    0x14(%ebp),%eax
  801963:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801967:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80196b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80196f:	89 3c 24             	mov    %edi,(%esp)
  801972:	e8 21 eb ff ff       	call   800498 <sys_ipc_try_send>
  801977:	85 c0                	test   %eax,%eax
  801979:	78 bb                	js     801936 <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  80197b:	83 c4 1c             	add    $0x1c,%esp
  80197e:	5b                   	pop    %ebx
  80197f:	5e                   	pop    %esi
  801980:	5f                   	pop    %edi
  801981:	5d                   	pop    %ebp
  801982:	c3                   	ret    

00801983 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801989:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80198e:	39 c8                	cmp    %ecx,%eax
  801990:	74 17                	je     8019a9 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801992:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801997:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80199a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8019a0:	8b 52 50             	mov    0x50(%edx),%edx
  8019a3:	39 ca                	cmp    %ecx,%edx
  8019a5:	75 14                	jne    8019bb <ipc_find_env+0x38>
  8019a7:	eb 05                	jmp    8019ae <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8019a9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8019ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8019b1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8019b6:	8b 40 40             	mov    0x40(%eax),%eax
  8019b9:	eb 0e                	jmp    8019c9 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8019bb:	83 c0 01             	add    $0x1,%eax
  8019be:	3d 00 04 00 00       	cmp    $0x400,%eax
  8019c3:	75 d2                	jne    801997 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8019c5:	66 b8 00 00          	mov    $0x0,%ax
}
  8019c9:	5d                   	pop    %ebp
  8019ca:	c3                   	ret    
  8019cb:	66 90                	xchg   %ax,%ax
  8019cd:	66 90                	xchg   %ax,%ax
  8019cf:	90                   	nop

008019d0 <__udivdi3>:
  8019d0:	83 ec 1c             	sub    $0x1c,%esp
  8019d3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8019d7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8019db:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8019df:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8019e3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8019e7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	89 74 24 10          	mov    %esi,0x10(%esp)
  8019f1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8019f5:	89 ea                	mov    %ebp,%edx
  8019f7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019fb:	75 33                	jne    801a30 <__udivdi3+0x60>
  8019fd:	39 e9                	cmp    %ebp,%ecx
  8019ff:	77 6f                	ja     801a70 <__udivdi3+0xa0>
  801a01:	85 c9                	test   %ecx,%ecx
  801a03:	89 ce                	mov    %ecx,%esi
  801a05:	75 0b                	jne    801a12 <__udivdi3+0x42>
  801a07:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0c:	31 d2                	xor    %edx,%edx
  801a0e:	f7 f1                	div    %ecx
  801a10:	89 c6                	mov    %eax,%esi
  801a12:	31 d2                	xor    %edx,%edx
  801a14:	89 e8                	mov    %ebp,%eax
  801a16:	f7 f6                	div    %esi
  801a18:	89 c5                	mov    %eax,%ebp
  801a1a:	89 f8                	mov    %edi,%eax
  801a1c:	f7 f6                	div    %esi
  801a1e:	89 ea                	mov    %ebp,%edx
  801a20:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a24:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a28:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a2c:	83 c4 1c             	add    $0x1c,%esp
  801a2f:	c3                   	ret    
  801a30:	39 e8                	cmp    %ebp,%eax
  801a32:	77 24                	ja     801a58 <__udivdi3+0x88>
  801a34:	0f bd c8             	bsr    %eax,%ecx
  801a37:	83 f1 1f             	xor    $0x1f,%ecx
  801a3a:	89 0c 24             	mov    %ecx,(%esp)
  801a3d:	75 49                	jne    801a88 <__udivdi3+0xb8>
  801a3f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801a43:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801a47:	0f 86 ab 00 00 00    	jbe    801af8 <__udivdi3+0x128>
  801a4d:	39 e8                	cmp    %ebp,%eax
  801a4f:	0f 82 a3 00 00 00    	jb     801af8 <__udivdi3+0x128>
  801a55:	8d 76 00             	lea    0x0(%esi),%esi
  801a58:	31 d2                	xor    %edx,%edx
  801a5a:	31 c0                	xor    %eax,%eax
  801a5c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a60:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a64:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a68:	83 c4 1c             	add    $0x1c,%esp
  801a6b:	c3                   	ret    
  801a6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a70:	89 f8                	mov    %edi,%eax
  801a72:	f7 f1                	div    %ecx
  801a74:	31 d2                	xor    %edx,%edx
  801a76:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a7a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a7e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a82:	83 c4 1c             	add    $0x1c,%esp
  801a85:	c3                   	ret    
  801a86:	66 90                	xchg   %ax,%ax
  801a88:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a8c:	89 c6                	mov    %eax,%esi
  801a8e:	b8 20 00 00 00       	mov    $0x20,%eax
  801a93:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801a97:	2b 04 24             	sub    (%esp),%eax
  801a9a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801a9e:	d3 e6                	shl    %cl,%esi
  801aa0:	89 c1                	mov    %eax,%ecx
  801aa2:	d3 ed                	shr    %cl,%ebp
  801aa4:	0f b6 0c 24          	movzbl (%esp),%ecx
  801aa8:	09 f5                	or     %esi,%ebp
  801aaa:	8b 74 24 04          	mov    0x4(%esp),%esi
  801aae:	d3 e6                	shl    %cl,%esi
  801ab0:	89 c1                	mov    %eax,%ecx
  801ab2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ab6:	89 d6                	mov    %edx,%esi
  801ab8:	d3 ee                	shr    %cl,%esi
  801aba:	0f b6 0c 24          	movzbl (%esp),%ecx
  801abe:	d3 e2                	shl    %cl,%edx
  801ac0:	89 c1                	mov    %eax,%ecx
  801ac2:	d3 ef                	shr    %cl,%edi
  801ac4:	09 d7                	or     %edx,%edi
  801ac6:	89 f2                	mov    %esi,%edx
  801ac8:	89 f8                	mov    %edi,%eax
  801aca:	f7 f5                	div    %ebp
  801acc:	89 d6                	mov    %edx,%esi
  801ace:	89 c7                	mov    %eax,%edi
  801ad0:	f7 64 24 04          	mull   0x4(%esp)
  801ad4:	39 d6                	cmp    %edx,%esi
  801ad6:	72 30                	jb     801b08 <__udivdi3+0x138>
  801ad8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801adc:	0f b6 0c 24          	movzbl (%esp),%ecx
  801ae0:	d3 e5                	shl    %cl,%ebp
  801ae2:	39 c5                	cmp    %eax,%ebp
  801ae4:	73 04                	jae    801aea <__udivdi3+0x11a>
  801ae6:	39 d6                	cmp    %edx,%esi
  801ae8:	74 1e                	je     801b08 <__udivdi3+0x138>
  801aea:	89 f8                	mov    %edi,%eax
  801aec:	31 d2                	xor    %edx,%edx
  801aee:	e9 69 ff ff ff       	jmp    801a5c <__udivdi3+0x8c>
  801af3:	90                   	nop
  801af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801af8:	31 d2                	xor    %edx,%edx
  801afa:	b8 01 00 00 00       	mov    $0x1,%eax
  801aff:	e9 58 ff ff ff       	jmp    801a5c <__udivdi3+0x8c>
  801b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b08:	8d 47 ff             	lea    -0x1(%edi),%eax
  801b0b:	31 d2                	xor    %edx,%edx
  801b0d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b11:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b15:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b19:	83 c4 1c             	add    $0x1c,%esp
  801b1c:	c3                   	ret    
  801b1d:	66 90                	xchg   %ax,%ax
  801b1f:	90                   	nop

00801b20 <__umoddi3>:
  801b20:	83 ec 2c             	sub    $0x2c,%esp
  801b23:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b27:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801b2b:	89 74 24 20          	mov    %esi,0x20(%esp)
  801b2f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801b33:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801b37:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	89 c2                	mov    %eax,%edx
  801b3f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801b43:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801b47:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b4b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801b4f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b53:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801b57:	75 1f                	jne    801b78 <__umoddi3+0x58>
  801b59:	39 fe                	cmp    %edi,%esi
  801b5b:	76 63                	jbe    801bc0 <__umoddi3+0xa0>
  801b5d:	89 c8                	mov    %ecx,%eax
  801b5f:	89 fa                	mov    %edi,%edx
  801b61:	f7 f6                	div    %esi
  801b63:	89 d0                	mov    %edx,%eax
  801b65:	31 d2                	xor    %edx,%edx
  801b67:	8b 74 24 20          	mov    0x20(%esp),%esi
  801b6b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801b6f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801b73:	83 c4 2c             	add    $0x2c,%esp
  801b76:	c3                   	ret    
  801b77:	90                   	nop
  801b78:	39 f8                	cmp    %edi,%eax
  801b7a:	77 64                	ja     801be0 <__umoddi3+0xc0>
  801b7c:	0f bd e8             	bsr    %eax,%ebp
  801b7f:	83 f5 1f             	xor    $0x1f,%ebp
  801b82:	75 74                	jne    801bf8 <__umoddi3+0xd8>
  801b84:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b88:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801b8c:	0f 87 0e 01 00 00    	ja     801ca0 <__umoddi3+0x180>
  801b92:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801b96:	29 f1                	sub    %esi,%ecx
  801b98:	19 c7                	sbb    %eax,%edi
  801b9a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b9e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801ba2:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ba6:	8b 54 24 18          	mov    0x18(%esp),%edx
  801baa:	8b 74 24 20          	mov    0x20(%esp),%esi
  801bae:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801bb2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801bb6:	83 c4 2c             	add    $0x2c,%esp
  801bb9:	c3                   	ret    
  801bba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bc0:	85 f6                	test   %esi,%esi
  801bc2:	89 f5                	mov    %esi,%ebp
  801bc4:	75 0b                	jne    801bd1 <__umoddi3+0xb1>
  801bc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bcb:	31 d2                	xor    %edx,%edx
  801bcd:	f7 f6                	div    %esi
  801bcf:	89 c5                	mov    %eax,%ebp
  801bd1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801bd5:	31 d2                	xor    %edx,%edx
  801bd7:	f7 f5                	div    %ebp
  801bd9:	89 c8                	mov    %ecx,%eax
  801bdb:	f7 f5                	div    %ebp
  801bdd:	eb 84                	jmp    801b63 <__umoddi3+0x43>
  801bdf:	90                   	nop
  801be0:	89 c8                	mov    %ecx,%eax
  801be2:	89 fa                	mov    %edi,%edx
  801be4:	8b 74 24 20          	mov    0x20(%esp),%esi
  801be8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801bec:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801bf0:	83 c4 2c             	add    $0x2c,%esp
  801bf3:	c3                   	ret    
  801bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf8:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bfc:	be 20 00 00 00       	mov    $0x20,%esi
  801c01:	89 e9                	mov    %ebp,%ecx
  801c03:	29 ee                	sub    %ebp,%esi
  801c05:	d3 e2                	shl    %cl,%edx
  801c07:	89 f1                	mov    %esi,%ecx
  801c09:	d3 e8                	shr    %cl,%eax
  801c0b:	89 e9                	mov    %ebp,%ecx
  801c0d:	09 d0                	or     %edx,%eax
  801c0f:	89 fa                	mov    %edi,%edx
  801c11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c15:	8b 44 24 10          	mov    0x10(%esp),%eax
  801c19:	d3 e0                	shl    %cl,%eax
  801c1b:	89 f1                	mov    %esi,%ecx
  801c1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c21:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801c25:	d3 ea                	shr    %cl,%edx
  801c27:	89 e9                	mov    %ebp,%ecx
  801c29:	d3 e7                	shl    %cl,%edi
  801c2b:	89 f1                	mov    %esi,%ecx
  801c2d:	d3 e8                	shr    %cl,%eax
  801c2f:	89 e9                	mov    %ebp,%ecx
  801c31:	09 f8                	or     %edi,%eax
  801c33:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801c37:	f7 74 24 0c          	divl   0xc(%esp)
  801c3b:	d3 e7                	shl    %cl,%edi
  801c3d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c41:	89 d7                	mov    %edx,%edi
  801c43:	f7 64 24 10          	mull   0x10(%esp)
  801c47:	39 d7                	cmp    %edx,%edi
  801c49:	89 c1                	mov    %eax,%ecx
  801c4b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801c4f:	72 3b                	jb     801c8c <__umoddi3+0x16c>
  801c51:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801c55:	72 31                	jb     801c88 <__umoddi3+0x168>
  801c57:	8b 44 24 18          	mov    0x18(%esp),%eax
  801c5b:	29 c8                	sub    %ecx,%eax
  801c5d:	19 d7                	sbb    %edx,%edi
  801c5f:	89 e9                	mov    %ebp,%ecx
  801c61:	89 fa                	mov    %edi,%edx
  801c63:	d3 e8                	shr    %cl,%eax
  801c65:	89 f1                	mov    %esi,%ecx
  801c67:	d3 e2                	shl    %cl,%edx
  801c69:	89 e9                	mov    %ebp,%ecx
  801c6b:	09 d0                	or     %edx,%eax
  801c6d:	89 fa                	mov    %edi,%edx
  801c6f:	d3 ea                	shr    %cl,%edx
  801c71:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c75:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c79:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c7d:	83 c4 2c             	add    $0x2c,%esp
  801c80:	c3                   	ret    
  801c81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c88:	39 d7                	cmp    %edx,%edi
  801c8a:	75 cb                	jne    801c57 <__umoddi3+0x137>
  801c8c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801c90:	89 c1                	mov    %eax,%ecx
  801c92:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801c96:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801c9a:	eb bb                	jmp    801c57 <__umoddi3+0x137>
  801c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801ca4:	0f 82 e8 fe ff ff    	jb     801b92 <__umoddi3+0x72>
  801caa:	e9 f3 fe ff ff       	jmp    801ba2 <__umoddi3+0x82>
