
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 20 05 80 	movl   $0x800520,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 c7 03 00 00       	call   800415 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
  80005a:	66 90                	xchg   %ax,%ax

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	83 ec 18             	sub    $0x18,%esp
  800062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800065:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800068:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  80006e:	e8 2c 01 00 00       	call   80019f <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 db                	test   %ebx,%ebx
  800087:	7e 07                	jle    800090 <libmain+0x34>
		binaryname = argv[0];
  800089:	8b 06                	mov    (%esi),%eax
  80008b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800090:	89 74 24 04          	mov    %esi,0x4(%esp)
  800094:	89 1c 24             	mov    %ebx,(%esp)
  800097:	e8 98 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0b 00 00 00       	call   8000ac <exit>
}
  8000a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a7:	89 ec                	mov    %ebp,%esp
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    
  8000ab:	90                   	nop

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b2:	e8 9c 06 00 00       	call   800753 <close_all>
	sys_env_destroy(0);
  8000b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000be:	e8 76 00 00 00       	call   800139 <sys_env_destroy>
}
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    
  8000c5:	66 90                	xchg   %ax,%ax
  8000c7:	90                   	nop

008000c8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 0c             	sub    $0xc,%esp
  8000ce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000d1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000d4:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	0f a2                	cpuid  
  8000de:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000eb:	89 c3                	mov    %eax,%ebx
  8000ed:	89 c7                	mov    %eax,%edi
  8000ef:	89 c6                	mov    %eax,%esi
  8000f1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000f6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000f9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000fc:	89 ec                	mov    %ebp,%esp
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    

00800100 <sys_cgetc>:

int
sys_cgetc(void)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800109:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80010c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80010f:	b8 01 00 00 00       	mov    $0x1,%eax
  800114:	0f a2                	cpuid  
  800116:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	b8 01 00 00 00       	mov    $0x1,%eax
  800122:	89 d1                	mov    %edx,%ecx
  800124:	89 d3                	mov    %edx,%ebx
  800126:	89 d7                	mov    %edx,%edi
  800128:	89 d6                	mov    %edx,%esi
  80012a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80012c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80012f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800132:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800135:	89 ec                	mov    %ebp,%esp
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    

00800139 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 38             	sub    $0x38,%esp
  80013f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800142:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800145:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800148:	b8 01 00 00 00       	mov    $0x1,%eax
  80014d:	0f a2                	cpuid  
  80014f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	b9 00 00 00 00       	mov    $0x0,%ecx
  800156:	b8 03 00 00 00       	mov    $0x3,%eax
  80015b:	8b 55 08             	mov    0x8(%ebp),%edx
  80015e:	89 cb                	mov    %ecx,%ebx
  800160:	89 cf                	mov    %ecx,%edi
  800162:	89 ce                	mov    %ecx,%esi
  800164:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800166:	85 c0                	test   %eax,%eax
  800168:	7e 28                	jle    800192 <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  80016a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80016e:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800175:	00 
  800176:	c7 44 24 08 4a 1d 80 	movl   $0x801d4a,0x8(%esp)
  80017d:	00 
  80017e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800185:	00 
  800186:	c7 04 24 67 1d 80 00 	movl   $0x801d67,(%esp)
  80018d:	e8 be 0b 00 00       	call   800d50 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800192:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800195:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800198:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    

0080019f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001a8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001ab:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8001ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8001b3:	0f a2                	cpuid  
  8001b5:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8001c1:	89 d1                	mov    %edx,%ecx
  8001c3:	89 d3                	mov    %edx,%ebx
  8001c5:	89 d7                	mov    %edx,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001cb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ce:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001d1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001d4:	89 ec                	mov    %ebp,%esp
  8001d6:	5d                   	pop    %ebp
  8001d7:	c3                   	ret    

008001d8 <sys_yield>:

void
sys_yield(void)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 0c             	sub    $0xc,%esp
  8001de:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001e1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001e4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8001e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8001ec:	0f a2                	cpuid  
  8001ee:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001f5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001fa:	89 d1                	mov    %edx,%ecx
  8001fc:	89 d3                	mov    %edx,%ebx
  8001fe:	89 d7                	mov    %edx,%edi
  800200:	89 d6                	mov    %edx,%esi
  800202:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800204:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800207:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80020a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80020d:	89 ec                	mov    %ebp,%esp
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    

00800211 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	83 ec 38             	sub    $0x38,%esp
  800217:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80021a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80021d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800220:	b8 01 00 00 00       	mov    $0x1,%eax
  800225:	0f a2                	cpuid  
  800227:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800229:	be 00 00 00 00       	mov    $0x0,%esi
  80022e:	b8 04 00 00 00       	mov    $0x4,%eax
  800233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800236:	8b 55 08             	mov    0x8(%ebp),%edx
  800239:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80023c:	89 f7                	mov    %esi,%edi
  80023e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 28                	jle    80026c <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	89 44 24 10          	mov    %eax,0x10(%esp)
  800248:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80024f:	00 
  800250:	c7 44 24 08 4a 1d 80 	movl   $0x801d4a,0x8(%esp)
  800257:	00 
  800258:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80025f:	00 
  800260:	c7 04 24 67 1d 80 00 	movl   $0x801d67,(%esp)
  800267:	e8 e4 0a 00 00       	call   800d50 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80026c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80026f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800272:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800275:	89 ec                	mov    %ebp,%esp
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	83 ec 38             	sub    $0x38,%esp
  80027f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800282:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800285:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800288:	b8 01 00 00 00       	mov    $0x1,%eax
  80028d:	0f a2                	cpuid  
  80028f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800291:	b8 05 00 00 00       	mov    $0x5,%eax
  800296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800299:	8b 55 08             	mov    0x8(%ebp),%edx
  80029c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80029f:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002a2:	8b 75 18             	mov    0x18(%ebp),%esi
  8002a5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a7:	85 c0                	test   %eax,%eax
  8002a9:	7e 28                	jle    8002d3 <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002af:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8002b6:	00 
  8002b7:	c7 44 24 08 4a 1d 80 	movl   $0x801d4a,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 67 1d 80 00 	movl   $0x801d67,(%esp)
  8002ce:	e8 7d 0a 00 00       	call   800d50 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002d3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002d6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002d9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002dc:	89 ec                	mov    %ebp,%esp
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	83 ec 38             	sub    $0x38,%esp
  8002e6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002e9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002ec:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8002ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8002f4:	0f a2                	cpuid  
  8002f6:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800302:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800305:	8b 55 08             	mov    0x8(%ebp),%edx
  800308:	89 df                	mov    %ebx,%edi
  80030a:	89 de                	mov    %ebx,%esi
  80030c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80030e:	85 c0                	test   %eax,%eax
  800310:	7e 28                	jle    80033a <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800312:	89 44 24 10          	mov    %eax,0x10(%esp)
  800316:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80031d:	00 
  80031e:	c7 44 24 08 4a 1d 80 	movl   $0x801d4a,0x8(%esp)
  800325:	00 
  800326:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80032d:	00 
  80032e:	c7 04 24 67 1d 80 00 	movl   $0x801d67,(%esp)
  800335:	e8 16 0a 00 00       	call   800d50 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80033a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80033d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800340:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800343:	89 ec                	mov    %ebp,%esp
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	83 ec 38             	sub    $0x38,%esp
  80034d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800350:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800353:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800356:	b8 01 00 00 00       	mov    $0x1,%eax
  80035b:	0f a2                	cpuid  
  80035d:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800364:	b8 08 00 00 00       	mov    $0x8,%eax
  800369:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80036c:	8b 55 08             	mov    0x8(%ebp),%edx
  80036f:	89 df                	mov    %ebx,%edi
  800371:	89 de                	mov    %ebx,%esi
  800373:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800375:	85 c0                	test   %eax,%eax
  800377:	7e 28                	jle    8003a1 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800379:	89 44 24 10          	mov    %eax,0x10(%esp)
  80037d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800384:	00 
  800385:	c7 44 24 08 4a 1d 80 	movl   $0x801d4a,0x8(%esp)
  80038c:	00 
  80038d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800394:	00 
  800395:	c7 04 24 67 1d 80 00 	movl   $0x801d67,(%esp)
  80039c:	e8 af 09 00 00       	call   800d50 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8003a1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003a4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003a7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003aa:	89 ec                	mov    %ebp,%esp
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	83 ec 38             	sub    $0x38,%esp
  8003b4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003b7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003ba:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8003bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8003c2:	0f a2                	cpuid  
  8003c4:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003cb:	b8 09 00 00 00       	mov    $0x9,%eax
  8003d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d6:	89 df                	mov    %ebx,%edi
  8003d8:	89 de                	mov    %ebx,%esi
  8003da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003dc:	85 c0                	test   %eax,%eax
  8003de:	7e 28                	jle    800408 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003e4:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003eb:	00 
  8003ec:	c7 44 24 08 4a 1d 80 	movl   $0x801d4a,0x8(%esp)
  8003f3:	00 
  8003f4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8003fb:	00 
  8003fc:	c7 04 24 67 1d 80 00 	movl   $0x801d67,(%esp)
  800403:	e8 48 09 00 00       	call   800d50 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800408:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80040b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80040e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800411:	89 ec                	mov    %ebp,%esp
  800413:	5d                   	pop    %ebp
  800414:	c3                   	ret    

00800415 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	83 ec 38             	sub    $0x38,%esp
  80041b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80041e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800421:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800424:	b8 01 00 00 00       	mov    $0x1,%eax
  800429:	0f a2                	cpuid  
  80042b:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80042d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800432:	b8 0a 00 00 00       	mov    $0xa,%eax
  800437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043a:	8b 55 08             	mov    0x8(%ebp),%edx
  80043d:	89 df                	mov    %ebx,%edi
  80043f:	89 de                	mov    %ebx,%esi
  800441:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800443:	85 c0                	test   %eax,%eax
  800445:	7e 28                	jle    80046f <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800447:	89 44 24 10          	mov    %eax,0x10(%esp)
  80044b:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800452:	00 
  800453:	c7 44 24 08 4a 1d 80 	movl   $0x801d4a,0x8(%esp)
  80045a:	00 
  80045b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800462:	00 
  800463:	c7 04 24 67 1d 80 00 	movl   $0x801d67,(%esp)
  80046a:	e8 e1 08 00 00       	call   800d50 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80046f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800472:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800475:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800478:	89 ec                	mov    %ebp,%esp
  80047a:	5d                   	pop    %ebp
  80047b:	c3                   	ret    

0080047c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
  80047f:	83 ec 0c             	sub    $0xc,%esp
  800482:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800485:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800488:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80048b:	b8 01 00 00 00       	mov    $0x1,%eax
  800490:	0f a2                	cpuid  
  800492:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800494:	be 00 00 00 00       	mov    $0x0,%esi
  800499:	b8 0c 00 00 00       	mov    $0xc,%eax
  80049e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8004aa:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8004ac:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8004af:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8004b2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004b5:	89 ec                	mov    %ebp,%esp
  8004b7:	5d                   	pop    %ebp
  8004b8:	c3                   	ret    

008004b9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8004b9:	55                   	push   %ebp
  8004ba:	89 e5                	mov    %esp,%ebp
  8004bc:	83 ec 38             	sub    $0x38,%esp
  8004bf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8004c2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8004c5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8004c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8004cd:	0f a2                	cpuid  
  8004cf:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8004db:	8b 55 08             	mov    0x8(%ebp),%edx
  8004de:	89 cb                	mov    %ecx,%ebx
  8004e0:	89 cf                	mov    %ecx,%edi
  8004e2:	89 ce                	mov    %ecx,%esi
  8004e4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004e6:	85 c0                	test   %eax,%eax
  8004e8:	7e 28                	jle    800512 <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004ee:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8004f5:	00 
  8004f6:	c7 44 24 08 4a 1d 80 	movl   $0x801d4a,0x8(%esp)
  8004fd:	00 
  8004fe:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800505:	00 
  800506:	c7 04 24 67 1d 80 00 	movl   $0x801d67,(%esp)
  80050d:	e8 3e 08 00 00       	call   800d50 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800512:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800515:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800518:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80051b:	89 ec                	mov    %ebp,%esp
  80051d:	5d                   	pop    %ebp
  80051e:	c3                   	ret    
  80051f:	90                   	nop

00800520 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800520:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800521:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800526:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800528:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// @yuhangj: get reserved place under old esp
	addl $0x08, %esp;
  80052b:	83 c4 08             	add    $0x8,%esp

	movl 0x28(%esp), %eax;
  80052e:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x04, %eax;
  800532:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x28(%esp);
  800535:	89 44 24 28          	mov    %eax,0x28(%esp)

    // @yuhangj: store old eip into the reserved place under old esp
	movl 0x20(%esp), %ebx;
  800539:	8b 5c 24 20          	mov    0x20(%esp),%ebx
	movl %ebx, (%eax);
  80053d:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  80053f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp;
  800540:	83 c4 04             	add    $0x4,%esp
	popfl
  800543:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  800544:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800545:	c3                   	ret    
  800546:	66 90                	xchg   %ax,%ax
  800548:	66 90                	xchg   %ax,%ax
  80054a:	66 90                	xchg   %ax,%ax
  80054c:	66 90                	xchg   %ax,%ax
  80054e:	66 90                	xchg   %ax,%ax

00800550 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800553:	8b 45 08             	mov    0x8(%ebp),%eax
  800556:	05 00 00 00 30       	add    $0x30000000,%eax
  80055b:	c1 e8 0c             	shr    $0xc,%eax
}
  80055e:	5d                   	pop    %ebp
  80055f:	c3                   	ret    

00800560 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800566:	8b 45 08             	mov    0x8(%ebp),%eax
  800569:	89 04 24             	mov    %eax,(%esp)
  80056c:	e8 df ff ff ff       	call   800550 <fd2num>
  800571:	c1 e0 0c             	shl    $0xc,%eax
  800574:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800579:	c9                   	leave  
  80057a:	c3                   	ret    

0080057b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80057b:	55                   	push   %ebp
  80057c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80057e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800583:	a8 01                	test   $0x1,%al
  800585:	74 34                	je     8005bb <fd_alloc+0x40>
  800587:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80058c:	a8 01                	test   $0x1,%al
  80058e:	74 32                	je     8005c2 <fd_alloc+0x47>
  800590:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800595:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800597:	89 c2                	mov    %eax,%edx
  800599:	c1 ea 16             	shr    $0x16,%edx
  80059c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8005a3:	f6 c2 01             	test   $0x1,%dl
  8005a6:	74 1f                	je     8005c7 <fd_alloc+0x4c>
  8005a8:	89 c2                	mov    %eax,%edx
  8005aa:	c1 ea 0c             	shr    $0xc,%edx
  8005ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005b4:	f6 c2 01             	test   $0x1,%dl
  8005b7:	75 1a                	jne    8005d3 <fd_alloc+0x58>
  8005b9:	eb 0c                	jmp    8005c7 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8005bb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8005c0:	eb 05                	jmp    8005c7 <fd_alloc+0x4c>
  8005c2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8005c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ca:	89 08                	mov    %ecx,(%eax)
			return 0;
  8005cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d1:	eb 1a                	jmp    8005ed <fd_alloc+0x72>
  8005d3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8005d8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8005dd:	75 b6                	jne    800595 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8005df:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8005e8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8005ed:	5d                   	pop    %ebp
  8005ee:	c3                   	ret    

008005ef <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8005ef:	55                   	push   %ebp
  8005f0:	89 e5                	mov    %esp,%ebp
  8005f2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8005f5:	83 f8 1f             	cmp    $0x1f,%eax
  8005f8:	77 36                	ja     800630 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8005fa:	c1 e0 0c             	shl    $0xc,%eax
  8005fd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800602:	89 c2                	mov    %eax,%edx
  800604:	c1 ea 16             	shr    $0x16,%edx
  800607:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80060e:	f6 c2 01             	test   $0x1,%dl
  800611:	74 24                	je     800637 <fd_lookup+0x48>
  800613:	89 c2                	mov    %eax,%edx
  800615:	c1 ea 0c             	shr    $0xc,%edx
  800618:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80061f:	f6 c2 01             	test   $0x1,%dl
  800622:	74 1a                	je     80063e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800624:	8b 55 0c             	mov    0xc(%ebp),%edx
  800627:	89 02                	mov    %eax,(%edx)
	return 0;
  800629:	b8 00 00 00 00       	mov    $0x0,%eax
  80062e:	eb 13                	jmp    800643 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  800630:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800635:	eb 0c                	jmp    800643 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  800637:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80063c:	eb 05                	jmp    800643 <fd_lookup+0x54>
  80063e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800643:	5d                   	pop    %ebp
  800644:	c3                   	ret    

00800645 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800645:	55                   	push   %ebp
  800646:	89 e5                	mov    %esp,%ebp
  800648:	83 ec 18             	sub    $0x18,%esp
  80064b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80064e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  800654:	75 10                	jne    800666 <dev_lookup+0x21>
			*dev = devtab[i];
  800656:	8b 45 0c             	mov    0xc(%ebp),%eax
  800659:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80065f:	b8 00 00 00 00       	mov    $0x0,%eax
  800664:	eb 2b                	jmp    800691 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800666:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80066c:	8b 52 48             	mov    0x48(%edx),%edx
  80066f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800673:	89 54 24 04          	mov    %edx,0x4(%esp)
  800677:	c7 04 24 78 1d 80 00 	movl   $0x801d78,(%esp)
  80067e:	e8 c8 07 00 00       	call   800e4b <cprintf>
	*dev = 0;
  800683:	8b 55 0c             	mov    0xc(%ebp),%edx
  800686:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80068c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800691:	c9                   	leave  
  800692:	c3                   	ret    

00800693 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800693:	55                   	push   %ebp
  800694:	89 e5                	mov    %esp,%ebp
  800696:	83 ec 38             	sub    $0x38,%esp
  800699:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80069c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80069f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8006a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8006a8:	89 3c 24             	mov    %edi,(%esp)
  8006ab:	e8 a0 fe ff ff       	call   800550 <fd2num>
  8006b0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8006b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b7:	89 04 24             	mov    %eax,(%esp)
  8006ba:	e8 30 ff ff ff       	call   8005ef <fd_lookup>
  8006bf:	89 c3                	mov    %eax,%ebx
  8006c1:	85 c0                	test   %eax,%eax
  8006c3:	78 05                	js     8006ca <fd_close+0x37>
	    || fd != fd2)
  8006c5:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8006c8:	74 0c                	je     8006d6 <fd_close+0x43>
		return (must_exist ? r : 0);
  8006ca:	85 f6                	test   %esi,%esi
  8006cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d1:	0f 44 d8             	cmove  %eax,%ebx
  8006d4:	eb 3d                	jmp    800713 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8006d6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8006d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dd:	8b 07                	mov    (%edi),%eax
  8006df:	89 04 24             	mov    %eax,(%esp)
  8006e2:	e8 5e ff ff ff       	call   800645 <dev_lookup>
  8006e7:	89 c3                	mov    %eax,%ebx
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	78 16                	js     800703 <fd_close+0x70>
		if (dev->dev_close)
  8006ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006f0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8006f3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	74 07                	je     800703 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  8006fc:	89 3c 24             	mov    %edi,(%esp)
  8006ff:	ff d0                	call   *%eax
  800701:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800703:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800707:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80070e:	e8 cd fb ff ff       	call   8002e0 <sys_page_unmap>
	return r;
}
  800713:	89 d8                	mov    %ebx,%eax
  800715:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800718:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80071b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80071e:	89 ec                	mov    %ebp,%esp
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800728:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072f:	8b 45 08             	mov    0x8(%ebp),%eax
  800732:	89 04 24             	mov    %eax,(%esp)
  800735:	e8 b5 fe ff ff       	call   8005ef <fd_lookup>
  80073a:	85 c0                	test   %eax,%eax
  80073c:	78 13                	js     800751 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80073e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800745:	00 
  800746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800749:	89 04 24             	mov    %eax,(%esp)
  80074c:	e8 42 ff ff ff       	call   800693 <fd_close>
}
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <close_all>:

void
close_all(void)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	53                   	push   %ebx
  800757:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80075a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80075f:	89 1c 24             	mov    %ebx,(%esp)
  800762:	e8 bb ff ff ff       	call   800722 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800767:	83 c3 01             	add    $0x1,%ebx
  80076a:	83 fb 20             	cmp    $0x20,%ebx
  80076d:	75 f0                	jne    80075f <close_all+0xc>
		close(i);
}
  80076f:	83 c4 14             	add    $0x14,%esp
  800772:	5b                   	pop    %ebx
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	83 ec 58             	sub    $0x58,%esp
  80077b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80077e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800781:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800784:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800787:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80078a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078e:	8b 45 08             	mov    0x8(%ebp),%eax
  800791:	89 04 24             	mov    %eax,(%esp)
  800794:	e8 56 fe ff ff       	call   8005ef <fd_lookup>
  800799:	85 c0                	test   %eax,%eax
  80079b:	0f 88 e3 00 00 00    	js     800884 <dup+0x10f>
		return r;
	close(newfdnum);
  8007a1:	89 1c 24             	mov    %ebx,(%esp)
  8007a4:	e8 79 ff ff ff       	call   800722 <close>

	newfd = INDEX2FD(newfdnum);
  8007a9:	89 de                	mov    %ebx,%esi
  8007ab:	c1 e6 0c             	shl    $0xc,%esi
  8007ae:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8007b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	e8 a1 fd ff ff       	call   800560 <fd2data>
  8007bf:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8007c1:	89 34 24             	mov    %esi,(%esp)
  8007c4:	e8 97 fd ff ff       	call   800560 <fd2data>
  8007c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8007cc:	89 f8                	mov    %edi,%eax
  8007ce:	c1 e8 16             	shr    $0x16,%eax
  8007d1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8007d8:	a8 01                	test   $0x1,%al
  8007da:	74 46                	je     800822 <dup+0xad>
  8007dc:	89 f8                	mov    %edi,%eax
  8007de:	c1 e8 0c             	shr    $0xc,%eax
  8007e1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8007e8:	f6 c2 01             	test   $0x1,%dl
  8007eb:	74 35                	je     800822 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8007ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8007f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8007f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800800:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800804:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80080b:	00 
  80080c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800810:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800817:	e8 5d fa ff ff       	call   800279 <sys_page_map>
  80081c:	89 c7                	mov    %eax,%edi
  80081e:	85 c0                	test   %eax,%eax
  800820:	78 3b                	js     80085d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800822:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800825:	89 c2                	mov    %eax,%edx
  800827:	c1 ea 0c             	shr    $0xc,%edx
  80082a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800831:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800837:	89 54 24 10          	mov    %edx,0x10(%esp)
  80083b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80083f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800846:	00 
  800847:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800852:	e8 22 fa ff ff       	call   800279 <sys_page_map>
  800857:	89 c7                	mov    %eax,%edi
  800859:	85 c0                	test   %eax,%eax
  80085b:	79 29                	jns    800886 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80085d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800861:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800868:	e8 73 fa ff ff       	call   8002e0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80086d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800870:	89 44 24 04          	mov    %eax,0x4(%esp)
  800874:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80087b:	e8 60 fa ff ff       	call   8002e0 <sys_page_unmap>
	return r;
  800880:	89 fb                	mov    %edi,%ebx
  800882:	eb 02                	jmp    800886 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  800884:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800886:	89 d8                	mov    %ebx,%eax
  800888:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80088b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80088e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800891:	89 ec                	mov    %ebp,%esp
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	53                   	push   %ebx
  800899:	83 ec 24             	sub    $0x24,%esp
  80089c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80089f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a6:	89 1c 24             	mov    %ebx,(%esp)
  8008a9:	e8 41 fd ff ff       	call   8005ef <fd_lookup>
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 6d                	js     80091f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008bc:	8b 00                	mov    (%eax),%eax
  8008be:	89 04 24             	mov    %eax,(%esp)
  8008c1:	e8 7f fd ff ff       	call   800645 <dev_lookup>
  8008c6:	85 c0                	test   %eax,%eax
  8008c8:	78 55                	js     80091f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8008ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008cd:	8b 50 08             	mov    0x8(%eax),%edx
  8008d0:	83 e2 03             	and    $0x3,%edx
  8008d3:	83 fa 01             	cmp    $0x1,%edx
  8008d6:	75 23                	jne    8008fb <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8008d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8008dd:	8b 40 48             	mov    0x48(%eax),%eax
  8008e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e8:	c7 04 24 b9 1d 80 00 	movl   $0x801db9,(%esp)
  8008ef:	e8 57 05 00 00       	call   800e4b <cprintf>
		return -E_INVAL;
  8008f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f9:	eb 24                	jmp    80091f <read+0x8a>
	}
	if (!dev->dev_read)
  8008fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008fe:	8b 52 08             	mov    0x8(%edx),%edx
  800901:	85 d2                	test   %edx,%edx
  800903:	74 15                	je     80091a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800905:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800908:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80090c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800913:	89 04 24             	mov    %eax,(%esp)
  800916:	ff d2                	call   *%edx
  800918:	eb 05                	jmp    80091f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80091a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80091f:	83 c4 24             	add    $0x24,%esp
  800922:	5b                   	pop    %ebx
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	83 ec 1c             	sub    $0x1c,%esp
  80092e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800931:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800934:	85 f6                	test   %esi,%esi
  800936:	74 33                	je     80096b <readn+0x46>
  800938:	b8 00 00 00 00       	mov    $0x0,%eax
  80093d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800942:	89 f2                	mov    %esi,%edx
  800944:	29 c2                	sub    %eax,%edx
  800946:	89 54 24 08          	mov    %edx,0x8(%esp)
  80094a:	03 45 0c             	add    0xc(%ebp),%eax
  80094d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800951:	89 3c 24             	mov    %edi,(%esp)
  800954:	e8 3c ff ff ff       	call   800895 <read>
		if (m < 0)
  800959:	85 c0                	test   %eax,%eax
  80095b:	78 17                	js     800974 <readn+0x4f>
			return m;
		if (m == 0)
  80095d:	85 c0                	test   %eax,%eax
  80095f:	74 11                	je     800972 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800961:	01 c3                	add    %eax,%ebx
  800963:	89 d8                	mov    %ebx,%eax
  800965:	39 f3                	cmp    %esi,%ebx
  800967:	72 d9                	jb     800942 <readn+0x1d>
  800969:	eb 09                	jmp    800974 <readn+0x4f>
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
  800970:	eb 02                	jmp    800974 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800972:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800974:	83 c4 1c             	add    $0x1c,%esp
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	53                   	push   %ebx
  800980:	83 ec 24             	sub    $0x24,%esp
  800983:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800986:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800989:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098d:	89 1c 24             	mov    %ebx,(%esp)
  800990:	e8 5a fc ff ff       	call   8005ef <fd_lookup>
  800995:	85 c0                	test   %eax,%eax
  800997:	78 68                	js     800a01 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800999:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80099c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a3:	8b 00                	mov    (%eax),%eax
  8009a5:	89 04 24             	mov    %eax,(%esp)
  8009a8:	e8 98 fc ff ff       	call   800645 <dev_lookup>
  8009ad:	85 c0                	test   %eax,%eax
  8009af:	78 50                	js     800a01 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8009b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8009b8:	75 23                	jne    8009dd <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8009ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8009bf:	8b 40 48             	mov    0x48(%eax),%eax
  8009c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ca:	c7 04 24 d5 1d 80 00 	movl   $0x801dd5,(%esp)
  8009d1:	e8 75 04 00 00       	call   800e4b <cprintf>
		return -E_INVAL;
  8009d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009db:	eb 24                	jmp    800a01 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8009dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009e0:	8b 52 0c             	mov    0xc(%edx),%edx
  8009e3:	85 d2                	test   %edx,%edx
  8009e5:	74 15                	je     8009fc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8009e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009f5:	89 04 24             	mov    %eax,(%esp)
  8009f8:	ff d2                	call   *%edx
  8009fa:	eb 05                	jmp    800a01 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8009fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800a01:	83 c4 24             	add    $0x24,%esp
  800a04:	5b                   	pop    %ebx
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <seek>:

int
seek(int fdnum, off_t offset)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a0d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	89 04 24             	mov    %eax,(%esp)
  800a1a:	e8 d0 fb ff ff       	call   8005ef <fd_lookup>
  800a1f:	85 c0                	test   %eax,%eax
  800a21:	78 0e                	js     800a31 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800a23:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a29:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	53                   	push   %ebx
  800a37:	83 ec 24             	sub    $0x24,%esp
  800a3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a40:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a44:	89 1c 24             	mov    %ebx,(%esp)
  800a47:	e8 a3 fb ff ff       	call   8005ef <fd_lookup>
  800a4c:	85 c0                	test   %eax,%eax
  800a4e:	78 61                	js     800ab1 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a53:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a5a:	8b 00                	mov    (%eax),%eax
  800a5c:	89 04 24             	mov    %eax,(%esp)
  800a5f:	e8 e1 fb ff ff       	call   800645 <dev_lookup>
  800a64:	85 c0                	test   %eax,%eax
  800a66:	78 49                	js     800ab1 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a6b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a6f:	75 23                	jne    800a94 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800a71:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800a76:	8b 40 48             	mov    0x48(%eax),%eax
  800a79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a81:	c7 04 24 98 1d 80 00 	movl   $0x801d98,(%esp)
  800a88:	e8 be 03 00 00       	call   800e4b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800a8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a92:	eb 1d                	jmp    800ab1 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800a94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a97:	8b 52 18             	mov    0x18(%edx),%edx
  800a9a:	85 d2                	test   %edx,%edx
  800a9c:	74 0e                	je     800aac <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800a9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800aa5:	89 04 24             	mov    %eax,(%esp)
  800aa8:	ff d2                	call   *%edx
  800aaa:	eb 05                	jmp    800ab1 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800aac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800ab1:	83 c4 24             	add    $0x24,%esp
  800ab4:	5b                   	pop    %ebx
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	53                   	push   %ebx
  800abb:	83 ec 24             	sub    $0x24,%esp
  800abe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ac1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	89 04 24             	mov    %eax,(%esp)
  800ace:	e8 1c fb ff ff       	call   8005ef <fd_lookup>
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	78 52                	js     800b29 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ad7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ada:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ae1:	8b 00                	mov    (%eax),%eax
  800ae3:	89 04 24             	mov    %eax,(%esp)
  800ae6:	e8 5a fb ff ff       	call   800645 <dev_lookup>
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	78 3a                	js     800b29 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800af2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800af6:	74 2c                	je     800b24 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800af8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800afb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800b02:	00 00 00 
	stat->st_isdir = 0;
  800b05:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b0c:	00 00 00 
	stat->st_dev = dev;
  800b0f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800b15:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b19:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b1c:	89 14 24             	mov    %edx,(%esp)
  800b1f:	ff 50 14             	call   *0x14(%eax)
  800b22:	eb 05                	jmp    800b29 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800b24:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800b29:	83 c4 24             	add    $0x24,%esp
  800b2c:	5b                   	pop    %ebx
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	83 ec 18             	sub    $0x18,%esp
  800b35:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b38:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800b3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800b42:	00 
  800b43:	8b 45 08             	mov    0x8(%ebp),%eax
  800b46:	89 04 24             	mov    %eax,(%esp)
  800b49:	e8 84 01 00 00       	call   800cd2 <open>
  800b4e:	89 c3                	mov    %eax,%ebx
  800b50:	85 c0                	test   %eax,%eax
  800b52:	78 1b                	js     800b6f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5b:	89 1c 24             	mov    %ebx,(%esp)
  800b5e:	e8 54 ff ff ff       	call   800ab7 <fstat>
  800b63:	89 c6                	mov    %eax,%esi
	close(fd);
  800b65:	89 1c 24             	mov    %ebx,(%esp)
  800b68:	e8 b5 fb ff ff       	call   800722 <close>
	return r;
  800b6d:	89 f3                	mov    %esi,%ebx
}
  800b6f:	89 d8                	mov    %ebx,%eax
  800b71:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b74:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b77:	89 ec                	mov    %ebp,%esp
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    
  800b7b:	90                   	nop

00800b7c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	83 ec 18             	sub    $0x18,%esp
  800b82:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b85:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b88:	89 c6                	mov    %eax,%esi
  800b8a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800b8c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800b93:	75 11                	jne    800ba6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b95:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b9c:	e8 62 0e 00 00       	call   801a03 <ipc_find_env>
  800ba1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ba6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800bad:	00 
  800bae:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800bb5:	00 
  800bb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bba:	a1 00 40 80 00       	mov    0x804000,%eax
  800bbf:	89 04 24             	mov    %eax,(%esp)
  800bc2:	e8 d1 0d 00 00       	call   801998 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800bc7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800bce:	00 
  800bcf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800bda:	e8 61 0d 00 00       	call   801940 <ipc_recv>
}
  800bdf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800be2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800be5:	89 ec                	mov    %ebp,%esp
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800bef:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf2:	8b 40 0c             	mov    0xc(%eax),%eax
  800bf5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800c02:	ba 00 00 00 00       	mov    $0x0,%edx
  800c07:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0c:	e8 6b ff ff ff       	call   800b7c <fsipc>
}
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	8b 40 0c             	mov    0xc(%eax),%eax
  800c1f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800c24:	ba 00 00 00 00       	mov    $0x0,%edx
  800c29:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2e:	e8 49 ff ff ff       	call   800b7c <fsipc>
}
  800c33:	c9                   	leave  
  800c34:	c3                   	ret    

00800c35 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	53                   	push   %ebx
  800c39:	83 ec 14             	sub    $0x14,%esp
  800c3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c42:	8b 40 0c             	mov    0xc(%eax),%eax
  800c45:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800c4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c54:	e8 23 ff ff ff       	call   800b7c <fsipc>
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	78 2b                	js     800c88 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800c5d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c64:	00 
  800c65:	89 1c 24             	mov    %ebx,(%esp)
  800c68:	e8 5e 08 00 00       	call   8014cb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800c6d:	a1 80 50 80 00       	mov    0x805080,%eax
  800c72:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800c78:	a1 84 50 80 00       	mov    0x805084,%eax
  800c7d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800c83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c88:	83 c4 14             	add    $0x14,%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800c94:	c7 44 24 08 f2 1d 80 	movl   $0x801df2,0x8(%esp)
  800c9b:	00 
  800c9c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  800ca3:	00 
  800ca4:	c7 04 24 10 1e 80 00 	movl   $0x801e10,(%esp)
  800cab:	e8 a0 00 00 00       	call   800d50 <_panic>

00800cb0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  800cb6:	c7 44 24 08 1b 1e 80 	movl   $0x801e1b,0x8(%esp)
  800cbd:	00 
  800cbe:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  800cc5:	00 
  800cc6:	c7 04 24 10 1e 80 00 	movl   $0x801e10,(%esp)
  800ccd:	e8 7e 00 00 00       	call   800d50 <_panic>

00800cd2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  800cd8:	c7 44 24 08 38 1e 80 	movl   $0x801e38,0x8(%esp)
  800cdf:	00 
  800ce0:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800ce7:	00 
  800ce8:	c7 04 24 10 1e 80 00 	movl   $0x801e10,(%esp)
  800cef:	e8 5c 00 00 00       	call   800d50 <_panic>

00800cf4 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 14             	sub    $0x14,%esp
  800cfb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800cfe:	89 1c 24             	mov    %ebx,(%esp)
  800d01:	e8 6a 07 00 00       	call   801470 <strlen>
  800d06:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800d0b:	7f 21                	jg     800d2e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800d0d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d11:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800d18:	e8 ae 07 00 00       	call   8014cb <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800d1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d22:	b8 07 00 00 00       	mov    $0x7,%eax
  800d27:	e8 50 fe ff ff       	call   800b7c <fsipc>
  800d2c:	eb 05                	jmp    800d33 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800d2e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  800d33:	83 c4 14             	add    $0x14,%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d44:	b8 08 00 00 00       	mov    $0x8,%eax
  800d49:	e8 2e fe ff ff       	call   800b7c <fsipc>
}
  800d4e:	c9                   	leave  
  800d4f:	c3                   	ret    

00800d50 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d58:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d5b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800d61:	e8 39 f4 ff ff       	call   80019f <sys_getenvid>
  800d66:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d69:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d74:	89 74 24 08          	mov    %esi,0x8(%esp)
  800d78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d7c:	c7 04 24 50 1e 80 00 	movl   $0x801e50,(%esp)
  800d83:	e8 c3 00 00 00       	call   800e4b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d8f:	89 04 24             	mov    %eax,(%esp)
  800d92:	e8 53 00 00 00       	call   800dea <vcprintf>
	cprintf("\n");
  800d97:	c7 04 24 db 21 80 00 	movl   $0x8021db,(%esp)
  800d9e:	e8 a8 00 00 00       	call   800e4b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800da3:	cc                   	int3   
  800da4:	eb fd                	jmp    800da3 <_panic+0x53>
  800da6:	66 90                	xchg   %ax,%ax

00800da8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	53                   	push   %ebx
  800dac:	83 ec 14             	sub    $0x14,%esp
  800daf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800db2:	8b 03                	mov    (%ebx),%eax
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800dbb:	83 c0 01             	add    $0x1,%eax
  800dbe:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800dc0:	3d ff 00 00 00       	cmp    $0xff,%eax
  800dc5:	75 19                	jne    800de0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800dc7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800dce:	00 
  800dcf:	8d 43 08             	lea    0x8(%ebx),%eax
  800dd2:	89 04 24             	mov    %eax,(%esp)
  800dd5:	e8 ee f2 ff ff       	call   8000c8 <sys_cputs>
		b->idx = 0;
  800dda:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800de0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800de4:	83 c4 14             	add    $0x14,%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800df3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800dfa:	00 00 00 
	b.cnt = 0;
  800dfd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800e04:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800e07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e15:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800e1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e1f:	c7 04 24 a8 0d 80 00 	movl   $0x800da8,(%esp)
  800e26:	e8 b7 01 00 00       	call   800fe2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800e2b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800e31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e35:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800e3b:	89 04 24             	mov    %eax,(%esp)
  800e3e:	e8 85 f2 ff ff       	call   8000c8 <sys_cputs>

	return b.cnt;
}
  800e43:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800e49:	c9                   	leave  
  800e4a:	c3                   	ret    

00800e4b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800e51:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800e54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e58:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5b:	89 04 24             	mov    %eax,(%esp)
  800e5e:	e8 87 ff ff ff       	call   800dea <vcprintf>
	va_end(ap);

	return cnt;
}
  800e63:	c9                   	leave  
  800e64:	c3                   	ret    
  800e65:	66 90                	xchg   %ax,%ax
  800e67:	66 90                	xchg   %ax,%ax
  800e69:	66 90                	xchg   %ax,%ax
  800e6b:	66 90                	xchg   %ax,%ax
  800e6d:	66 90                	xchg   %ax,%ax
  800e6f:	90                   	nop

00800e70 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
  800e76:	83 ec 4c             	sub    $0x4c,%esp
  800e79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e7c:	89 d7                	mov    %edx,%edi
  800e7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e81:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800e84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e87:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800e8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8f:	39 d8                	cmp    %ebx,%eax
  800e91:	72 17                	jb     800eaa <printnum+0x3a>
  800e93:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800e96:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800e99:	76 0f                	jbe    800eaa <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800e9b:	8b 75 14             	mov    0x14(%ebp),%esi
  800e9e:	83 ee 01             	sub    $0x1,%esi
  800ea1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ea4:	85 f6                	test   %esi,%esi
  800ea6:	7f 63                	jg     800f0b <printnum+0x9b>
  800ea8:	eb 75                	jmp    800f1f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800eaa:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800ead:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800eb1:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb4:	83 e8 01             	sub    $0x1,%eax
  800eb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ebb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ec2:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ec6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800eca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ecd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ed0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed7:	00 
  800ed8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800edb:	89 1c 24             	mov    %ebx,(%esp)
  800ede:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800ee1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ee5:	e8 66 0b 00 00       	call   801a50 <__udivdi3>
  800eea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800eed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ef0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ef4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ef8:	89 04 24             	mov    %eax,(%esp)
  800efb:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eff:	89 fa                	mov    %edi,%edx
  800f01:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800f04:	e8 67 ff ff ff       	call   800e70 <printnum>
  800f09:	eb 14                	jmp    800f1f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800f0b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f0f:	8b 45 18             	mov    0x18(%ebp),%eax
  800f12:	89 04 24             	mov    %eax,(%esp)
  800f15:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800f17:	83 ee 01             	sub    $0x1,%esi
  800f1a:	75 ef                	jne    800f0b <printnum+0x9b>
  800f1c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800f1f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f23:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f2e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f35:	00 
  800f36:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800f39:	89 1c 24             	mov    %ebx,(%esp)
  800f3c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800f3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f43:	e8 58 0c 00 00       	call   801ba0 <__umoddi3>
  800f48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f4c:	0f be 80 73 1e 80 00 	movsbl 0x801e73(%eax),%eax
  800f53:	89 04 24             	mov    %eax,(%esp)
  800f56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800f59:	ff d0                	call   *%eax
}
  800f5b:	83 c4 4c             	add    $0x4c,%esp
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    

00800f63 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800f66:	83 fa 01             	cmp    $0x1,%edx
  800f69:	7e 0e                	jle    800f79 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800f6b:	8b 10                	mov    (%eax),%edx
  800f6d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800f70:	89 08                	mov    %ecx,(%eax)
  800f72:	8b 02                	mov    (%edx),%eax
  800f74:	8b 52 04             	mov    0x4(%edx),%edx
  800f77:	eb 22                	jmp    800f9b <getuint+0x38>
	else if (lflag)
  800f79:	85 d2                	test   %edx,%edx
  800f7b:	74 10                	je     800f8d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800f7d:	8b 10                	mov    (%eax),%edx
  800f7f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f82:	89 08                	mov    %ecx,(%eax)
  800f84:	8b 02                	mov    (%edx),%eax
  800f86:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8b:	eb 0e                	jmp    800f9b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800f8d:	8b 10                	mov    (%eax),%edx
  800f8f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f92:	89 08                	mov    %ecx,(%eax)
  800f94:	8b 02                	mov    (%edx),%eax
  800f96:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    

00800f9d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800fa3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800fa7:	8b 10                	mov    (%eax),%edx
  800fa9:	3b 50 04             	cmp    0x4(%eax),%edx
  800fac:	73 0a                	jae    800fb8 <sprintputch+0x1b>
		*b->buf++ = ch;
  800fae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb1:	88 0a                	mov    %cl,(%edx)
  800fb3:	83 c2 01             	add    $0x1,%edx
  800fb6:	89 10                	mov    %edx,(%eax)
}
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800fc0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800fc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800fca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd8:	89 04 24             	mov    %eax,(%esp)
  800fdb:	e8 02 00 00 00       	call   800fe2 <vprintfmt>
	va_end(ap);
}
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    

00800fe2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	57                   	push   %edi
  800fe6:	56                   	push   %esi
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 4c             	sub    $0x4c,%esp
  800feb:	8b 75 08             	mov    0x8(%ebp),%esi
  800fee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ff1:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ff4:	eb 11                	jmp    801007 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	0f 84 db 03 00 00    	je     8013d9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  800ffe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801002:	89 04 24             	mov    %eax,(%esp)
  801005:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801007:	0f b6 07             	movzbl (%edi),%eax
  80100a:	83 c7 01             	add    $0x1,%edi
  80100d:	83 f8 25             	cmp    $0x25,%eax
  801010:	75 e4                	jne    800ff6 <vprintfmt+0x14>
  801012:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  801016:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80101d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801024:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80102b:	ba 00 00 00 00       	mov    $0x0,%edx
  801030:	eb 2b                	jmp    80105d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801032:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801035:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  801039:	eb 22                	jmp    80105d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80103b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80103e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  801042:	eb 19                	jmp    80105d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801044:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801047:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80104e:	eb 0d                	jmp    80105d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801050:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801053:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801056:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80105d:	0f b6 0f             	movzbl (%edi),%ecx
  801060:	8d 47 01             	lea    0x1(%edi),%eax
  801063:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801066:	0f b6 07             	movzbl (%edi),%eax
  801069:	83 e8 23             	sub    $0x23,%eax
  80106c:	3c 55                	cmp    $0x55,%al
  80106e:	0f 87 40 03 00 00    	ja     8013b4 <vprintfmt+0x3d2>
  801074:	0f b6 c0             	movzbl %al,%eax
  801077:	ff 24 85 c0 1f 80 00 	jmp    *0x801fc0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80107e:	83 e9 30             	sub    $0x30,%ecx
  801081:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  801084:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  801088:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80108b:	83 f9 09             	cmp    $0x9,%ecx
  80108e:	77 57                	ja     8010e7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801090:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801093:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801096:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801099:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80109c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80109f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8010a3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8010a6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8010a9:	83 f9 09             	cmp    $0x9,%ecx
  8010ac:	76 eb                	jbe    801099 <vprintfmt+0xb7>
  8010ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8010b4:	eb 34                	jmp    8010ea <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8010b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8010b9:	8d 48 04             	lea    0x4(%eax),%ecx
  8010bc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8010bf:	8b 00                	mov    (%eax),%eax
  8010c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010c4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8010c7:	eb 21                	jmp    8010ea <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8010c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8010cd:	0f 88 71 ff ff ff    	js     801044 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010d3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010d6:	eb 85                	jmp    80105d <vprintfmt+0x7b>
  8010d8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8010db:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8010e2:	e9 76 ff ff ff       	jmp    80105d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010e7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8010ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8010ee:	0f 89 69 ff ff ff    	jns    80105d <vprintfmt+0x7b>
  8010f4:	e9 57 ff ff ff       	jmp    801050 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8010f9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010fc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8010ff:	e9 59 ff ff ff       	jmp    80105d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801104:	8b 45 14             	mov    0x14(%ebp),%eax
  801107:	8d 50 04             	lea    0x4(%eax),%edx
  80110a:	89 55 14             	mov    %edx,0x14(%ebp)
  80110d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801111:	8b 00                	mov    (%eax),%eax
  801113:	89 04 24             	mov    %eax,(%esp)
  801116:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801118:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80111b:	e9 e7 fe ff ff       	jmp    801007 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801120:	8b 45 14             	mov    0x14(%ebp),%eax
  801123:	8d 50 04             	lea    0x4(%eax),%edx
  801126:	89 55 14             	mov    %edx,0x14(%ebp)
  801129:	8b 00                	mov    (%eax),%eax
  80112b:	89 c2                	mov    %eax,%edx
  80112d:	c1 fa 1f             	sar    $0x1f,%edx
  801130:	31 d0                	xor    %edx,%eax
  801132:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801134:	83 f8 0f             	cmp    $0xf,%eax
  801137:	7f 0b                	jg     801144 <vprintfmt+0x162>
  801139:	8b 14 85 20 21 80 00 	mov    0x802120(,%eax,4),%edx
  801140:	85 d2                	test   %edx,%edx
  801142:	75 20                	jne    801164 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  801144:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801148:	c7 44 24 08 8b 1e 80 	movl   $0x801e8b,0x8(%esp)
  80114f:	00 
  801150:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801154:	89 34 24             	mov    %esi,(%esp)
  801157:	e8 5e fe ff ff       	call   800fba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80115c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80115f:	e9 a3 fe ff ff       	jmp    801007 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  801164:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801168:	c7 44 24 08 94 1e 80 	movl   $0x801e94,0x8(%esp)
  80116f:	00 
  801170:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801174:	89 34 24             	mov    %esi,(%esp)
  801177:	e8 3e fe ff ff       	call   800fba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80117c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80117f:	e9 83 fe ff ff       	jmp    801007 <vprintfmt+0x25>
  801184:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801187:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80118a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80118d:	8b 45 14             	mov    0x14(%ebp),%eax
  801190:	8d 50 04             	lea    0x4(%eax),%edx
  801193:	89 55 14             	mov    %edx,0x14(%ebp)
  801196:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801198:	85 ff                	test   %edi,%edi
  80119a:	b8 84 1e 80 00       	mov    $0x801e84,%eax
  80119f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8011a2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8011a6:	74 06                	je     8011ae <vprintfmt+0x1cc>
  8011a8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8011ac:	7f 16                	jg     8011c4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8011ae:	0f b6 17             	movzbl (%edi),%edx
  8011b1:	0f be c2             	movsbl %dl,%eax
  8011b4:	83 c7 01             	add    $0x1,%edi
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	0f 85 9f 00 00 00    	jne    80125e <vprintfmt+0x27c>
  8011bf:	e9 8b 00 00 00       	jmp    80124f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011c8:	89 3c 24             	mov    %edi,(%esp)
  8011cb:	e8 c2 02 00 00       	call   801492 <strnlen>
  8011d0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8011d3:	29 c2                	sub    %eax,%edx
  8011d5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8011d8:	85 d2                	test   %edx,%edx
  8011da:	7e d2                	jle    8011ae <vprintfmt+0x1cc>
					putch(padc, putdat);
  8011dc:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8011e0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8011e3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8011e6:	89 d7                	mov    %edx,%edi
  8011e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011ef:	89 04 24             	mov    %eax,(%esp)
  8011f2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011f4:	83 ef 01             	sub    $0x1,%edi
  8011f7:	75 ef                	jne    8011e8 <vprintfmt+0x206>
  8011f9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8011fc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8011ff:	eb ad                	jmp    8011ae <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801201:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801205:	74 20                	je     801227 <vprintfmt+0x245>
  801207:	0f be d2             	movsbl %dl,%edx
  80120a:	83 ea 20             	sub    $0x20,%edx
  80120d:	83 fa 5e             	cmp    $0x5e,%edx
  801210:	76 15                	jbe    801227 <vprintfmt+0x245>
					putch('?', putdat);
  801212:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801215:	89 54 24 04          	mov    %edx,0x4(%esp)
  801219:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801220:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801223:	ff d1                	call   *%ecx
  801225:	eb 0f                	jmp    801236 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  801227:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80122a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80122e:	89 04 24             	mov    %eax,(%esp)
  801231:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801234:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801236:	83 eb 01             	sub    $0x1,%ebx
  801239:	0f b6 17             	movzbl (%edi),%edx
  80123c:	0f be c2             	movsbl %dl,%eax
  80123f:	83 c7 01             	add    $0x1,%edi
  801242:	85 c0                	test   %eax,%eax
  801244:	75 24                	jne    80126a <vprintfmt+0x288>
  801246:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801249:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80124c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80124f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801252:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801256:	0f 8e ab fd ff ff    	jle    801007 <vprintfmt+0x25>
  80125c:	eb 20                	jmp    80127e <vprintfmt+0x29c>
  80125e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801261:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801264:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801267:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80126a:	85 f6                	test   %esi,%esi
  80126c:	78 93                	js     801201 <vprintfmt+0x21f>
  80126e:	83 ee 01             	sub    $0x1,%esi
  801271:	79 8e                	jns    801201 <vprintfmt+0x21f>
  801273:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801276:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801279:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80127c:	eb d1                	jmp    80124f <vprintfmt+0x26d>
  80127e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801281:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801285:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80128c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80128e:	83 ef 01             	sub    $0x1,%edi
  801291:	75 ee                	jne    801281 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801293:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801296:	e9 6c fd ff ff       	jmp    801007 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80129b:	83 fa 01             	cmp    $0x1,%edx
  80129e:	66 90                	xchg   %ax,%ax
  8012a0:	7e 16                	jle    8012b8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8012a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a5:	8d 50 08             	lea    0x8(%eax),%edx
  8012a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8012ab:	8b 10                	mov    (%eax),%edx
  8012ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8012b0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8012b3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8012b6:	eb 32                	jmp    8012ea <vprintfmt+0x308>
	else if (lflag)
  8012b8:	85 d2                	test   %edx,%edx
  8012ba:	74 18                	je     8012d4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8012bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8012bf:	8d 50 04             	lea    0x4(%eax),%edx
  8012c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8012c5:	8b 00                	mov    (%eax),%eax
  8012c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ca:	89 c1                	mov    %eax,%ecx
  8012cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8012cf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8012d2:	eb 16                	jmp    8012ea <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8012d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d7:	8d 50 04             	lea    0x4(%eax),%edx
  8012da:	89 55 14             	mov    %edx,0x14(%ebp)
  8012dd:	8b 00                	mov    (%eax),%eax
  8012df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012e2:	89 c7                	mov    %eax,%edi
  8012e4:	c1 ff 1f             	sar    $0x1f,%edi
  8012e7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8012ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012ed:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8012f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8012f5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8012f9:	79 7d                	jns    801378 <vprintfmt+0x396>
				putch('-', putdat);
  8012fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012ff:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801306:	ff d6                	call   *%esi
				num = -(long long) num;
  801308:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80130b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80130e:	f7 d8                	neg    %eax
  801310:	83 d2 00             	adc    $0x0,%edx
  801313:	f7 da                	neg    %edx
			}
			base = 10;
  801315:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80131a:	eb 5c                	jmp    801378 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80131c:	8d 45 14             	lea    0x14(%ebp),%eax
  80131f:	e8 3f fc ff ff       	call   800f63 <getuint>
			base = 10;
  801324:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801329:	eb 4d                	jmp    801378 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80132b:	8d 45 14             	lea    0x14(%ebp),%eax
  80132e:	e8 30 fc ff ff       	call   800f63 <getuint>
			base = 8;
  801333:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801338:	eb 3e                	jmp    801378 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80133a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80133e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801345:	ff d6                	call   *%esi
			putch('x', putdat);
  801347:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80134b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801352:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801354:	8b 45 14             	mov    0x14(%ebp),%eax
  801357:	8d 50 04             	lea    0x4(%eax),%edx
  80135a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80135d:	8b 00                	mov    (%eax),%eax
  80135f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801364:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801369:	eb 0d                	jmp    801378 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80136b:	8d 45 14             	lea    0x14(%ebp),%eax
  80136e:	e8 f0 fb ff ff       	call   800f63 <getuint>
			base = 16;
  801373:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801378:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80137c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801380:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801383:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801387:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80138b:	89 04 24             	mov    %eax,(%esp)
  80138e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801392:	89 da                	mov    %ebx,%edx
  801394:	89 f0                	mov    %esi,%eax
  801396:	e8 d5 fa ff ff       	call   800e70 <printnum>
			break;
  80139b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80139e:	e9 64 fc ff ff       	jmp    801007 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8013a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013a7:	89 0c 24             	mov    %ecx,(%esp)
  8013aa:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8013af:	e9 53 fc ff ff       	jmp    801007 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8013b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013b8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8013bf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8013c1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8013c5:	0f 84 3c fc ff ff    	je     801007 <vprintfmt+0x25>
  8013cb:	83 ef 01             	sub    $0x1,%edi
  8013ce:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8013d2:	75 f7                	jne    8013cb <vprintfmt+0x3e9>
  8013d4:	e9 2e fc ff ff       	jmp    801007 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8013d9:	83 c4 4c             	add    $0x4c,%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5e                   	pop    %esi
  8013de:	5f                   	pop    %edi
  8013df:	5d                   	pop    %ebp
  8013e0:	c3                   	ret    

008013e1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	83 ec 28             	sub    $0x28,%esp
  8013e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8013ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8013f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8013f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8013f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8013fe:	85 d2                	test   %edx,%edx
  801400:	7e 30                	jle    801432 <vsnprintf+0x51>
  801402:	85 c0                	test   %eax,%eax
  801404:	74 2c                	je     801432 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801406:	8b 45 14             	mov    0x14(%ebp),%eax
  801409:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80140d:	8b 45 10             	mov    0x10(%ebp),%eax
  801410:	89 44 24 08          	mov    %eax,0x8(%esp)
  801414:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801417:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141b:	c7 04 24 9d 0f 80 00 	movl   $0x800f9d,(%esp)
  801422:	e8 bb fb ff ff       	call   800fe2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801427:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80142a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80142d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801430:	eb 05                	jmp    801437 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801432:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801437:	c9                   	leave  
  801438:	c3                   	ret    

00801439 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80143f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801442:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801446:	8b 45 10             	mov    0x10(%ebp),%eax
  801449:	89 44 24 08          	mov    %eax,0x8(%esp)
  80144d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801450:	89 44 24 04          	mov    %eax,0x4(%esp)
  801454:	8b 45 08             	mov    0x8(%ebp),%eax
  801457:	89 04 24             	mov    %eax,(%esp)
  80145a:	e8 82 ff ff ff       	call   8013e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80145f:	c9                   	leave  
  801460:	c3                   	ret    
  801461:	66 90                	xchg   %ax,%ax
  801463:	66 90                	xchg   %ax,%ax
  801465:	66 90                	xchg   %ax,%ax
  801467:	66 90                	xchg   %ax,%ax
  801469:	66 90                	xchg   %ax,%ax
  80146b:	66 90                	xchg   %ax,%ax
  80146d:	66 90                	xchg   %ax,%ax
  80146f:	90                   	nop

00801470 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801476:	80 3a 00             	cmpb   $0x0,(%edx)
  801479:	74 10                	je     80148b <strlen+0x1b>
  80147b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801480:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801483:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801487:	75 f7                	jne    801480 <strlen+0x10>
  801489:	eb 05                	jmp    801490 <strlen+0x20>
  80148b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	53                   	push   %ebx
  801496:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801499:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80149c:	85 c9                	test   %ecx,%ecx
  80149e:	74 1c                	je     8014bc <strnlen+0x2a>
  8014a0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8014a3:	74 1e                	je     8014c3 <strnlen+0x31>
  8014a5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8014aa:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8014ac:	39 ca                	cmp    %ecx,%edx
  8014ae:	74 18                	je     8014c8 <strnlen+0x36>
  8014b0:	83 c2 01             	add    $0x1,%edx
  8014b3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8014b8:	75 f0                	jne    8014aa <strnlen+0x18>
  8014ba:	eb 0c                	jmp    8014c8 <strnlen+0x36>
  8014bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c1:	eb 05                	jmp    8014c8 <strnlen+0x36>
  8014c3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8014c8:	5b                   	pop    %ebx
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	53                   	push   %ebx
  8014cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8014d5:	89 c2                	mov    %eax,%edx
  8014d7:	0f b6 19             	movzbl (%ecx),%ebx
  8014da:	88 1a                	mov    %bl,(%edx)
  8014dc:	83 c2 01             	add    $0x1,%edx
  8014df:	83 c1 01             	add    $0x1,%ecx
  8014e2:	84 db                	test   %bl,%bl
  8014e4:	75 f1                	jne    8014d7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8014e6:	5b                   	pop    %ebx
  8014e7:	5d                   	pop    %ebp
  8014e8:	c3                   	ret    

008014e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	53                   	push   %ebx
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8014f3:	89 1c 24             	mov    %ebx,(%esp)
  8014f6:	e8 75 ff ff ff       	call   801470 <strlen>
	strcpy(dst + len, src);
  8014fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801502:	01 d8                	add    %ebx,%eax
  801504:	89 04 24             	mov    %eax,(%esp)
  801507:	e8 bf ff ff ff       	call   8014cb <strcpy>
	return dst;
}
  80150c:	89 d8                	mov    %ebx,%eax
  80150e:	83 c4 08             	add    $0x8,%esp
  801511:	5b                   	pop    %ebx
  801512:	5d                   	pop    %ebp
  801513:	c3                   	ret    

00801514 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	56                   	push   %esi
  801518:	53                   	push   %ebx
  801519:	8b 75 08             	mov    0x8(%ebp),%esi
  80151c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80151f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801522:	85 db                	test   %ebx,%ebx
  801524:	74 16                	je     80153c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  801526:	01 f3                	add    %esi,%ebx
  801528:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80152a:	0f b6 02             	movzbl (%edx),%eax
  80152d:	88 01                	mov    %al,(%ecx)
  80152f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801532:	80 3a 01             	cmpb   $0x1,(%edx)
  801535:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801538:	39 d9                	cmp    %ebx,%ecx
  80153a:	75 ee                	jne    80152a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80153c:	89 f0                	mov    %esi,%eax
  80153e:	5b                   	pop    %ebx
  80153f:	5e                   	pop    %esi
  801540:	5d                   	pop    %ebp
  801541:	c3                   	ret    

00801542 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	57                   	push   %edi
  801546:	56                   	push   %esi
  801547:	53                   	push   %ebx
  801548:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80154e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801551:	89 f8                	mov    %edi,%eax
  801553:	85 f6                	test   %esi,%esi
  801555:	74 33                	je     80158a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  801557:	83 fe 01             	cmp    $0x1,%esi
  80155a:	74 25                	je     801581 <strlcpy+0x3f>
  80155c:	0f b6 0b             	movzbl (%ebx),%ecx
  80155f:	84 c9                	test   %cl,%cl
  801561:	74 22                	je     801585 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801563:	83 ee 02             	sub    $0x2,%esi
  801566:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80156b:	88 08                	mov    %cl,(%eax)
  80156d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801570:	39 f2                	cmp    %esi,%edx
  801572:	74 13                	je     801587 <strlcpy+0x45>
  801574:	83 c2 01             	add    $0x1,%edx
  801577:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80157b:	84 c9                	test   %cl,%cl
  80157d:	75 ec                	jne    80156b <strlcpy+0x29>
  80157f:	eb 06                	jmp    801587 <strlcpy+0x45>
  801581:	89 f8                	mov    %edi,%eax
  801583:	eb 02                	jmp    801587 <strlcpy+0x45>
  801585:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801587:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80158a:	29 f8                	sub    %edi,%eax
}
  80158c:	5b                   	pop    %ebx
  80158d:	5e                   	pop    %esi
  80158e:	5f                   	pop    %edi
  80158f:	5d                   	pop    %ebp
  801590:	c3                   	ret    

00801591 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801597:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80159a:	0f b6 01             	movzbl (%ecx),%eax
  80159d:	84 c0                	test   %al,%al
  80159f:	74 15                	je     8015b6 <strcmp+0x25>
  8015a1:	3a 02                	cmp    (%edx),%al
  8015a3:	75 11                	jne    8015b6 <strcmp+0x25>
		p++, q++;
  8015a5:	83 c1 01             	add    $0x1,%ecx
  8015a8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8015ab:	0f b6 01             	movzbl (%ecx),%eax
  8015ae:	84 c0                	test   %al,%al
  8015b0:	74 04                	je     8015b6 <strcmp+0x25>
  8015b2:	3a 02                	cmp    (%edx),%al
  8015b4:	74 ef                	je     8015a5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8015b6:	0f b6 c0             	movzbl %al,%eax
  8015b9:	0f b6 12             	movzbl (%edx),%edx
  8015bc:	29 d0                	sub    %edx,%eax
}
  8015be:	5d                   	pop    %ebp
  8015bf:	c3                   	ret    

008015c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	56                   	push   %esi
  8015c4:	53                   	push   %ebx
  8015c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8015c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015cb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8015ce:	85 f6                	test   %esi,%esi
  8015d0:	74 29                	je     8015fb <strncmp+0x3b>
  8015d2:	0f b6 03             	movzbl (%ebx),%eax
  8015d5:	84 c0                	test   %al,%al
  8015d7:	74 30                	je     801609 <strncmp+0x49>
  8015d9:	3a 02                	cmp    (%edx),%al
  8015db:	75 2c                	jne    801609 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8015dd:	8d 43 01             	lea    0x1(%ebx),%eax
  8015e0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8015e2:	89 c3                	mov    %eax,%ebx
  8015e4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8015e7:	39 f0                	cmp    %esi,%eax
  8015e9:	74 17                	je     801602 <strncmp+0x42>
  8015eb:	0f b6 08             	movzbl (%eax),%ecx
  8015ee:	84 c9                	test   %cl,%cl
  8015f0:	74 17                	je     801609 <strncmp+0x49>
  8015f2:	83 c0 01             	add    $0x1,%eax
  8015f5:	3a 0a                	cmp    (%edx),%cl
  8015f7:	74 e9                	je     8015e2 <strncmp+0x22>
  8015f9:	eb 0e                	jmp    801609 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8015fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801600:	eb 0f                	jmp    801611 <strncmp+0x51>
  801602:	b8 00 00 00 00       	mov    $0x0,%eax
  801607:	eb 08                	jmp    801611 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801609:	0f b6 03             	movzbl (%ebx),%eax
  80160c:	0f b6 12             	movzbl (%edx),%edx
  80160f:	29 d0                	sub    %edx,%eax
}
  801611:	5b                   	pop    %ebx
  801612:	5e                   	pop    %esi
  801613:	5d                   	pop    %ebp
  801614:	c3                   	ret    

00801615 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	53                   	push   %ebx
  801619:	8b 45 08             	mov    0x8(%ebp),%eax
  80161c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  80161f:	0f b6 18             	movzbl (%eax),%ebx
  801622:	84 db                	test   %bl,%bl
  801624:	74 1d                	je     801643 <strchr+0x2e>
  801626:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  801628:	38 d3                	cmp    %dl,%bl
  80162a:	75 06                	jne    801632 <strchr+0x1d>
  80162c:	eb 1a                	jmp    801648 <strchr+0x33>
  80162e:	38 ca                	cmp    %cl,%dl
  801630:	74 16                	je     801648 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801632:	83 c0 01             	add    $0x1,%eax
  801635:	0f b6 10             	movzbl (%eax),%edx
  801638:	84 d2                	test   %dl,%dl
  80163a:	75 f2                	jne    80162e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  80163c:	b8 00 00 00 00       	mov    $0x0,%eax
  801641:	eb 05                	jmp    801648 <strchr+0x33>
  801643:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801648:	5b                   	pop    %ebx
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	53                   	push   %ebx
  80164f:	8b 45 08             	mov    0x8(%ebp),%eax
  801652:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801655:	0f b6 18             	movzbl (%eax),%ebx
  801658:	84 db                	test   %bl,%bl
  80165a:	74 16                	je     801672 <strfind+0x27>
  80165c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80165e:	38 d3                	cmp    %dl,%bl
  801660:	75 06                	jne    801668 <strfind+0x1d>
  801662:	eb 0e                	jmp    801672 <strfind+0x27>
  801664:	38 ca                	cmp    %cl,%dl
  801666:	74 0a                	je     801672 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801668:	83 c0 01             	add    $0x1,%eax
  80166b:	0f b6 10             	movzbl (%eax),%edx
  80166e:	84 d2                	test   %dl,%dl
  801670:	75 f2                	jne    801664 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  801672:	5b                   	pop    %ebx
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 0c             	sub    $0xc,%esp
  80167b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80167e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801681:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801684:	8b 7d 08             	mov    0x8(%ebp),%edi
  801687:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80168a:	85 c9                	test   %ecx,%ecx
  80168c:	74 36                	je     8016c4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80168e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801694:	75 28                	jne    8016be <memset+0x49>
  801696:	f6 c1 03             	test   $0x3,%cl
  801699:	75 23                	jne    8016be <memset+0x49>
		c &= 0xFF;
  80169b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80169f:	89 d3                	mov    %edx,%ebx
  8016a1:	c1 e3 08             	shl    $0x8,%ebx
  8016a4:	89 d6                	mov    %edx,%esi
  8016a6:	c1 e6 18             	shl    $0x18,%esi
  8016a9:	89 d0                	mov    %edx,%eax
  8016ab:	c1 e0 10             	shl    $0x10,%eax
  8016ae:	09 f0                	or     %esi,%eax
  8016b0:	09 c2                	or     %eax,%edx
  8016b2:	89 d0                	mov    %edx,%eax
  8016b4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8016b6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8016b9:	fc                   	cld    
  8016ba:	f3 ab                	rep stos %eax,%es:(%edi)
  8016bc:	eb 06                	jmp    8016c4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8016be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c1:	fc                   	cld    
  8016c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  8016c4:	89 f8                	mov    %edi,%eax
  8016c6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016c9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016cf:	89 ec                	mov    %ebp,%esp
  8016d1:	5d                   	pop    %ebp
  8016d2:	c3                   	ret    

008016d3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016dc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8016df:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8016e8:	39 c6                	cmp    %eax,%esi
  8016ea:	73 36                	jae    801722 <memmove+0x4f>
  8016ec:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8016ef:	39 d0                	cmp    %edx,%eax
  8016f1:	73 2f                	jae    801722 <memmove+0x4f>
		s += n;
		d += n;
  8016f3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8016f6:	f6 c2 03             	test   $0x3,%dl
  8016f9:	75 1b                	jne    801716 <memmove+0x43>
  8016fb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801701:	75 13                	jne    801716 <memmove+0x43>
  801703:	f6 c1 03             	test   $0x3,%cl
  801706:	75 0e                	jne    801716 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801708:	83 ef 04             	sub    $0x4,%edi
  80170b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80170e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801711:	fd                   	std    
  801712:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801714:	eb 09                	jmp    80171f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801716:	83 ef 01             	sub    $0x1,%edi
  801719:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80171c:	fd                   	std    
  80171d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80171f:	fc                   	cld    
  801720:	eb 20                	jmp    801742 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801722:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801728:	75 13                	jne    80173d <memmove+0x6a>
  80172a:	a8 03                	test   $0x3,%al
  80172c:	75 0f                	jne    80173d <memmove+0x6a>
  80172e:	f6 c1 03             	test   $0x3,%cl
  801731:	75 0a                	jne    80173d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801733:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801736:	89 c7                	mov    %eax,%edi
  801738:	fc                   	cld    
  801739:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80173b:	eb 05                	jmp    801742 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80173d:	89 c7                	mov    %eax,%edi
  80173f:	fc                   	cld    
  801740:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801742:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801745:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801748:	89 ec                	mov    %ebp,%esp
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    

0080174c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801752:	8b 45 10             	mov    0x10(%ebp),%eax
  801755:	89 44 24 08          	mov    %eax,0x8(%esp)
  801759:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	89 04 24             	mov    %eax,(%esp)
  801766:	e8 68 ff ff ff       	call   8016d3 <memmove>
}
  80176b:	c9                   	leave  
  80176c:	c3                   	ret    

0080176d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	57                   	push   %edi
  801771:	56                   	push   %esi
  801772:	53                   	push   %ebx
  801773:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801776:	8b 75 0c             	mov    0xc(%ebp),%esi
  801779:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80177c:	8d 78 ff             	lea    -0x1(%eax),%edi
  80177f:	85 c0                	test   %eax,%eax
  801781:	74 36                	je     8017b9 <memcmp+0x4c>
		if (*s1 != *s2)
  801783:	0f b6 03             	movzbl (%ebx),%eax
  801786:	0f b6 0e             	movzbl (%esi),%ecx
  801789:	38 c8                	cmp    %cl,%al
  80178b:	75 17                	jne    8017a4 <memcmp+0x37>
  80178d:	ba 00 00 00 00       	mov    $0x0,%edx
  801792:	eb 1a                	jmp    8017ae <memcmp+0x41>
  801794:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801799:	83 c2 01             	add    $0x1,%edx
  80179c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8017a0:	38 c8                	cmp    %cl,%al
  8017a2:	74 0a                	je     8017ae <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  8017a4:	0f b6 c0             	movzbl %al,%eax
  8017a7:	0f b6 c9             	movzbl %cl,%ecx
  8017aa:	29 c8                	sub    %ecx,%eax
  8017ac:	eb 10                	jmp    8017be <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8017ae:	39 fa                	cmp    %edi,%edx
  8017b0:	75 e2                	jne    801794 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8017b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b7:	eb 05                	jmp    8017be <memcmp+0x51>
  8017b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017be:	5b                   	pop    %ebx
  8017bf:	5e                   	pop    %esi
  8017c0:	5f                   	pop    %edi
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    

008017c3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  8017cd:	89 c2                	mov    %eax,%edx
  8017cf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8017d2:	39 d0                	cmp    %edx,%eax
  8017d4:	73 13                	jae    8017e9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  8017d6:	89 d9                	mov    %ebx,%ecx
  8017d8:	38 18                	cmp    %bl,(%eax)
  8017da:	75 06                	jne    8017e2 <memfind+0x1f>
  8017dc:	eb 0b                	jmp    8017e9 <memfind+0x26>
  8017de:	38 08                	cmp    %cl,(%eax)
  8017e0:	74 07                	je     8017e9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8017e2:	83 c0 01             	add    $0x1,%eax
  8017e5:	39 d0                	cmp    %edx,%eax
  8017e7:	75 f5                	jne    8017de <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8017e9:	5b                   	pop    %ebx
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    

008017ec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	57                   	push   %edi
  8017f0:	56                   	push   %esi
  8017f1:	53                   	push   %ebx
  8017f2:	83 ec 04             	sub    $0x4,%esp
  8017f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8017fb:	0f b6 02             	movzbl (%edx),%eax
  8017fe:	3c 09                	cmp    $0x9,%al
  801800:	74 04                	je     801806 <strtol+0x1a>
  801802:	3c 20                	cmp    $0x20,%al
  801804:	75 0e                	jne    801814 <strtol+0x28>
		s++;
  801806:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801809:	0f b6 02             	movzbl (%edx),%eax
  80180c:	3c 09                	cmp    $0x9,%al
  80180e:	74 f6                	je     801806 <strtol+0x1a>
  801810:	3c 20                	cmp    $0x20,%al
  801812:	74 f2                	je     801806 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801814:	3c 2b                	cmp    $0x2b,%al
  801816:	75 0a                	jne    801822 <strtol+0x36>
		s++;
  801818:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80181b:	bf 00 00 00 00       	mov    $0x0,%edi
  801820:	eb 10                	jmp    801832 <strtol+0x46>
  801822:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801827:	3c 2d                	cmp    $0x2d,%al
  801829:	75 07                	jne    801832 <strtol+0x46>
		s++, neg = 1;
  80182b:	83 c2 01             	add    $0x1,%edx
  80182e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801832:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801838:	75 15                	jne    80184f <strtol+0x63>
  80183a:	80 3a 30             	cmpb   $0x30,(%edx)
  80183d:	75 10                	jne    80184f <strtol+0x63>
  80183f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801843:	75 0a                	jne    80184f <strtol+0x63>
		s += 2, base = 16;
  801845:	83 c2 02             	add    $0x2,%edx
  801848:	bb 10 00 00 00       	mov    $0x10,%ebx
  80184d:	eb 10                	jmp    80185f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  80184f:	85 db                	test   %ebx,%ebx
  801851:	75 0c                	jne    80185f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801853:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801855:	80 3a 30             	cmpb   $0x30,(%edx)
  801858:	75 05                	jne    80185f <strtol+0x73>
		s++, base = 8;
  80185a:	83 c2 01             	add    $0x1,%edx
  80185d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80185f:	b8 00 00 00 00       	mov    $0x0,%eax
  801864:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801867:	0f b6 0a             	movzbl (%edx),%ecx
  80186a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80186d:	89 f3                	mov    %esi,%ebx
  80186f:	80 fb 09             	cmp    $0x9,%bl
  801872:	77 08                	ja     80187c <strtol+0x90>
			dig = *s - '0';
  801874:	0f be c9             	movsbl %cl,%ecx
  801877:	83 e9 30             	sub    $0x30,%ecx
  80187a:	eb 22                	jmp    80189e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  80187c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80187f:	89 f3                	mov    %esi,%ebx
  801881:	80 fb 19             	cmp    $0x19,%bl
  801884:	77 08                	ja     80188e <strtol+0xa2>
			dig = *s - 'a' + 10;
  801886:	0f be c9             	movsbl %cl,%ecx
  801889:	83 e9 57             	sub    $0x57,%ecx
  80188c:	eb 10                	jmp    80189e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  80188e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801891:	89 f3                	mov    %esi,%ebx
  801893:	80 fb 19             	cmp    $0x19,%bl
  801896:	77 16                	ja     8018ae <strtol+0xc2>
			dig = *s - 'A' + 10;
  801898:	0f be c9             	movsbl %cl,%ecx
  80189b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80189e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8018a1:	7d 0f                	jge    8018b2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  8018a3:	83 c2 01             	add    $0x1,%edx
  8018a6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  8018aa:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8018ac:	eb b9                	jmp    801867 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8018ae:	89 c1                	mov    %eax,%ecx
  8018b0:	eb 02                	jmp    8018b4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8018b2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8018b4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8018b8:	74 05                	je     8018bf <strtol+0xd3>
		*endptr = (char *) s;
  8018ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018bd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8018bf:	89 ca                	mov    %ecx,%edx
  8018c1:	f7 da                	neg    %edx
  8018c3:	85 ff                	test   %edi,%edi
  8018c5:	0f 45 c2             	cmovne %edx,%eax
}
  8018c8:	83 c4 04             	add    $0x4,%esp
  8018cb:	5b                   	pop    %ebx
  8018cc:	5e                   	pop    %esi
  8018cd:	5f                   	pop    %edi
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8018d6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8018dd:	75 54                	jne    801933 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  8018df:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018e6:	00 
  8018e7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8018ee:	ee 
  8018ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f6:	e8 16 e9 ff ff       	call   800211 <sys_page_alloc>
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	74 20                	je     80191f <set_pgfault_handler+0x4f>
			panic("sys_page_alloc() failed in set_pgfault_handler()[%e]\n", r);
  8018ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801903:	c7 44 24 08 80 21 80 	movl   $0x802180,0x8(%esp)
  80190a:	00 
  80190b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801912:	00 
  801913:	c7 04 24 b8 21 80 00 	movl   $0x8021b8,(%esp)
  80191a:	e8 31 f4 ff ff       	call   800d50 <_panic>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80191f:	c7 44 24 04 20 05 80 	movl   $0x800520,0x4(%esp)
  801926:	00 
  801927:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80192e:	e8 e2 ea ff ff       	call   800415 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801933:	8b 45 08             	mov    0x8(%ebp),%eax
  801936:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    
  80193d:	66 90                	xchg   %ax,%ax
  80193f:	90                   	nop

00801940 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	83 ec 10             	sub    $0x10,%esp
  801948:	8b 75 08             	mov    0x8(%ebp),%esi
  80194b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  80194e:	85 db                	test   %ebx,%ebx
  801950:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801955:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  801958:	89 1c 24             	mov    %ebx,(%esp)
  80195b:	e8 59 eb ff ff       	call   8004b9 <sys_ipc_recv>
  801960:	85 c0                	test   %eax,%eax
  801962:	78 2d                	js     801991 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  801964:	85 f6                	test   %esi,%esi
  801966:	74 0a                	je     801972 <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  801968:	a1 04 40 80 00       	mov    0x804004,%eax
  80196d:	8b 40 74             	mov    0x74(%eax),%eax
  801970:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  801972:	85 db                	test   %ebx,%ebx
  801974:	74 13                	je     801989 <ipc_recv+0x49>
  801976:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80197a:	74 0d                	je     801989 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  80197c:	a1 04 40 80 00       	mov    0x804004,%eax
  801981:	8b 40 78             	mov    0x78(%eax),%eax
  801984:	8b 55 10             	mov    0x10(%ebp),%edx
  801987:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801989:	a1 04 40 80 00       	mov    0x804004,%eax
  80198e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	5b                   	pop    %ebx
  801995:	5e                   	pop    %esi
  801996:	5d                   	pop    %ebp
  801997:	c3                   	ret    

00801998 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	57                   	push   %edi
  80199c:	56                   	push   %esi
  80199d:	53                   	push   %ebx
  80199e:	83 ec 1c             	sub    $0x1c,%esp
  8019a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  8019aa:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  8019ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8019b1:	0f 44 d8             	cmove  %eax,%ebx
  8019b4:	eb 2a                	jmp    8019e0 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  8019b6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8019b9:	74 20                	je     8019db <ipc_send+0x43>
            panic("Send message error %e\n",r);
  8019bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019bf:	c7 44 24 08 c6 21 80 	movl   $0x8021c6,0x8(%esp)
  8019c6:	00 
  8019c7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8019ce:	00 
  8019cf:	c7 04 24 dd 21 80 00 	movl   $0x8021dd,(%esp)
  8019d6:	e8 75 f3 ff ff       	call   800d50 <_panic>
		sys_yield();
  8019db:	e8 f8 e7 ff ff       	call   8001d8 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  8019e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019e7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019eb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019ef:	89 3c 24             	mov    %edi,(%esp)
  8019f2:	e8 85 ea ff ff       	call   80047c <sys_ipc_try_send>
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 bb                	js     8019b6 <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  8019fb:	83 c4 1c             	add    $0x1c,%esp
  8019fe:	5b                   	pop    %ebx
  8019ff:	5e                   	pop    %esi
  801a00:	5f                   	pop    %edi
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a09:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801a0e:	39 c8                	cmp    %ecx,%eax
  801a10:	74 17                	je     801a29 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a12:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801a17:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a1a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a20:	8b 52 50             	mov    0x50(%edx),%edx
  801a23:	39 ca                	cmp    %ecx,%edx
  801a25:	75 14                	jne    801a3b <ipc_find_env+0x38>
  801a27:	eb 05                	jmp    801a2e <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a29:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801a2e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a31:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801a36:	8b 40 40             	mov    0x40(%eax),%eax
  801a39:	eb 0e                	jmp    801a49 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a3b:	83 c0 01             	add    $0x1,%eax
  801a3e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a43:	75 d2                	jne    801a17 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801a45:	66 b8 00 00          	mov    $0x0,%ax
}
  801a49:	5d                   	pop    %ebp
  801a4a:	c3                   	ret    
  801a4b:	66 90                	xchg   %ax,%ax
  801a4d:	66 90                	xchg   %ax,%ax
  801a4f:	90                   	nop

00801a50 <__udivdi3>:
  801a50:	83 ec 1c             	sub    $0x1c,%esp
  801a53:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801a57:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801a5b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801a5f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801a63:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801a67:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801a71:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a75:	89 ea                	mov    %ebp,%edx
  801a77:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a7b:	75 33                	jne    801ab0 <__udivdi3+0x60>
  801a7d:	39 e9                	cmp    %ebp,%ecx
  801a7f:	77 6f                	ja     801af0 <__udivdi3+0xa0>
  801a81:	85 c9                	test   %ecx,%ecx
  801a83:	89 ce                	mov    %ecx,%esi
  801a85:	75 0b                	jne    801a92 <__udivdi3+0x42>
  801a87:	b8 01 00 00 00       	mov    $0x1,%eax
  801a8c:	31 d2                	xor    %edx,%edx
  801a8e:	f7 f1                	div    %ecx
  801a90:	89 c6                	mov    %eax,%esi
  801a92:	31 d2                	xor    %edx,%edx
  801a94:	89 e8                	mov    %ebp,%eax
  801a96:	f7 f6                	div    %esi
  801a98:	89 c5                	mov    %eax,%ebp
  801a9a:	89 f8                	mov    %edi,%eax
  801a9c:	f7 f6                	div    %esi
  801a9e:	89 ea                	mov    %ebp,%edx
  801aa0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801aa4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801aa8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801aac:	83 c4 1c             	add    $0x1c,%esp
  801aaf:	c3                   	ret    
  801ab0:	39 e8                	cmp    %ebp,%eax
  801ab2:	77 24                	ja     801ad8 <__udivdi3+0x88>
  801ab4:	0f bd c8             	bsr    %eax,%ecx
  801ab7:	83 f1 1f             	xor    $0x1f,%ecx
  801aba:	89 0c 24             	mov    %ecx,(%esp)
  801abd:	75 49                	jne    801b08 <__udivdi3+0xb8>
  801abf:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ac3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801ac7:	0f 86 ab 00 00 00    	jbe    801b78 <__udivdi3+0x128>
  801acd:	39 e8                	cmp    %ebp,%eax
  801acf:	0f 82 a3 00 00 00    	jb     801b78 <__udivdi3+0x128>
  801ad5:	8d 76 00             	lea    0x0(%esi),%esi
  801ad8:	31 d2                	xor    %edx,%edx
  801ada:	31 c0                	xor    %eax,%eax
  801adc:	8b 74 24 10          	mov    0x10(%esp),%esi
  801ae0:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801ae4:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801ae8:	83 c4 1c             	add    $0x1c,%esp
  801aeb:	c3                   	ret    
  801aec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801af0:	89 f8                	mov    %edi,%eax
  801af2:	f7 f1                	div    %ecx
  801af4:	31 d2                	xor    %edx,%edx
  801af6:	8b 74 24 10          	mov    0x10(%esp),%esi
  801afa:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801afe:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b02:	83 c4 1c             	add    $0x1c,%esp
  801b05:	c3                   	ret    
  801b06:	66 90                	xchg   %ax,%ax
  801b08:	0f b6 0c 24          	movzbl (%esp),%ecx
  801b0c:	89 c6                	mov    %eax,%esi
  801b0e:	b8 20 00 00 00       	mov    $0x20,%eax
  801b13:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801b17:	2b 04 24             	sub    (%esp),%eax
  801b1a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b1e:	d3 e6                	shl    %cl,%esi
  801b20:	89 c1                	mov    %eax,%ecx
  801b22:	d3 ed                	shr    %cl,%ebp
  801b24:	0f b6 0c 24          	movzbl (%esp),%ecx
  801b28:	09 f5                	or     %esi,%ebp
  801b2a:	8b 74 24 04          	mov    0x4(%esp),%esi
  801b2e:	d3 e6                	shl    %cl,%esi
  801b30:	89 c1                	mov    %eax,%ecx
  801b32:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b36:	89 d6                	mov    %edx,%esi
  801b38:	d3 ee                	shr    %cl,%esi
  801b3a:	0f b6 0c 24          	movzbl (%esp),%ecx
  801b3e:	d3 e2                	shl    %cl,%edx
  801b40:	89 c1                	mov    %eax,%ecx
  801b42:	d3 ef                	shr    %cl,%edi
  801b44:	09 d7                	or     %edx,%edi
  801b46:	89 f2                	mov    %esi,%edx
  801b48:	89 f8                	mov    %edi,%eax
  801b4a:	f7 f5                	div    %ebp
  801b4c:	89 d6                	mov    %edx,%esi
  801b4e:	89 c7                	mov    %eax,%edi
  801b50:	f7 64 24 04          	mull   0x4(%esp)
  801b54:	39 d6                	cmp    %edx,%esi
  801b56:	72 30                	jb     801b88 <__udivdi3+0x138>
  801b58:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801b5c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801b60:	d3 e5                	shl    %cl,%ebp
  801b62:	39 c5                	cmp    %eax,%ebp
  801b64:	73 04                	jae    801b6a <__udivdi3+0x11a>
  801b66:	39 d6                	cmp    %edx,%esi
  801b68:	74 1e                	je     801b88 <__udivdi3+0x138>
  801b6a:	89 f8                	mov    %edi,%eax
  801b6c:	31 d2                	xor    %edx,%edx
  801b6e:	e9 69 ff ff ff       	jmp    801adc <__udivdi3+0x8c>
  801b73:	90                   	nop
  801b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b78:	31 d2                	xor    %edx,%edx
  801b7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7f:	e9 58 ff ff ff       	jmp    801adc <__udivdi3+0x8c>
  801b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b88:	8d 47 ff             	lea    -0x1(%edi),%eax
  801b8b:	31 d2                	xor    %edx,%edx
  801b8d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b91:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b95:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b99:	83 c4 1c             	add    $0x1c,%esp
  801b9c:	c3                   	ret    
  801b9d:	66 90                	xchg   %ax,%ax
  801b9f:	90                   	nop

00801ba0 <__umoddi3>:
  801ba0:	83 ec 2c             	sub    $0x2c,%esp
  801ba3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801ba7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801bab:	89 74 24 20          	mov    %esi,0x20(%esp)
  801baf:	8b 74 24 38          	mov    0x38(%esp),%esi
  801bb3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801bb7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	89 c2                	mov    %eax,%edx
  801bbf:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801bc3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801bc7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bcb:	89 74 24 10          	mov    %esi,0x10(%esp)
  801bcf:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801bd3:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801bd7:	75 1f                	jne    801bf8 <__umoddi3+0x58>
  801bd9:	39 fe                	cmp    %edi,%esi
  801bdb:	76 63                	jbe    801c40 <__umoddi3+0xa0>
  801bdd:	89 c8                	mov    %ecx,%eax
  801bdf:	89 fa                	mov    %edi,%edx
  801be1:	f7 f6                	div    %esi
  801be3:	89 d0                	mov    %edx,%eax
  801be5:	31 d2                	xor    %edx,%edx
  801be7:	8b 74 24 20          	mov    0x20(%esp),%esi
  801beb:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801bef:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801bf3:	83 c4 2c             	add    $0x2c,%esp
  801bf6:	c3                   	ret    
  801bf7:	90                   	nop
  801bf8:	39 f8                	cmp    %edi,%eax
  801bfa:	77 64                	ja     801c60 <__umoddi3+0xc0>
  801bfc:	0f bd e8             	bsr    %eax,%ebp
  801bff:	83 f5 1f             	xor    $0x1f,%ebp
  801c02:	75 74                	jne    801c78 <__umoddi3+0xd8>
  801c04:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801c08:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801c0c:	0f 87 0e 01 00 00    	ja     801d20 <__umoddi3+0x180>
  801c12:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801c16:	29 f1                	sub    %esi,%ecx
  801c18:	19 c7                	sbb    %eax,%edi
  801c1a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801c1e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c22:	8b 44 24 14          	mov    0x14(%esp),%eax
  801c26:	8b 54 24 18          	mov    0x18(%esp),%edx
  801c2a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c2e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c32:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c36:	83 c4 2c             	add    $0x2c,%esp
  801c39:	c3                   	ret    
  801c3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c40:	85 f6                	test   %esi,%esi
  801c42:	89 f5                	mov    %esi,%ebp
  801c44:	75 0b                	jne    801c51 <__umoddi3+0xb1>
  801c46:	b8 01 00 00 00       	mov    $0x1,%eax
  801c4b:	31 d2                	xor    %edx,%edx
  801c4d:	f7 f6                	div    %esi
  801c4f:	89 c5                	mov    %eax,%ebp
  801c51:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801c55:	31 d2                	xor    %edx,%edx
  801c57:	f7 f5                	div    %ebp
  801c59:	89 c8                	mov    %ecx,%eax
  801c5b:	f7 f5                	div    %ebp
  801c5d:	eb 84                	jmp    801be3 <__umoddi3+0x43>
  801c5f:	90                   	nop
  801c60:	89 c8                	mov    %ecx,%eax
  801c62:	89 fa                	mov    %edi,%edx
  801c64:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c68:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c6c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c70:	83 c4 2c             	add    $0x2c,%esp
  801c73:	c3                   	ret    
  801c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c78:	8b 44 24 10          	mov    0x10(%esp),%eax
  801c7c:	be 20 00 00 00       	mov    $0x20,%esi
  801c81:	89 e9                	mov    %ebp,%ecx
  801c83:	29 ee                	sub    %ebp,%esi
  801c85:	d3 e2                	shl    %cl,%edx
  801c87:	89 f1                	mov    %esi,%ecx
  801c89:	d3 e8                	shr    %cl,%eax
  801c8b:	89 e9                	mov    %ebp,%ecx
  801c8d:	09 d0                	or     %edx,%eax
  801c8f:	89 fa                	mov    %edi,%edx
  801c91:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c95:	8b 44 24 10          	mov    0x10(%esp),%eax
  801c99:	d3 e0                	shl    %cl,%eax
  801c9b:	89 f1                	mov    %esi,%ecx
  801c9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ca1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801ca5:	d3 ea                	shr    %cl,%edx
  801ca7:	89 e9                	mov    %ebp,%ecx
  801ca9:	d3 e7                	shl    %cl,%edi
  801cab:	89 f1                	mov    %esi,%ecx
  801cad:	d3 e8                	shr    %cl,%eax
  801caf:	89 e9                	mov    %ebp,%ecx
  801cb1:	09 f8                	or     %edi,%eax
  801cb3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801cb7:	f7 74 24 0c          	divl   0xc(%esp)
  801cbb:	d3 e7                	shl    %cl,%edi
  801cbd:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801cc1:	89 d7                	mov    %edx,%edi
  801cc3:	f7 64 24 10          	mull   0x10(%esp)
  801cc7:	39 d7                	cmp    %edx,%edi
  801cc9:	89 c1                	mov    %eax,%ecx
  801ccb:	89 54 24 14          	mov    %edx,0x14(%esp)
  801ccf:	72 3b                	jb     801d0c <__umoddi3+0x16c>
  801cd1:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801cd5:	72 31                	jb     801d08 <__umoddi3+0x168>
  801cd7:	8b 44 24 18          	mov    0x18(%esp),%eax
  801cdb:	29 c8                	sub    %ecx,%eax
  801cdd:	19 d7                	sbb    %edx,%edi
  801cdf:	89 e9                	mov    %ebp,%ecx
  801ce1:	89 fa                	mov    %edi,%edx
  801ce3:	d3 e8                	shr    %cl,%eax
  801ce5:	89 f1                	mov    %esi,%ecx
  801ce7:	d3 e2                	shl    %cl,%edx
  801ce9:	89 e9                	mov    %ebp,%ecx
  801ceb:	09 d0                	or     %edx,%eax
  801ced:	89 fa                	mov    %edi,%edx
  801cef:	d3 ea                	shr    %cl,%edx
  801cf1:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cf5:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cf9:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801cfd:	83 c4 2c             	add    $0x2c,%esp
  801d00:	c3                   	ret    
  801d01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d08:	39 d7                	cmp    %edx,%edi
  801d0a:	75 cb                	jne    801cd7 <__umoddi3+0x137>
  801d0c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801d10:	89 c1                	mov    %eax,%ecx
  801d12:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801d16:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801d1a:	eb bb                	jmp    801cd7 <__umoddi3+0x137>
  801d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d20:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801d24:	0f 82 e8 fe ff ff    	jb     801c12 <__umoddi3+0x72>
  801d2a:	e9 f3 fe ff ff       	jmp    801c22 <__umoddi3+0x82>
