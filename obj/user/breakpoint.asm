
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    
  80003a:	66 90                	xchg   %ax,%ax

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	83 ec 18             	sub    $0x18,%esp
  800042:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800045:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800048:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  80004e:	e8 2c 01 00 00       	call   80017f <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 db                	test   %ebx,%ebx
  800067:	7e 07                	jle    800070 <libmain+0x34>
		binaryname = argv[0];
  800069:	8b 06                	mov    (%esi),%eax
  80006b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800070:	89 74 24 04          	mov    %esi,0x4(%esp)
  800074:	89 1c 24             	mov    %ebx,(%esp)
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0b 00 00 00       	call   80008c <exit>
}
  800081:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800084:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800087:	89 ec                	mov    %ebp,%esp
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    
  80008b:	90                   	nop

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800092:	e8 6c 06 00 00       	call   800703 <close_all>
	sys_env_destroy(0);
  800097:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009e:	e8 76 00 00 00       	call   800119 <sys_env_destroy>
}
  8000a3:	c9                   	leave  
  8000a4:	c3                   	ret    
  8000a5:	66 90                	xchg   %ax,%ax
  8000a7:	90                   	nop

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000b1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000b4:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  8000b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bc:	0f a2                	cpuid  
  8000be:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	89 c3                	mov    %eax,%ebx
  8000cd:	89 c7                	mov    %eax,%edi
  8000cf:	89 c6                	mov    %eax,%esi
  8000d1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000d6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000d9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000dc:	89 ec                	mov    %ebp,%esp
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 0c             	sub    $0xc,%esp
  8000e6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000e9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000ec:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8000ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f4:	0f a2                	cpuid  
  8000f6:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fd:	b8 01 00 00 00       	mov    $0x1,%eax
  800102:	89 d1                	mov    %edx,%ecx
  800104:	89 d3                	mov    %edx,%ebx
  800106:	89 d7                	mov    %edx,%edi
  800108:	89 d6                	mov    %edx,%esi
  80010a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80010f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800112:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800115:	89 ec                	mov    %ebp,%esp
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	83 ec 38             	sub    $0x38,%esp
  80011f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800122:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800125:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800128:	b8 01 00 00 00       	mov    $0x1,%eax
  80012d:	0f a2                	cpuid  
  80012f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800131:	b9 00 00 00 00       	mov    $0x0,%ecx
  800136:	b8 03 00 00 00       	mov    $0x3,%eax
  80013b:	8b 55 08             	mov    0x8(%ebp),%edx
  80013e:	89 cb                	mov    %ecx,%ebx
  800140:	89 cf                	mov    %ecx,%edi
  800142:	89 ce                	mov    %ecx,%esi
  800144:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800146:	85 c0                	test   %eax,%eax
  800148:	7e 28                	jle    800172 <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  80014a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80014e:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800155:	00 
  800156:	c7 44 24 08 8a 1c 80 	movl   $0x801c8a,0x8(%esp)
  80015d:	00 
  80015e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800165:	00 
  800166:	c7 04 24 a7 1c 80 00 	movl   $0x801ca7,(%esp)
  80016d:	e8 8e 0b 00 00       	call   800d00 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800172:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800175:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800178:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80017b:	89 ec                	mov    %ebp,%esp
  80017d:	5d                   	pop    %ebp
  80017e:	c3                   	ret    

0080017f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800188:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80018b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80018e:	b8 01 00 00 00       	mov    $0x1,%eax
  800193:	0f a2                	cpuid  
  800195:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800197:	ba 00 00 00 00       	mov    $0x0,%edx
  80019c:	b8 02 00 00 00       	mov    $0x2,%eax
  8001a1:	89 d1                	mov    %edx,%ecx
  8001a3:	89 d3                	mov    %edx,%ebx
  8001a5:	89 d7                	mov    %edx,%edi
  8001a7:	89 d6                	mov    %edx,%esi
  8001a9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001ab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ae:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001b1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001b4:	89 ec                	mov    %ebp,%esp
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <sys_yield>:

void
sys_yield(void)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001c1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001c4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8001c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8001cc:	0f a2                	cpuid  
  8001ce:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001d5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001da:	89 d1                	mov    %edx,%ecx
  8001dc:	89 d3                	mov    %edx,%ebx
  8001de:	89 d7                	mov    %edx,%edi
  8001e0:	89 d6                	mov    %edx,%esi
  8001e2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001e4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001e7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001ea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001ed:	89 ec                	mov    %ebp,%esp
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    

008001f1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 38             	sub    $0x38,%esp
  8001f7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001fa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001fd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800200:	b8 01 00 00 00       	mov    $0x1,%eax
  800205:	0f a2                	cpuid  
  800207:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800209:	be 00 00 00 00       	mov    $0x0,%esi
  80020e:	b8 04 00 00 00       	mov    $0x4,%eax
  800213:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800216:	8b 55 08             	mov    0x8(%ebp),%edx
  800219:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80021c:	89 f7                	mov    %esi,%edi
  80021e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800220:	85 c0                	test   %eax,%eax
  800222:	7e 28                	jle    80024c <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800224:	89 44 24 10          	mov    %eax,0x10(%esp)
  800228:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80022f:	00 
  800230:	c7 44 24 08 8a 1c 80 	movl   $0x801c8a,0x8(%esp)
  800237:	00 
  800238:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80023f:	00 
  800240:	c7 04 24 a7 1c 80 00 	movl   $0x801ca7,(%esp)
  800247:	e8 b4 0a 00 00       	call   800d00 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80024c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80024f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800252:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800255:	89 ec                	mov    %ebp,%esp
  800257:	5d                   	pop    %ebp
  800258:	c3                   	ret    

00800259 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	83 ec 38             	sub    $0x38,%esp
  80025f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800262:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800265:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800268:	b8 01 00 00 00       	mov    $0x1,%eax
  80026d:	0f a2                	cpuid  
  80026f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800271:	b8 05 00 00 00       	mov    $0x5,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80027f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800282:	8b 75 18             	mov    0x18(%ebp),%esi
  800285:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800287:	85 c0                	test   %eax,%eax
  800289:	7e 28                	jle    8002b3 <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80028f:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800296:	00 
  800297:	c7 44 24 08 8a 1c 80 	movl   $0x801c8a,0x8(%esp)
  80029e:	00 
  80029f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8002a6:	00 
  8002a7:	c7 04 24 a7 1c 80 00 	movl   $0x801ca7,(%esp)
  8002ae:	e8 4d 0a 00 00       	call   800d00 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002b3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002b6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002b9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002bc:	89 ec                	mov    %ebp,%esp
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	83 ec 38             	sub    $0x38,%esp
  8002c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8002cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8002d4:	0f a2                	cpuid  
  8002d6:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dd:	b8 06 00 00 00       	mov    $0x6,%eax
  8002e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e8:	89 df                	mov    %ebx,%edi
  8002ea:	89 de                	mov    %ebx,%esi
  8002ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	7e 28                	jle    80031a <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002fd:	00 
  8002fe:	c7 44 24 08 8a 1c 80 	movl   $0x801c8a,0x8(%esp)
  800305:	00 
  800306:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80030d:	00 
  80030e:	c7 04 24 a7 1c 80 00 	movl   $0x801ca7,(%esp)
  800315:	e8 e6 09 00 00       	call   800d00 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80031a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80031d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800320:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800323:	89 ec                	mov    %ebp,%esp
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	83 ec 38             	sub    $0x38,%esp
  80032d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800330:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800333:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800336:	b8 01 00 00 00       	mov    $0x1,%eax
  80033b:	0f a2                	cpuid  
  80033d:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	b8 08 00 00 00       	mov    $0x8,%eax
  800349:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034c:	8b 55 08             	mov    0x8(%ebp),%edx
  80034f:	89 df                	mov    %ebx,%edi
  800351:	89 de                	mov    %ebx,%esi
  800353:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800355:	85 c0                	test   %eax,%eax
  800357:	7e 28                	jle    800381 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800359:	89 44 24 10          	mov    %eax,0x10(%esp)
  80035d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800364:	00 
  800365:	c7 44 24 08 8a 1c 80 	movl   $0x801c8a,0x8(%esp)
  80036c:	00 
  80036d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800374:	00 
  800375:	c7 04 24 a7 1c 80 00 	movl   $0x801ca7,(%esp)
  80037c:	e8 7f 09 00 00       	call   800d00 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800381:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800384:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800387:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80038a:	89 ec                	mov    %ebp,%esp
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 38             	sub    $0x38,%esp
  800394:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800397:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80039a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80039d:	b8 01 00 00 00       	mov    $0x1,%eax
  8003a2:	0f a2                	cpuid  
  8003a4:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ab:	b8 09 00 00 00       	mov    $0x9,%eax
  8003b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b6:	89 df                	mov    %ebx,%edi
  8003b8:	89 de                	mov    %ebx,%esi
  8003ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003bc:	85 c0                	test   %eax,%eax
  8003be:	7e 28                	jle    8003e8 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c4:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003cb:	00 
  8003cc:	c7 44 24 08 8a 1c 80 	movl   $0x801c8a,0x8(%esp)
  8003d3:	00 
  8003d4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8003db:	00 
  8003dc:	c7 04 24 a7 1c 80 00 	movl   $0x801ca7,(%esp)
  8003e3:	e8 18 09 00 00       	call   800d00 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8003e8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003eb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003ee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003f1:	89 ec                	mov    %ebp,%esp
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

008003f5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	83 ec 38             	sub    $0x38,%esp
  8003fb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003fe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800401:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800404:	b8 01 00 00 00       	mov    $0x1,%eax
  800409:	0f a2                	cpuid  
  80040b:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80040d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800412:	b8 0a 00 00 00       	mov    $0xa,%eax
  800417:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80041a:	8b 55 08             	mov    0x8(%ebp),%edx
  80041d:	89 df                	mov    %ebx,%edi
  80041f:	89 de                	mov    %ebx,%esi
  800421:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800423:	85 c0                	test   %eax,%eax
  800425:	7e 28                	jle    80044f <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800427:	89 44 24 10          	mov    %eax,0x10(%esp)
  80042b:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800432:	00 
  800433:	c7 44 24 08 8a 1c 80 	movl   $0x801c8a,0x8(%esp)
  80043a:	00 
  80043b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800442:	00 
  800443:	c7 04 24 a7 1c 80 00 	movl   $0x801ca7,(%esp)
  80044a:	e8 b1 08 00 00       	call   800d00 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80044f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800452:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800455:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800458:	89 ec                	mov    %ebp,%esp
  80045a:	5d                   	pop    %ebp
  80045b:	c3                   	ret    

0080045c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	83 ec 0c             	sub    $0xc,%esp
  800462:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800465:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800468:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80046b:	b8 01 00 00 00       	mov    $0x1,%eax
  800470:	0f a2                	cpuid  
  800472:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800474:	be 00 00 00 00       	mov    $0x0,%esi
  800479:	b8 0c 00 00 00       	mov    $0xc,%eax
  80047e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800481:	8b 55 08             	mov    0x8(%ebp),%edx
  800484:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800487:	8b 7d 14             	mov    0x14(%ebp),%edi
  80048a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80048c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80048f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800492:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800495:	89 ec                	mov    %ebp,%esp
  800497:	5d                   	pop    %ebp
  800498:	c3                   	ret    

00800499 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
  80049c:	83 ec 38             	sub    $0x38,%esp
  80049f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8004a2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8004a5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8004a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8004ad:	0f a2                	cpuid  
  8004af:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8004bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8004be:	89 cb                	mov    %ecx,%ebx
  8004c0:	89 cf                	mov    %ecx,%edi
  8004c2:	89 ce                	mov    %ecx,%esi
  8004c4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	7e 28                	jle    8004f2 <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004ce:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8004d5:	00 
  8004d6:	c7 44 24 08 8a 1c 80 	movl   $0x801c8a,0x8(%esp)
  8004dd:	00 
  8004de:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8004e5:	00 
  8004e6:	c7 04 24 a7 1c 80 00 	movl   $0x801ca7,(%esp)
  8004ed:	e8 0e 08 00 00       	call   800d00 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8004f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8004f5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8004f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004fb:	89 ec                	mov    %ebp,%esp
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    
  8004ff:	90                   	nop

00800500 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800503:	8b 45 08             	mov    0x8(%ebp),%eax
  800506:	05 00 00 00 30       	add    $0x30000000,%eax
  80050b:	c1 e8 0c             	shr    $0xc,%eax
}
  80050e:	5d                   	pop    %ebp
  80050f:	c3                   	ret    

00800510 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800516:	8b 45 08             	mov    0x8(%ebp),%eax
  800519:	89 04 24             	mov    %eax,(%esp)
  80051c:	e8 df ff ff ff       	call   800500 <fd2num>
  800521:	c1 e0 0c             	shl    $0xc,%eax
  800524:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800529:	c9                   	leave  
  80052a:	c3                   	ret    

0080052b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80052e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800533:	a8 01                	test   $0x1,%al
  800535:	74 34                	je     80056b <fd_alloc+0x40>
  800537:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80053c:	a8 01                	test   $0x1,%al
  80053e:	74 32                	je     800572 <fd_alloc+0x47>
  800540:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800545:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800547:	89 c2                	mov    %eax,%edx
  800549:	c1 ea 16             	shr    $0x16,%edx
  80054c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800553:	f6 c2 01             	test   $0x1,%dl
  800556:	74 1f                	je     800577 <fd_alloc+0x4c>
  800558:	89 c2                	mov    %eax,%edx
  80055a:	c1 ea 0c             	shr    $0xc,%edx
  80055d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800564:	f6 c2 01             	test   $0x1,%dl
  800567:	75 1a                	jne    800583 <fd_alloc+0x58>
  800569:	eb 0c                	jmp    800577 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80056b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800570:	eb 05                	jmp    800577 <fd_alloc+0x4c>
  800572:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800577:	8b 45 08             	mov    0x8(%ebp),%eax
  80057a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80057c:	b8 00 00 00 00       	mov    $0x0,%eax
  800581:	eb 1a                	jmp    80059d <fd_alloc+0x72>
  800583:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800588:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80058d:	75 b6                	jne    800545 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80058f:	8b 45 08             	mov    0x8(%ebp),%eax
  800592:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800598:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80059d:	5d                   	pop    %ebp
  80059e:	c3                   	ret    

0080059f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80059f:	55                   	push   %ebp
  8005a0:	89 e5                	mov    %esp,%ebp
  8005a2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8005a5:	83 f8 1f             	cmp    $0x1f,%eax
  8005a8:	77 36                	ja     8005e0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8005aa:	c1 e0 0c             	shl    $0xc,%eax
  8005ad:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8005b2:	89 c2                	mov    %eax,%edx
  8005b4:	c1 ea 16             	shr    $0x16,%edx
  8005b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8005be:	f6 c2 01             	test   $0x1,%dl
  8005c1:	74 24                	je     8005e7 <fd_lookup+0x48>
  8005c3:	89 c2                	mov    %eax,%edx
  8005c5:	c1 ea 0c             	shr    $0xc,%edx
  8005c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005cf:	f6 c2 01             	test   $0x1,%dl
  8005d2:	74 1a                	je     8005ee <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8005d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005d7:	89 02                	mov    %eax,(%edx)
	return 0;
  8005d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005de:	eb 13                	jmp    8005f3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8005e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8005e5:	eb 0c                	jmp    8005f3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8005e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8005ec:	eb 05                	jmp    8005f3 <fd_lookup+0x54>
  8005ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8005f3:	5d                   	pop    %ebp
  8005f4:	c3                   	ret    

008005f5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8005f5:	55                   	push   %ebp
  8005f6:	89 e5                	mov    %esp,%ebp
  8005f8:	83 ec 18             	sub    $0x18,%esp
  8005fb:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8005fe:	39 05 04 30 80 00    	cmp    %eax,0x803004
  800604:	75 10                	jne    800616 <dev_lookup+0x21>
			*dev = devtab[i];
  800606:	8b 45 0c             	mov    0xc(%ebp),%eax
  800609:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80060f:	b8 00 00 00 00       	mov    $0x0,%eax
  800614:	eb 2b                	jmp    800641 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800616:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80061c:	8b 52 48             	mov    0x48(%edx),%edx
  80061f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800623:	89 54 24 04          	mov    %edx,0x4(%esp)
  800627:	c7 04 24 b8 1c 80 00 	movl   $0x801cb8,(%esp)
  80062e:	e8 c8 07 00 00       	call   800dfb <cprintf>
	*dev = 0;
  800633:	8b 55 0c             	mov    0xc(%ebp),%edx
  800636:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80063c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800641:	c9                   	leave  
  800642:	c3                   	ret    

00800643 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800643:	55                   	push   %ebp
  800644:	89 e5                	mov    %esp,%ebp
  800646:	83 ec 38             	sub    $0x38,%esp
  800649:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80064c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80064f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800652:	8b 7d 08             	mov    0x8(%ebp),%edi
  800655:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800658:	89 3c 24             	mov    %edi,(%esp)
  80065b:	e8 a0 fe ff ff       	call   800500 <fd2num>
  800660:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800663:	89 54 24 04          	mov    %edx,0x4(%esp)
  800667:	89 04 24             	mov    %eax,(%esp)
  80066a:	e8 30 ff ff ff       	call   80059f <fd_lookup>
  80066f:	89 c3                	mov    %eax,%ebx
  800671:	85 c0                	test   %eax,%eax
  800673:	78 05                	js     80067a <fd_close+0x37>
	    || fd != fd2)
  800675:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800678:	74 0c                	je     800686 <fd_close+0x43>
		return (must_exist ? r : 0);
  80067a:	85 f6                	test   %esi,%esi
  80067c:	b8 00 00 00 00       	mov    $0x0,%eax
  800681:	0f 44 d8             	cmove  %eax,%ebx
  800684:	eb 3d                	jmp    8006c3 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800686:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068d:	8b 07                	mov    (%edi),%eax
  80068f:	89 04 24             	mov    %eax,(%esp)
  800692:	e8 5e ff ff ff       	call   8005f5 <dev_lookup>
  800697:	89 c3                	mov    %eax,%ebx
  800699:	85 c0                	test   %eax,%eax
  80069b:	78 16                	js     8006b3 <fd_close+0x70>
		if (dev->dev_close)
  80069d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006a0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8006a3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8006a8:	85 c0                	test   %eax,%eax
  8006aa:	74 07                	je     8006b3 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  8006ac:	89 3c 24             	mov    %edi,(%esp)
  8006af:	ff d0                	call   *%eax
  8006b1:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8006b3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006be:	e8 fd fb ff ff       	call   8002c0 <sys_page_unmap>
	return r;
}
  8006c3:	89 d8                	mov    %ebx,%eax
  8006c5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8006c8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8006cb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8006ce:	89 ec                	mov    %ebp,%esp
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8006d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006df:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e2:	89 04 24             	mov    %eax,(%esp)
  8006e5:	e8 b5 fe ff ff       	call   80059f <fd_lookup>
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	78 13                	js     800701 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8006ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8006f5:	00 
  8006f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f9:	89 04 24             	mov    %eax,(%esp)
  8006fc:	e8 42 ff ff ff       	call   800643 <fd_close>
}
  800701:	c9                   	leave  
  800702:	c3                   	ret    

00800703 <close_all>:

void
close_all(void)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	53                   	push   %ebx
  800707:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80070a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80070f:	89 1c 24             	mov    %ebx,(%esp)
  800712:	e8 bb ff ff ff       	call   8006d2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800717:	83 c3 01             	add    $0x1,%ebx
  80071a:	83 fb 20             	cmp    $0x20,%ebx
  80071d:	75 f0                	jne    80070f <close_all+0xc>
		close(i);
}
  80071f:	83 c4 14             	add    $0x14,%esp
  800722:	5b                   	pop    %ebx
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    

00800725 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	83 ec 58             	sub    $0x58,%esp
  80072b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80072e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800731:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800734:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800737:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80073a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	89 04 24             	mov    %eax,(%esp)
  800744:	e8 56 fe ff ff       	call   80059f <fd_lookup>
  800749:	85 c0                	test   %eax,%eax
  80074b:	0f 88 e3 00 00 00    	js     800834 <dup+0x10f>
		return r;
	close(newfdnum);
  800751:	89 1c 24             	mov    %ebx,(%esp)
  800754:	e8 79 ff ff ff       	call   8006d2 <close>

	newfd = INDEX2FD(newfdnum);
  800759:	89 de                	mov    %ebx,%esi
  80075b:	c1 e6 0c             	shl    $0xc,%esi
  80075e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800764:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800767:	89 04 24             	mov    %eax,(%esp)
  80076a:	e8 a1 fd ff ff       	call   800510 <fd2data>
  80076f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800771:	89 34 24             	mov    %esi,(%esp)
  800774:	e8 97 fd ff ff       	call   800510 <fd2data>
  800779:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80077c:	89 f8                	mov    %edi,%eax
  80077e:	c1 e8 16             	shr    $0x16,%eax
  800781:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800788:	a8 01                	test   $0x1,%al
  80078a:	74 46                	je     8007d2 <dup+0xad>
  80078c:	89 f8                	mov    %edi,%eax
  80078e:	c1 e8 0c             	shr    $0xc,%eax
  800791:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800798:	f6 c2 01             	test   $0x1,%dl
  80079b:	74 35                	je     8007d2 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80079d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8007a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8007a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8007bb:	00 
  8007bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007c7:	e8 8d fa ff ff       	call   800259 <sys_page_map>
  8007cc:	89 c7                	mov    %eax,%edi
  8007ce:	85 c0                	test   %eax,%eax
  8007d0:	78 3b                	js     80080d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8007d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007d5:	89 c2                	mov    %eax,%edx
  8007d7:	c1 ea 0c             	shr    $0xc,%edx
  8007da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007e1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8007e7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007eb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8007f6:	00 
  8007f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800802:	e8 52 fa ff ff       	call   800259 <sys_page_map>
  800807:	89 c7                	mov    %eax,%edi
  800809:	85 c0                	test   %eax,%eax
  80080b:	79 29                	jns    800836 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80080d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800811:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800818:	e8 a3 fa ff ff       	call   8002c0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80081d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800820:	89 44 24 04          	mov    %eax,0x4(%esp)
  800824:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80082b:	e8 90 fa ff ff       	call   8002c0 <sys_page_unmap>
	return r;
  800830:	89 fb                	mov    %edi,%ebx
  800832:	eb 02                	jmp    800836 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  800834:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800836:	89 d8                	mov    %ebx,%eax
  800838:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80083b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80083e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800841:	89 ec                	mov    %ebp,%esp
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	83 ec 24             	sub    $0x24,%esp
  80084c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800852:	89 44 24 04          	mov    %eax,0x4(%esp)
  800856:	89 1c 24             	mov    %ebx,(%esp)
  800859:	e8 41 fd ff ff       	call   80059f <fd_lookup>
  80085e:	85 c0                	test   %eax,%eax
  800860:	78 6d                	js     8008cf <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800862:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800865:	89 44 24 04          	mov    %eax,0x4(%esp)
  800869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086c:	8b 00                	mov    (%eax),%eax
  80086e:	89 04 24             	mov    %eax,(%esp)
  800871:	e8 7f fd ff ff       	call   8005f5 <dev_lookup>
  800876:	85 c0                	test   %eax,%eax
  800878:	78 55                	js     8008cf <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80087a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80087d:	8b 50 08             	mov    0x8(%eax),%edx
  800880:	83 e2 03             	and    $0x3,%edx
  800883:	83 fa 01             	cmp    $0x1,%edx
  800886:	75 23                	jne    8008ab <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800888:	a1 04 40 80 00       	mov    0x804004,%eax
  80088d:	8b 40 48             	mov    0x48(%eax),%eax
  800890:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800894:	89 44 24 04          	mov    %eax,0x4(%esp)
  800898:	c7 04 24 f9 1c 80 00 	movl   $0x801cf9,(%esp)
  80089f:	e8 57 05 00 00       	call   800dfb <cprintf>
		return -E_INVAL;
  8008a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a9:	eb 24                	jmp    8008cf <read+0x8a>
	}
	if (!dev->dev_read)
  8008ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008ae:	8b 52 08             	mov    0x8(%edx),%edx
  8008b1:	85 d2                	test   %edx,%edx
  8008b3:	74 15                	je     8008ca <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8008b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008c3:	89 04 24             	mov    %eax,(%esp)
  8008c6:	ff d2                	call   *%edx
  8008c8:	eb 05                	jmp    8008cf <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8008ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8008cf:	83 c4 24             	add    $0x24,%esp
  8008d2:	5b                   	pop    %ebx
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	57                   	push   %edi
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	83 ec 1c             	sub    $0x1c,%esp
  8008de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008e4:	85 f6                	test   %esi,%esi
  8008e6:	74 33                	je     80091b <readn+0x46>
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8008f2:	89 f2                	mov    %esi,%edx
  8008f4:	29 c2                	sub    %eax,%edx
  8008f6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8008fa:	03 45 0c             	add    0xc(%ebp),%eax
  8008fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800901:	89 3c 24             	mov    %edi,(%esp)
  800904:	e8 3c ff ff ff       	call   800845 <read>
		if (m < 0)
  800909:	85 c0                	test   %eax,%eax
  80090b:	78 17                	js     800924 <readn+0x4f>
			return m;
		if (m == 0)
  80090d:	85 c0                	test   %eax,%eax
  80090f:	74 11                	je     800922 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800911:	01 c3                	add    %eax,%ebx
  800913:	89 d8                	mov    %ebx,%eax
  800915:	39 f3                	cmp    %esi,%ebx
  800917:	72 d9                	jb     8008f2 <readn+0x1d>
  800919:	eb 09                	jmp    800924 <readn+0x4f>
  80091b:	b8 00 00 00 00       	mov    $0x0,%eax
  800920:	eb 02                	jmp    800924 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800922:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800924:	83 c4 1c             	add    $0x1c,%esp
  800927:	5b                   	pop    %ebx
  800928:	5e                   	pop    %esi
  800929:	5f                   	pop    %edi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	53                   	push   %ebx
  800930:	83 ec 24             	sub    $0x24,%esp
  800933:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800936:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800939:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093d:	89 1c 24             	mov    %ebx,(%esp)
  800940:	e8 5a fc ff ff       	call   80059f <fd_lookup>
  800945:	85 c0                	test   %eax,%eax
  800947:	78 68                	js     8009b1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800949:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80094c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800950:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800953:	8b 00                	mov    (%eax),%eax
  800955:	89 04 24             	mov    %eax,(%esp)
  800958:	e8 98 fc ff ff       	call   8005f5 <dev_lookup>
  80095d:	85 c0                	test   %eax,%eax
  80095f:	78 50                	js     8009b1 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800961:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800964:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800968:	75 23                	jne    80098d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80096a:	a1 04 40 80 00       	mov    0x804004,%eax
  80096f:	8b 40 48             	mov    0x48(%eax),%eax
  800972:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097a:	c7 04 24 15 1d 80 00 	movl   $0x801d15,(%esp)
  800981:	e8 75 04 00 00       	call   800dfb <cprintf>
		return -E_INVAL;
  800986:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80098b:	eb 24                	jmp    8009b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80098d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800990:	8b 52 0c             	mov    0xc(%edx),%edx
  800993:	85 d2                	test   %edx,%edx
  800995:	74 15                	je     8009ac <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800997:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80099a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80099e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009a5:	89 04 24             	mov    %eax,(%esp)
  8009a8:	ff d2                	call   *%edx
  8009aa:	eb 05                	jmp    8009b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8009ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8009b1:	83 c4 24             	add    $0x24,%esp
  8009b4:	5b                   	pop    %ebx
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009bd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8009c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	89 04 24             	mov    %eax,(%esp)
  8009ca:	e8 d0 fb ff ff       	call   80059f <fd_lookup>
  8009cf:	85 c0                	test   %eax,%eax
  8009d1:	78 0e                	js     8009e1 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8009d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	c9                   	leave  
  8009e2:	c3                   	ret    

008009e3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	53                   	push   %ebx
  8009e7:	83 ec 24             	sub    $0x24,%esp
  8009ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f4:	89 1c 24             	mov    %ebx,(%esp)
  8009f7:	e8 a3 fb ff ff       	call   80059f <fd_lookup>
  8009fc:	85 c0                	test   %eax,%eax
  8009fe:	78 61                	js     800a61 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a03:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a0a:	8b 00                	mov    (%eax),%eax
  800a0c:	89 04 24             	mov    %eax,(%esp)
  800a0f:	e8 e1 fb ff ff       	call   8005f5 <dev_lookup>
  800a14:	85 c0                	test   %eax,%eax
  800a16:	78 49                	js     800a61 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a1b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a1f:	75 23                	jne    800a44 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800a21:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800a26:	8b 40 48             	mov    0x48(%eax),%eax
  800a29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a31:	c7 04 24 d8 1c 80 00 	movl   $0x801cd8,(%esp)
  800a38:	e8 be 03 00 00       	call   800dfb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800a3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a42:	eb 1d                	jmp    800a61 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800a44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a47:	8b 52 18             	mov    0x18(%edx),%edx
  800a4a:	85 d2                	test   %edx,%edx
  800a4c:	74 0e                	je     800a5c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800a4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a51:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a55:	89 04 24             	mov    %eax,(%esp)
  800a58:	ff d2                	call   *%edx
  800a5a:	eb 05                	jmp    800a61 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800a5c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800a61:	83 c4 24             	add    $0x24,%esp
  800a64:	5b                   	pop    %ebx
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	53                   	push   %ebx
  800a6b:	83 ec 24             	sub    $0x24,%esp
  800a6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	89 04 24             	mov    %eax,(%esp)
  800a7e:	e8 1c fb ff ff       	call   80059f <fd_lookup>
  800a83:	85 c0                	test   %eax,%eax
  800a85:	78 52                	js     800ad9 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a91:	8b 00                	mov    (%eax),%eax
  800a93:	89 04 24             	mov    %eax,(%esp)
  800a96:	e8 5a fb ff ff       	call   8005f5 <dev_lookup>
  800a9b:	85 c0                	test   %eax,%eax
  800a9d:	78 3a                	js     800ad9 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aa2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800aa6:	74 2c                	je     800ad4 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800aa8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800aab:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ab2:	00 00 00 
	stat->st_isdir = 0;
  800ab5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800abc:	00 00 00 
	stat->st_dev = dev;
  800abf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800ac5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ac9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800acc:	89 14 24             	mov    %edx,(%esp)
  800acf:	ff 50 14             	call   *0x14(%eax)
  800ad2:	eb 05                	jmp    800ad9 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800ad4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800ad9:	83 c4 24             	add    $0x24,%esp
  800adc:	5b                   	pop    %ebx
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	83 ec 18             	sub    $0x18,%esp
  800ae5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ae8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800aeb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800af2:	00 
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	89 04 24             	mov    %eax,(%esp)
  800af9:	e8 84 01 00 00       	call   800c82 <open>
  800afe:	89 c3                	mov    %eax,%ebx
  800b00:	85 c0                	test   %eax,%eax
  800b02:	78 1b                	js     800b1f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800b04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0b:	89 1c 24             	mov    %ebx,(%esp)
  800b0e:	e8 54 ff ff ff       	call   800a67 <fstat>
  800b13:	89 c6                	mov    %eax,%esi
	close(fd);
  800b15:	89 1c 24             	mov    %ebx,(%esp)
  800b18:	e8 b5 fb ff ff       	call   8006d2 <close>
	return r;
  800b1d:	89 f3                	mov    %esi,%ebx
}
  800b1f:	89 d8                	mov    %ebx,%eax
  800b21:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b24:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b27:	89 ec                	mov    %ebp,%esp
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    
  800b2b:	90                   	nop

00800b2c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	83 ec 18             	sub    $0x18,%esp
  800b32:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b35:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b38:	89 c6                	mov    %eax,%esi
  800b3a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800b3c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800b43:	75 11                	jne    800b56 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b45:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b4c:	e8 f2 0d 00 00       	call   801943 <ipc_find_env>
  800b51:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b56:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b5d:	00 
  800b5e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800b65:	00 
  800b66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b6a:	a1 00 40 80 00       	mov    0x804000,%eax
  800b6f:	89 04 24             	mov    %eax,(%esp)
  800b72:	e8 61 0d 00 00       	call   8018d8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800b77:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b7e:	00 
  800b7f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b8a:	e8 f1 0c 00 00       	call   801880 <ipc_recv>
}
  800b8f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b92:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b95:	89 ec                	mov    %ebp,%esp
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba2:	8b 40 0c             	mov    0xc(%eax),%eax
  800ba5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800baa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bad:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbc:	e8 6b ff ff ff       	call   800b2c <fsipc>
}
  800bc1:	c9                   	leave  
  800bc2:	c3                   	ret    

00800bc3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 40 0c             	mov    0xc(%eax),%eax
  800bcf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 06 00 00 00       	mov    $0x6,%eax
  800bde:	e8 49 ff ff ff       	call   800b2c <fsipc>
}
  800be3:	c9                   	leave  
  800be4:	c3                   	ret    

00800be5 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	53                   	push   %ebx
  800be9:	83 ec 14             	sub    $0x14,%esp
  800bec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800bef:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf2:	8b 40 0c             	mov    0xc(%eax),%eax
  800bf5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800bfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800bff:	b8 05 00 00 00       	mov    $0x5,%eax
  800c04:	e8 23 ff ff ff       	call   800b2c <fsipc>
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	78 2b                	js     800c38 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800c0d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c14:	00 
  800c15:	89 1c 24             	mov    %ebx,(%esp)
  800c18:	e8 5e 08 00 00       	call   80147b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800c1d:	a1 80 50 80 00       	mov    0x805080,%eax
  800c22:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800c28:	a1 84 50 80 00       	mov    0x805084,%eax
  800c2d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800c33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c38:	83 c4 14             	add    $0x14,%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800c44:	c7 44 24 08 32 1d 80 	movl   $0x801d32,0x8(%esp)
  800c4b:	00 
  800c4c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  800c53:	00 
  800c54:	c7 04 24 50 1d 80 00 	movl   $0x801d50,(%esp)
  800c5b:	e8 a0 00 00 00       	call   800d00 <_panic>

00800c60 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  800c66:	c7 44 24 08 5b 1d 80 	movl   $0x801d5b,0x8(%esp)
  800c6d:	00 
  800c6e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  800c75:	00 
  800c76:	c7 04 24 50 1d 80 00 	movl   $0x801d50,(%esp)
  800c7d:	e8 7e 00 00 00       	call   800d00 <_panic>

00800c82 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  800c88:	c7 44 24 08 78 1d 80 	movl   $0x801d78,0x8(%esp)
  800c8f:	00 
  800c90:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800c97:	00 
  800c98:	c7 04 24 50 1d 80 00 	movl   $0x801d50,(%esp)
  800c9f:	e8 5c 00 00 00       	call   800d00 <_panic>

00800ca4 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 14             	sub    $0x14,%esp
  800cab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800cae:	89 1c 24             	mov    %ebx,(%esp)
  800cb1:	e8 6a 07 00 00       	call   801420 <strlen>
  800cb6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800cbb:	7f 21                	jg     800cde <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800cbd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cc1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cc8:	e8 ae 07 00 00       	call   80147b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800ccd:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd2:	b8 07 00 00 00       	mov    $0x7,%eax
  800cd7:	e8 50 fe ff ff       	call   800b2c <fsipc>
  800cdc:	eb 05                	jmp    800ce3 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cde:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  800ce3:	83 c4 14             	add    $0x14,%esp
  800ce6:	5b                   	pop    %ebx
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800cef:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf4:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf9:	e8 2e fe ff ff       	call   800b2c <fsipc>
}
  800cfe:	c9                   	leave  
  800cff:	c3                   	ret    

00800d00 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d08:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d0b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800d11:	e8 69 f4 ff ff       	call   80017f <sys_getenvid>
  800d16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d19:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d24:	89 74 24 08          	mov    %esi,0x8(%esp)
  800d28:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d2c:	c7 04 24 90 1d 80 00 	movl   $0x801d90,(%esp)
  800d33:	e8 c3 00 00 00       	call   800dfb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d38:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3f:	89 04 24             	mov    %eax,(%esp)
  800d42:	e8 53 00 00 00       	call   800d9a <vcprintf>
	cprintf("\n");
  800d47:	c7 04 24 d5 20 80 00 	movl   $0x8020d5,(%esp)
  800d4e:	e8 a8 00 00 00       	call   800dfb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d53:	cc                   	int3   
  800d54:	eb fd                	jmp    800d53 <_panic+0x53>
  800d56:	66 90                	xchg   %ax,%ax

00800d58 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	53                   	push   %ebx
  800d5c:	83 ec 14             	sub    $0x14,%esp
  800d5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800d62:	8b 03                	mov    (%ebx),%eax
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800d6b:	83 c0 01             	add    $0x1,%eax
  800d6e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800d70:	3d ff 00 00 00       	cmp    $0xff,%eax
  800d75:	75 19                	jne    800d90 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800d77:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800d7e:	00 
  800d7f:	8d 43 08             	lea    0x8(%ebx),%eax
  800d82:	89 04 24             	mov    %eax,(%esp)
  800d85:	e8 1e f3 ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  800d8a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800d90:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800d94:	83 c4 14             	add    $0x14,%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800da3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800daa:	00 00 00 
	b.cnt = 0;
  800dad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800db4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800db7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dcf:	c7 04 24 58 0d 80 00 	movl   $0x800d58,(%esp)
  800dd6:	e8 b7 01 00 00       	call   800f92 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ddb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800de1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800deb:	89 04 24             	mov    %eax,(%esp)
  800dee:	e8 b5 f2 ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  800df3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800df9:	c9                   	leave  
  800dfa:	c3                   	ret    

00800dfb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800e01:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800e04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e08:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0b:	89 04 24             	mov    %eax,(%esp)
  800e0e:	e8 87 ff ff ff       	call   800d9a <vcprintf>
	va_end(ap);

	return cnt;
}
  800e13:	c9                   	leave  
  800e14:	c3                   	ret    
  800e15:	66 90                	xchg   %ax,%ax
  800e17:	66 90                	xchg   %ax,%ax
  800e19:	66 90                	xchg   %ax,%ax
  800e1b:	66 90                	xchg   %ax,%ax
  800e1d:	66 90                	xchg   %ax,%ax
  800e1f:	90                   	nop

00800e20 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 4c             	sub    $0x4c,%esp
  800e29:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e2c:	89 d7                	mov    %edx,%edi
  800e2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e31:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800e34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e37:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800e3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3f:	39 d8                	cmp    %ebx,%eax
  800e41:	72 17                	jb     800e5a <printnum+0x3a>
  800e43:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800e46:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800e49:	76 0f                	jbe    800e5a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800e4b:	8b 75 14             	mov    0x14(%ebp),%esi
  800e4e:	83 ee 01             	sub    $0x1,%esi
  800e51:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800e54:	85 f6                	test   %esi,%esi
  800e56:	7f 63                	jg     800ebb <printnum+0x9b>
  800e58:	eb 75                	jmp    800ecf <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800e5a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e5d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e61:	8b 45 14             	mov    0x14(%ebp),%eax
  800e64:	83 e8 01             	sub    $0x1,%eax
  800e67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e72:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e76:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800e7a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e7d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e80:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e87:	00 
  800e88:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800e8b:	89 1c 24             	mov    %ebx,(%esp)
  800e8e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800e91:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e95:	e8 f6 0a 00 00       	call   801990 <__udivdi3>
  800e9a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e9d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ea0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ea4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ea8:	89 04 24             	mov    %eax,(%esp)
  800eab:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eaf:	89 fa                	mov    %edi,%edx
  800eb1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800eb4:	e8 67 ff ff ff       	call   800e20 <printnum>
  800eb9:	eb 14                	jmp    800ecf <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800ebb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ebf:	8b 45 18             	mov    0x18(%ebp),%eax
  800ec2:	89 04 24             	mov    %eax,(%esp)
  800ec5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800ec7:	83 ee 01             	sub    $0x1,%esi
  800eca:	75 ef                	jne    800ebb <printnum+0x9b>
  800ecc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800ecf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ed3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eda:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ede:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ee5:	00 
  800ee6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800ee9:	89 1c 24             	mov    %ebx,(%esp)
  800eec:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800eef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ef3:	e8 e8 0b 00 00       	call   801ae0 <__umoddi3>
  800ef8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800efc:	0f be 80 b3 1d 80 00 	movsbl 0x801db3(%eax),%eax
  800f03:	89 04 24             	mov    %eax,(%esp)
  800f06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800f09:	ff d0                	call   *%eax
}
  800f0b:	83 c4 4c             	add    $0x4c,%esp
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800f16:	83 fa 01             	cmp    $0x1,%edx
  800f19:	7e 0e                	jle    800f29 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800f1b:	8b 10                	mov    (%eax),%edx
  800f1d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800f20:	89 08                	mov    %ecx,(%eax)
  800f22:	8b 02                	mov    (%edx),%eax
  800f24:	8b 52 04             	mov    0x4(%edx),%edx
  800f27:	eb 22                	jmp    800f4b <getuint+0x38>
	else if (lflag)
  800f29:	85 d2                	test   %edx,%edx
  800f2b:	74 10                	je     800f3d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800f2d:	8b 10                	mov    (%eax),%edx
  800f2f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f32:	89 08                	mov    %ecx,(%eax)
  800f34:	8b 02                	mov    (%edx),%eax
  800f36:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3b:	eb 0e                	jmp    800f4b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800f3d:	8b 10                	mov    (%eax),%edx
  800f3f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f42:	89 08                	mov    %ecx,(%eax)
  800f44:	8b 02                	mov    (%edx),%eax
  800f46:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800f53:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800f57:	8b 10                	mov    (%eax),%edx
  800f59:	3b 50 04             	cmp    0x4(%eax),%edx
  800f5c:	73 0a                	jae    800f68 <sprintputch+0x1b>
		*b->buf++ = ch;
  800f5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f61:	88 0a                	mov    %cl,(%edx)
  800f63:	83 c2 01             	add    $0x1,%edx
  800f66:	89 10                	mov    %edx,(%eax)
}
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800f70:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800f73:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f77:	8b 45 10             	mov    0x10(%ebp),%eax
  800f7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f85:	8b 45 08             	mov    0x8(%ebp),%eax
  800f88:	89 04 24             	mov    %eax,(%esp)
  800f8b:	e8 02 00 00 00       	call   800f92 <vprintfmt>
	va_end(ap);
}
  800f90:	c9                   	leave  
  800f91:	c3                   	ret    

00800f92 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	57                   	push   %edi
  800f96:	56                   	push   %esi
  800f97:	53                   	push   %ebx
  800f98:	83 ec 4c             	sub    $0x4c,%esp
  800f9b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fa1:	8b 7d 10             	mov    0x10(%ebp),%edi
  800fa4:	eb 11                	jmp    800fb7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	0f 84 db 03 00 00    	je     801389 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  800fae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fb2:	89 04 24             	mov    %eax,(%esp)
  800fb5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800fb7:	0f b6 07             	movzbl (%edi),%eax
  800fba:	83 c7 01             	add    $0x1,%edi
  800fbd:	83 f8 25             	cmp    $0x25,%eax
  800fc0:	75 e4                	jne    800fa6 <vprintfmt+0x14>
  800fc2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800fc6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800fcd:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800fd4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800fdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe0:	eb 2b                	jmp    80100d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fe2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800fe5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800fe9:	eb 22                	jmp    80100d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800feb:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800fee:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800ff2:	eb 19                	jmp    80100d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ff4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800ff7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800ffe:	eb 0d                	jmp    80100d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801000:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801003:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801006:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80100d:	0f b6 0f             	movzbl (%edi),%ecx
  801010:	8d 47 01             	lea    0x1(%edi),%eax
  801013:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801016:	0f b6 07             	movzbl (%edi),%eax
  801019:	83 e8 23             	sub    $0x23,%eax
  80101c:	3c 55                	cmp    $0x55,%al
  80101e:	0f 87 40 03 00 00    	ja     801364 <vprintfmt+0x3d2>
  801024:	0f b6 c0             	movzbl %al,%eax
  801027:	ff 24 85 00 1f 80 00 	jmp    *0x801f00(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80102e:	83 e9 30             	sub    $0x30,%ecx
  801031:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  801034:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  801038:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80103b:	83 f9 09             	cmp    $0x9,%ecx
  80103e:	77 57                	ja     801097 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801040:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801043:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801046:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801049:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80104c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80104f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801053:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  801056:	8d 48 d0             	lea    -0x30(%eax),%ecx
  801059:	83 f9 09             	cmp    $0x9,%ecx
  80105c:	76 eb                	jbe    801049 <vprintfmt+0xb7>
  80105e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801061:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801064:	eb 34                	jmp    80109a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801066:	8b 45 14             	mov    0x14(%ebp),%eax
  801069:	8d 48 04             	lea    0x4(%eax),%ecx
  80106c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80106f:	8b 00                	mov    (%eax),%eax
  801071:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801074:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801077:	eb 21                	jmp    80109a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  801079:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80107d:	0f 88 71 ff ff ff    	js     800ff4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801083:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801086:	eb 85                	jmp    80100d <vprintfmt+0x7b>
  801088:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80108b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  801092:	e9 76 ff ff ff       	jmp    80100d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801097:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80109a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80109e:	0f 89 69 ff ff ff    	jns    80100d <vprintfmt+0x7b>
  8010a4:	e9 57 ff ff ff       	jmp    801000 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8010a9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8010af:	e9 59 ff ff ff       	jmp    80100d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8010b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8010b7:	8d 50 04             	lea    0x4(%eax),%edx
  8010ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8010bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010c1:	8b 00                	mov    (%eax),%eax
  8010c3:	89 04 24             	mov    %eax,(%esp)
  8010c6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010c8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8010cb:	e9 e7 fe ff ff       	jmp    800fb7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8010d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8010d3:	8d 50 04             	lea    0x4(%eax),%edx
  8010d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8010d9:	8b 00                	mov    (%eax),%eax
  8010db:	89 c2                	mov    %eax,%edx
  8010dd:	c1 fa 1f             	sar    $0x1f,%edx
  8010e0:	31 d0                	xor    %edx,%eax
  8010e2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8010e4:	83 f8 0f             	cmp    $0xf,%eax
  8010e7:	7f 0b                	jg     8010f4 <vprintfmt+0x162>
  8010e9:	8b 14 85 60 20 80 00 	mov    0x802060(,%eax,4),%edx
  8010f0:	85 d2                	test   %edx,%edx
  8010f2:	75 20                	jne    801114 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8010f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010f8:	c7 44 24 08 cb 1d 80 	movl   $0x801dcb,0x8(%esp)
  8010ff:	00 
  801100:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801104:	89 34 24             	mov    %esi,(%esp)
  801107:	e8 5e fe ff ff       	call   800f6a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80110c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80110f:	e9 a3 fe ff ff       	jmp    800fb7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  801114:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801118:	c7 44 24 08 d4 1d 80 	movl   $0x801dd4,0x8(%esp)
  80111f:	00 
  801120:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801124:	89 34 24             	mov    %esi,(%esp)
  801127:	e8 3e fe ff ff       	call   800f6a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80112c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80112f:	e9 83 fe ff ff       	jmp    800fb7 <vprintfmt+0x25>
  801134:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801137:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80113a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80113d:	8b 45 14             	mov    0x14(%ebp),%eax
  801140:	8d 50 04             	lea    0x4(%eax),%edx
  801143:	89 55 14             	mov    %edx,0x14(%ebp)
  801146:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801148:	85 ff                	test   %edi,%edi
  80114a:	b8 c4 1d 80 00       	mov    $0x801dc4,%eax
  80114f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801152:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  801156:	74 06                	je     80115e <vprintfmt+0x1cc>
  801158:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80115c:	7f 16                	jg     801174 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80115e:	0f b6 17             	movzbl (%edi),%edx
  801161:	0f be c2             	movsbl %dl,%eax
  801164:	83 c7 01             	add    $0x1,%edi
  801167:	85 c0                	test   %eax,%eax
  801169:	0f 85 9f 00 00 00    	jne    80120e <vprintfmt+0x27c>
  80116f:	e9 8b 00 00 00       	jmp    8011ff <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801174:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801178:	89 3c 24             	mov    %edi,(%esp)
  80117b:	e8 c2 02 00 00       	call   801442 <strnlen>
  801180:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801183:	29 c2                	sub    %eax,%edx
  801185:	89 55 d8             	mov    %edx,-0x28(%ebp)
  801188:	85 d2                	test   %edx,%edx
  80118a:	7e d2                	jle    80115e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80118c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  801190:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  801193:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801196:	89 d7                	mov    %edx,%edi
  801198:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80119c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80119f:	89 04 24             	mov    %eax,(%esp)
  8011a2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011a4:	83 ef 01             	sub    $0x1,%edi
  8011a7:	75 ef                	jne    801198 <vprintfmt+0x206>
  8011a9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8011ac:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8011af:	eb ad                	jmp    80115e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8011b1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8011b5:	74 20                	je     8011d7 <vprintfmt+0x245>
  8011b7:	0f be d2             	movsbl %dl,%edx
  8011ba:	83 ea 20             	sub    $0x20,%edx
  8011bd:	83 fa 5e             	cmp    $0x5e,%edx
  8011c0:	76 15                	jbe    8011d7 <vprintfmt+0x245>
					putch('?', putdat);
  8011c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8011c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011c9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8011d0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8011d3:	ff d1                	call   *%ecx
  8011d5:	eb 0f                	jmp    8011e6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  8011d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8011da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011de:	89 04 24             	mov    %eax,(%esp)
  8011e1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8011e4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8011e6:	83 eb 01             	sub    $0x1,%ebx
  8011e9:	0f b6 17             	movzbl (%edi),%edx
  8011ec:	0f be c2             	movsbl %dl,%eax
  8011ef:	83 c7 01             	add    $0x1,%edi
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	75 24                	jne    80121a <vprintfmt+0x288>
  8011f6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8011f9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011fc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8011ff:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801202:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801206:	0f 8e ab fd ff ff    	jle    800fb7 <vprintfmt+0x25>
  80120c:	eb 20                	jmp    80122e <vprintfmt+0x29c>
  80120e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801211:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801214:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801217:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80121a:	85 f6                	test   %esi,%esi
  80121c:	78 93                	js     8011b1 <vprintfmt+0x21f>
  80121e:	83 ee 01             	sub    $0x1,%esi
  801221:	79 8e                	jns    8011b1 <vprintfmt+0x21f>
  801223:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801226:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801229:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80122c:	eb d1                	jmp    8011ff <vprintfmt+0x26d>
  80122e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801231:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801235:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80123c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80123e:	83 ef 01             	sub    $0x1,%edi
  801241:	75 ee                	jne    801231 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801243:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801246:	e9 6c fd ff ff       	jmp    800fb7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80124b:	83 fa 01             	cmp    $0x1,%edx
  80124e:	66 90                	xchg   %ax,%ax
  801250:	7e 16                	jle    801268 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  801252:	8b 45 14             	mov    0x14(%ebp),%eax
  801255:	8d 50 08             	lea    0x8(%eax),%edx
  801258:	89 55 14             	mov    %edx,0x14(%ebp)
  80125b:	8b 10                	mov    (%eax),%edx
  80125d:	8b 48 04             	mov    0x4(%eax),%ecx
  801260:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801263:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801266:	eb 32                	jmp    80129a <vprintfmt+0x308>
	else if (lflag)
  801268:	85 d2                	test   %edx,%edx
  80126a:	74 18                	je     801284 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80126c:	8b 45 14             	mov    0x14(%ebp),%eax
  80126f:	8d 50 04             	lea    0x4(%eax),%edx
  801272:	89 55 14             	mov    %edx,0x14(%ebp)
  801275:	8b 00                	mov    (%eax),%eax
  801277:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80127a:	89 c1                	mov    %eax,%ecx
  80127c:	c1 f9 1f             	sar    $0x1f,%ecx
  80127f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801282:	eb 16                	jmp    80129a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  801284:	8b 45 14             	mov    0x14(%ebp),%eax
  801287:	8d 50 04             	lea    0x4(%eax),%edx
  80128a:	89 55 14             	mov    %edx,0x14(%ebp)
  80128d:	8b 00                	mov    (%eax),%eax
  80128f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801292:	89 c7                	mov    %eax,%edi
  801294:	c1 ff 1f             	sar    $0x1f,%edi
  801297:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80129a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80129d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8012a0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8012a5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8012a9:	79 7d                	jns    801328 <vprintfmt+0x396>
				putch('-', putdat);
  8012ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012af:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8012b6:	ff d6                	call   *%esi
				num = -(long long) num;
  8012b8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012bb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8012be:	f7 d8                	neg    %eax
  8012c0:	83 d2 00             	adc    $0x0,%edx
  8012c3:	f7 da                	neg    %edx
			}
			base = 10;
  8012c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8012ca:	eb 5c                	jmp    801328 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8012cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8012cf:	e8 3f fc ff ff       	call   800f13 <getuint>
			base = 10;
  8012d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8012d9:	eb 4d                	jmp    801328 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8012db:	8d 45 14             	lea    0x14(%ebp),%eax
  8012de:	e8 30 fc ff ff       	call   800f13 <getuint>
			base = 8;
  8012e3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8012e8:	eb 3e                	jmp    801328 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8012ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012ee:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8012f5:	ff d6                	call   *%esi
			putch('x', putdat);
  8012f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012fb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801302:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801304:	8b 45 14             	mov    0x14(%ebp),%eax
  801307:	8d 50 04             	lea    0x4(%eax),%edx
  80130a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80130d:	8b 00                	mov    (%eax),%eax
  80130f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801314:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801319:	eb 0d                	jmp    801328 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80131b:	8d 45 14             	lea    0x14(%ebp),%eax
  80131e:	e8 f0 fb ff ff       	call   800f13 <getuint>
			base = 16;
  801323:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801328:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80132c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801330:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801333:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801337:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133b:	89 04 24             	mov    %eax,(%esp)
  80133e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801342:	89 da                	mov    %ebx,%edx
  801344:	89 f0                	mov    %esi,%eax
  801346:	e8 d5 fa ff ff       	call   800e20 <printnum>
			break;
  80134b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80134e:	e9 64 fc ff ff       	jmp    800fb7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801353:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801357:	89 0c 24             	mov    %ecx,(%esp)
  80135a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80135f:	e9 53 fc ff ff       	jmp    800fb7 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801364:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801368:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80136f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801371:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801375:	0f 84 3c fc ff ff    	je     800fb7 <vprintfmt+0x25>
  80137b:	83 ef 01             	sub    $0x1,%edi
  80137e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801382:	75 f7                	jne    80137b <vprintfmt+0x3e9>
  801384:	e9 2e fc ff ff       	jmp    800fb7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  801389:	83 c4 4c             	add    $0x4c,%esp
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5f                   	pop    %edi
  80138f:	5d                   	pop    %ebp
  801390:	c3                   	ret    

00801391 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	83 ec 28             	sub    $0x28,%esp
  801397:	8b 45 08             	mov    0x8(%ebp),%eax
  80139a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80139d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8013a0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8013a4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8013a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8013ae:	85 d2                	test   %edx,%edx
  8013b0:	7e 30                	jle    8013e2 <vsnprintf+0x51>
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	74 2c                	je     8013e2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8013b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8013c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8013c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013cb:	c7 04 24 4d 0f 80 00 	movl   $0x800f4d,(%esp)
  8013d2:	e8 bb fb ff ff       	call   800f92 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8013d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8013da:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8013dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e0:	eb 05                	jmp    8013e7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8013e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8013e7:	c9                   	leave  
  8013e8:	c3                   	ret    

008013e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8013ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8013f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8013f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801400:	89 44 24 04          	mov    %eax,0x4(%esp)
  801404:	8b 45 08             	mov    0x8(%ebp),%eax
  801407:	89 04 24             	mov    %eax,(%esp)
  80140a:	e8 82 ff ff ff       	call   801391 <vsnprintf>
	va_end(ap);

	return rc;
}
  80140f:	c9                   	leave  
  801410:	c3                   	ret    
  801411:	66 90                	xchg   %ax,%ax
  801413:	66 90                	xchg   %ax,%ax
  801415:	66 90                	xchg   %ax,%ax
  801417:	66 90                	xchg   %ax,%ax
  801419:	66 90                	xchg   %ax,%ax
  80141b:	66 90                	xchg   %ax,%ax
  80141d:	66 90                	xchg   %ax,%ax
  80141f:	90                   	nop

00801420 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801426:	80 3a 00             	cmpb   $0x0,(%edx)
  801429:	74 10                	je     80143b <strlen+0x1b>
  80142b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801430:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801433:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801437:	75 f7                	jne    801430 <strlen+0x10>
  801439:	eb 05                	jmp    801440 <strlen+0x20>
  80143b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801440:	5d                   	pop    %ebp
  801441:	c3                   	ret    

00801442 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	53                   	push   %ebx
  801446:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801449:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80144c:	85 c9                	test   %ecx,%ecx
  80144e:	74 1c                	je     80146c <strnlen+0x2a>
  801450:	80 3b 00             	cmpb   $0x0,(%ebx)
  801453:	74 1e                	je     801473 <strnlen+0x31>
  801455:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80145a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80145c:	39 ca                	cmp    %ecx,%edx
  80145e:	74 18                	je     801478 <strnlen+0x36>
  801460:	83 c2 01             	add    $0x1,%edx
  801463:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  801468:	75 f0                	jne    80145a <strnlen+0x18>
  80146a:	eb 0c                	jmp    801478 <strnlen+0x36>
  80146c:	b8 00 00 00 00       	mov    $0x0,%eax
  801471:	eb 05                	jmp    801478 <strnlen+0x36>
  801473:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801478:	5b                   	pop    %ebx
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	53                   	push   %ebx
  80147f:	8b 45 08             	mov    0x8(%ebp),%eax
  801482:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801485:	89 c2                	mov    %eax,%edx
  801487:	0f b6 19             	movzbl (%ecx),%ebx
  80148a:	88 1a                	mov    %bl,(%edx)
  80148c:	83 c2 01             	add    $0x1,%edx
  80148f:	83 c1 01             	add    $0x1,%ecx
  801492:	84 db                	test   %bl,%bl
  801494:	75 f1                	jne    801487 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801496:	5b                   	pop    %ebx
  801497:	5d                   	pop    %ebp
  801498:	c3                   	ret    

00801499 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	53                   	push   %ebx
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8014a3:	89 1c 24             	mov    %ebx,(%esp)
  8014a6:	e8 75 ff ff ff       	call   801420 <strlen>
	strcpy(dst + len, src);
  8014ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014b2:	01 d8                	add    %ebx,%eax
  8014b4:	89 04 24             	mov    %eax,(%esp)
  8014b7:	e8 bf ff ff ff       	call   80147b <strcpy>
	return dst;
}
  8014bc:	89 d8                	mov    %ebx,%eax
  8014be:	83 c4 08             	add    $0x8,%esp
  8014c1:	5b                   	pop    %ebx
  8014c2:	5d                   	pop    %ebp
  8014c3:	c3                   	ret    

008014c4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	56                   	push   %esi
  8014c8:	53                   	push   %ebx
  8014c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8014d2:	85 db                	test   %ebx,%ebx
  8014d4:	74 16                	je     8014ec <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  8014d6:	01 f3                	add    %esi,%ebx
  8014d8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8014da:	0f b6 02             	movzbl (%edx),%eax
  8014dd:	88 01                	mov    %al,(%ecx)
  8014df:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8014e2:	80 3a 01             	cmpb   $0x1,(%edx)
  8014e5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8014e8:	39 d9                	cmp    %ebx,%ecx
  8014ea:	75 ee                	jne    8014da <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8014ec:	89 f0                	mov    %esi,%eax
  8014ee:	5b                   	pop    %ebx
  8014ef:	5e                   	pop    %esi
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    

008014f2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	57                   	push   %edi
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
  8014f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014fe:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801501:	89 f8                	mov    %edi,%eax
  801503:	85 f6                	test   %esi,%esi
  801505:	74 33                	je     80153a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  801507:	83 fe 01             	cmp    $0x1,%esi
  80150a:	74 25                	je     801531 <strlcpy+0x3f>
  80150c:	0f b6 0b             	movzbl (%ebx),%ecx
  80150f:	84 c9                	test   %cl,%cl
  801511:	74 22                	je     801535 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801513:	83 ee 02             	sub    $0x2,%esi
  801516:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80151b:	88 08                	mov    %cl,(%eax)
  80151d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801520:	39 f2                	cmp    %esi,%edx
  801522:	74 13                	je     801537 <strlcpy+0x45>
  801524:	83 c2 01             	add    $0x1,%edx
  801527:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80152b:	84 c9                	test   %cl,%cl
  80152d:	75 ec                	jne    80151b <strlcpy+0x29>
  80152f:	eb 06                	jmp    801537 <strlcpy+0x45>
  801531:	89 f8                	mov    %edi,%eax
  801533:	eb 02                	jmp    801537 <strlcpy+0x45>
  801535:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801537:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80153a:	29 f8                	sub    %edi,%eax
}
  80153c:	5b                   	pop    %ebx
  80153d:	5e                   	pop    %esi
  80153e:	5f                   	pop    %edi
  80153f:	5d                   	pop    %ebp
  801540:	c3                   	ret    

00801541 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801547:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80154a:	0f b6 01             	movzbl (%ecx),%eax
  80154d:	84 c0                	test   %al,%al
  80154f:	74 15                	je     801566 <strcmp+0x25>
  801551:	3a 02                	cmp    (%edx),%al
  801553:	75 11                	jne    801566 <strcmp+0x25>
		p++, q++;
  801555:	83 c1 01             	add    $0x1,%ecx
  801558:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80155b:	0f b6 01             	movzbl (%ecx),%eax
  80155e:	84 c0                	test   %al,%al
  801560:	74 04                	je     801566 <strcmp+0x25>
  801562:	3a 02                	cmp    (%edx),%al
  801564:	74 ef                	je     801555 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801566:	0f b6 c0             	movzbl %al,%eax
  801569:	0f b6 12             	movzbl (%edx),%edx
  80156c:	29 d0                	sub    %edx,%eax
}
  80156e:	5d                   	pop    %ebp
  80156f:	c3                   	ret    

00801570 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
  801575:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801578:	8b 55 0c             	mov    0xc(%ebp),%edx
  80157b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80157e:	85 f6                	test   %esi,%esi
  801580:	74 29                	je     8015ab <strncmp+0x3b>
  801582:	0f b6 03             	movzbl (%ebx),%eax
  801585:	84 c0                	test   %al,%al
  801587:	74 30                	je     8015b9 <strncmp+0x49>
  801589:	3a 02                	cmp    (%edx),%al
  80158b:	75 2c                	jne    8015b9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80158d:	8d 43 01             	lea    0x1(%ebx),%eax
  801590:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  801592:	89 c3                	mov    %eax,%ebx
  801594:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801597:	39 f0                	cmp    %esi,%eax
  801599:	74 17                	je     8015b2 <strncmp+0x42>
  80159b:	0f b6 08             	movzbl (%eax),%ecx
  80159e:	84 c9                	test   %cl,%cl
  8015a0:	74 17                	je     8015b9 <strncmp+0x49>
  8015a2:	83 c0 01             	add    $0x1,%eax
  8015a5:	3a 0a                	cmp    (%edx),%cl
  8015a7:	74 e9                	je     801592 <strncmp+0x22>
  8015a9:	eb 0e                	jmp    8015b9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8015ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b0:	eb 0f                	jmp    8015c1 <strncmp+0x51>
  8015b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b7:	eb 08                	jmp    8015c1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8015b9:	0f b6 03             	movzbl (%ebx),%eax
  8015bc:	0f b6 12             	movzbl (%edx),%edx
  8015bf:	29 d0                	sub    %edx,%eax
}
  8015c1:	5b                   	pop    %ebx
  8015c2:	5e                   	pop    %esi
  8015c3:	5d                   	pop    %ebp
  8015c4:	c3                   	ret    

008015c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	53                   	push   %ebx
  8015c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8015cf:	0f b6 18             	movzbl (%eax),%ebx
  8015d2:	84 db                	test   %bl,%bl
  8015d4:	74 1d                	je     8015f3 <strchr+0x2e>
  8015d6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8015d8:	38 d3                	cmp    %dl,%bl
  8015da:	75 06                	jne    8015e2 <strchr+0x1d>
  8015dc:	eb 1a                	jmp    8015f8 <strchr+0x33>
  8015de:	38 ca                	cmp    %cl,%dl
  8015e0:	74 16                	je     8015f8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8015e2:	83 c0 01             	add    $0x1,%eax
  8015e5:	0f b6 10             	movzbl (%eax),%edx
  8015e8:	84 d2                	test   %dl,%dl
  8015ea:	75 f2                	jne    8015de <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  8015ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f1:	eb 05                	jmp    8015f8 <strchr+0x33>
  8015f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f8:	5b                   	pop    %ebx
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    

008015fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	53                   	push   %ebx
  8015ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801602:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801605:	0f b6 18             	movzbl (%eax),%ebx
  801608:	84 db                	test   %bl,%bl
  80160a:	74 16                	je     801622 <strfind+0x27>
  80160c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80160e:	38 d3                	cmp    %dl,%bl
  801610:	75 06                	jne    801618 <strfind+0x1d>
  801612:	eb 0e                	jmp    801622 <strfind+0x27>
  801614:	38 ca                	cmp    %cl,%dl
  801616:	74 0a                	je     801622 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801618:	83 c0 01             	add    $0x1,%eax
  80161b:	0f b6 10             	movzbl (%eax),%edx
  80161e:	84 d2                	test   %dl,%dl
  801620:	75 f2                	jne    801614 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  801622:	5b                   	pop    %ebx
  801623:	5d                   	pop    %ebp
  801624:	c3                   	ret    

00801625 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	83 ec 0c             	sub    $0xc,%esp
  80162b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80162e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801631:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801634:	8b 7d 08             	mov    0x8(%ebp),%edi
  801637:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80163a:	85 c9                	test   %ecx,%ecx
  80163c:	74 36                	je     801674 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80163e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801644:	75 28                	jne    80166e <memset+0x49>
  801646:	f6 c1 03             	test   $0x3,%cl
  801649:	75 23                	jne    80166e <memset+0x49>
		c &= 0xFF;
  80164b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80164f:	89 d3                	mov    %edx,%ebx
  801651:	c1 e3 08             	shl    $0x8,%ebx
  801654:	89 d6                	mov    %edx,%esi
  801656:	c1 e6 18             	shl    $0x18,%esi
  801659:	89 d0                	mov    %edx,%eax
  80165b:	c1 e0 10             	shl    $0x10,%eax
  80165e:	09 f0                	or     %esi,%eax
  801660:	09 c2                	or     %eax,%edx
  801662:	89 d0                	mov    %edx,%eax
  801664:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801666:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801669:	fc                   	cld    
  80166a:	f3 ab                	rep stos %eax,%es:(%edi)
  80166c:	eb 06                	jmp    801674 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80166e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801671:	fc                   	cld    
  801672:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  801674:	89 f8                	mov    %edi,%eax
  801676:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801679:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80167c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80167f:	89 ec                	mov    %ebp,%esp
  801681:	5d                   	pop    %ebp
  801682:	c3                   	ret    

00801683 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80168c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80168f:	8b 45 08             	mov    0x8(%ebp),%eax
  801692:	8b 75 0c             	mov    0xc(%ebp),%esi
  801695:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801698:	39 c6                	cmp    %eax,%esi
  80169a:	73 36                	jae    8016d2 <memmove+0x4f>
  80169c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80169f:	39 d0                	cmp    %edx,%eax
  8016a1:	73 2f                	jae    8016d2 <memmove+0x4f>
		s += n;
		d += n;
  8016a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8016a6:	f6 c2 03             	test   $0x3,%dl
  8016a9:	75 1b                	jne    8016c6 <memmove+0x43>
  8016ab:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8016b1:	75 13                	jne    8016c6 <memmove+0x43>
  8016b3:	f6 c1 03             	test   $0x3,%cl
  8016b6:	75 0e                	jne    8016c6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8016b8:	83 ef 04             	sub    $0x4,%edi
  8016bb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8016be:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8016c1:	fd                   	std    
  8016c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8016c4:	eb 09                	jmp    8016cf <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8016c6:	83 ef 01             	sub    $0x1,%edi
  8016c9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8016cc:	fd                   	std    
  8016cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8016cf:	fc                   	cld    
  8016d0:	eb 20                	jmp    8016f2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8016d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8016d8:	75 13                	jne    8016ed <memmove+0x6a>
  8016da:	a8 03                	test   $0x3,%al
  8016dc:	75 0f                	jne    8016ed <memmove+0x6a>
  8016de:	f6 c1 03             	test   $0x3,%cl
  8016e1:	75 0a                	jne    8016ed <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8016e3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8016e6:	89 c7                	mov    %eax,%edi
  8016e8:	fc                   	cld    
  8016e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8016eb:	eb 05                	jmp    8016f2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8016ed:	89 c7                	mov    %eax,%edi
  8016ef:	fc                   	cld    
  8016f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8016f2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016f5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016f8:	89 ec                	mov    %ebp,%esp
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801702:	8b 45 10             	mov    0x10(%ebp),%eax
  801705:	89 44 24 08          	mov    %eax,0x8(%esp)
  801709:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801710:	8b 45 08             	mov    0x8(%ebp),%eax
  801713:	89 04 24             	mov    %eax,(%esp)
  801716:	e8 68 ff ff ff       	call   801683 <memmove>
}
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	57                   	push   %edi
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
  801723:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801726:	8b 75 0c             	mov    0xc(%ebp),%esi
  801729:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80172c:	8d 78 ff             	lea    -0x1(%eax),%edi
  80172f:	85 c0                	test   %eax,%eax
  801731:	74 36                	je     801769 <memcmp+0x4c>
		if (*s1 != *s2)
  801733:	0f b6 03             	movzbl (%ebx),%eax
  801736:	0f b6 0e             	movzbl (%esi),%ecx
  801739:	38 c8                	cmp    %cl,%al
  80173b:	75 17                	jne    801754 <memcmp+0x37>
  80173d:	ba 00 00 00 00       	mov    $0x0,%edx
  801742:	eb 1a                	jmp    80175e <memcmp+0x41>
  801744:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801749:	83 c2 01             	add    $0x1,%edx
  80174c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801750:	38 c8                	cmp    %cl,%al
  801752:	74 0a                	je     80175e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801754:	0f b6 c0             	movzbl %al,%eax
  801757:	0f b6 c9             	movzbl %cl,%ecx
  80175a:	29 c8                	sub    %ecx,%eax
  80175c:	eb 10                	jmp    80176e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80175e:	39 fa                	cmp    %edi,%edx
  801760:	75 e2                	jne    801744 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801762:	b8 00 00 00 00       	mov    $0x0,%eax
  801767:	eb 05                	jmp    80176e <memcmp+0x51>
  801769:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5f                   	pop    %edi
  801771:	5d                   	pop    %ebp
  801772:	c3                   	ret    

00801773 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	53                   	push   %ebx
  801777:	8b 45 08             	mov    0x8(%ebp),%eax
  80177a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  80177d:	89 c2                	mov    %eax,%edx
  80177f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801782:	39 d0                	cmp    %edx,%eax
  801784:	73 13                	jae    801799 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801786:	89 d9                	mov    %ebx,%ecx
  801788:	38 18                	cmp    %bl,(%eax)
  80178a:	75 06                	jne    801792 <memfind+0x1f>
  80178c:	eb 0b                	jmp    801799 <memfind+0x26>
  80178e:	38 08                	cmp    %cl,(%eax)
  801790:	74 07                	je     801799 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801792:	83 c0 01             	add    $0x1,%eax
  801795:	39 d0                	cmp    %edx,%eax
  801797:	75 f5                	jne    80178e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801799:	5b                   	pop    %ebx
  80179a:	5d                   	pop    %ebp
  80179b:	c3                   	ret    

0080179c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	57                   	push   %edi
  8017a0:	56                   	push   %esi
  8017a1:	53                   	push   %ebx
  8017a2:	83 ec 04             	sub    $0x4,%esp
  8017a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8017ab:	0f b6 02             	movzbl (%edx),%eax
  8017ae:	3c 09                	cmp    $0x9,%al
  8017b0:	74 04                	je     8017b6 <strtol+0x1a>
  8017b2:	3c 20                	cmp    $0x20,%al
  8017b4:	75 0e                	jne    8017c4 <strtol+0x28>
		s++;
  8017b6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8017b9:	0f b6 02             	movzbl (%edx),%eax
  8017bc:	3c 09                	cmp    $0x9,%al
  8017be:	74 f6                	je     8017b6 <strtol+0x1a>
  8017c0:	3c 20                	cmp    $0x20,%al
  8017c2:	74 f2                	je     8017b6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8017c4:	3c 2b                	cmp    $0x2b,%al
  8017c6:	75 0a                	jne    8017d2 <strtol+0x36>
		s++;
  8017c8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8017cb:	bf 00 00 00 00       	mov    $0x0,%edi
  8017d0:	eb 10                	jmp    8017e2 <strtol+0x46>
  8017d2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8017d7:	3c 2d                	cmp    $0x2d,%al
  8017d9:	75 07                	jne    8017e2 <strtol+0x46>
		s++, neg = 1;
  8017db:	83 c2 01             	add    $0x1,%edx
  8017de:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8017e2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8017e8:	75 15                	jne    8017ff <strtol+0x63>
  8017ea:	80 3a 30             	cmpb   $0x30,(%edx)
  8017ed:	75 10                	jne    8017ff <strtol+0x63>
  8017ef:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8017f3:	75 0a                	jne    8017ff <strtol+0x63>
		s += 2, base = 16;
  8017f5:	83 c2 02             	add    $0x2,%edx
  8017f8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8017fd:	eb 10                	jmp    80180f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  8017ff:	85 db                	test   %ebx,%ebx
  801801:	75 0c                	jne    80180f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801803:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801805:	80 3a 30             	cmpb   $0x30,(%edx)
  801808:	75 05                	jne    80180f <strtol+0x73>
		s++, base = 8;
  80180a:	83 c2 01             	add    $0x1,%edx
  80180d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80180f:	b8 00 00 00 00       	mov    $0x0,%eax
  801814:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801817:	0f b6 0a             	movzbl (%edx),%ecx
  80181a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80181d:	89 f3                	mov    %esi,%ebx
  80181f:	80 fb 09             	cmp    $0x9,%bl
  801822:	77 08                	ja     80182c <strtol+0x90>
			dig = *s - '0';
  801824:	0f be c9             	movsbl %cl,%ecx
  801827:	83 e9 30             	sub    $0x30,%ecx
  80182a:	eb 22                	jmp    80184e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  80182c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80182f:	89 f3                	mov    %esi,%ebx
  801831:	80 fb 19             	cmp    $0x19,%bl
  801834:	77 08                	ja     80183e <strtol+0xa2>
			dig = *s - 'a' + 10;
  801836:	0f be c9             	movsbl %cl,%ecx
  801839:	83 e9 57             	sub    $0x57,%ecx
  80183c:	eb 10                	jmp    80184e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  80183e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801841:	89 f3                	mov    %esi,%ebx
  801843:	80 fb 19             	cmp    $0x19,%bl
  801846:	77 16                	ja     80185e <strtol+0xc2>
			dig = *s - 'A' + 10;
  801848:	0f be c9             	movsbl %cl,%ecx
  80184b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80184e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801851:	7d 0f                	jge    801862 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801853:	83 c2 01             	add    $0x1,%edx
  801856:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  80185a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80185c:	eb b9                	jmp    801817 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80185e:	89 c1                	mov    %eax,%ecx
  801860:	eb 02                	jmp    801864 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801862:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801864:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801868:	74 05                	je     80186f <strtol+0xd3>
		*endptr = (char *) s;
  80186a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80186d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80186f:	89 ca                	mov    %ecx,%edx
  801871:	f7 da                	neg    %edx
  801873:	85 ff                	test   %edi,%edi
  801875:	0f 45 c2             	cmovne %edx,%eax
}
  801878:	83 c4 04             	add    $0x4,%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5e                   	pop    %esi
  80187d:	5f                   	pop    %edi
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	56                   	push   %esi
  801884:	53                   	push   %ebx
  801885:	83 ec 10             	sub    $0x10,%esp
  801888:	8b 75 08             	mov    0x8(%ebp),%esi
  80188b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  80188e:	85 db                	test   %ebx,%ebx
  801890:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801895:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  801898:	89 1c 24             	mov    %ebx,(%esp)
  80189b:	e8 f9 eb ff ff       	call   800499 <sys_ipc_recv>
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	78 2d                	js     8018d1 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  8018a4:	85 f6                	test   %esi,%esi
  8018a6:	74 0a                	je     8018b2 <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  8018a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8018ad:	8b 40 74             	mov    0x74(%eax),%eax
  8018b0:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  8018b2:	85 db                	test   %ebx,%ebx
  8018b4:	74 13                	je     8018c9 <ipc_recv+0x49>
  8018b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018ba:	74 0d                	je     8018c9 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  8018bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8018c1:	8b 40 78             	mov    0x78(%eax),%eax
  8018c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8018c7:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  8018c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8018ce:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	5b                   	pop    %ebx
  8018d5:	5e                   	pop    %esi
  8018d6:	5d                   	pop    %ebp
  8018d7:	c3                   	ret    

008018d8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	57                   	push   %edi
  8018dc:	56                   	push   %esi
  8018dd:	53                   	push   %ebx
  8018de:	83 ec 1c             	sub    $0x1c,%esp
  8018e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  8018ea:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  8018ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8018f1:	0f 44 d8             	cmove  %eax,%ebx
  8018f4:	eb 2a                	jmp    801920 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  8018f6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8018f9:	74 20                	je     80191b <ipc_send+0x43>
            panic("Send message error %e\n",r);
  8018fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018ff:	c7 44 24 08 c0 20 80 	movl   $0x8020c0,0x8(%esp)
  801906:	00 
  801907:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80190e:	00 
  80190f:	c7 04 24 d7 20 80 00 	movl   $0x8020d7,(%esp)
  801916:	e8 e5 f3 ff ff       	call   800d00 <_panic>
		sys_yield();
  80191b:	e8 98 e8 ff ff       	call   8001b8 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801920:	8b 45 14             	mov    0x14(%ebp),%eax
  801923:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801927:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80192f:	89 3c 24             	mov    %edi,(%esp)
  801932:	e8 25 eb ff ff       	call   80045c <sys_ipc_try_send>
  801937:	85 c0                	test   %eax,%eax
  801939:	78 bb                	js     8018f6 <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  80193b:	83 c4 1c             	add    $0x1c,%esp
  80193e:	5b                   	pop    %ebx
  80193f:	5e                   	pop    %esi
  801940:	5f                   	pop    %edi
  801941:	5d                   	pop    %ebp
  801942:	c3                   	ret    

00801943 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801949:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80194e:	39 c8                	cmp    %ecx,%eax
  801950:	74 17                	je     801969 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801952:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801957:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80195a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801960:	8b 52 50             	mov    0x50(%edx),%edx
  801963:	39 ca                	cmp    %ecx,%edx
  801965:	75 14                	jne    80197b <ipc_find_env+0x38>
  801967:	eb 05                	jmp    80196e <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801969:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80196e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801971:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801976:	8b 40 40             	mov    0x40(%eax),%eax
  801979:	eb 0e                	jmp    801989 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80197b:	83 c0 01             	add    $0x1,%eax
  80197e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801983:	75 d2                	jne    801957 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801985:	66 b8 00 00          	mov    $0x0,%ax
}
  801989:	5d                   	pop    %ebp
  80198a:	c3                   	ret    
  80198b:	66 90                	xchg   %ax,%ax
  80198d:	66 90                	xchg   %ax,%ax
  80198f:	90                   	nop

00801990 <__udivdi3>:
  801990:	83 ec 1c             	sub    $0x1c,%esp
  801993:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801997:	89 7c 24 14          	mov    %edi,0x14(%esp)
  80199b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80199f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8019a3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8019a7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	89 74 24 10          	mov    %esi,0x10(%esp)
  8019b1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8019b5:	89 ea                	mov    %ebp,%edx
  8019b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019bb:	75 33                	jne    8019f0 <__udivdi3+0x60>
  8019bd:	39 e9                	cmp    %ebp,%ecx
  8019bf:	77 6f                	ja     801a30 <__udivdi3+0xa0>
  8019c1:	85 c9                	test   %ecx,%ecx
  8019c3:	89 ce                	mov    %ecx,%esi
  8019c5:	75 0b                	jne    8019d2 <__udivdi3+0x42>
  8019c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019cc:	31 d2                	xor    %edx,%edx
  8019ce:	f7 f1                	div    %ecx
  8019d0:	89 c6                	mov    %eax,%esi
  8019d2:	31 d2                	xor    %edx,%edx
  8019d4:	89 e8                	mov    %ebp,%eax
  8019d6:	f7 f6                	div    %esi
  8019d8:	89 c5                	mov    %eax,%ebp
  8019da:	89 f8                	mov    %edi,%eax
  8019dc:	f7 f6                	div    %esi
  8019de:	89 ea                	mov    %ebp,%edx
  8019e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8019e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8019e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8019ec:	83 c4 1c             	add    $0x1c,%esp
  8019ef:	c3                   	ret    
  8019f0:	39 e8                	cmp    %ebp,%eax
  8019f2:	77 24                	ja     801a18 <__udivdi3+0x88>
  8019f4:	0f bd c8             	bsr    %eax,%ecx
  8019f7:	83 f1 1f             	xor    $0x1f,%ecx
  8019fa:	89 0c 24             	mov    %ecx,(%esp)
  8019fd:	75 49                	jne    801a48 <__udivdi3+0xb8>
  8019ff:	8b 74 24 08          	mov    0x8(%esp),%esi
  801a03:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801a07:	0f 86 ab 00 00 00    	jbe    801ab8 <__udivdi3+0x128>
  801a0d:	39 e8                	cmp    %ebp,%eax
  801a0f:	0f 82 a3 00 00 00    	jb     801ab8 <__udivdi3+0x128>
  801a15:	8d 76 00             	lea    0x0(%esi),%esi
  801a18:	31 d2                	xor    %edx,%edx
  801a1a:	31 c0                	xor    %eax,%eax
  801a1c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a20:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a24:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a28:	83 c4 1c             	add    $0x1c,%esp
  801a2b:	c3                   	ret    
  801a2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a30:	89 f8                	mov    %edi,%eax
  801a32:	f7 f1                	div    %ecx
  801a34:	31 d2                	xor    %edx,%edx
  801a36:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a3a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a3e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a42:	83 c4 1c             	add    $0x1c,%esp
  801a45:	c3                   	ret    
  801a46:	66 90                	xchg   %ax,%ax
  801a48:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a4c:	89 c6                	mov    %eax,%esi
  801a4e:	b8 20 00 00 00       	mov    $0x20,%eax
  801a53:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801a57:	2b 04 24             	sub    (%esp),%eax
  801a5a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801a5e:	d3 e6                	shl    %cl,%esi
  801a60:	89 c1                	mov    %eax,%ecx
  801a62:	d3 ed                	shr    %cl,%ebp
  801a64:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a68:	09 f5                	or     %esi,%ebp
  801a6a:	8b 74 24 04          	mov    0x4(%esp),%esi
  801a6e:	d3 e6                	shl    %cl,%esi
  801a70:	89 c1                	mov    %eax,%ecx
  801a72:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a76:	89 d6                	mov    %edx,%esi
  801a78:	d3 ee                	shr    %cl,%esi
  801a7a:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a7e:	d3 e2                	shl    %cl,%edx
  801a80:	89 c1                	mov    %eax,%ecx
  801a82:	d3 ef                	shr    %cl,%edi
  801a84:	09 d7                	or     %edx,%edi
  801a86:	89 f2                	mov    %esi,%edx
  801a88:	89 f8                	mov    %edi,%eax
  801a8a:	f7 f5                	div    %ebp
  801a8c:	89 d6                	mov    %edx,%esi
  801a8e:	89 c7                	mov    %eax,%edi
  801a90:	f7 64 24 04          	mull   0x4(%esp)
  801a94:	39 d6                	cmp    %edx,%esi
  801a96:	72 30                	jb     801ac8 <__udivdi3+0x138>
  801a98:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801a9c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801aa0:	d3 e5                	shl    %cl,%ebp
  801aa2:	39 c5                	cmp    %eax,%ebp
  801aa4:	73 04                	jae    801aaa <__udivdi3+0x11a>
  801aa6:	39 d6                	cmp    %edx,%esi
  801aa8:	74 1e                	je     801ac8 <__udivdi3+0x138>
  801aaa:	89 f8                	mov    %edi,%eax
  801aac:	31 d2                	xor    %edx,%edx
  801aae:	e9 69 ff ff ff       	jmp    801a1c <__udivdi3+0x8c>
  801ab3:	90                   	nop
  801ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ab8:	31 d2                	xor    %edx,%edx
  801aba:	b8 01 00 00 00       	mov    $0x1,%eax
  801abf:	e9 58 ff ff ff       	jmp    801a1c <__udivdi3+0x8c>
  801ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ac8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801acb:	31 d2                	xor    %edx,%edx
  801acd:	8b 74 24 10          	mov    0x10(%esp),%esi
  801ad1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801ad5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801ad9:	83 c4 1c             	add    $0x1c,%esp
  801adc:	c3                   	ret    
  801add:	66 90                	xchg   %ax,%ax
  801adf:	90                   	nop

00801ae0 <__umoddi3>:
  801ae0:	83 ec 2c             	sub    $0x2c,%esp
  801ae3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801ae7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801aeb:	89 74 24 20          	mov    %esi,0x20(%esp)
  801aef:	8b 74 24 38          	mov    0x38(%esp),%esi
  801af3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801af7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801afb:	85 c0                	test   %eax,%eax
  801afd:	89 c2                	mov    %eax,%edx
  801aff:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801b03:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801b07:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b0b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801b0f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b13:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801b17:	75 1f                	jne    801b38 <__umoddi3+0x58>
  801b19:	39 fe                	cmp    %edi,%esi
  801b1b:	76 63                	jbe    801b80 <__umoddi3+0xa0>
  801b1d:	89 c8                	mov    %ecx,%eax
  801b1f:	89 fa                	mov    %edi,%edx
  801b21:	f7 f6                	div    %esi
  801b23:	89 d0                	mov    %edx,%eax
  801b25:	31 d2                	xor    %edx,%edx
  801b27:	8b 74 24 20          	mov    0x20(%esp),%esi
  801b2b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801b2f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801b33:	83 c4 2c             	add    $0x2c,%esp
  801b36:	c3                   	ret    
  801b37:	90                   	nop
  801b38:	39 f8                	cmp    %edi,%eax
  801b3a:	77 64                	ja     801ba0 <__umoddi3+0xc0>
  801b3c:	0f bd e8             	bsr    %eax,%ebp
  801b3f:	83 f5 1f             	xor    $0x1f,%ebp
  801b42:	75 74                	jne    801bb8 <__umoddi3+0xd8>
  801b44:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b48:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801b4c:	0f 87 0e 01 00 00    	ja     801c60 <__umoddi3+0x180>
  801b52:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801b56:	29 f1                	sub    %esi,%ecx
  801b58:	19 c7                	sbb    %eax,%edi
  801b5a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b5e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801b62:	8b 44 24 14          	mov    0x14(%esp),%eax
  801b66:	8b 54 24 18          	mov    0x18(%esp),%edx
  801b6a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801b6e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801b72:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801b76:	83 c4 2c             	add    $0x2c,%esp
  801b79:	c3                   	ret    
  801b7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b80:	85 f6                	test   %esi,%esi
  801b82:	89 f5                	mov    %esi,%ebp
  801b84:	75 0b                	jne    801b91 <__umoddi3+0xb1>
  801b86:	b8 01 00 00 00       	mov    $0x1,%eax
  801b8b:	31 d2                	xor    %edx,%edx
  801b8d:	f7 f6                	div    %esi
  801b8f:	89 c5                	mov    %eax,%ebp
  801b91:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801b95:	31 d2                	xor    %edx,%edx
  801b97:	f7 f5                	div    %ebp
  801b99:	89 c8                	mov    %ecx,%eax
  801b9b:	f7 f5                	div    %ebp
  801b9d:	eb 84                	jmp    801b23 <__umoddi3+0x43>
  801b9f:	90                   	nop
  801ba0:	89 c8                	mov    %ecx,%eax
  801ba2:	89 fa                	mov    %edi,%edx
  801ba4:	8b 74 24 20          	mov    0x20(%esp),%esi
  801ba8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801bac:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801bb0:	83 c4 2c             	add    $0x2c,%esp
  801bb3:	c3                   	ret    
  801bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bb8:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bbc:	be 20 00 00 00       	mov    $0x20,%esi
  801bc1:	89 e9                	mov    %ebp,%ecx
  801bc3:	29 ee                	sub    %ebp,%esi
  801bc5:	d3 e2                	shl    %cl,%edx
  801bc7:	89 f1                	mov    %esi,%ecx
  801bc9:	d3 e8                	shr    %cl,%eax
  801bcb:	89 e9                	mov    %ebp,%ecx
  801bcd:	09 d0                	or     %edx,%eax
  801bcf:	89 fa                	mov    %edi,%edx
  801bd1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bd5:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bd9:	d3 e0                	shl    %cl,%eax
  801bdb:	89 f1                	mov    %esi,%ecx
  801bdd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801be1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801be5:	d3 ea                	shr    %cl,%edx
  801be7:	89 e9                	mov    %ebp,%ecx
  801be9:	d3 e7                	shl    %cl,%edi
  801beb:	89 f1                	mov    %esi,%ecx
  801bed:	d3 e8                	shr    %cl,%eax
  801bef:	89 e9                	mov    %ebp,%ecx
  801bf1:	09 f8                	or     %edi,%eax
  801bf3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801bf7:	f7 74 24 0c          	divl   0xc(%esp)
  801bfb:	d3 e7                	shl    %cl,%edi
  801bfd:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c01:	89 d7                	mov    %edx,%edi
  801c03:	f7 64 24 10          	mull   0x10(%esp)
  801c07:	39 d7                	cmp    %edx,%edi
  801c09:	89 c1                	mov    %eax,%ecx
  801c0b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801c0f:	72 3b                	jb     801c4c <__umoddi3+0x16c>
  801c11:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801c15:	72 31                	jb     801c48 <__umoddi3+0x168>
  801c17:	8b 44 24 18          	mov    0x18(%esp),%eax
  801c1b:	29 c8                	sub    %ecx,%eax
  801c1d:	19 d7                	sbb    %edx,%edi
  801c1f:	89 e9                	mov    %ebp,%ecx
  801c21:	89 fa                	mov    %edi,%edx
  801c23:	d3 e8                	shr    %cl,%eax
  801c25:	89 f1                	mov    %esi,%ecx
  801c27:	d3 e2                	shl    %cl,%edx
  801c29:	89 e9                	mov    %ebp,%ecx
  801c2b:	09 d0                	or     %edx,%eax
  801c2d:	89 fa                	mov    %edi,%edx
  801c2f:	d3 ea                	shr    %cl,%edx
  801c31:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c35:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c39:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c3d:	83 c4 2c             	add    $0x2c,%esp
  801c40:	c3                   	ret    
  801c41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c48:	39 d7                	cmp    %edx,%edi
  801c4a:	75 cb                	jne    801c17 <__umoddi3+0x137>
  801c4c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801c50:	89 c1                	mov    %eax,%ecx
  801c52:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801c56:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801c5a:	eb bb                	jmp    801c17 <__umoddi3+0x137>
  801c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c60:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801c64:	0f 82 e8 fe ff ff    	jb     801b52 <__umoddi3+0x72>
  801c6a:	e9 f3 fe ff ff       	jmp    801b62 <__umoddi3+0x82>
