
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	sys_cputs((char*)1, 1);
  80003a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800049:	e8 6e 00 00 00       	call   8000bc <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  800062:	e8 2c 01 00 00       	call   800193 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 db                	test   %ebx,%ebx
  80007b:	7e 07                	jle    800084 <libmain+0x34>
		binaryname = argv[0];
  80007d:	8b 06                	mov    (%esi),%eax
  80007f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800084:	89 74 24 04          	mov    %esi,0x4(%esp)
  800088:	89 1c 24             	mov    %ebx,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
}
  800095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800098:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009b:	89 ec                	mov    %ebp,%esp
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
  80009f:	90                   	nop

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000a6:	e8 78 06 00 00       	call   800723 <close_all>
	sys_env_destroy(0);
  8000ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b2:	e8 76 00 00 00       	call   80012d <sys_env_destroy>
}
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    
  8000b9:	66 90                	xchg   %ax,%ax
  8000bb:	90                   	nop

008000bc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	83 ec 0c             	sub    $0xc,%esp
  8000c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	0f a2                	cpuid  
  8000d2:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	89 c3                	mov    %eax,%ebx
  8000e1:	89 c7                	mov    %eax,%edi
  8000e3:	89 c6                	mov    %eax,%esi
  8000e5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000ea:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000ed:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000f0:	89 ec                	mov    %ebp,%esp
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 0c             	sub    $0xc,%esp
  8000fa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000fd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800100:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800103:	b8 01 00 00 00       	mov    $0x1,%eax
  800108:	0f a2                	cpuid  
  80010a:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010c:	ba 00 00 00 00       	mov    $0x0,%edx
  800111:	b8 01 00 00 00       	mov    $0x1,%eax
  800116:	89 d1                	mov    %edx,%ecx
  800118:	89 d3                	mov    %edx,%ebx
  80011a:	89 d7                	mov    %edx,%edi
  80011c:	89 d6                	mov    %edx,%esi
  80011e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800120:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800123:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800126:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800129:	89 ec                	mov    %ebp,%esp
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    

0080012d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	83 ec 38             	sub    $0x38,%esp
  800133:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800136:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800139:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80013c:	b8 01 00 00 00       	mov    $0x1,%eax
  800141:	0f a2                	cpuid  
  800143:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	b9 00 00 00 00       	mov    $0x0,%ecx
  80014a:	b8 03 00 00 00       	mov    $0x3,%eax
  80014f:	8b 55 08             	mov    0x8(%ebp),%edx
  800152:	89 cb                	mov    %ecx,%ebx
  800154:	89 cf                	mov    %ecx,%edi
  800156:	89 ce                	mov    %ecx,%esi
  800158:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80015a:	85 c0                	test   %eax,%eax
  80015c:	7e 28                	jle    800186 <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  80015e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800162:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800169:	00 
  80016a:	c7 44 24 08 aa 1c 80 	movl   $0x801caa,0x8(%esp)
  800171:	00 
  800172:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800179:	00 
  80017a:	c7 04 24 c7 1c 80 00 	movl   $0x801cc7,(%esp)
  800181:	e8 9a 0b 00 00       	call   800d20 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800186:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800189:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80018c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80018f:	89 ec                	mov    %ebp,%esp
  800191:	5d                   	pop    %ebp
  800192:	c3                   	ret    

00800193 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80019c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80019f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8001a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8001a7:	0f a2                	cpuid  
  8001a9:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8001b5:	89 d1                	mov    %edx,%ecx
  8001b7:	89 d3                	mov    %edx,%ebx
  8001b9:	89 d7                	mov    %edx,%edi
  8001bb:	89 d6                	mov    %edx,%esi
  8001bd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001bf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001c2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001c5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001c8:	89 ec                	mov    %ebp,%esp
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <sys_yield>:

void
sys_yield(void)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 0c             	sub    $0xc,%esp
  8001d2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001d8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8001db:	b8 01 00 00 00       	mov    $0x1,%eax
  8001e0:	0f a2                	cpuid  
  8001e2:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001e9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ee:	89 d1                	mov    %edx,%ecx
  8001f0:	89 d3                	mov    %edx,%ebx
  8001f2:	89 d7                	mov    %edx,%edi
  8001f4:	89 d6                	mov    %edx,%esi
  8001f6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001f8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001fb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001fe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800201:	89 ec                	mov    %ebp,%esp
  800203:	5d                   	pop    %ebp
  800204:	c3                   	ret    

00800205 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	83 ec 38             	sub    $0x38,%esp
  80020b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80020e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800211:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800214:	b8 01 00 00 00       	mov    $0x1,%eax
  800219:	0f a2                	cpuid  
  80021b:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021d:	be 00 00 00 00       	mov    $0x0,%esi
  800222:	b8 04 00 00 00       	mov    $0x4,%eax
  800227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800230:	89 f7                	mov    %esi,%edi
  800232:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800234:	85 c0                	test   %eax,%eax
  800236:	7e 28                	jle    800260 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800238:	89 44 24 10          	mov    %eax,0x10(%esp)
  80023c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800243:	00 
  800244:	c7 44 24 08 aa 1c 80 	movl   $0x801caa,0x8(%esp)
  80024b:	00 
  80024c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800253:	00 
  800254:	c7 04 24 c7 1c 80 00 	movl   $0x801cc7,(%esp)
  80025b:	e8 c0 0a 00 00       	call   800d20 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800260:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800263:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800266:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800269:	89 ec                	mov    %ebp,%esp
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 38             	sub    $0x38,%esp
  800273:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800276:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800279:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80027c:	b8 01 00 00 00       	mov    $0x1,%eax
  800281:	0f a2                	cpuid  
  800283:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800285:	b8 05 00 00 00       	mov    $0x5,%eax
  80028a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028d:	8b 55 08             	mov    0x8(%ebp),%edx
  800290:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800293:	8b 7d 14             	mov    0x14(%ebp),%edi
  800296:	8b 75 18             	mov    0x18(%ebp),%esi
  800299:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029b:	85 c0                	test   %eax,%eax
  80029d:	7e 28                	jle    8002c7 <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a3:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8002aa:	00 
  8002ab:	c7 44 24 08 aa 1c 80 	movl   $0x801caa,0x8(%esp)
  8002b2:	00 
  8002b3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8002ba:	00 
  8002bb:	c7 04 24 c7 1c 80 00 	movl   $0x801cc7,(%esp)
  8002c2:	e8 59 0a 00 00       	call   800d20 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002c7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002ca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002cd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002d0:	89 ec                	mov    %ebp,%esp
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	83 ec 38             	sub    $0x38,%esp
  8002da:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002dd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002e0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8002e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8002e8:	0f a2                	cpuid  
  8002ea:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8002f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fc:	89 df                	mov    %ebx,%edi
  8002fe:	89 de                	mov    %ebx,%esi
  800300:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800302:	85 c0                	test   %eax,%eax
  800304:	7e 28                	jle    80032e <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800306:	89 44 24 10          	mov    %eax,0x10(%esp)
  80030a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800311:	00 
  800312:	c7 44 24 08 aa 1c 80 	movl   $0x801caa,0x8(%esp)
  800319:	00 
  80031a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800321:	00 
  800322:	c7 04 24 c7 1c 80 00 	movl   $0x801cc7,(%esp)
  800329:	e8 f2 09 00 00       	call   800d20 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80032e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800331:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800334:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800337:	89 ec                	mov    %ebp,%esp
  800339:	5d                   	pop    %ebp
  80033a:	c3                   	ret    

0080033b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	83 ec 38             	sub    $0x38,%esp
  800341:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800344:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800347:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80034a:	b8 01 00 00 00       	mov    $0x1,%eax
  80034f:	0f a2                	cpuid  
  800351:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800353:	bb 00 00 00 00       	mov    $0x0,%ebx
  800358:	b8 08 00 00 00       	mov    $0x8,%eax
  80035d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800360:	8b 55 08             	mov    0x8(%ebp),%edx
  800363:	89 df                	mov    %ebx,%edi
  800365:	89 de                	mov    %ebx,%esi
  800367:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800369:	85 c0                	test   %eax,%eax
  80036b:	7e 28                	jle    800395 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800371:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800378:	00 
  800379:	c7 44 24 08 aa 1c 80 	movl   $0x801caa,0x8(%esp)
  800380:	00 
  800381:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800388:	00 
  800389:	c7 04 24 c7 1c 80 00 	movl   $0x801cc7,(%esp)
  800390:	e8 8b 09 00 00       	call   800d20 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800395:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800398:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80039b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80039e:	89 ec                	mov    %ebp,%esp
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	83 ec 38             	sub    $0x38,%esp
  8003a8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003ab:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003ae:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8003b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8003b6:	0f a2                	cpuid  
  8003b8:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003bf:	b8 09 00 00 00       	mov    $0x9,%eax
  8003c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ca:	89 df                	mov    %ebx,%edi
  8003cc:	89 de                	mov    %ebx,%esi
  8003ce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	7e 28                	jle    8003fc <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003d8:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003df:	00 
  8003e0:	c7 44 24 08 aa 1c 80 	movl   $0x801caa,0x8(%esp)
  8003e7:	00 
  8003e8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8003ef:	00 
  8003f0:	c7 04 24 c7 1c 80 00 	movl   $0x801cc7,(%esp)
  8003f7:	e8 24 09 00 00       	call   800d20 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8003fc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003ff:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800402:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800405:	89 ec                	mov    %ebp,%esp
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	83 ec 38             	sub    $0x38,%esp
  80040f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800412:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800415:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800418:	b8 01 00 00 00       	mov    $0x1,%eax
  80041d:	0f a2                	cpuid  
  80041f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800421:	bb 00 00 00 00       	mov    $0x0,%ebx
  800426:	b8 0a 00 00 00       	mov    $0xa,%eax
  80042b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042e:	8b 55 08             	mov    0x8(%ebp),%edx
  800431:	89 df                	mov    %ebx,%edi
  800433:	89 de                	mov    %ebx,%esi
  800435:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800437:	85 c0                	test   %eax,%eax
  800439:	7e 28                	jle    800463 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80043b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80043f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800446:	00 
  800447:	c7 44 24 08 aa 1c 80 	movl   $0x801caa,0x8(%esp)
  80044e:	00 
  80044f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800456:	00 
  800457:	c7 04 24 c7 1c 80 00 	movl   $0x801cc7,(%esp)
  80045e:	e8 bd 08 00 00       	call   800d20 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800463:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800466:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800469:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80046c:	89 ec                	mov    %ebp,%esp
  80046e:	5d                   	pop    %ebp
  80046f:	c3                   	ret    

00800470 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	83 ec 0c             	sub    $0xc,%esp
  800476:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800479:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80047c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80047f:	b8 01 00 00 00       	mov    $0x1,%eax
  800484:	0f a2                	cpuid  
  800486:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800488:	be 00 00 00 00       	mov    $0x0,%esi
  80048d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800492:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800495:	8b 55 08             	mov    0x8(%ebp),%edx
  800498:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80049b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80049e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8004a0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8004a3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8004a6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004a9:	89 ec                	mov    %ebp,%esp
  8004ab:	5d                   	pop    %ebp
  8004ac:	c3                   	ret    

008004ad <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
  8004b0:	83 ec 38             	sub    $0x38,%esp
  8004b3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8004b6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8004b9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8004bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8004c1:	0f a2                	cpuid  
  8004c3:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ca:	b8 0d 00 00 00       	mov    $0xd,%eax
  8004cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d2:	89 cb                	mov    %ecx,%ebx
  8004d4:	89 cf                	mov    %ecx,%edi
  8004d6:	89 ce                	mov    %ecx,%esi
  8004d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004da:	85 c0                	test   %eax,%eax
  8004dc:	7e 28                	jle    800506 <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004de:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004e2:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8004e9:	00 
  8004ea:	c7 44 24 08 aa 1c 80 	movl   $0x801caa,0x8(%esp)
  8004f1:	00 
  8004f2:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8004f9:	00 
  8004fa:	c7 04 24 c7 1c 80 00 	movl   $0x801cc7,(%esp)
  800501:	e8 1a 08 00 00       	call   800d20 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800506:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800509:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80050c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80050f:	89 ec                	mov    %ebp,%esp
  800511:	5d                   	pop    %ebp
  800512:	c3                   	ret    
  800513:	66 90                	xchg   %ax,%ax
  800515:	66 90                	xchg   %ax,%ax
  800517:	66 90                	xchg   %ax,%ax
  800519:	66 90                	xchg   %ax,%ax
  80051b:	66 90                	xchg   %ax,%ax
  80051d:	66 90                	xchg   %ax,%ax
  80051f:	90                   	nop

00800520 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800523:	8b 45 08             	mov    0x8(%ebp),%eax
  800526:	05 00 00 00 30       	add    $0x30000000,%eax
  80052b:	c1 e8 0c             	shr    $0xc,%eax
}
  80052e:	5d                   	pop    %ebp
  80052f:	c3                   	ret    

00800530 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800536:	8b 45 08             	mov    0x8(%ebp),%eax
  800539:	89 04 24             	mov    %eax,(%esp)
  80053c:	e8 df ff ff ff       	call   800520 <fd2num>
  800541:	c1 e0 0c             	shl    $0xc,%eax
  800544:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80054e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800553:	a8 01                	test   $0x1,%al
  800555:	74 34                	je     80058b <fd_alloc+0x40>
  800557:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80055c:	a8 01                	test   $0x1,%al
  80055e:	74 32                	je     800592 <fd_alloc+0x47>
  800560:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800565:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800567:	89 c2                	mov    %eax,%edx
  800569:	c1 ea 16             	shr    $0x16,%edx
  80056c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800573:	f6 c2 01             	test   $0x1,%dl
  800576:	74 1f                	je     800597 <fd_alloc+0x4c>
  800578:	89 c2                	mov    %eax,%edx
  80057a:	c1 ea 0c             	shr    $0xc,%edx
  80057d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800584:	f6 c2 01             	test   $0x1,%dl
  800587:	75 1a                	jne    8005a3 <fd_alloc+0x58>
  800589:	eb 0c                	jmp    800597 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80058b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800590:	eb 05                	jmp    800597 <fd_alloc+0x4c>
  800592:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800597:	8b 45 08             	mov    0x8(%ebp),%eax
  80059a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80059c:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a1:	eb 1a                	jmp    8005bd <fd_alloc+0x72>
  8005a3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8005a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8005ad:	75 b6                	jne    800565 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8005af:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8005b8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8005bd:	5d                   	pop    %ebp
  8005be:	c3                   	ret    

008005bf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8005bf:	55                   	push   %ebp
  8005c0:	89 e5                	mov    %esp,%ebp
  8005c2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8005c5:	83 f8 1f             	cmp    $0x1f,%eax
  8005c8:	77 36                	ja     800600 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8005ca:	c1 e0 0c             	shl    $0xc,%eax
  8005cd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8005d2:	89 c2                	mov    %eax,%edx
  8005d4:	c1 ea 16             	shr    $0x16,%edx
  8005d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8005de:	f6 c2 01             	test   $0x1,%dl
  8005e1:	74 24                	je     800607 <fd_lookup+0x48>
  8005e3:	89 c2                	mov    %eax,%edx
  8005e5:	c1 ea 0c             	shr    $0xc,%edx
  8005e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005ef:	f6 c2 01             	test   $0x1,%dl
  8005f2:	74 1a                	je     80060e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8005f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f7:	89 02                	mov    %eax,(%edx)
	return 0;
  8005f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005fe:	eb 13                	jmp    800613 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  800600:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800605:	eb 0c                	jmp    800613 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  800607:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80060c:	eb 05                	jmp    800613 <fd_lookup+0x54>
  80060e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800613:	5d                   	pop    %ebp
  800614:	c3                   	ret    

00800615 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800615:	55                   	push   %ebp
  800616:	89 e5                	mov    %esp,%ebp
  800618:	83 ec 18             	sub    $0x18,%esp
  80061b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80061e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  800624:	75 10                	jne    800636 <dev_lookup+0x21>
			*dev = devtab[i];
  800626:	8b 45 0c             	mov    0xc(%ebp),%eax
  800629:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80062f:	b8 00 00 00 00       	mov    $0x0,%eax
  800634:	eb 2b                	jmp    800661 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800636:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80063c:	8b 52 48             	mov    0x48(%edx),%edx
  80063f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800643:	89 54 24 04          	mov    %edx,0x4(%esp)
  800647:	c7 04 24 d8 1c 80 00 	movl   $0x801cd8,(%esp)
  80064e:	e8 c8 07 00 00       	call   800e1b <cprintf>
	*dev = 0;
  800653:	8b 55 0c             	mov    0xc(%ebp),%edx
  800656:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80065c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800661:	c9                   	leave  
  800662:	c3                   	ret    

00800663 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800663:	55                   	push   %ebp
  800664:	89 e5                	mov    %esp,%ebp
  800666:	83 ec 38             	sub    $0x38,%esp
  800669:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80066c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80066f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800672:	8b 7d 08             	mov    0x8(%ebp),%edi
  800675:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800678:	89 3c 24             	mov    %edi,(%esp)
  80067b:	e8 a0 fe ff ff       	call   800520 <fd2num>
  800680:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800683:	89 54 24 04          	mov    %edx,0x4(%esp)
  800687:	89 04 24             	mov    %eax,(%esp)
  80068a:	e8 30 ff ff ff       	call   8005bf <fd_lookup>
  80068f:	89 c3                	mov    %eax,%ebx
  800691:	85 c0                	test   %eax,%eax
  800693:	78 05                	js     80069a <fd_close+0x37>
	    || fd != fd2)
  800695:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800698:	74 0c                	je     8006a6 <fd_close+0x43>
		return (must_exist ? r : 0);
  80069a:	85 f6                	test   %esi,%esi
  80069c:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a1:	0f 44 d8             	cmove  %eax,%ebx
  8006a4:	eb 3d                	jmp    8006e3 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8006a6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8006a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ad:	8b 07                	mov    (%edi),%eax
  8006af:	89 04 24             	mov    %eax,(%esp)
  8006b2:	e8 5e ff ff ff       	call   800615 <dev_lookup>
  8006b7:	89 c3                	mov    %eax,%ebx
  8006b9:	85 c0                	test   %eax,%eax
  8006bb:	78 16                	js     8006d3 <fd_close+0x70>
		if (dev->dev_close)
  8006bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006c0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8006c3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	74 07                	je     8006d3 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  8006cc:	89 3c 24             	mov    %edi,(%esp)
  8006cf:	ff d0                	call   *%eax
  8006d1:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8006d3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006de:	e8 f1 fb ff ff       	call   8002d4 <sys_page_unmap>
	return r;
}
  8006e3:	89 d8                	mov    %ebx,%eax
  8006e5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8006e8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8006eb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8006ee:	89 ec                	mov    %ebp,%esp
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8006f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800702:	89 04 24             	mov    %eax,(%esp)
  800705:	e8 b5 fe ff ff       	call   8005bf <fd_lookup>
  80070a:	85 c0                	test   %eax,%eax
  80070c:	78 13                	js     800721 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80070e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800715:	00 
  800716:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800719:	89 04 24             	mov    %eax,(%esp)
  80071c:	e8 42 ff ff ff       	call   800663 <fd_close>
}
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <close_all>:

void
close_all(void)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	53                   	push   %ebx
  800727:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80072a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80072f:	89 1c 24             	mov    %ebx,(%esp)
  800732:	e8 bb ff ff ff       	call   8006f2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800737:	83 c3 01             	add    $0x1,%ebx
  80073a:	83 fb 20             	cmp    $0x20,%ebx
  80073d:	75 f0                	jne    80072f <close_all+0xc>
		close(i);
}
  80073f:	83 c4 14             	add    $0x14,%esp
  800742:	5b                   	pop    %ebx
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	83 ec 58             	sub    $0x58,%esp
  80074b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80074e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800751:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800754:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800757:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80075a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	89 04 24             	mov    %eax,(%esp)
  800764:	e8 56 fe ff ff       	call   8005bf <fd_lookup>
  800769:	85 c0                	test   %eax,%eax
  80076b:	0f 88 e3 00 00 00    	js     800854 <dup+0x10f>
		return r;
	close(newfdnum);
  800771:	89 1c 24             	mov    %ebx,(%esp)
  800774:	e8 79 ff ff ff       	call   8006f2 <close>

	newfd = INDEX2FD(newfdnum);
  800779:	89 de                	mov    %ebx,%esi
  80077b:	c1 e6 0c             	shl    $0xc,%esi
  80077e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800784:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800787:	89 04 24             	mov    %eax,(%esp)
  80078a:	e8 a1 fd ff ff       	call   800530 <fd2data>
  80078f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800791:	89 34 24             	mov    %esi,(%esp)
  800794:	e8 97 fd ff ff       	call   800530 <fd2data>
  800799:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80079c:	89 f8                	mov    %edi,%eax
  80079e:	c1 e8 16             	shr    $0x16,%eax
  8007a1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8007a8:	a8 01                	test   $0x1,%al
  8007aa:	74 46                	je     8007f2 <dup+0xad>
  8007ac:	89 f8                	mov    %edi,%eax
  8007ae:	c1 e8 0c             	shr    $0xc,%eax
  8007b1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8007b8:	f6 c2 01             	test   $0x1,%dl
  8007bb:	74 35                	je     8007f2 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8007bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8007c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8007c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8007db:	00 
  8007dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007e7:	e8 81 fa ff ff       	call   80026d <sys_page_map>
  8007ec:	89 c7                	mov    %eax,%edi
  8007ee:	85 c0                	test   %eax,%eax
  8007f0:	78 3b                	js     80082d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8007f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007f5:	89 c2                	mov    %eax,%edx
  8007f7:	c1 ea 0c             	shr    $0xc,%edx
  8007fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800801:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800807:	89 54 24 10          	mov    %edx,0x10(%esp)
  80080b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80080f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800816:	00 
  800817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800822:	e8 46 fa ff ff       	call   80026d <sys_page_map>
  800827:	89 c7                	mov    %eax,%edi
  800829:	85 c0                	test   %eax,%eax
  80082b:	79 29                	jns    800856 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80082d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800831:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800838:	e8 97 fa ff ff       	call   8002d4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80083d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800840:	89 44 24 04          	mov    %eax,0x4(%esp)
  800844:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80084b:	e8 84 fa ff ff       	call   8002d4 <sys_page_unmap>
	return r;
  800850:	89 fb                	mov    %edi,%ebx
  800852:	eb 02                	jmp    800856 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  800854:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800856:	89 d8                	mov    %ebx,%eax
  800858:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80085b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80085e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800861:	89 ec                	mov    %ebp,%esp
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	53                   	push   %ebx
  800869:	83 ec 24             	sub    $0x24,%esp
  80086c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80086f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800872:	89 44 24 04          	mov    %eax,0x4(%esp)
  800876:	89 1c 24             	mov    %ebx,(%esp)
  800879:	e8 41 fd ff ff       	call   8005bf <fd_lookup>
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 6d                	js     8008ef <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800882:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800885:	89 44 24 04          	mov    %eax,0x4(%esp)
  800889:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088c:	8b 00                	mov    (%eax),%eax
  80088e:	89 04 24             	mov    %eax,(%esp)
  800891:	e8 7f fd ff ff       	call   800615 <dev_lookup>
  800896:	85 c0                	test   %eax,%eax
  800898:	78 55                	js     8008ef <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80089a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80089d:	8b 50 08             	mov    0x8(%eax),%edx
  8008a0:	83 e2 03             	and    $0x3,%edx
  8008a3:	83 fa 01             	cmp    $0x1,%edx
  8008a6:	75 23                	jne    8008cb <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8008a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8008ad:	8b 40 48             	mov    0x48(%eax),%eax
  8008b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b8:	c7 04 24 19 1d 80 00 	movl   $0x801d19,(%esp)
  8008bf:	e8 57 05 00 00       	call   800e1b <cprintf>
		return -E_INVAL;
  8008c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c9:	eb 24                	jmp    8008ef <read+0x8a>
	}
	if (!dev->dev_read)
  8008cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008ce:	8b 52 08             	mov    0x8(%edx),%edx
  8008d1:	85 d2                	test   %edx,%edx
  8008d3:	74 15                	je     8008ea <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8008d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008df:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008e3:	89 04 24             	mov    %eax,(%esp)
  8008e6:	ff d2                	call   *%edx
  8008e8:	eb 05                	jmp    8008ef <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8008ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8008ef:	83 c4 24             	add    $0x24,%esp
  8008f2:	5b                   	pop    %ebx
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	57                   	push   %edi
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	83 ec 1c             	sub    $0x1c,%esp
  8008fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800901:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800904:	85 f6                	test   %esi,%esi
  800906:	74 33                	je     80093b <readn+0x46>
  800908:	b8 00 00 00 00       	mov    $0x0,%eax
  80090d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800912:	89 f2                	mov    %esi,%edx
  800914:	29 c2                	sub    %eax,%edx
  800916:	89 54 24 08          	mov    %edx,0x8(%esp)
  80091a:	03 45 0c             	add    0xc(%ebp),%eax
  80091d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800921:	89 3c 24             	mov    %edi,(%esp)
  800924:	e8 3c ff ff ff       	call   800865 <read>
		if (m < 0)
  800929:	85 c0                	test   %eax,%eax
  80092b:	78 17                	js     800944 <readn+0x4f>
			return m;
		if (m == 0)
  80092d:	85 c0                	test   %eax,%eax
  80092f:	74 11                	je     800942 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800931:	01 c3                	add    %eax,%ebx
  800933:	89 d8                	mov    %ebx,%eax
  800935:	39 f3                	cmp    %esi,%ebx
  800937:	72 d9                	jb     800912 <readn+0x1d>
  800939:	eb 09                	jmp    800944 <readn+0x4f>
  80093b:	b8 00 00 00 00       	mov    $0x0,%eax
  800940:	eb 02                	jmp    800944 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800942:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800944:	83 c4 1c             	add    $0x1c,%esp
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	5f                   	pop    %edi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	53                   	push   %ebx
  800950:	83 ec 24             	sub    $0x24,%esp
  800953:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800956:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800959:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095d:	89 1c 24             	mov    %ebx,(%esp)
  800960:	e8 5a fc ff ff       	call   8005bf <fd_lookup>
  800965:	85 c0                	test   %eax,%eax
  800967:	78 68                	js     8009d1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800969:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80096c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800970:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800973:	8b 00                	mov    (%eax),%eax
  800975:	89 04 24             	mov    %eax,(%esp)
  800978:	e8 98 fc ff ff       	call   800615 <dev_lookup>
  80097d:	85 c0                	test   %eax,%eax
  80097f:	78 50                	js     8009d1 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800981:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800984:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800988:	75 23                	jne    8009ad <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80098a:	a1 04 40 80 00       	mov    0x804004,%eax
  80098f:	8b 40 48             	mov    0x48(%eax),%eax
  800992:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800996:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099a:	c7 04 24 35 1d 80 00 	movl   $0x801d35,(%esp)
  8009a1:	e8 75 04 00 00       	call   800e1b <cprintf>
		return -E_INVAL;
  8009a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009ab:	eb 24                	jmp    8009d1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8009ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009b0:	8b 52 0c             	mov    0xc(%edx),%edx
  8009b3:	85 d2                	test   %edx,%edx
  8009b5:	74 15                	je     8009cc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8009b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009c5:	89 04 24             	mov    %eax,(%esp)
  8009c8:	ff d2                	call   *%edx
  8009ca:	eb 05                	jmp    8009d1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8009cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8009d1:	83 c4 24             	add    $0x24,%esp
  8009d4:	5b                   	pop    %ebx
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009dd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8009e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	89 04 24             	mov    %eax,(%esp)
  8009ea:	e8 d0 fb ff ff       	call   8005bf <fd_lookup>
  8009ef:	85 c0                	test   %eax,%eax
  8009f1:	78 0e                	js     800a01 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8009f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	53                   	push   %ebx
  800a07:	83 ec 24             	sub    $0x24,%esp
  800a0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a0d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a14:	89 1c 24             	mov    %ebx,(%esp)
  800a17:	e8 a3 fb ff ff       	call   8005bf <fd_lookup>
  800a1c:	85 c0                	test   %eax,%eax
  800a1e:	78 61                	js     800a81 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a2a:	8b 00                	mov    (%eax),%eax
  800a2c:	89 04 24             	mov    %eax,(%esp)
  800a2f:	e8 e1 fb ff ff       	call   800615 <dev_lookup>
  800a34:	85 c0                	test   %eax,%eax
  800a36:	78 49                	js     800a81 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a3b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a3f:	75 23                	jne    800a64 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800a41:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800a46:	8b 40 48             	mov    0x48(%eax),%eax
  800a49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a51:	c7 04 24 f8 1c 80 00 	movl   $0x801cf8,(%esp)
  800a58:	e8 be 03 00 00       	call   800e1b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800a5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a62:	eb 1d                	jmp    800a81 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800a64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a67:	8b 52 18             	mov    0x18(%edx),%edx
  800a6a:	85 d2                	test   %edx,%edx
  800a6c:	74 0e                	je     800a7c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a71:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a75:	89 04 24             	mov    %eax,(%esp)
  800a78:	ff d2                	call   *%edx
  800a7a:	eb 05                	jmp    800a81 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800a7c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800a81:	83 c4 24             	add    $0x24,%esp
  800a84:	5b                   	pop    %ebx
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	53                   	push   %ebx
  800a8b:	83 ec 24             	sub    $0x24,%esp
  800a8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a91:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	89 04 24             	mov    %eax,(%esp)
  800a9e:	e8 1c fb ff ff       	call   8005bf <fd_lookup>
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	78 52                	js     800af9 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800aa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ab1:	8b 00                	mov    (%eax),%eax
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	e8 5a fb ff ff       	call   800615 <dev_lookup>
  800abb:	85 c0                	test   %eax,%eax
  800abd:	78 3a                	js     800af9 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800ac6:	74 2c                	je     800af4 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800ac8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800acb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ad2:	00 00 00 
	stat->st_isdir = 0;
  800ad5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800adc:	00 00 00 
	stat->st_dev = dev;
  800adf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800ae5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800aec:	89 14 24             	mov    %edx,(%esp)
  800aef:	ff 50 14             	call   *0x14(%eax)
  800af2:	eb 05                	jmp    800af9 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800af4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800af9:	83 c4 24             	add    $0x24,%esp
  800afc:	5b                   	pop    %ebx
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	83 ec 18             	sub    $0x18,%esp
  800b05:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b08:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800b0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800b12:	00 
  800b13:	8b 45 08             	mov    0x8(%ebp),%eax
  800b16:	89 04 24             	mov    %eax,(%esp)
  800b19:	e8 84 01 00 00       	call   800ca2 <open>
  800b1e:	89 c3                	mov    %eax,%ebx
  800b20:	85 c0                	test   %eax,%eax
  800b22:	78 1b                	js     800b3f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2b:	89 1c 24             	mov    %ebx,(%esp)
  800b2e:	e8 54 ff ff ff       	call   800a87 <fstat>
  800b33:	89 c6                	mov    %eax,%esi
	close(fd);
  800b35:	89 1c 24             	mov    %ebx,(%esp)
  800b38:	e8 b5 fb ff ff       	call   8006f2 <close>
	return r;
  800b3d:	89 f3                	mov    %esi,%ebx
}
  800b3f:	89 d8                	mov    %ebx,%eax
  800b41:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b44:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b47:	89 ec                	mov    %ebp,%esp
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    
  800b4b:	90                   	nop

00800b4c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	83 ec 18             	sub    $0x18,%esp
  800b52:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b55:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b58:	89 c6                	mov    %eax,%esi
  800b5a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800b5c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800b63:	75 11                	jne    800b76 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b65:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b6c:	e8 f2 0d 00 00       	call   801963 <ipc_find_env>
  800b71:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b76:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b7d:	00 
  800b7e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800b85:	00 
  800b86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b8a:	a1 00 40 80 00       	mov    0x804000,%eax
  800b8f:	89 04 24             	mov    %eax,(%esp)
  800b92:	e8 61 0d 00 00       	call   8018f8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800b97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b9e:	00 
  800b9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ba3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800baa:	e8 f1 0c 00 00       	call   8018a0 <ipc_recv>
}
  800baf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800bb2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800bb5:	89 ec                	mov    %ebp,%esp
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc2:	8b 40 0c             	mov    0xc(%eax),%eax
  800bc5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800bca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdc:	e8 6b ff ff ff       	call   800b4c <fsipc>
}
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800be9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bec:	8b 40 0c             	mov    0xc(%eax),%eax
  800bef:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf9:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfe:	e8 49 ff ff ff       	call   800b4c <fsipc>
}
  800c03:	c9                   	leave  
  800c04:	c3                   	ret    

00800c05 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	53                   	push   %ebx
  800c09:	83 ec 14             	sub    $0x14,%esp
  800c0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c12:	8b 40 0c             	mov    0xc(%eax),%eax
  800c15:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c24:	e8 23 ff ff ff       	call   800b4c <fsipc>
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	78 2b                	js     800c58 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800c2d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c34:	00 
  800c35:	89 1c 24             	mov    %ebx,(%esp)
  800c38:	e8 5e 08 00 00       	call   80149b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800c3d:	a1 80 50 80 00       	mov    0x805080,%eax
  800c42:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800c48:	a1 84 50 80 00       	mov    0x805084,%eax
  800c4d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800c53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c58:	83 c4 14             	add    $0x14,%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800c64:	c7 44 24 08 52 1d 80 	movl   $0x801d52,0x8(%esp)
  800c6b:	00 
  800c6c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  800c73:	00 
  800c74:	c7 04 24 70 1d 80 00 	movl   $0x801d70,(%esp)
  800c7b:	e8 a0 00 00 00       	call   800d20 <_panic>

00800c80 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  800c86:	c7 44 24 08 7b 1d 80 	movl   $0x801d7b,0x8(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  800c95:	00 
  800c96:	c7 04 24 70 1d 80 00 	movl   $0x801d70,(%esp)
  800c9d:	e8 7e 00 00 00       	call   800d20 <_panic>

00800ca2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  800ca8:	c7 44 24 08 98 1d 80 	movl   $0x801d98,0x8(%esp)
  800caf:	00 
  800cb0:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800cb7:	00 
  800cb8:	c7 04 24 70 1d 80 00 	movl   $0x801d70,(%esp)
  800cbf:	e8 5c 00 00 00       	call   800d20 <_panic>

00800cc4 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 14             	sub    $0x14,%esp
  800ccb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800cce:	89 1c 24             	mov    %ebx,(%esp)
  800cd1:	e8 6a 07 00 00       	call   801440 <strlen>
  800cd6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800cdb:	7f 21                	jg     800cfe <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800cdd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ce1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800ce8:	e8 ae 07 00 00       	call   80149b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800ced:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf2:	b8 07 00 00 00       	mov    $0x7,%eax
  800cf7:	e8 50 fe ff ff       	call   800b4c <fsipc>
  800cfc:	eb 05                	jmp    800d03 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cfe:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  800d03:	83 c4 14             	add    $0x14,%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d14:	b8 08 00 00 00       	mov    $0x8,%eax
  800d19:	e8 2e fe ff ff       	call   800b4c <fsipc>
}
  800d1e:	c9                   	leave  
  800d1f:	c3                   	ret    

00800d20 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d28:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d2b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800d31:	e8 5d f4 ff ff       	call   800193 <sys_getenvid>
  800d36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d39:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d44:	89 74 24 08          	mov    %esi,0x8(%esp)
  800d48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d4c:	c7 04 24 b0 1d 80 00 	movl   $0x801db0,(%esp)
  800d53:	e8 c3 00 00 00       	call   800e1b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d58:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d5f:	89 04 24             	mov    %eax,(%esp)
  800d62:	e8 53 00 00 00       	call   800dba <vcprintf>
	cprintf("\n");
  800d67:	c7 04 24 f5 20 80 00 	movl   $0x8020f5,(%esp)
  800d6e:	e8 a8 00 00 00       	call   800e1b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d73:	cc                   	int3   
  800d74:	eb fd                	jmp    800d73 <_panic+0x53>
  800d76:	66 90                	xchg   %ax,%ax

00800d78 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	53                   	push   %ebx
  800d7c:	83 ec 14             	sub    $0x14,%esp
  800d7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800d82:	8b 03                	mov    (%ebx),%eax
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800d8b:	83 c0 01             	add    $0x1,%eax
  800d8e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800d90:	3d ff 00 00 00       	cmp    $0xff,%eax
  800d95:	75 19                	jne    800db0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800d97:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800d9e:	00 
  800d9f:	8d 43 08             	lea    0x8(%ebx),%eax
  800da2:	89 04 24             	mov    %eax,(%esp)
  800da5:	e8 12 f3 ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  800daa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800db0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800db4:	83 c4 14             	add    $0x14,%esp
  800db7:	5b                   	pop    %ebx
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800dc3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800dca:	00 00 00 
	b.cnt = 0;
  800dcd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800dd4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dda:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dde:	8b 45 08             	mov    0x8(%ebp),%eax
  800de1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800deb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800def:	c7 04 24 78 0d 80 00 	movl   $0x800d78,(%esp)
  800df6:	e8 b7 01 00 00       	call   800fb2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800dfb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800e01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e05:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800e0b:	89 04 24             	mov    %eax,(%esp)
  800e0e:	e8 a9 f2 ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  800e13:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    

00800e1b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800e21:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800e24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	89 04 24             	mov    %eax,(%esp)
  800e2e:	e8 87 ff ff ff       	call   800dba <vcprintf>
	va_end(ap);

	return cnt;
}
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    
  800e35:	66 90                	xchg   %ax,%ax
  800e37:	66 90                	xchg   %ax,%ax
  800e39:	66 90                	xchg   %ax,%ax
  800e3b:	66 90                	xchg   %ax,%ax
  800e3d:	66 90                	xchg   %ax,%ax
  800e3f:	90                   	nop

00800e40 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	83 ec 4c             	sub    $0x4c,%esp
  800e49:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e4c:	89 d7                	mov    %edx,%edi
  800e4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e51:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800e54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e57:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800e5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5f:	39 d8                	cmp    %ebx,%eax
  800e61:	72 17                	jb     800e7a <printnum+0x3a>
  800e63:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800e66:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800e69:	76 0f                	jbe    800e7a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800e6b:	8b 75 14             	mov    0x14(%ebp),%esi
  800e6e:	83 ee 01             	sub    $0x1,%esi
  800e71:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800e74:	85 f6                	test   %esi,%esi
  800e76:	7f 63                	jg     800edb <printnum+0x9b>
  800e78:	eb 75                	jmp    800eef <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800e7a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e7d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e81:	8b 45 14             	mov    0x14(%ebp),%eax
  800e84:	83 e8 01             	sub    $0x1,%eax
  800e87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e92:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e96:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800e9a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e9d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ea0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ea7:	00 
  800ea8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800eab:	89 1c 24             	mov    %ebx,(%esp)
  800eae:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800eb1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800eb5:	e8 f6 0a 00 00       	call   8019b0 <__udivdi3>
  800eba:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ebd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ec0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ec4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ec8:	89 04 24             	mov    %eax,(%esp)
  800ecb:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ecf:	89 fa                	mov    %edi,%edx
  800ed1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ed4:	e8 67 ff ff ff       	call   800e40 <printnum>
  800ed9:	eb 14                	jmp    800eef <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800edb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800edf:	8b 45 18             	mov    0x18(%ebp),%eax
  800ee2:	89 04 24             	mov    %eax,(%esp)
  800ee5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800ee7:	83 ee 01             	sub    $0x1,%esi
  800eea:	75 ef                	jne    800edb <printnum+0x9b>
  800eec:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800eef:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ef3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ef7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800efe:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f05:	00 
  800f06:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800f09:	89 1c 24             	mov    %ebx,(%esp)
  800f0c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800f0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f13:	e8 e8 0b 00 00       	call   801b00 <__umoddi3>
  800f18:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f1c:	0f be 80 d3 1d 80 00 	movsbl 0x801dd3(%eax),%eax
  800f23:	89 04 24             	mov    %eax,(%esp)
  800f26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800f29:	ff d0                	call   *%eax
}
  800f2b:	83 c4 4c             	add    $0x4c,%esp
  800f2e:	5b                   	pop    %ebx
  800f2f:	5e                   	pop    %esi
  800f30:	5f                   	pop    %edi
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800f36:	83 fa 01             	cmp    $0x1,%edx
  800f39:	7e 0e                	jle    800f49 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800f3b:	8b 10                	mov    (%eax),%edx
  800f3d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800f40:	89 08                	mov    %ecx,(%eax)
  800f42:	8b 02                	mov    (%edx),%eax
  800f44:	8b 52 04             	mov    0x4(%edx),%edx
  800f47:	eb 22                	jmp    800f6b <getuint+0x38>
	else if (lflag)
  800f49:	85 d2                	test   %edx,%edx
  800f4b:	74 10                	je     800f5d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800f4d:	8b 10                	mov    (%eax),%edx
  800f4f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f52:	89 08                	mov    %ecx,(%eax)
  800f54:	8b 02                	mov    (%edx),%eax
  800f56:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5b:	eb 0e                	jmp    800f6b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800f5d:	8b 10                	mov    (%eax),%edx
  800f5f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f62:	89 08                	mov    %ecx,(%eax)
  800f64:	8b 02                	mov    (%edx),%eax
  800f66:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800f73:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800f77:	8b 10                	mov    (%eax),%edx
  800f79:	3b 50 04             	cmp    0x4(%eax),%edx
  800f7c:	73 0a                	jae    800f88 <sprintputch+0x1b>
		*b->buf++ = ch;
  800f7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f81:	88 0a                	mov    %cl,(%edx)
  800f83:	83 c2 01             	add    $0x1,%edx
  800f86:	89 10                	mov    %edx,(%eax)
}
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800f90:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800f93:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f97:	8b 45 10             	mov    0x10(%ebp),%eax
  800f9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa8:	89 04 24             	mov    %eax,(%esp)
  800fab:	e8 02 00 00 00       	call   800fb2 <vprintfmt>
	va_end(ap);
}
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    

00800fb2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	57                   	push   %edi
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
  800fb8:	83 ec 4c             	sub    $0x4c,%esp
  800fbb:	8b 75 08             	mov    0x8(%ebp),%esi
  800fbe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fc1:	8b 7d 10             	mov    0x10(%ebp),%edi
  800fc4:	eb 11                	jmp    800fd7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	0f 84 db 03 00 00    	je     8013a9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  800fce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fd2:	89 04 24             	mov    %eax,(%esp)
  800fd5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800fd7:	0f b6 07             	movzbl (%edi),%eax
  800fda:	83 c7 01             	add    $0x1,%edi
  800fdd:	83 f8 25             	cmp    $0x25,%eax
  800fe0:	75 e4                	jne    800fc6 <vprintfmt+0x14>
  800fe2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800fe6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800fed:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800ff4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800ffb:	ba 00 00 00 00       	mov    $0x0,%edx
  801000:	eb 2b                	jmp    80102d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801002:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801005:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  801009:	eb 22                	jmp    80102d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80100b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80100e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  801012:	eb 19                	jmp    80102d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801014:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801017:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80101e:	eb 0d                	jmp    80102d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801020:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801023:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801026:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80102d:	0f b6 0f             	movzbl (%edi),%ecx
  801030:	8d 47 01             	lea    0x1(%edi),%eax
  801033:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801036:	0f b6 07             	movzbl (%edi),%eax
  801039:	83 e8 23             	sub    $0x23,%eax
  80103c:	3c 55                	cmp    $0x55,%al
  80103e:	0f 87 40 03 00 00    	ja     801384 <vprintfmt+0x3d2>
  801044:	0f b6 c0             	movzbl %al,%eax
  801047:	ff 24 85 20 1f 80 00 	jmp    *0x801f20(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80104e:	83 e9 30             	sub    $0x30,%ecx
  801051:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  801054:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  801058:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80105b:	83 f9 09             	cmp    $0x9,%ecx
  80105e:	77 57                	ja     8010b7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801060:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801063:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801066:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801069:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80106c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80106f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801073:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  801076:	8d 48 d0             	lea    -0x30(%eax),%ecx
  801079:	83 f9 09             	cmp    $0x9,%ecx
  80107c:	76 eb                	jbe    801069 <vprintfmt+0xb7>
  80107e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801081:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801084:	eb 34                	jmp    8010ba <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801086:	8b 45 14             	mov    0x14(%ebp),%eax
  801089:	8d 48 04             	lea    0x4(%eax),%ecx
  80108c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80108f:	8b 00                	mov    (%eax),%eax
  801091:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801094:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801097:	eb 21                	jmp    8010ba <vprintfmt+0x108>

		case '.':
			if (width < 0)
  801099:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80109d:	0f 88 71 ff ff ff    	js     801014 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010a3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010a6:	eb 85                	jmp    80102d <vprintfmt+0x7b>
  8010a8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8010ab:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8010b2:	e9 76 ff ff ff       	jmp    80102d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010b7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8010ba:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8010be:	0f 89 69 ff ff ff    	jns    80102d <vprintfmt+0x7b>
  8010c4:	e9 57 ff ff ff       	jmp    801020 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8010c9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010cc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8010cf:	e9 59 ff ff ff       	jmp    80102d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8010d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8010d7:	8d 50 04             	lea    0x4(%eax),%edx
  8010da:	89 55 14             	mov    %edx,0x14(%ebp)
  8010dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010e1:	8b 00                	mov    (%eax),%eax
  8010e3:	89 04 24             	mov    %eax,(%esp)
  8010e6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010e8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8010eb:	e9 e7 fe ff ff       	jmp    800fd7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8010f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8010f3:	8d 50 04             	lea    0x4(%eax),%edx
  8010f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8010f9:	8b 00                	mov    (%eax),%eax
  8010fb:	89 c2                	mov    %eax,%edx
  8010fd:	c1 fa 1f             	sar    $0x1f,%edx
  801100:	31 d0                	xor    %edx,%eax
  801102:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801104:	83 f8 0f             	cmp    $0xf,%eax
  801107:	7f 0b                	jg     801114 <vprintfmt+0x162>
  801109:	8b 14 85 80 20 80 00 	mov    0x802080(,%eax,4),%edx
  801110:	85 d2                	test   %edx,%edx
  801112:	75 20                	jne    801134 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  801114:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801118:	c7 44 24 08 eb 1d 80 	movl   $0x801deb,0x8(%esp)
  80111f:	00 
  801120:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801124:	89 34 24             	mov    %esi,(%esp)
  801127:	e8 5e fe ff ff       	call   800f8a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80112c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80112f:	e9 a3 fe ff ff       	jmp    800fd7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  801134:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801138:	c7 44 24 08 f4 1d 80 	movl   $0x801df4,0x8(%esp)
  80113f:	00 
  801140:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801144:	89 34 24             	mov    %esi,(%esp)
  801147:	e8 3e fe ff ff       	call   800f8a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80114c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80114f:	e9 83 fe ff ff       	jmp    800fd7 <vprintfmt+0x25>
  801154:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801157:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80115a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80115d:	8b 45 14             	mov    0x14(%ebp),%eax
  801160:	8d 50 04             	lea    0x4(%eax),%edx
  801163:	89 55 14             	mov    %edx,0x14(%ebp)
  801166:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801168:	85 ff                	test   %edi,%edi
  80116a:	b8 e4 1d 80 00       	mov    $0x801de4,%eax
  80116f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801172:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  801176:	74 06                	je     80117e <vprintfmt+0x1cc>
  801178:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80117c:	7f 16                	jg     801194 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80117e:	0f b6 17             	movzbl (%edi),%edx
  801181:	0f be c2             	movsbl %dl,%eax
  801184:	83 c7 01             	add    $0x1,%edi
  801187:	85 c0                	test   %eax,%eax
  801189:	0f 85 9f 00 00 00    	jne    80122e <vprintfmt+0x27c>
  80118f:	e9 8b 00 00 00       	jmp    80121f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801194:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801198:	89 3c 24             	mov    %edi,(%esp)
  80119b:	e8 c2 02 00 00       	call   801462 <strnlen>
  8011a0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8011a3:	29 c2                	sub    %eax,%edx
  8011a5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8011a8:	85 d2                	test   %edx,%edx
  8011aa:	7e d2                	jle    80117e <vprintfmt+0x1cc>
					putch(padc, putdat);
  8011ac:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8011b0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8011b3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8011b6:	89 d7                	mov    %edx,%edi
  8011b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011bf:	89 04 24             	mov    %eax,(%esp)
  8011c2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011c4:	83 ef 01             	sub    $0x1,%edi
  8011c7:	75 ef                	jne    8011b8 <vprintfmt+0x206>
  8011c9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8011cc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8011cf:	eb ad                	jmp    80117e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8011d1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8011d5:	74 20                	je     8011f7 <vprintfmt+0x245>
  8011d7:	0f be d2             	movsbl %dl,%edx
  8011da:	83 ea 20             	sub    $0x20,%edx
  8011dd:	83 fa 5e             	cmp    $0x5e,%edx
  8011e0:	76 15                	jbe    8011f7 <vprintfmt+0x245>
					putch('?', putdat);
  8011e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8011e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011e9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8011f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8011f3:	ff d1                	call   *%ecx
  8011f5:	eb 0f                	jmp    801206 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  8011f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8011fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011fe:	89 04 24             	mov    %eax,(%esp)
  801201:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801204:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801206:	83 eb 01             	sub    $0x1,%ebx
  801209:	0f b6 17             	movzbl (%edi),%edx
  80120c:	0f be c2             	movsbl %dl,%eax
  80120f:	83 c7 01             	add    $0x1,%edi
  801212:	85 c0                	test   %eax,%eax
  801214:	75 24                	jne    80123a <vprintfmt+0x288>
  801216:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801219:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80121c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80121f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801222:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801226:	0f 8e ab fd ff ff    	jle    800fd7 <vprintfmt+0x25>
  80122c:	eb 20                	jmp    80124e <vprintfmt+0x29c>
  80122e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801231:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801234:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801237:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80123a:	85 f6                	test   %esi,%esi
  80123c:	78 93                	js     8011d1 <vprintfmt+0x21f>
  80123e:	83 ee 01             	sub    $0x1,%esi
  801241:	79 8e                	jns    8011d1 <vprintfmt+0x21f>
  801243:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801246:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801249:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80124c:	eb d1                	jmp    80121f <vprintfmt+0x26d>
  80124e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801251:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801255:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80125c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80125e:	83 ef 01             	sub    $0x1,%edi
  801261:	75 ee                	jne    801251 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801263:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801266:	e9 6c fd ff ff       	jmp    800fd7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80126b:	83 fa 01             	cmp    $0x1,%edx
  80126e:	66 90                	xchg   %ax,%ax
  801270:	7e 16                	jle    801288 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  801272:	8b 45 14             	mov    0x14(%ebp),%eax
  801275:	8d 50 08             	lea    0x8(%eax),%edx
  801278:	89 55 14             	mov    %edx,0x14(%ebp)
  80127b:	8b 10                	mov    (%eax),%edx
  80127d:	8b 48 04             	mov    0x4(%eax),%ecx
  801280:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801283:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801286:	eb 32                	jmp    8012ba <vprintfmt+0x308>
	else if (lflag)
  801288:	85 d2                	test   %edx,%edx
  80128a:	74 18                	je     8012a4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80128c:	8b 45 14             	mov    0x14(%ebp),%eax
  80128f:	8d 50 04             	lea    0x4(%eax),%edx
  801292:	89 55 14             	mov    %edx,0x14(%ebp)
  801295:	8b 00                	mov    (%eax),%eax
  801297:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80129a:	89 c1                	mov    %eax,%ecx
  80129c:	c1 f9 1f             	sar    $0x1f,%ecx
  80129f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8012a2:	eb 16                	jmp    8012ba <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8012a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a7:	8d 50 04             	lea    0x4(%eax),%edx
  8012aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8012ad:	8b 00                	mov    (%eax),%eax
  8012af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012b2:	89 c7                	mov    %eax,%edi
  8012b4:	c1 ff 1f             	sar    $0x1f,%edi
  8012b7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8012ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012bd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8012c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8012c5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8012c9:	79 7d                	jns    801348 <vprintfmt+0x396>
				putch('-', putdat);
  8012cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012cf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8012d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8012d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8012de:	f7 d8                	neg    %eax
  8012e0:	83 d2 00             	adc    $0x0,%edx
  8012e3:	f7 da                	neg    %edx
			}
			base = 10;
  8012e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8012ea:	eb 5c                	jmp    801348 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8012ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8012ef:	e8 3f fc ff ff       	call   800f33 <getuint>
			base = 10;
  8012f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8012f9:	eb 4d                	jmp    801348 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8012fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8012fe:	e8 30 fc ff ff       	call   800f33 <getuint>
			base = 8;
  801303:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801308:	eb 3e                	jmp    801348 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80130a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80130e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801315:	ff d6                	call   *%esi
			putch('x', putdat);
  801317:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80131b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801322:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801324:	8b 45 14             	mov    0x14(%ebp),%eax
  801327:	8d 50 04             	lea    0x4(%eax),%edx
  80132a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80132d:	8b 00                	mov    (%eax),%eax
  80132f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801334:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801339:	eb 0d                	jmp    801348 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80133b:	8d 45 14             	lea    0x14(%ebp),%eax
  80133e:	e8 f0 fb ff ff       	call   800f33 <getuint>
			base = 16;
  801343:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801348:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80134c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801350:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801353:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801357:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80135b:	89 04 24             	mov    %eax,(%esp)
  80135e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801362:	89 da                	mov    %ebx,%edx
  801364:	89 f0                	mov    %esi,%eax
  801366:	e8 d5 fa ff ff       	call   800e40 <printnum>
			break;
  80136b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80136e:	e9 64 fc ff ff       	jmp    800fd7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801373:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801377:	89 0c 24             	mov    %ecx,(%esp)
  80137a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80137f:	e9 53 fc ff ff       	jmp    800fd7 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801384:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801388:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80138f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801391:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801395:	0f 84 3c fc ff ff    	je     800fd7 <vprintfmt+0x25>
  80139b:	83 ef 01             	sub    $0x1,%edi
  80139e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8013a2:	75 f7                	jne    80139b <vprintfmt+0x3e9>
  8013a4:	e9 2e fc ff ff       	jmp    800fd7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8013a9:	83 c4 4c             	add    $0x4c,%esp
  8013ac:	5b                   	pop    %ebx
  8013ad:	5e                   	pop    %esi
  8013ae:	5f                   	pop    %edi
  8013af:	5d                   	pop    %ebp
  8013b0:	c3                   	ret    

008013b1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	83 ec 28             	sub    $0x28,%esp
  8013b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8013bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8013c0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8013c4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8013c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8013ce:	85 d2                	test   %edx,%edx
  8013d0:	7e 30                	jle    801402 <vsnprintf+0x51>
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	74 2c                	je     801402 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8013d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8013e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8013e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013eb:	c7 04 24 6d 0f 80 00 	movl   $0x800f6d,(%esp)
  8013f2:	e8 bb fb ff ff       	call   800fb2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8013f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8013fa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8013fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801400:	eb 05                	jmp    801407 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801407:	c9                   	leave  
  801408:	c3                   	ret    

00801409 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80140f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801412:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801416:	8b 45 10             	mov    0x10(%ebp),%eax
  801419:	89 44 24 08          	mov    %eax,0x8(%esp)
  80141d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801420:	89 44 24 04          	mov    %eax,0x4(%esp)
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	89 04 24             	mov    %eax,(%esp)
  80142a:	e8 82 ff ff ff       	call   8013b1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    
  801431:	66 90                	xchg   %ax,%ax
  801433:	66 90                	xchg   %ax,%ax
  801435:	66 90                	xchg   %ax,%ax
  801437:	66 90                	xchg   %ax,%ax
  801439:	66 90                	xchg   %ax,%ax
  80143b:	66 90                	xchg   %ax,%ax
  80143d:	66 90                	xchg   %ax,%ax
  80143f:	90                   	nop

00801440 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801446:	80 3a 00             	cmpb   $0x0,(%edx)
  801449:	74 10                	je     80145b <strlen+0x1b>
  80144b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801450:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801453:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801457:	75 f7                	jne    801450 <strlen+0x10>
  801459:	eb 05                	jmp    801460 <strlen+0x20>
  80145b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    

00801462 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	53                   	push   %ebx
  801466:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801469:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80146c:	85 c9                	test   %ecx,%ecx
  80146e:	74 1c                	je     80148c <strnlen+0x2a>
  801470:	80 3b 00             	cmpb   $0x0,(%ebx)
  801473:	74 1e                	je     801493 <strnlen+0x31>
  801475:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80147a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80147c:	39 ca                	cmp    %ecx,%edx
  80147e:	74 18                	je     801498 <strnlen+0x36>
  801480:	83 c2 01             	add    $0x1,%edx
  801483:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  801488:	75 f0                	jne    80147a <strnlen+0x18>
  80148a:	eb 0c                	jmp    801498 <strnlen+0x36>
  80148c:	b8 00 00 00 00       	mov    $0x0,%eax
  801491:	eb 05                	jmp    801498 <strnlen+0x36>
  801493:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801498:	5b                   	pop    %ebx
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    

0080149b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	53                   	push   %ebx
  80149f:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8014a5:	89 c2                	mov    %eax,%edx
  8014a7:	0f b6 19             	movzbl (%ecx),%ebx
  8014aa:	88 1a                	mov    %bl,(%edx)
  8014ac:	83 c2 01             	add    $0x1,%edx
  8014af:	83 c1 01             	add    $0x1,%ecx
  8014b2:	84 db                	test   %bl,%bl
  8014b4:	75 f1                	jne    8014a7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8014b6:	5b                   	pop    %ebx
  8014b7:	5d                   	pop    %ebp
  8014b8:	c3                   	ret    

008014b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	53                   	push   %ebx
  8014bd:	83 ec 08             	sub    $0x8,%esp
  8014c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8014c3:	89 1c 24             	mov    %ebx,(%esp)
  8014c6:	e8 75 ff ff ff       	call   801440 <strlen>
	strcpy(dst + len, src);
  8014cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014d2:	01 d8                	add    %ebx,%eax
  8014d4:	89 04 24             	mov    %eax,(%esp)
  8014d7:	e8 bf ff ff ff       	call   80149b <strcpy>
	return dst;
}
  8014dc:	89 d8                	mov    %ebx,%eax
  8014de:	83 c4 08             	add    $0x8,%esp
  8014e1:	5b                   	pop    %ebx
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    

008014e4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	56                   	push   %esi
  8014e8:	53                   	push   %ebx
  8014e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8014f2:	85 db                	test   %ebx,%ebx
  8014f4:	74 16                	je     80150c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  8014f6:	01 f3                	add    %esi,%ebx
  8014f8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8014fa:	0f b6 02             	movzbl (%edx),%eax
  8014fd:	88 01                	mov    %al,(%ecx)
  8014ff:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801502:	80 3a 01             	cmpb   $0x1,(%edx)
  801505:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801508:	39 d9                	cmp    %ebx,%ecx
  80150a:	75 ee                	jne    8014fa <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80150c:	89 f0                	mov    %esi,%eax
  80150e:	5b                   	pop    %ebx
  80150f:	5e                   	pop    %esi
  801510:	5d                   	pop    %ebp
  801511:	c3                   	ret    

00801512 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	57                   	push   %edi
  801516:	56                   	push   %esi
  801517:	53                   	push   %ebx
  801518:	8b 7d 08             	mov    0x8(%ebp),%edi
  80151b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80151e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801521:	89 f8                	mov    %edi,%eax
  801523:	85 f6                	test   %esi,%esi
  801525:	74 33                	je     80155a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  801527:	83 fe 01             	cmp    $0x1,%esi
  80152a:	74 25                	je     801551 <strlcpy+0x3f>
  80152c:	0f b6 0b             	movzbl (%ebx),%ecx
  80152f:	84 c9                	test   %cl,%cl
  801531:	74 22                	je     801555 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801533:	83 ee 02             	sub    $0x2,%esi
  801536:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80153b:	88 08                	mov    %cl,(%eax)
  80153d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801540:	39 f2                	cmp    %esi,%edx
  801542:	74 13                	je     801557 <strlcpy+0x45>
  801544:	83 c2 01             	add    $0x1,%edx
  801547:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80154b:	84 c9                	test   %cl,%cl
  80154d:	75 ec                	jne    80153b <strlcpy+0x29>
  80154f:	eb 06                	jmp    801557 <strlcpy+0x45>
  801551:	89 f8                	mov    %edi,%eax
  801553:	eb 02                	jmp    801557 <strlcpy+0x45>
  801555:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801557:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80155a:	29 f8                	sub    %edi,%eax
}
  80155c:	5b                   	pop    %ebx
  80155d:	5e                   	pop    %esi
  80155e:	5f                   	pop    %edi
  80155f:	5d                   	pop    %ebp
  801560:	c3                   	ret    

00801561 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801567:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80156a:	0f b6 01             	movzbl (%ecx),%eax
  80156d:	84 c0                	test   %al,%al
  80156f:	74 15                	je     801586 <strcmp+0x25>
  801571:	3a 02                	cmp    (%edx),%al
  801573:	75 11                	jne    801586 <strcmp+0x25>
		p++, q++;
  801575:	83 c1 01             	add    $0x1,%ecx
  801578:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80157b:	0f b6 01             	movzbl (%ecx),%eax
  80157e:	84 c0                	test   %al,%al
  801580:	74 04                	je     801586 <strcmp+0x25>
  801582:	3a 02                	cmp    (%edx),%al
  801584:	74 ef                	je     801575 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801586:	0f b6 c0             	movzbl %al,%eax
  801589:	0f b6 12             	movzbl (%edx),%edx
  80158c:	29 d0                	sub    %edx,%eax
}
  80158e:	5d                   	pop    %ebp
  80158f:	c3                   	ret    

00801590 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	56                   	push   %esi
  801594:	53                   	push   %ebx
  801595:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801598:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80159e:	85 f6                	test   %esi,%esi
  8015a0:	74 29                	je     8015cb <strncmp+0x3b>
  8015a2:	0f b6 03             	movzbl (%ebx),%eax
  8015a5:	84 c0                	test   %al,%al
  8015a7:	74 30                	je     8015d9 <strncmp+0x49>
  8015a9:	3a 02                	cmp    (%edx),%al
  8015ab:	75 2c                	jne    8015d9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8015ad:	8d 43 01             	lea    0x1(%ebx),%eax
  8015b0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8015b2:	89 c3                	mov    %eax,%ebx
  8015b4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8015b7:	39 f0                	cmp    %esi,%eax
  8015b9:	74 17                	je     8015d2 <strncmp+0x42>
  8015bb:	0f b6 08             	movzbl (%eax),%ecx
  8015be:	84 c9                	test   %cl,%cl
  8015c0:	74 17                	je     8015d9 <strncmp+0x49>
  8015c2:	83 c0 01             	add    $0x1,%eax
  8015c5:	3a 0a                	cmp    (%edx),%cl
  8015c7:	74 e9                	je     8015b2 <strncmp+0x22>
  8015c9:	eb 0e                	jmp    8015d9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8015cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d0:	eb 0f                	jmp    8015e1 <strncmp+0x51>
  8015d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d7:	eb 08                	jmp    8015e1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8015d9:	0f b6 03             	movzbl (%ebx),%eax
  8015dc:	0f b6 12             	movzbl (%edx),%edx
  8015df:	29 d0                	sub    %edx,%eax
}
  8015e1:	5b                   	pop    %ebx
  8015e2:	5e                   	pop    %esi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	53                   	push   %ebx
  8015e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8015ef:	0f b6 18             	movzbl (%eax),%ebx
  8015f2:	84 db                	test   %bl,%bl
  8015f4:	74 1d                	je     801613 <strchr+0x2e>
  8015f6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8015f8:	38 d3                	cmp    %dl,%bl
  8015fa:	75 06                	jne    801602 <strchr+0x1d>
  8015fc:	eb 1a                	jmp    801618 <strchr+0x33>
  8015fe:	38 ca                	cmp    %cl,%dl
  801600:	74 16                	je     801618 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801602:	83 c0 01             	add    $0x1,%eax
  801605:	0f b6 10             	movzbl (%eax),%edx
  801608:	84 d2                	test   %dl,%dl
  80160a:	75 f2                	jne    8015fe <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  80160c:	b8 00 00 00 00       	mov    $0x0,%eax
  801611:	eb 05                	jmp    801618 <strchr+0x33>
  801613:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801618:	5b                   	pop    %ebx
  801619:	5d                   	pop    %ebp
  80161a:	c3                   	ret    

0080161b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	53                   	push   %ebx
  80161f:	8b 45 08             	mov    0x8(%ebp),%eax
  801622:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801625:	0f b6 18             	movzbl (%eax),%ebx
  801628:	84 db                	test   %bl,%bl
  80162a:	74 16                	je     801642 <strfind+0x27>
  80162c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80162e:	38 d3                	cmp    %dl,%bl
  801630:	75 06                	jne    801638 <strfind+0x1d>
  801632:	eb 0e                	jmp    801642 <strfind+0x27>
  801634:	38 ca                	cmp    %cl,%dl
  801636:	74 0a                	je     801642 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801638:	83 c0 01             	add    $0x1,%eax
  80163b:	0f b6 10             	movzbl (%eax),%edx
  80163e:	84 d2                	test   %dl,%dl
  801640:	75 f2                	jne    801634 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  801642:	5b                   	pop    %ebx
  801643:	5d                   	pop    %ebp
  801644:	c3                   	ret    

00801645 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80164e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801651:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801654:	8b 7d 08             	mov    0x8(%ebp),%edi
  801657:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80165a:	85 c9                	test   %ecx,%ecx
  80165c:	74 36                	je     801694 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80165e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801664:	75 28                	jne    80168e <memset+0x49>
  801666:	f6 c1 03             	test   $0x3,%cl
  801669:	75 23                	jne    80168e <memset+0x49>
		c &= 0xFF;
  80166b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80166f:	89 d3                	mov    %edx,%ebx
  801671:	c1 e3 08             	shl    $0x8,%ebx
  801674:	89 d6                	mov    %edx,%esi
  801676:	c1 e6 18             	shl    $0x18,%esi
  801679:	89 d0                	mov    %edx,%eax
  80167b:	c1 e0 10             	shl    $0x10,%eax
  80167e:	09 f0                	or     %esi,%eax
  801680:	09 c2                	or     %eax,%edx
  801682:	89 d0                	mov    %edx,%eax
  801684:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801686:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801689:	fc                   	cld    
  80168a:	f3 ab                	rep stos %eax,%es:(%edi)
  80168c:	eb 06                	jmp    801694 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80168e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801691:	fc                   	cld    
  801692:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  801694:	89 f8                	mov    %edi,%eax
  801696:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801699:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80169c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80169f:	89 ec                	mov    %ebp,%esp
  8016a1:	5d                   	pop    %ebp
  8016a2:	c3                   	ret    

008016a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8016af:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8016b8:	39 c6                	cmp    %eax,%esi
  8016ba:	73 36                	jae    8016f2 <memmove+0x4f>
  8016bc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8016bf:	39 d0                	cmp    %edx,%eax
  8016c1:	73 2f                	jae    8016f2 <memmove+0x4f>
		s += n;
		d += n;
  8016c3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8016c6:	f6 c2 03             	test   $0x3,%dl
  8016c9:	75 1b                	jne    8016e6 <memmove+0x43>
  8016cb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8016d1:	75 13                	jne    8016e6 <memmove+0x43>
  8016d3:	f6 c1 03             	test   $0x3,%cl
  8016d6:	75 0e                	jne    8016e6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8016d8:	83 ef 04             	sub    $0x4,%edi
  8016db:	8d 72 fc             	lea    -0x4(%edx),%esi
  8016de:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8016e1:	fd                   	std    
  8016e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8016e4:	eb 09                	jmp    8016ef <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8016e6:	83 ef 01             	sub    $0x1,%edi
  8016e9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8016ec:	fd                   	std    
  8016ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8016ef:	fc                   	cld    
  8016f0:	eb 20                	jmp    801712 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8016f2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8016f8:	75 13                	jne    80170d <memmove+0x6a>
  8016fa:	a8 03                	test   $0x3,%al
  8016fc:	75 0f                	jne    80170d <memmove+0x6a>
  8016fe:	f6 c1 03             	test   $0x3,%cl
  801701:	75 0a                	jne    80170d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801703:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801706:	89 c7                	mov    %eax,%edi
  801708:	fc                   	cld    
  801709:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80170b:	eb 05                	jmp    801712 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80170d:	89 c7                	mov    %eax,%edi
  80170f:	fc                   	cld    
  801710:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801712:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801715:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801718:	89 ec                	mov    %ebp,%esp
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801722:	8b 45 10             	mov    0x10(%ebp),%eax
  801725:	89 44 24 08          	mov    %eax,0x8(%esp)
  801729:	8b 45 0c             	mov    0xc(%ebp),%eax
  80172c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801730:	8b 45 08             	mov    0x8(%ebp),%eax
  801733:	89 04 24             	mov    %eax,(%esp)
  801736:	e8 68 ff ff ff       	call   8016a3 <memmove>
}
  80173b:	c9                   	leave  
  80173c:	c3                   	ret    

0080173d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	57                   	push   %edi
  801741:	56                   	push   %esi
  801742:	53                   	push   %ebx
  801743:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801746:	8b 75 0c             	mov    0xc(%ebp),%esi
  801749:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80174c:	8d 78 ff             	lea    -0x1(%eax),%edi
  80174f:	85 c0                	test   %eax,%eax
  801751:	74 36                	je     801789 <memcmp+0x4c>
		if (*s1 != *s2)
  801753:	0f b6 03             	movzbl (%ebx),%eax
  801756:	0f b6 0e             	movzbl (%esi),%ecx
  801759:	38 c8                	cmp    %cl,%al
  80175b:	75 17                	jne    801774 <memcmp+0x37>
  80175d:	ba 00 00 00 00       	mov    $0x0,%edx
  801762:	eb 1a                	jmp    80177e <memcmp+0x41>
  801764:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801769:	83 c2 01             	add    $0x1,%edx
  80176c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801770:	38 c8                	cmp    %cl,%al
  801772:	74 0a                	je     80177e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801774:	0f b6 c0             	movzbl %al,%eax
  801777:	0f b6 c9             	movzbl %cl,%ecx
  80177a:	29 c8                	sub    %ecx,%eax
  80177c:	eb 10                	jmp    80178e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80177e:	39 fa                	cmp    %edi,%edx
  801780:	75 e2                	jne    801764 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801782:	b8 00 00 00 00       	mov    $0x0,%eax
  801787:	eb 05                	jmp    80178e <memcmp+0x51>
  801789:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80178e:	5b                   	pop    %ebx
  80178f:	5e                   	pop    %esi
  801790:	5f                   	pop    %edi
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    

00801793 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	53                   	push   %ebx
  801797:	8b 45 08             	mov    0x8(%ebp),%eax
  80179a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  80179d:	89 c2                	mov    %eax,%edx
  80179f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8017a2:	39 d0                	cmp    %edx,%eax
  8017a4:	73 13                	jae    8017b9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  8017a6:	89 d9                	mov    %ebx,%ecx
  8017a8:	38 18                	cmp    %bl,(%eax)
  8017aa:	75 06                	jne    8017b2 <memfind+0x1f>
  8017ac:	eb 0b                	jmp    8017b9 <memfind+0x26>
  8017ae:	38 08                	cmp    %cl,(%eax)
  8017b0:	74 07                	je     8017b9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8017b2:	83 c0 01             	add    $0x1,%eax
  8017b5:	39 d0                	cmp    %edx,%eax
  8017b7:	75 f5                	jne    8017ae <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8017b9:	5b                   	pop    %ebx
  8017ba:	5d                   	pop    %ebp
  8017bb:	c3                   	ret    

008017bc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	57                   	push   %edi
  8017c0:	56                   	push   %esi
  8017c1:	53                   	push   %ebx
  8017c2:	83 ec 04             	sub    $0x4,%esp
  8017c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8017cb:	0f b6 02             	movzbl (%edx),%eax
  8017ce:	3c 09                	cmp    $0x9,%al
  8017d0:	74 04                	je     8017d6 <strtol+0x1a>
  8017d2:	3c 20                	cmp    $0x20,%al
  8017d4:	75 0e                	jne    8017e4 <strtol+0x28>
		s++;
  8017d6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8017d9:	0f b6 02             	movzbl (%edx),%eax
  8017dc:	3c 09                	cmp    $0x9,%al
  8017de:	74 f6                	je     8017d6 <strtol+0x1a>
  8017e0:	3c 20                	cmp    $0x20,%al
  8017e2:	74 f2                	je     8017d6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8017e4:	3c 2b                	cmp    $0x2b,%al
  8017e6:	75 0a                	jne    8017f2 <strtol+0x36>
		s++;
  8017e8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8017eb:	bf 00 00 00 00       	mov    $0x0,%edi
  8017f0:	eb 10                	jmp    801802 <strtol+0x46>
  8017f2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8017f7:	3c 2d                	cmp    $0x2d,%al
  8017f9:	75 07                	jne    801802 <strtol+0x46>
		s++, neg = 1;
  8017fb:	83 c2 01             	add    $0x1,%edx
  8017fe:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801802:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801808:	75 15                	jne    80181f <strtol+0x63>
  80180a:	80 3a 30             	cmpb   $0x30,(%edx)
  80180d:	75 10                	jne    80181f <strtol+0x63>
  80180f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801813:	75 0a                	jne    80181f <strtol+0x63>
		s += 2, base = 16;
  801815:	83 c2 02             	add    $0x2,%edx
  801818:	bb 10 00 00 00       	mov    $0x10,%ebx
  80181d:	eb 10                	jmp    80182f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  80181f:	85 db                	test   %ebx,%ebx
  801821:	75 0c                	jne    80182f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801823:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801825:	80 3a 30             	cmpb   $0x30,(%edx)
  801828:	75 05                	jne    80182f <strtol+0x73>
		s++, base = 8;
  80182a:	83 c2 01             	add    $0x1,%edx
  80182d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80182f:	b8 00 00 00 00       	mov    $0x0,%eax
  801834:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801837:	0f b6 0a             	movzbl (%edx),%ecx
  80183a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80183d:	89 f3                	mov    %esi,%ebx
  80183f:	80 fb 09             	cmp    $0x9,%bl
  801842:	77 08                	ja     80184c <strtol+0x90>
			dig = *s - '0';
  801844:	0f be c9             	movsbl %cl,%ecx
  801847:	83 e9 30             	sub    $0x30,%ecx
  80184a:	eb 22                	jmp    80186e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  80184c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80184f:	89 f3                	mov    %esi,%ebx
  801851:	80 fb 19             	cmp    $0x19,%bl
  801854:	77 08                	ja     80185e <strtol+0xa2>
			dig = *s - 'a' + 10;
  801856:	0f be c9             	movsbl %cl,%ecx
  801859:	83 e9 57             	sub    $0x57,%ecx
  80185c:	eb 10                	jmp    80186e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  80185e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801861:	89 f3                	mov    %esi,%ebx
  801863:	80 fb 19             	cmp    $0x19,%bl
  801866:	77 16                	ja     80187e <strtol+0xc2>
			dig = *s - 'A' + 10;
  801868:	0f be c9             	movsbl %cl,%ecx
  80186b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80186e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801871:	7d 0f                	jge    801882 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801873:	83 c2 01             	add    $0x1,%edx
  801876:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  80187a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80187c:	eb b9                	jmp    801837 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80187e:	89 c1                	mov    %eax,%ecx
  801880:	eb 02                	jmp    801884 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801882:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801884:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801888:	74 05                	je     80188f <strtol+0xd3>
		*endptr = (char *) s;
  80188a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80188d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80188f:	89 ca                	mov    %ecx,%edx
  801891:	f7 da                	neg    %edx
  801893:	85 ff                	test   %edi,%edi
  801895:	0f 45 c2             	cmovne %edx,%eax
}
  801898:	83 c4 04             	add    $0x4,%esp
  80189b:	5b                   	pop    %ebx
  80189c:	5e                   	pop    %esi
  80189d:	5f                   	pop    %edi
  80189e:	5d                   	pop    %ebp
  80189f:	c3                   	ret    

008018a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	56                   	push   %esi
  8018a4:	53                   	push   %ebx
  8018a5:	83 ec 10             	sub    $0x10,%esp
  8018a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8018ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  8018ae:	85 db                	test   %ebx,%ebx
  8018b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8018b5:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  8018b8:	89 1c 24             	mov    %ebx,(%esp)
  8018bb:	e8 ed eb ff ff       	call   8004ad <sys_ipc_recv>
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 2d                	js     8018f1 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  8018c4:	85 f6                	test   %esi,%esi
  8018c6:	74 0a                	je     8018d2 <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  8018c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8018cd:	8b 40 74             	mov    0x74(%eax),%eax
  8018d0:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  8018d2:	85 db                	test   %ebx,%ebx
  8018d4:	74 13                	je     8018e9 <ipc_recv+0x49>
  8018d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018da:	74 0d                	je     8018e9 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  8018dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e1:	8b 40 78             	mov    0x78(%eax),%eax
  8018e4:	8b 55 10             	mov    0x10(%ebp),%edx
  8018e7:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  8018e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8018ee:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5e                   	pop    %esi
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    

008018f8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	57                   	push   %edi
  8018fc:	56                   	push   %esi
  8018fd:	53                   	push   %ebx
  8018fe:	83 ec 1c             	sub    $0x1c,%esp
  801901:	8b 7d 08             	mov    0x8(%ebp),%edi
  801904:	8b 75 0c             	mov    0xc(%ebp),%esi
  801907:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  80190a:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  80190c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801911:	0f 44 d8             	cmove  %eax,%ebx
  801914:	eb 2a                	jmp    801940 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  801916:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801919:	74 20                	je     80193b <ipc_send+0x43>
            panic("Send message error %e\n",r);
  80191b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80191f:	c7 44 24 08 e0 20 80 	movl   $0x8020e0,0x8(%esp)
  801926:	00 
  801927:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80192e:	00 
  80192f:	c7 04 24 f7 20 80 00 	movl   $0x8020f7,(%esp)
  801936:	e8 e5 f3 ff ff       	call   800d20 <_panic>
		sys_yield();
  80193b:	e8 8c e8 ff ff       	call   8001cc <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801940:	8b 45 14             	mov    0x14(%ebp),%eax
  801943:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801947:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80194b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80194f:	89 3c 24             	mov    %edi,(%esp)
  801952:	e8 19 eb ff ff       	call   800470 <sys_ipc_try_send>
  801957:	85 c0                	test   %eax,%eax
  801959:	78 bb                	js     801916 <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  80195b:	83 c4 1c             	add    $0x1c,%esp
  80195e:	5b                   	pop    %ebx
  80195f:	5e                   	pop    %esi
  801960:	5f                   	pop    %edi
  801961:	5d                   	pop    %ebp
  801962:	c3                   	ret    

00801963 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801969:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80196e:	39 c8                	cmp    %ecx,%eax
  801970:	74 17                	je     801989 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801972:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801977:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80197a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801980:	8b 52 50             	mov    0x50(%edx),%edx
  801983:	39 ca                	cmp    %ecx,%edx
  801985:	75 14                	jne    80199b <ipc_find_env+0x38>
  801987:	eb 05                	jmp    80198e <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801989:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80198e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801991:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801996:	8b 40 40             	mov    0x40(%eax),%eax
  801999:	eb 0e                	jmp    8019a9 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80199b:	83 c0 01             	add    $0x1,%eax
  80199e:	3d 00 04 00 00       	cmp    $0x400,%eax
  8019a3:	75 d2                	jne    801977 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8019a5:	66 b8 00 00          	mov    $0x0,%ax
}
  8019a9:	5d                   	pop    %ebp
  8019aa:	c3                   	ret    
  8019ab:	66 90                	xchg   %ax,%ax
  8019ad:	66 90                	xchg   %ax,%ax
  8019af:	90                   	nop

008019b0 <__udivdi3>:
  8019b0:	83 ec 1c             	sub    $0x1c,%esp
  8019b3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8019b7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8019bb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8019bf:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8019c3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8019c7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	89 74 24 10          	mov    %esi,0x10(%esp)
  8019d1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8019d5:	89 ea                	mov    %ebp,%edx
  8019d7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019db:	75 33                	jne    801a10 <__udivdi3+0x60>
  8019dd:	39 e9                	cmp    %ebp,%ecx
  8019df:	77 6f                	ja     801a50 <__udivdi3+0xa0>
  8019e1:	85 c9                	test   %ecx,%ecx
  8019e3:	89 ce                	mov    %ecx,%esi
  8019e5:	75 0b                	jne    8019f2 <__udivdi3+0x42>
  8019e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ec:	31 d2                	xor    %edx,%edx
  8019ee:	f7 f1                	div    %ecx
  8019f0:	89 c6                	mov    %eax,%esi
  8019f2:	31 d2                	xor    %edx,%edx
  8019f4:	89 e8                	mov    %ebp,%eax
  8019f6:	f7 f6                	div    %esi
  8019f8:	89 c5                	mov    %eax,%ebp
  8019fa:	89 f8                	mov    %edi,%eax
  8019fc:	f7 f6                	div    %esi
  8019fe:	89 ea                	mov    %ebp,%edx
  801a00:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a04:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a08:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a0c:	83 c4 1c             	add    $0x1c,%esp
  801a0f:	c3                   	ret    
  801a10:	39 e8                	cmp    %ebp,%eax
  801a12:	77 24                	ja     801a38 <__udivdi3+0x88>
  801a14:	0f bd c8             	bsr    %eax,%ecx
  801a17:	83 f1 1f             	xor    $0x1f,%ecx
  801a1a:	89 0c 24             	mov    %ecx,(%esp)
  801a1d:	75 49                	jne    801a68 <__udivdi3+0xb8>
  801a1f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801a23:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801a27:	0f 86 ab 00 00 00    	jbe    801ad8 <__udivdi3+0x128>
  801a2d:	39 e8                	cmp    %ebp,%eax
  801a2f:	0f 82 a3 00 00 00    	jb     801ad8 <__udivdi3+0x128>
  801a35:	8d 76 00             	lea    0x0(%esi),%esi
  801a38:	31 d2                	xor    %edx,%edx
  801a3a:	31 c0                	xor    %eax,%eax
  801a3c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a40:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a44:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a48:	83 c4 1c             	add    $0x1c,%esp
  801a4b:	c3                   	ret    
  801a4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a50:	89 f8                	mov    %edi,%eax
  801a52:	f7 f1                	div    %ecx
  801a54:	31 d2                	xor    %edx,%edx
  801a56:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a5a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a5e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a62:	83 c4 1c             	add    $0x1c,%esp
  801a65:	c3                   	ret    
  801a66:	66 90                	xchg   %ax,%ax
  801a68:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a6c:	89 c6                	mov    %eax,%esi
  801a6e:	b8 20 00 00 00       	mov    $0x20,%eax
  801a73:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801a77:	2b 04 24             	sub    (%esp),%eax
  801a7a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801a7e:	d3 e6                	shl    %cl,%esi
  801a80:	89 c1                	mov    %eax,%ecx
  801a82:	d3 ed                	shr    %cl,%ebp
  801a84:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a88:	09 f5                	or     %esi,%ebp
  801a8a:	8b 74 24 04          	mov    0x4(%esp),%esi
  801a8e:	d3 e6                	shl    %cl,%esi
  801a90:	89 c1                	mov    %eax,%ecx
  801a92:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a96:	89 d6                	mov    %edx,%esi
  801a98:	d3 ee                	shr    %cl,%esi
  801a9a:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a9e:	d3 e2                	shl    %cl,%edx
  801aa0:	89 c1                	mov    %eax,%ecx
  801aa2:	d3 ef                	shr    %cl,%edi
  801aa4:	09 d7                	or     %edx,%edi
  801aa6:	89 f2                	mov    %esi,%edx
  801aa8:	89 f8                	mov    %edi,%eax
  801aaa:	f7 f5                	div    %ebp
  801aac:	89 d6                	mov    %edx,%esi
  801aae:	89 c7                	mov    %eax,%edi
  801ab0:	f7 64 24 04          	mull   0x4(%esp)
  801ab4:	39 d6                	cmp    %edx,%esi
  801ab6:	72 30                	jb     801ae8 <__udivdi3+0x138>
  801ab8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801abc:	0f b6 0c 24          	movzbl (%esp),%ecx
  801ac0:	d3 e5                	shl    %cl,%ebp
  801ac2:	39 c5                	cmp    %eax,%ebp
  801ac4:	73 04                	jae    801aca <__udivdi3+0x11a>
  801ac6:	39 d6                	cmp    %edx,%esi
  801ac8:	74 1e                	je     801ae8 <__udivdi3+0x138>
  801aca:	89 f8                	mov    %edi,%eax
  801acc:	31 d2                	xor    %edx,%edx
  801ace:	e9 69 ff ff ff       	jmp    801a3c <__udivdi3+0x8c>
  801ad3:	90                   	nop
  801ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ad8:	31 d2                	xor    %edx,%edx
  801ada:	b8 01 00 00 00       	mov    $0x1,%eax
  801adf:	e9 58 ff ff ff       	jmp    801a3c <__udivdi3+0x8c>
  801ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ae8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801aeb:	31 d2                	xor    %edx,%edx
  801aed:	8b 74 24 10          	mov    0x10(%esp),%esi
  801af1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801af5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801af9:	83 c4 1c             	add    $0x1c,%esp
  801afc:	c3                   	ret    
  801afd:	66 90                	xchg   %ax,%ax
  801aff:	90                   	nop

00801b00 <__umoddi3>:
  801b00:	83 ec 2c             	sub    $0x2c,%esp
  801b03:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b07:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801b0b:	89 74 24 20          	mov    %esi,0x20(%esp)
  801b0f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801b13:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801b17:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	89 c2                	mov    %eax,%edx
  801b1f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801b23:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801b27:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b2b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801b2f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b33:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801b37:	75 1f                	jne    801b58 <__umoddi3+0x58>
  801b39:	39 fe                	cmp    %edi,%esi
  801b3b:	76 63                	jbe    801ba0 <__umoddi3+0xa0>
  801b3d:	89 c8                	mov    %ecx,%eax
  801b3f:	89 fa                	mov    %edi,%edx
  801b41:	f7 f6                	div    %esi
  801b43:	89 d0                	mov    %edx,%eax
  801b45:	31 d2                	xor    %edx,%edx
  801b47:	8b 74 24 20          	mov    0x20(%esp),%esi
  801b4b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801b4f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801b53:	83 c4 2c             	add    $0x2c,%esp
  801b56:	c3                   	ret    
  801b57:	90                   	nop
  801b58:	39 f8                	cmp    %edi,%eax
  801b5a:	77 64                	ja     801bc0 <__umoddi3+0xc0>
  801b5c:	0f bd e8             	bsr    %eax,%ebp
  801b5f:	83 f5 1f             	xor    $0x1f,%ebp
  801b62:	75 74                	jne    801bd8 <__umoddi3+0xd8>
  801b64:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b68:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801b6c:	0f 87 0e 01 00 00    	ja     801c80 <__umoddi3+0x180>
  801b72:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801b76:	29 f1                	sub    %esi,%ecx
  801b78:	19 c7                	sbb    %eax,%edi
  801b7a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b7e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801b82:	8b 44 24 14          	mov    0x14(%esp),%eax
  801b86:	8b 54 24 18          	mov    0x18(%esp),%edx
  801b8a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801b8e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801b92:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801b96:	83 c4 2c             	add    $0x2c,%esp
  801b99:	c3                   	ret    
  801b9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ba0:	85 f6                	test   %esi,%esi
  801ba2:	89 f5                	mov    %esi,%ebp
  801ba4:	75 0b                	jne    801bb1 <__umoddi3+0xb1>
  801ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bab:	31 d2                	xor    %edx,%edx
  801bad:	f7 f6                	div    %esi
  801baf:	89 c5                	mov    %eax,%ebp
  801bb1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801bb5:	31 d2                	xor    %edx,%edx
  801bb7:	f7 f5                	div    %ebp
  801bb9:	89 c8                	mov    %ecx,%eax
  801bbb:	f7 f5                	div    %ebp
  801bbd:	eb 84                	jmp    801b43 <__umoddi3+0x43>
  801bbf:	90                   	nop
  801bc0:	89 c8                	mov    %ecx,%eax
  801bc2:	89 fa                	mov    %edi,%edx
  801bc4:	8b 74 24 20          	mov    0x20(%esp),%esi
  801bc8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801bcc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801bd0:	83 c4 2c             	add    $0x2c,%esp
  801bd3:	c3                   	ret    
  801bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bd8:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bdc:	be 20 00 00 00       	mov    $0x20,%esi
  801be1:	89 e9                	mov    %ebp,%ecx
  801be3:	29 ee                	sub    %ebp,%esi
  801be5:	d3 e2                	shl    %cl,%edx
  801be7:	89 f1                	mov    %esi,%ecx
  801be9:	d3 e8                	shr    %cl,%eax
  801beb:	89 e9                	mov    %ebp,%ecx
  801bed:	09 d0                	or     %edx,%eax
  801bef:	89 fa                	mov    %edi,%edx
  801bf1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bf5:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bf9:	d3 e0                	shl    %cl,%eax
  801bfb:	89 f1                	mov    %esi,%ecx
  801bfd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c01:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801c05:	d3 ea                	shr    %cl,%edx
  801c07:	89 e9                	mov    %ebp,%ecx
  801c09:	d3 e7                	shl    %cl,%edi
  801c0b:	89 f1                	mov    %esi,%ecx
  801c0d:	d3 e8                	shr    %cl,%eax
  801c0f:	89 e9                	mov    %ebp,%ecx
  801c11:	09 f8                	or     %edi,%eax
  801c13:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801c17:	f7 74 24 0c          	divl   0xc(%esp)
  801c1b:	d3 e7                	shl    %cl,%edi
  801c1d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c21:	89 d7                	mov    %edx,%edi
  801c23:	f7 64 24 10          	mull   0x10(%esp)
  801c27:	39 d7                	cmp    %edx,%edi
  801c29:	89 c1                	mov    %eax,%ecx
  801c2b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801c2f:	72 3b                	jb     801c6c <__umoddi3+0x16c>
  801c31:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801c35:	72 31                	jb     801c68 <__umoddi3+0x168>
  801c37:	8b 44 24 18          	mov    0x18(%esp),%eax
  801c3b:	29 c8                	sub    %ecx,%eax
  801c3d:	19 d7                	sbb    %edx,%edi
  801c3f:	89 e9                	mov    %ebp,%ecx
  801c41:	89 fa                	mov    %edi,%edx
  801c43:	d3 e8                	shr    %cl,%eax
  801c45:	89 f1                	mov    %esi,%ecx
  801c47:	d3 e2                	shl    %cl,%edx
  801c49:	89 e9                	mov    %ebp,%ecx
  801c4b:	09 d0                	or     %edx,%eax
  801c4d:	89 fa                	mov    %edi,%edx
  801c4f:	d3 ea                	shr    %cl,%edx
  801c51:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c55:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c59:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c5d:	83 c4 2c             	add    $0x2c,%esp
  801c60:	c3                   	ret    
  801c61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c68:	39 d7                	cmp    %edx,%edi
  801c6a:	75 cb                	jne    801c37 <__umoddi3+0x137>
  801c6c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801c70:	89 c1                	mov    %eax,%ecx
  801c72:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801c76:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801c7a:	eb bb                	jmp    801c37 <__umoddi3+0x137>
  801c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c80:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801c84:	0f 82 e8 fe ff ff    	jb     801b72 <__umoddi3+0x72>
  801c8a:	e9 f3 fe ff ff       	jmp    801b82 <__umoddi3+0x82>
