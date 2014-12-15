
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 30 80 00 80 	movl   $0x801c80,0x803000
  800041:	1c 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 7f 01 00 00       	call   8001c8 <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
  80004b:	90                   	nop

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	83 ec 18             	sub    $0x18,%esp
  800052:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800055:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  80005e:	e8 2c 01 00 00       	call   80018f <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x34>
		binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800080:	89 74 24 04          	mov    %esi,0x4(%esp)
  800084:	89 1c 24             	mov    %ebx,(%esp)
  800087:	e8 a8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008c:	e8 0b 00 00 00       	call   80009c <exit>
}
  800091:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800094:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800097:	89 ec                	mov    %ebp,%esp
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
  80009b:	90                   	nop

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000a2:	e8 6c 06 00 00       	call   800713 <close_all>
	sys_env_destroy(0);
  8000a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ae:	e8 76 00 00 00       	call   800129 <sys_env_destroy>
}
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    
  8000b5:	66 90                	xchg   %ax,%ax
  8000b7:	90                   	nop

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c4:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	0f a2                	cpuid  
  8000ce:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	89 c3                	mov    %eax,%ebx
  8000dd:	89 c7                	mov    %eax,%edi
  8000df:	89 c6                	mov    %eax,%esi
  8000e1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000e6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000ec:	89 ec                	mov    %ebp,%esp
  8000ee:	5d                   	pop    %ebp
  8000ef:	c3                   	ret    

008000f0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 0c             	sub    $0xc,%esp
  8000f6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000fc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8000ff:	b8 01 00 00 00       	mov    $0x1,%eax
  800104:	0f a2                	cpuid  
  800106:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800108:	ba 00 00 00 00       	mov    $0x0,%edx
  80010d:	b8 01 00 00 00       	mov    $0x1,%eax
  800112:	89 d1                	mov    %edx,%ecx
  800114:	89 d3                	mov    %edx,%ebx
  800116:	89 d7                	mov    %edx,%edi
  800118:	89 d6                	mov    %edx,%esi
  80011a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80011c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80011f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800122:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800125:	89 ec                	mov    %ebp,%esp
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 38             	sub    $0x38,%esp
  80012f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800132:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800135:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800138:	b8 01 00 00 00       	mov    $0x1,%eax
  80013d:	0f a2                	cpuid  
  80013f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	b9 00 00 00 00       	mov    $0x0,%ecx
  800146:	b8 03 00 00 00       	mov    $0x3,%eax
  80014b:	8b 55 08             	mov    0x8(%ebp),%edx
  80014e:	89 cb                	mov    %ecx,%ebx
  800150:	89 cf                	mov    %ecx,%edi
  800152:	89 ce                	mov    %ecx,%esi
  800154:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800156:	85 c0                	test   %eax,%eax
  800158:	7e 28                	jle    800182 <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  80015a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80015e:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800165:	00 
  800166:	c7 44 24 08 8f 1c 80 	movl   $0x801c8f,0x8(%esp)
  80016d:	00 
  80016e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800175:	00 
  800176:	c7 04 24 ac 1c 80 00 	movl   $0x801cac,(%esp)
  80017d:	e8 8e 0b 00 00       	call   800d10 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800182:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800185:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800188:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80018b:	89 ec                	mov    %ebp,%esp
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    

0080018f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800198:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80019b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80019e:	b8 01 00 00 00       	mov    $0x1,%eax
  8001a3:	0f a2                	cpuid  
  8001a5:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8001b1:	89 d1                	mov    %edx,%ecx
  8001b3:	89 d3                	mov    %edx,%ebx
  8001b5:	89 d7                	mov    %edx,%edi
  8001b7:	89 d6                	mov    %edx,%esi
  8001b9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001bb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001be:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001c4:	89 ec                	mov    %ebp,%esp
  8001c6:	5d                   	pop    %ebp
  8001c7:	c3                   	ret    

008001c8 <sys_yield>:

void
sys_yield(void)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	83 ec 0c             	sub    $0xc,%esp
  8001ce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001d4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8001d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8001dc:	0f a2                	cpuid  
  8001de:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001e5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ea:	89 d1                	mov    %edx,%ecx
  8001ec:	89 d3                	mov    %edx,%ebx
  8001ee:	89 d7                	mov    %edx,%edi
  8001f0:	89 d6                	mov    %edx,%esi
  8001f2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001f4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001f7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001fa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001fd:	89 ec                	mov    %ebp,%esp
  8001ff:	5d                   	pop    %ebp
  800200:	c3                   	ret    

00800201 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	83 ec 38             	sub    $0x38,%esp
  800207:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80020a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80020d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800210:	b8 01 00 00 00       	mov    $0x1,%eax
  800215:	0f a2                	cpuid  
  800217:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800219:	be 00 00 00 00       	mov    $0x0,%esi
  80021e:	b8 04 00 00 00       	mov    $0x4,%eax
  800223:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800226:	8b 55 08             	mov    0x8(%ebp),%edx
  800229:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80022c:	89 f7                	mov    %esi,%edi
  80022e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800230:	85 c0                	test   %eax,%eax
  800232:	7e 28                	jle    80025c <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800234:	89 44 24 10          	mov    %eax,0x10(%esp)
  800238:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80023f:	00 
  800240:	c7 44 24 08 8f 1c 80 	movl   $0x801c8f,0x8(%esp)
  800247:	00 
  800248:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80024f:	00 
  800250:	c7 04 24 ac 1c 80 00 	movl   $0x801cac,(%esp)
  800257:	e8 b4 0a 00 00       	call   800d10 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80025c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80025f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800262:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800265:	89 ec                	mov    %ebp,%esp
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    

00800269 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	83 ec 38             	sub    $0x38,%esp
  80026f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800272:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800275:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800278:	b8 01 00 00 00       	mov    $0x1,%eax
  80027d:	0f a2                	cpuid  
  80027f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800281:	b8 05 00 00 00       	mov    $0x5,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80028f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800292:	8b 75 18             	mov    0x18(%ebp),%esi
  800295:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800297:	85 c0                	test   %eax,%eax
  800299:	7e 28                	jle    8002c3 <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029f:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8002a6:	00 
  8002a7:	c7 44 24 08 8f 1c 80 	movl   $0x801c8f,0x8(%esp)
  8002ae:	00 
  8002af:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8002b6:	00 
  8002b7:	c7 04 24 ac 1c 80 00 	movl   $0x801cac,(%esp)
  8002be:	e8 4d 0a 00 00       	call   800d10 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002c3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002c6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002cc:	89 ec                	mov    %ebp,%esp
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	83 ec 38             	sub    $0x38,%esp
  8002d6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002d9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002dc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8002df:	b8 01 00 00 00       	mov    $0x1,%eax
  8002e4:	0f a2                	cpuid  
  8002e6:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	89 df                	mov    %ebx,%edi
  8002fa:	89 de                	mov    %ebx,%esi
  8002fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002fe:	85 c0                	test   %eax,%eax
  800300:	7e 28                	jle    80032a <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800302:	89 44 24 10          	mov    %eax,0x10(%esp)
  800306:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80030d:	00 
  80030e:	c7 44 24 08 8f 1c 80 	movl   $0x801c8f,0x8(%esp)
  800315:	00 
  800316:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80031d:	00 
  80031e:	c7 04 24 ac 1c 80 00 	movl   $0x801cac,(%esp)
  800325:	e8 e6 09 00 00       	call   800d10 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80032a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80032d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800330:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800333:	89 ec                	mov    %ebp,%esp
  800335:	5d                   	pop    %ebp
  800336:	c3                   	ret    

00800337 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	83 ec 38             	sub    $0x38,%esp
  80033d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800340:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800343:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800346:	b8 01 00 00 00       	mov    $0x1,%eax
  80034b:	0f a2                	cpuid  
  80034d:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800354:	b8 08 00 00 00       	mov    $0x8,%eax
  800359:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80035c:	8b 55 08             	mov    0x8(%ebp),%edx
  80035f:	89 df                	mov    %ebx,%edi
  800361:	89 de                	mov    %ebx,%esi
  800363:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800365:	85 c0                	test   %eax,%eax
  800367:	7e 28                	jle    800391 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800369:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800374:	00 
  800375:	c7 44 24 08 8f 1c 80 	movl   $0x801c8f,0x8(%esp)
  80037c:	00 
  80037d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800384:	00 
  800385:	c7 04 24 ac 1c 80 00 	movl   $0x801cac,(%esp)
  80038c:	e8 7f 09 00 00       	call   800d10 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800391:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800394:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800397:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80039a:	89 ec                	mov    %ebp,%esp
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 38             	sub    $0x38,%esp
  8003a4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003a7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003aa:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8003ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8003b2:	0f a2                	cpuid  
  8003b4:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003bb:	b8 09 00 00 00       	mov    $0x9,%eax
  8003c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c6:	89 df                	mov    %ebx,%edi
  8003c8:	89 de                	mov    %ebx,%esi
  8003ca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003cc:	85 c0                	test   %eax,%eax
  8003ce:	7e 28                	jle    8003f8 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003d4:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003db:	00 
  8003dc:	c7 44 24 08 8f 1c 80 	movl   $0x801c8f,0x8(%esp)
  8003e3:	00 
  8003e4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8003eb:	00 
  8003ec:	c7 04 24 ac 1c 80 00 	movl   $0x801cac,(%esp)
  8003f3:	e8 18 09 00 00       	call   800d10 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8003f8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003fb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003fe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800401:	89 ec                	mov    %ebp,%esp
  800403:	5d                   	pop    %ebp
  800404:	c3                   	ret    

00800405 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	83 ec 38             	sub    $0x38,%esp
  80040b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80040e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800411:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800414:	b8 01 00 00 00       	mov    $0x1,%eax
  800419:	0f a2                	cpuid  
  80041b:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80041d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800422:	b8 0a 00 00 00       	mov    $0xa,%eax
  800427:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042a:	8b 55 08             	mov    0x8(%ebp),%edx
  80042d:	89 df                	mov    %ebx,%edi
  80042f:	89 de                	mov    %ebx,%esi
  800431:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800433:	85 c0                	test   %eax,%eax
  800435:	7e 28                	jle    80045f <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800437:	89 44 24 10          	mov    %eax,0x10(%esp)
  80043b:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800442:	00 
  800443:	c7 44 24 08 8f 1c 80 	movl   $0x801c8f,0x8(%esp)
  80044a:	00 
  80044b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800452:	00 
  800453:	c7 04 24 ac 1c 80 00 	movl   $0x801cac,(%esp)
  80045a:	e8 b1 08 00 00       	call   800d10 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80045f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800462:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800465:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800468:	89 ec                	mov    %ebp,%esp
  80046a:	5d                   	pop    %ebp
  80046b:	c3                   	ret    

0080046c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	83 ec 0c             	sub    $0xc,%esp
  800472:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800475:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800478:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80047b:	b8 01 00 00 00       	mov    $0x1,%eax
  800480:	0f a2                	cpuid  
  800482:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800484:	be 00 00 00 00       	mov    $0x0,%esi
  800489:	b8 0c 00 00 00       	mov    $0xc,%eax
  80048e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800491:	8b 55 08             	mov    0x8(%ebp),%edx
  800494:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800497:	8b 7d 14             	mov    0x14(%ebp),%edi
  80049a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80049c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80049f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8004a2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004a5:	89 ec                	mov    %ebp,%esp
  8004a7:	5d                   	pop    %ebp
  8004a8:	c3                   	ret    

008004a9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
  8004ac:	83 ec 38             	sub    $0x38,%esp
  8004af:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8004b2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8004b5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8004b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8004bd:	0f a2                	cpuid  
  8004bf:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8004cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ce:	89 cb                	mov    %ecx,%ebx
  8004d0:	89 cf                	mov    %ecx,%edi
  8004d2:	89 ce                	mov    %ecx,%esi
  8004d4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8004d6:	85 c0                	test   %eax,%eax
  8004d8:	7e 28                	jle    800502 <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004da:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004de:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8004e5:	00 
  8004e6:	c7 44 24 08 8f 1c 80 	movl   $0x801c8f,0x8(%esp)
  8004ed:	00 
  8004ee:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8004f5:	00 
  8004f6:	c7 04 24 ac 1c 80 00 	movl   $0x801cac,(%esp)
  8004fd:	e8 0e 08 00 00       	call   800d10 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800502:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800505:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800508:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80050b:	89 ec                	mov    %ebp,%esp
  80050d:	5d                   	pop    %ebp
  80050e:	c3                   	ret    
  80050f:	90                   	nop

00800510 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800513:	8b 45 08             	mov    0x8(%ebp),%eax
  800516:	05 00 00 00 30       	add    $0x30000000,%eax
  80051b:	c1 e8 0c             	shr    $0xc,%eax
}
  80051e:	5d                   	pop    %ebp
  80051f:	c3                   	ret    

00800520 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800526:	8b 45 08             	mov    0x8(%ebp),%eax
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	e8 df ff ff ff       	call   800510 <fd2num>
  800531:	c1 e0 0c             	shl    $0xc,%eax
  800534:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800539:	c9                   	leave  
  80053a:	c3                   	ret    

0080053b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80053e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800543:	a8 01                	test   $0x1,%al
  800545:	74 34                	je     80057b <fd_alloc+0x40>
  800547:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80054c:	a8 01                	test   $0x1,%al
  80054e:	74 32                	je     800582 <fd_alloc+0x47>
  800550:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800555:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800557:	89 c2                	mov    %eax,%edx
  800559:	c1 ea 16             	shr    $0x16,%edx
  80055c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800563:	f6 c2 01             	test   $0x1,%dl
  800566:	74 1f                	je     800587 <fd_alloc+0x4c>
  800568:	89 c2                	mov    %eax,%edx
  80056a:	c1 ea 0c             	shr    $0xc,%edx
  80056d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800574:	f6 c2 01             	test   $0x1,%dl
  800577:	75 1a                	jne    800593 <fd_alloc+0x58>
  800579:	eb 0c                	jmp    800587 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80057b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800580:	eb 05                	jmp    800587 <fd_alloc+0x4c>
  800582:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800587:	8b 45 08             	mov    0x8(%ebp),%eax
  80058a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80058c:	b8 00 00 00 00       	mov    $0x0,%eax
  800591:	eb 1a                	jmp    8005ad <fd_alloc+0x72>
  800593:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800598:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80059d:	75 b6                	jne    800555 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80059f:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8005a8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8005ad:	5d                   	pop    %ebp
  8005ae:	c3                   	ret    

008005af <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8005af:	55                   	push   %ebp
  8005b0:	89 e5                	mov    %esp,%ebp
  8005b2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8005b5:	83 f8 1f             	cmp    $0x1f,%eax
  8005b8:	77 36                	ja     8005f0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8005ba:	c1 e0 0c             	shl    $0xc,%eax
  8005bd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8005c2:	89 c2                	mov    %eax,%edx
  8005c4:	c1 ea 16             	shr    $0x16,%edx
  8005c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8005ce:	f6 c2 01             	test   $0x1,%dl
  8005d1:	74 24                	je     8005f7 <fd_lookup+0x48>
  8005d3:	89 c2                	mov    %eax,%edx
  8005d5:	c1 ea 0c             	shr    $0xc,%edx
  8005d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005df:	f6 c2 01             	test   $0x1,%dl
  8005e2:	74 1a                	je     8005fe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8005e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e7:	89 02                	mov    %eax,(%edx)
	return 0;
  8005e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ee:	eb 13                	jmp    800603 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8005f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8005f5:	eb 0c                	jmp    800603 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8005f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8005fc:	eb 05                	jmp    800603 <fd_lookup+0x54>
  8005fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800603:	5d                   	pop    %ebp
  800604:	c3                   	ret    

00800605 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800605:	55                   	push   %ebp
  800606:	89 e5                	mov    %esp,%ebp
  800608:	83 ec 18             	sub    $0x18,%esp
  80060b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80060e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  800614:	75 10                	jne    800626 <dev_lookup+0x21>
			*dev = devtab[i];
  800616:	8b 45 0c             	mov    0xc(%ebp),%eax
  800619:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80061f:	b8 00 00 00 00       	mov    $0x0,%eax
  800624:	eb 2b                	jmp    800651 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800626:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80062c:	8b 52 48             	mov    0x48(%edx),%edx
  80062f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800633:	89 54 24 04          	mov    %edx,0x4(%esp)
  800637:	c7 04 24 bc 1c 80 00 	movl   $0x801cbc,(%esp)
  80063e:	e8 c8 07 00 00       	call   800e0b <cprintf>
	*dev = 0;
  800643:	8b 55 0c             	mov    0xc(%ebp),%edx
  800646:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80064c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800651:	c9                   	leave  
  800652:	c3                   	ret    

00800653 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
  800656:	83 ec 38             	sub    $0x38,%esp
  800659:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80065c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80065f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800662:	8b 7d 08             	mov    0x8(%ebp),%edi
  800665:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800668:	89 3c 24             	mov    %edi,(%esp)
  80066b:	e8 a0 fe ff ff       	call   800510 <fd2num>
  800670:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800673:	89 54 24 04          	mov    %edx,0x4(%esp)
  800677:	89 04 24             	mov    %eax,(%esp)
  80067a:	e8 30 ff ff ff       	call   8005af <fd_lookup>
  80067f:	89 c3                	mov    %eax,%ebx
  800681:	85 c0                	test   %eax,%eax
  800683:	78 05                	js     80068a <fd_close+0x37>
	    || fd != fd2)
  800685:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800688:	74 0c                	je     800696 <fd_close+0x43>
		return (must_exist ? r : 0);
  80068a:	85 f6                	test   %esi,%esi
  80068c:	b8 00 00 00 00       	mov    $0x0,%eax
  800691:	0f 44 d8             	cmove  %eax,%ebx
  800694:	eb 3d                	jmp    8006d3 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800696:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069d:	8b 07                	mov    (%edi),%eax
  80069f:	89 04 24             	mov    %eax,(%esp)
  8006a2:	e8 5e ff ff ff       	call   800605 <dev_lookup>
  8006a7:	89 c3                	mov    %eax,%ebx
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	78 16                	js     8006c3 <fd_close+0x70>
		if (dev->dev_close)
  8006ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006b0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8006b3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 07                	je     8006c3 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  8006bc:	89 3c 24             	mov    %edi,(%esp)
  8006bf:	ff d0                	call   *%eax
  8006c1:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8006c3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ce:	e8 fd fb ff ff       	call   8002d0 <sys_page_unmap>
	return r;
}
  8006d3:	89 d8                	mov    %ebx,%eax
  8006d5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8006d8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8006db:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8006de:	89 ec                	mov    %ebp,%esp
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    

008006e2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8006e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f2:	89 04 24             	mov    %eax,(%esp)
  8006f5:	e8 b5 fe ff ff       	call   8005af <fd_lookup>
  8006fa:	85 c0                	test   %eax,%eax
  8006fc:	78 13                	js     800711 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8006fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800705:	00 
  800706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800709:	89 04 24             	mov    %eax,(%esp)
  80070c:	e8 42 ff ff ff       	call   800653 <fd_close>
}
  800711:	c9                   	leave  
  800712:	c3                   	ret    

00800713 <close_all>:

void
close_all(void)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	53                   	push   %ebx
  800717:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80071a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80071f:	89 1c 24             	mov    %ebx,(%esp)
  800722:	e8 bb ff ff ff       	call   8006e2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800727:	83 c3 01             	add    $0x1,%ebx
  80072a:	83 fb 20             	cmp    $0x20,%ebx
  80072d:	75 f0                	jne    80071f <close_all+0xc>
		close(i);
}
  80072f:	83 c4 14             	add    $0x14,%esp
  800732:	5b                   	pop    %ebx
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 58             	sub    $0x58,%esp
  80073b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80073e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800741:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800744:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800747:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80074a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	89 04 24             	mov    %eax,(%esp)
  800754:	e8 56 fe ff ff       	call   8005af <fd_lookup>
  800759:	85 c0                	test   %eax,%eax
  80075b:	0f 88 e3 00 00 00    	js     800844 <dup+0x10f>
		return r;
	close(newfdnum);
  800761:	89 1c 24             	mov    %ebx,(%esp)
  800764:	e8 79 ff ff ff       	call   8006e2 <close>

	newfd = INDEX2FD(newfdnum);
  800769:	89 de                	mov    %ebx,%esi
  80076b:	c1 e6 0c             	shl    $0xc,%esi
  80076e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800777:	89 04 24             	mov    %eax,(%esp)
  80077a:	e8 a1 fd ff ff       	call   800520 <fd2data>
  80077f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800781:	89 34 24             	mov    %esi,(%esp)
  800784:	e8 97 fd ff ff       	call   800520 <fd2data>
  800789:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80078c:	89 f8                	mov    %edi,%eax
  80078e:	c1 e8 16             	shr    $0x16,%eax
  800791:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800798:	a8 01                	test   $0x1,%al
  80079a:	74 46                	je     8007e2 <dup+0xad>
  80079c:	89 f8                	mov    %edi,%eax
  80079e:	c1 e8 0c             	shr    $0xc,%eax
  8007a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8007a8:	f6 c2 01             	test   $0x1,%dl
  8007ab:	74 35                	je     8007e2 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8007ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8007b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8007b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8007cb:	00 
  8007cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007d7:	e8 8d fa ff ff       	call   800269 <sys_page_map>
  8007dc:	89 c7                	mov    %eax,%edi
  8007de:	85 c0                	test   %eax,%eax
  8007e0:	78 3b                	js     80081d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8007e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007e5:	89 c2                	mov    %eax,%edx
  8007e7:	c1 ea 0c             	shr    $0xc,%edx
  8007ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007f1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8007f7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007fb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800806:	00 
  800807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800812:	e8 52 fa ff ff       	call   800269 <sys_page_map>
  800817:	89 c7                	mov    %eax,%edi
  800819:	85 c0                	test   %eax,%eax
  80081b:	79 29                	jns    800846 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80081d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800821:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800828:	e8 a3 fa ff ff       	call   8002d0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80082d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800830:	89 44 24 04          	mov    %eax,0x4(%esp)
  800834:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80083b:	e8 90 fa ff ff       	call   8002d0 <sys_page_unmap>
	return r;
  800840:	89 fb                	mov    %edi,%ebx
  800842:	eb 02                	jmp    800846 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  800844:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800846:	89 d8                	mov    %ebx,%eax
  800848:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80084b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80084e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800851:	89 ec                	mov    %ebp,%esp
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	83 ec 24             	sub    $0x24,%esp
  80085c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80085f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800862:	89 44 24 04          	mov    %eax,0x4(%esp)
  800866:	89 1c 24             	mov    %ebx,(%esp)
  800869:	e8 41 fd ff ff       	call   8005af <fd_lookup>
  80086e:	85 c0                	test   %eax,%eax
  800870:	78 6d                	js     8008df <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800872:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800875:	89 44 24 04          	mov    %eax,0x4(%esp)
  800879:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80087c:	8b 00                	mov    (%eax),%eax
  80087e:	89 04 24             	mov    %eax,(%esp)
  800881:	e8 7f fd ff ff       	call   800605 <dev_lookup>
  800886:	85 c0                	test   %eax,%eax
  800888:	78 55                	js     8008df <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80088a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088d:	8b 50 08             	mov    0x8(%eax),%edx
  800890:	83 e2 03             	and    $0x3,%edx
  800893:	83 fa 01             	cmp    $0x1,%edx
  800896:	75 23                	jne    8008bb <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800898:	a1 04 40 80 00       	mov    0x804004,%eax
  80089d:	8b 40 48             	mov    0x48(%eax),%eax
  8008a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a8:	c7 04 24 fd 1c 80 00 	movl   $0x801cfd,(%esp)
  8008af:	e8 57 05 00 00       	call   800e0b <cprintf>
		return -E_INVAL;
  8008b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b9:	eb 24                	jmp    8008df <read+0x8a>
	}
	if (!dev->dev_read)
  8008bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008be:	8b 52 08             	mov    0x8(%edx),%edx
  8008c1:	85 d2                	test   %edx,%edx
  8008c3:	74 15                	je     8008da <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8008c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008d3:	89 04 24             	mov    %eax,(%esp)
  8008d6:	ff d2                	call   *%edx
  8008d8:	eb 05                	jmp    8008df <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8008da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8008df:	83 c4 24             	add    $0x24,%esp
  8008e2:	5b                   	pop    %ebx
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	57                   	push   %edi
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	83 ec 1c             	sub    $0x1c,%esp
  8008ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008f4:	85 f6                	test   %esi,%esi
  8008f6:	74 33                	je     80092b <readn+0x46>
  8008f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800902:	89 f2                	mov    %esi,%edx
  800904:	29 c2                	sub    %eax,%edx
  800906:	89 54 24 08          	mov    %edx,0x8(%esp)
  80090a:	03 45 0c             	add    0xc(%ebp),%eax
  80090d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800911:	89 3c 24             	mov    %edi,(%esp)
  800914:	e8 3c ff ff ff       	call   800855 <read>
		if (m < 0)
  800919:	85 c0                	test   %eax,%eax
  80091b:	78 17                	js     800934 <readn+0x4f>
			return m;
		if (m == 0)
  80091d:	85 c0                	test   %eax,%eax
  80091f:	74 11                	je     800932 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800921:	01 c3                	add    %eax,%ebx
  800923:	89 d8                	mov    %ebx,%eax
  800925:	39 f3                	cmp    %esi,%ebx
  800927:	72 d9                	jb     800902 <readn+0x1d>
  800929:	eb 09                	jmp    800934 <readn+0x4f>
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
  800930:	eb 02                	jmp    800934 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800932:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800934:	83 c4 1c             	add    $0x1c,%esp
  800937:	5b                   	pop    %ebx
  800938:	5e                   	pop    %esi
  800939:	5f                   	pop    %edi
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	53                   	push   %ebx
  800940:	83 ec 24             	sub    $0x24,%esp
  800943:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800946:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094d:	89 1c 24             	mov    %ebx,(%esp)
  800950:	e8 5a fc ff ff       	call   8005af <fd_lookup>
  800955:	85 c0                	test   %eax,%eax
  800957:	78 68                	js     8009c1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800959:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80095c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800960:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800963:	8b 00                	mov    (%eax),%eax
  800965:	89 04 24             	mov    %eax,(%esp)
  800968:	e8 98 fc ff ff       	call   800605 <dev_lookup>
  80096d:	85 c0                	test   %eax,%eax
  80096f:	78 50                	js     8009c1 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800971:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800974:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800978:	75 23                	jne    80099d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80097a:	a1 04 40 80 00       	mov    0x804004,%eax
  80097f:	8b 40 48             	mov    0x48(%eax),%eax
  800982:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800986:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098a:	c7 04 24 19 1d 80 00 	movl   $0x801d19,(%esp)
  800991:	e8 75 04 00 00       	call   800e0b <cprintf>
		return -E_INVAL;
  800996:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80099b:	eb 24                	jmp    8009c1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80099d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009a0:	8b 52 0c             	mov    0xc(%edx),%edx
  8009a3:	85 d2                	test   %edx,%edx
  8009a5:	74 15                	je     8009bc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8009a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009aa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009b5:	89 04 24             	mov    %eax,(%esp)
  8009b8:	ff d2                	call   *%edx
  8009ba:	eb 05                	jmp    8009c1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8009bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8009c1:	83 c4 24             	add    $0x24,%esp
  8009c4:	5b                   	pop    %ebx
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009cd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8009d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	89 04 24             	mov    %eax,(%esp)
  8009da:	e8 d0 fb ff ff       	call   8005af <fd_lookup>
  8009df:	85 c0                	test   %eax,%eax
  8009e1:	78 0e                	js     8009f1 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8009e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	53                   	push   %ebx
  8009f7:	83 ec 24             	sub    $0x24,%esp
  8009fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a04:	89 1c 24             	mov    %ebx,(%esp)
  800a07:	e8 a3 fb ff ff       	call   8005af <fd_lookup>
  800a0c:	85 c0                	test   %eax,%eax
  800a0e:	78 61                	js     800a71 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a1a:	8b 00                	mov    (%eax),%eax
  800a1c:	89 04 24             	mov    %eax,(%esp)
  800a1f:	e8 e1 fb ff ff       	call   800605 <dev_lookup>
  800a24:	85 c0                	test   %eax,%eax
  800a26:	78 49                	js     800a71 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a2b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a2f:	75 23                	jne    800a54 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800a31:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800a36:	8b 40 48             	mov    0x48(%eax),%eax
  800a39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a41:	c7 04 24 dc 1c 80 00 	movl   $0x801cdc,(%esp)
  800a48:	e8 be 03 00 00       	call   800e0b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800a4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a52:	eb 1d                	jmp    800a71 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800a54:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a57:	8b 52 18             	mov    0x18(%edx),%edx
  800a5a:	85 d2                	test   %edx,%edx
  800a5c:	74 0e                	je     800a6c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800a5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a61:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a65:	89 04 24             	mov    %eax,(%esp)
  800a68:	ff d2                	call   *%edx
  800a6a:	eb 05                	jmp    800a71 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800a6c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800a71:	83 c4 24             	add    $0x24,%esp
  800a74:	5b                   	pop    %ebx
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	53                   	push   %ebx
  800a7b:	83 ec 24             	sub    $0x24,%esp
  800a7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a81:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	89 04 24             	mov    %eax,(%esp)
  800a8e:	e8 1c fb ff ff       	call   8005af <fd_lookup>
  800a93:	85 c0                	test   %eax,%eax
  800a95:	78 52                	js     800ae9 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aa1:	8b 00                	mov    (%eax),%eax
  800aa3:	89 04 24             	mov    %eax,(%esp)
  800aa6:	e8 5a fb ff ff       	call   800605 <dev_lookup>
  800aab:	85 c0                	test   %eax,%eax
  800aad:	78 3a                	js     800ae9 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ab2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800ab6:	74 2c                	je     800ae4 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800ab8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800abb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ac2:	00 00 00 
	stat->st_isdir = 0;
  800ac5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800acc:	00 00 00 
	stat->st_dev = dev;
  800acf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800ad5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800adc:	89 14 24             	mov    %edx,(%esp)
  800adf:	ff 50 14             	call   *0x14(%eax)
  800ae2:	eb 05                	jmp    800ae9 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800ae4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800ae9:	83 c4 24             	add    $0x24,%esp
  800aec:	5b                   	pop    %ebx
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 18             	sub    $0x18,%esp
  800af5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800af8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800afb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800b02:	00 
  800b03:	8b 45 08             	mov    0x8(%ebp),%eax
  800b06:	89 04 24             	mov    %eax,(%esp)
  800b09:	e8 84 01 00 00       	call   800c92 <open>
  800b0e:	89 c3                	mov    %eax,%ebx
  800b10:	85 c0                	test   %eax,%eax
  800b12:	78 1b                	js     800b2f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800b14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b17:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1b:	89 1c 24             	mov    %ebx,(%esp)
  800b1e:	e8 54 ff ff ff       	call   800a77 <fstat>
  800b23:	89 c6                	mov    %eax,%esi
	close(fd);
  800b25:	89 1c 24             	mov    %ebx,(%esp)
  800b28:	e8 b5 fb ff ff       	call   8006e2 <close>
	return r;
  800b2d:	89 f3                	mov    %esi,%ebx
}
  800b2f:	89 d8                	mov    %ebx,%eax
  800b31:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b34:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b37:	89 ec                	mov    %ebp,%esp
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    
  800b3b:	90                   	nop

00800b3c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 18             	sub    $0x18,%esp
  800b42:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b45:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b48:	89 c6                	mov    %eax,%esi
  800b4a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800b4c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800b53:	75 11                	jne    800b66 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b55:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b5c:	e8 f2 0d 00 00       	call   801953 <ipc_find_env>
  800b61:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b66:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b6d:	00 
  800b6e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800b75:	00 
  800b76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b7a:	a1 00 40 80 00       	mov    0x804000,%eax
  800b7f:	89 04 24             	mov    %eax,(%esp)
  800b82:	e8 61 0d 00 00       	call   8018e8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800b87:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b8e:	00 
  800b8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b9a:	e8 f1 0c 00 00       	call   801890 <ipc_recv>
}
  800b9f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ba2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800ba5:	89 ec                	mov    %ebp,%esp
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	8b 40 0c             	mov    0xc(%eax),%eax
  800bb5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800bba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcc:	e8 6b ff ff ff       	call   800b3c <fsipc>
}
  800bd1:	c9                   	leave  
  800bd2:	c3                   	ret    

00800bd3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdc:	8b 40 0c             	mov    0xc(%eax),%eax
  800bdf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 06 00 00 00       	mov    $0x6,%eax
  800bee:	e8 49 ff ff ff       	call   800b3c <fsipc>
}
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 14             	sub    $0x14,%esp
  800bfc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800bff:	8b 45 08             	mov    0x8(%ebp),%eax
  800c02:	8b 40 0c             	mov    0xc(%eax),%eax
  800c05:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800c0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c14:	e8 23 ff ff ff       	call   800b3c <fsipc>
  800c19:	85 c0                	test   %eax,%eax
  800c1b:	78 2b                	js     800c48 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800c1d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c24:	00 
  800c25:	89 1c 24             	mov    %ebx,(%esp)
  800c28:	e8 5e 08 00 00       	call   80148b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800c2d:	a1 80 50 80 00       	mov    0x805080,%eax
  800c32:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800c38:	a1 84 50 80 00       	mov    0x805084,%eax
  800c3d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800c43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c48:	83 c4 14             	add    $0x14,%esp
  800c4b:	5b                   	pop    %ebx
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800c54:	c7 44 24 08 36 1d 80 	movl   $0x801d36,0x8(%esp)
  800c5b:	00 
  800c5c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  800c63:	00 
  800c64:	c7 04 24 54 1d 80 00 	movl   $0x801d54,(%esp)
  800c6b:	e8 a0 00 00 00       	call   800d10 <_panic>

00800c70 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  800c76:	c7 44 24 08 5f 1d 80 	movl   $0x801d5f,0x8(%esp)
  800c7d:	00 
  800c7e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  800c85:	00 
  800c86:	c7 04 24 54 1d 80 00 	movl   $0x801d54,(%esp)
  800c8d:	e8 7e 00 00 00       	call   800d10 <_panic>

00800c92 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  800c98:	c7 44 24 08 7c 1d 80 	movl   $0x801d7c,0x8(%esp)
  800c9f:	00 
  800ca0:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800ca7:	00 
  800ca8:	c7 04 24 54 1d 80 00 	movl   $0x801d54,(%esp)
  800caf:	e8 5c 00 00 00       	call   800d10 <_panic>

00800cb4 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 14             	sub    $0x14,%esp
  800cbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800cbe:	89 1c 24             	mov    %ebx,(%esp)
  800cc1:	e8 6a 07 00 00       	call   801430 <strlen>
  800cc6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ccb:	7f 21                	jg     800cee <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800ccd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cd1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cd8:	e8 ae 07 00 00       	call   80148b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800cdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce2:	b8 07 00 00 00       	mov    $0x7,%eax
  800ce7:	e8 50 fe ff ff       	call   800b3c <fsipc>
  800cec:	eb 05                	jmp    800cf3 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cee:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  800cf3:	83 c4 14             	add    $0x14,%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800cff:	ba 00 00 00 00       	mov    $0x0,%edx
  800d04:	b8 08 00 00 00       	mov    $0x8,%eax
  800d09:	e8 2e fe ff ff       	call   800b3c <fsipc>
}
  800d0e:	c9                   	leave  
  800d0f:	c3                   	ret    

00800d10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d18:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d1b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800d21:	e8 69 f4 ff ff       	call   80018f <sys_getenvid>
  800d26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d29:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d34:	89 74 24 08          	mov    %esi,0x8(%esp)
  800d38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d3c:	c7 04 24 94 1d 80 00 	movl   $0x801d94,(%esp)
  800d43:	e8 c3 00 00 00       	call   800e0b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d48:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4f:	89 04 24             	mov    %eax,(%esp)
  800d52:	e8 53 00 00 00       	call   800daa <vcprintf>
	cprintf("\n");
  800d57:	c7 04 24 d5 20 80 00 	movl   $0x8020d5,(%esp)
  800d5e:	e8 a8 00 00 00       	call   800e0b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d63:	cc                   	int3   
  800d64:	eb fd                	jmp    800d63 <_panic+0x53>
  800d66:	66 90                	xchg   %ax,%ax

00800d68 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 14             	sub    $0x14,%esp
  800d6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800d72:	8b 03                	mov    (%ebx),%eax
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800d7b:	83 c0 01             	add    $0x1,%eax
  800d7e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800d80:	3d ff 00 00 00       	cmp    $0xff,%eax
  800d85:	75 19                	jne    800da0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800d87:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800d8e:	00 
  800d8f:	8d 43 08             	lea    0x8(%ebx),%eax
  800d92:	89 04 24             	mov    %eax,(%esp)
  800d95:	e8 1e f3 ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  800d9a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800da0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800da4:	83 c4 14             	add    $0x14,%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800db3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800dba:	00 00 00 
	b.cnt = 0;
  800dbd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800dc4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dd5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ddb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ddf:	c7 04 24 68 0d 80 00 	movl   $0x800d68,(%esp)
  800de6:	e8 b7 01 00 00       	call   800fa2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800deb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800df1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800dfb:	89 04 24             	mov    %eax,(%esp)
  800dfe:	e8 b5 f2 ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  800e03:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800e09:	c9                   	leave  
  800e0a:	c3                   	ret    

00800e0b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800e11:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800e14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1b:	89 04 24             	mov    %eax,(%esp)
  800e1e:	e8 87 ff ff ff       	call   800daa <vcprintf>
	va_end(ap);

	return cnt;
}
  800e23:	c9                   	leave  
  800e24:	c3                   	ret    
  800e25:	66 90                	xchg   %ax,%ax
  800e27:	66 90                	xchg   %ax,%ax
  800e29:	66 90                	xchg   %ax,%ax
  800e2b:	66 90                	xchg   %ax,%ax
  800e2d:	66 90                	xchg   %ax,%ax
  800e2f:	90                   	nop

00800e30 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	57                   	push   %edi
  800e34:	56                   	push   %esi
  800e35:	53                   	push   %ebx
  800e36:	83 ec 4c             	sub    $0x4c,%esp
  800e39:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e3c:	89 d7                	mov    %edx,%edi
  800e3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e41:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800e44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e47:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800e4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4f:	39 d8                	cmp    %ebx,%eax
  800e51:	72 17                	jb     800e6a <printnum+0x3a>
  800e53:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800e56:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800e59:	76 0f                	jbe    800e6a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800e5b:	8b 75 14             	mov    0x14(%ebp),%esi
  800e5e:	83 ee 01             	sub    $0x1,%esi
  800e61:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800e64:	85 f6                	test   %esi,%esi
  800e66:	7f 63                	jg     800ecb <printnum+0x9b>
  800e68:	eb 75                	jmp    800edf <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800e6a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e6d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e71:	8b 45 14             	mov    0x14(%ebp),%eax
  800e74:	83 e8 01             	sub    $0x1,%eax
  800e77:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e82:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e86:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800e8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e8d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e90:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e97:	00 
  800e98:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800e9b:	89 1c 24             	mov    %ebx,(%esp)
  800e9e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800ea1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ea5:	e8 f6 0a 00 00       	call   8019a0 <__udivdi3>
  800eaa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ead:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800eb0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eb4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eb8:	89 04 24             	mov    %eax,(%esp)
  800ebb:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ebf:	89 fa                	mov    %edi,%edx
  800ec1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ec4:	e8 67 ff ff ff       	call   800e30 <printnum>
  800ec9:	eb 14                	jmp    800edf <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800ecb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ecf:	8b 45 18             	mov    0x18(%ebp),%eax
  800ed2:	89 04 24             	mov    %eax,(%esp)
  800ed5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800ed7:	83 ee 01             	sub    $0x1,%esi
  800eda:	75 ef                	jne    800ecb <printnum+0x9b>
  800edc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800edf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ee3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ee7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800eee:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ef5:	00 
  800ef6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800ef9:	89 1c 24             	mov    %ebx,(%esp)
  800efc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800eff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f03:	e8 e8 0b 00 00       	call   801af0 <__umoddi3>
  800f08:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f0c:	0f be 80 b7 1d 80 00 	movsbl 0x801db7(%eax),%eax
  800f13:	89 04 24             	mov    %eax,(%esp)
  800f16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800f19:	ff d0                	call   *%eax
}
  800f1b:	83 c4 4c             	add    $0x4c,%esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800f26:	83 fa 01             	cmp    $0x1,%edx
  800f29:	7e 0e                	jle    800f39 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800f2b:	8b 10                	mov    (%eax),%edx
  800f2d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800f30:	89 08                	mov    %ecx,(%eax)
  800f32:	8b 02                	mov    (%edx),%eax
  800f34:	8b 52 04             	mov    0x4(%edx),%edx
  800f37:	eb 22                	jmp    800f5b <getuint+0x38>
	else if (lflag)
  800f39:	85 d2                	test   %edx,%edx
  800f3b:	74 10                	je     800f4d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800f3d:	8b 10                	mov    (%eax),%edx
  800f3f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f42:	89 08                	mov    %ecx,(%eax)
  800f44:	8b 02                	mov    (%edx),%eax
  800f46:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4b:	eb 0e                	jmp    800f5b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800f4d:	8b 10                	mov    (%eax),%edx
  800f4f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f52:	89 08                	mov    %ecx,(%eax)
  800f54:	8b 02                	mov    (%edx),%eax
  800f56:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    

00800f5d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800f63:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800f67:	8b 10                	mov    (%eax),%edx
  800f69:	3b 50 04             	cmp    0x4(%eax),%edx
  800f6c:	73 0a                	jae    800f78 <sprintputch+0x1b>
		*b->buf++ = ch;
  800f6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f71:	88 0a                	mov    %cl,(%edx)
  800f73:	83 c2 01             	add    $0x1,%edx
  800f76:	89 10                	mov    %edx,(%eax)
}
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    

00800f7a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800f80:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800f83:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f87:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f95:	8b 45 08             	mov    0x8(%ebp),%eax
  800f98:	89 04 24             	mov    %eax,(%esp)
  800f9b:	e8 02 00 00 00       	call   800fa2 <vprintfmt>
	va_end(ap);
}
  800fa0:	c9                   	leave  
  800fa1:	c3                   	ret    

00800fa2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	57                   	push   %edi
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 4c             	sub    $0x4c,%esp
  800fab:	8b 75 08             	mov    0x8(%ebp),%esi
  800fae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fb1:	8b 7d 10             	mov    0x10(%ebp),%edi
  800fb4:	eb 11                	jmp    800fc7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	0f 84 db 03 00 00    	je     801399 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  800fbe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fc2:	89 04 24             	mov    %eax,(%esp)
  800fc5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800fc7:	0f b6 07             	movzbl (%edi),%eax
  800fca:	83 c7 01             	add    $0x1,%edi
  800fcd:	83 f8 25             	cmp    $0x25,%eax
  800fd0:	75 e4                	jne    800fb6 <vprintfmt+0x14>
  800fd2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800fd6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800fdd:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800fe4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800feb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff0:	eb 2b                	jmp    80101d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ff2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800ff5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800ff9:	eb 22                	jmp    80101d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ffb:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ffe:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  801002:	eb 19                	jmp    80101d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801004:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801007:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80100e:	eb 0d                	jmp    80101d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801010:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801013:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801016:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80101d:	0f b6 0f             	movzbl (%edi),%ecx
  801020:	8d 47 01             	lea    0x1(%edi),%eax
  801023:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801026:	0f b6 07             	movzbl (%edi),%eax
  801029:	83 e8 23             	sub    $0x23,%eax
  80102c:	3c 55                	cmp    $0x55,%al
  80102e:	0f 87 40 03 00 00    	ja     801374 <vprintfmt+0x3d2>
  801034:	0f b6 c0             	movzbl %al,%eax
  801037:	ff 24 85 00 1f 80 00 	jmp    *0x801f00(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80103e:	83 e9 30             	sub    $0x30,%ecx
  801041:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  801044:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  801048:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80104b:	83 f9 09             	cmp    $0x9,%ecx
  80104e:	77 57                	ja     8010a7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801050:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801053:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801056:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801059:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80105c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80105f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801063:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  801066:	8d 48 d0             	lea    -0x30(%eax),%ecx
  801069:	83 f9 09             	cmp    $0x9,%ecx
  80106c:	76 eb                	jbe    801059 <vprintfmt+0xb7>
  80106e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801071:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801074:	eb 34                	jmp    8010aa <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801076:	8b 45 14             	mov    0x14(%ebp),%eax
  801079:	8d 48 04             	lea    0x4(%eax),%ecx
  80107c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80107f:	8b 00                	mov    (%eax),%eax
  801081:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801084:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801087:	eb 21                	jmp    8010aa <vprintfmt+0x108>

		case '.':
			if (width < 0)
  801089:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80108d:	0f 88 71 ff ff ff    	js     801004 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801093:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801096:	eb 85                	jmp    80101d <vprintfmt+0x7b>
  801098:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80109b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8010a2:	e9 76 ff ff ff       	jmp    80101d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010a7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8010aa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8010ae:	0f 89 69 ff ff ff    	jns    80101d <vprintfmt+0x7b>
  8010b4:	e9 57 ff ff ff       	jmp    801010 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8010b9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8010bf:	e9 59 ff ff ff       	jmp    80101d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8010c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8010c7:	8d 50 04             	lea    0x4(%eax),%edx
  8010ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8010cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010d1:	8b 00                	mov    (%eax),%eax
  8010d3:	89 04 24             	mov    %eax,(%esp)
  8010d6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010d8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8010db:	e9 e7 fe ff ff       	jmp    800fc7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8010e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8010e3:	8d 50 04             	lea    0x4(%eax),%edx
  8010e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8010e9:	8b 00                	mov    (%eax),%eax
  8010eb:	89 c2                	mov    %eax,%edx
  8010ed:	c1 fa 1f             	sar    $0x1f,%edx
  8010f0:	31 d0                	xor    %edx,%eax
  8010f2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8010f4:	83 f8 0f             	cmp    $0xf,%eax
  8010f7:	7f 0b                	jg     801104 <vprintfmt+0x162>
  8010f9:	8b 14 85 60 20 80 00 	mov    0x802060(,%eax,4),%edx
  801100:	85 d2                	test   %edx,%edx
  801102:	75 20                	jne    801124 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  801104:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801108:	c7 44 24 08 cf 1d 80 	movl   $0x801dcf,0x8(%esp)
  80110f:	00 
  801110:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801114:	89 34 24             	mov    %esi,(%esp)
  801117:	e8 5e fe ff ff       	call   800f7a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80111c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80111f:	e9 a3 fe ff ff       	jmp    800fc7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  801124:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801128:	c7 44 24 08 d8 1d 80 	movl   $0x801dd8,0x8(%esp)
  80112f:	00 
  801130:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801134:	89 34 24             	mov    %esi,(%esp)
  801137:	e8 3e fe ff ff       	call   800f7a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80113c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80113f:	e9 83 fe ff ff       	jmp    800fc7 <vprintfmt+0x25>
  801144:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801147:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80114a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80114d:	8b 45 14             	mov    0x14(%ebp),%eax
  801150:	8d 50 04             	lea    0x4(%eax),%edx
  801153:	89 55 14             	mov    %edx,0x14(%ebp)
  801156:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801158:	85 ff                	test   %edi,%edi
  80115a:	b8 c8 1d 80 00       	mov    $0x801dc8,%eax
  80115f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801162:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  801166:	74 06                	je     80116e <vprintfmt+0x1cc>
  801168:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80116c:	7f 16                	jg     801184 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80116e:	0f b6 17             	movzbl (%edi),%edx
  801171:	0f be c2             	movsbl %dl,%eax
  801174:	83 c7 01             	add    $0x1,%edi
  801177:	85 c0                	test   %eax,%eax
  801179:	0f 85 9f 00 00 00    	jne    80121e <vprintfmt+0x27c>
  80117f:	e9 8b 00 00 00       	jmp    80120f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801184:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801188:	89 3c 24             	mov    %edi,(%esp)
  80118b:	e8 c2 02 00 00       	call   801452 <strnlen>
  801190:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801193:	29 c2                	sub    %eax,%edx
  801195:	89 55 d8             	mov    %edx,-0x28(%ebp)
  801198:	85 d2                	test   %edx,%edx
  80119a:	7e d2                	jle    80116e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80119c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8011a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8011a3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8011a6:	89 d7                	mov    %edx,%edi
  8011a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011af:	89 04 24             	mov    %eax,(%esp)
  8011b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011b4:	83 ef 01             	sub    $0x1,%edi
  8011b7:	75 ef                	jne    8011a8 <vprintfmt+0x206>
  8011b9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8011bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8011bf:	eb ad                	jmp    80116e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8011c1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8011c5:	74 20                	je     8011e7 <vprintfmt+0x245>
  8011c7:	0f be d2             	movsbl %dl,%edx
  8011ca:	83 ea 20             	sub    $0x20,%edx
  8011cd:	83 fa 5e             	cmp    $0x5e,%edx
  8011d0:	76 15                	jbe    8011e7 <vprintfmt+0x245>
					putch('?', putdat);
  8011d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8011d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011d9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8011e0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8011e3:	ff d1                	call   *%ecx
  8011e5:	eb 0f                	jmp    8011f6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  8011e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8011ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011ee:	89 04 24             	mov    %eax,(%esp)
  8011f1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8011f4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8011f6:	83 eb 01             	sub    $0x1,%ebx
  8011f9:	0f b6 17             	movzbl (%edi),%edx
  8011fc:	0f be c2             	movsbl %dl,%eax
  8011ff:	83 c7 01             	add    $0x1,%edi
  801202:	85 c0                	test   %eax,%eax
  801204:	75 24                	jne    80122a <vprintfmt+0x288>
  801206:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801209:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80120c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80120f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801212:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801216:	0f 8e ab fd ff ff    	jle    800fc7 <vprintfmt+0x25>
  80121c:	eb 20                	jmp    80123e <vprintfmt+0x29c>
  80121e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801221:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801224:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801227:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80122a:	85 f6                	test   %esi,%esi
  80122c:	78 93                	js     8011c1 <vprintfmt+0x21f>
  80122e:	83 ee 01             	sub    $0x1,%esi
  801231:	79 8e                	jns    8011c1 <vprintfmt+0x21f>
  801233:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801236:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801239:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80123c:	eb d1                	jmp    80120f <vprintfmt+0x26d>
  80123e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801241:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801245:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80124c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80124e:	83 ef 01             	sub    $0x1,%edi
  801251:	75 ee                	jne    801241 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801253:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801256:	e9 6c fd ff ff       	jmp    800fc7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80125b:	83 fa 01             	cmp    $0x1,%edx
  80125e:	66 90                	xchg   %ax,%ax
  801260:	7e 16                	jle    801278 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  801262:	8b 45 14             	mov    0x14(%ebp),%eax
  801265:	8d 50 08             	lea    0x8(%eax),%edx
  801268:	89 55 14             	mov    %edx,0x14(%ebp)
  80126b:	8b 10                	mov    (%eax),%edx
  80126d:	8b 48 04             	mov    0x4(%eax),%ecx
  801270:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801273:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801276:	eb 32                	jmp    8012aa <vprintfmt+0x308>
	else if (lflag)
  801278:	85 d2                	test   %edx,%edx
  80127a:	74 18                	je     801294 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80127c:	8b 45 14             	mov    0x14(%ebp),%eax
  80127f:	8d 50 04             	lea    0x4(%eax),%edx
  801282:	89 55 14             	mov    %edx,0x14(%ebp)
  801285:	8b 00                	mov    (%eax),%eax
  801287:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80128a:	89 c1                	mov    %eax,%ecx
  80128c:	c1 f9 1f             	sar    $0x1f,%ecx
  80128f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801292:	eb 16                	jmp    8012aa <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  801294:	8b 45 14             	mov    0x14(%ebp),%eax
  801297:	8d 50 04             	lea    0x4(%eax),%edx
  80129a:	89 55 14             	mov    %edx,0x14(%ebp)
  80129d:	8b 00                	mov    (%eax),%eax
  80129f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012a2:	89 c7                	mov    %eax,%edi
  8012a4:	c1 ff 1f             	sar    $0x1f,%edi
  8012a7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8012aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012ad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8012b0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8012b5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8012b9:	79 7d                	jns    801338 <vprintfmt+0x396>
				putch('-', putdat);
  8012bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012bf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8012c6:	ff d6                	call   *%esi
				num = -(long long) num;
  8012c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012cb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8012ce:	f7 d8                	neg    %eax
  8012d0:	83 d2 00             	adc    $0x0,%edx
  8012d3:	f7 da                	neg    %edx
			}
			base = 10;
  8012d5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8012da:	eb 5c                	jmp    801338 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8012dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8012df:	e8 3f fc ff ff       	call   800f23 <getuint>
			base = 10;
  8012e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8012e9:	eb 4d                	jmp    801338 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8012eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8012ee:	e8 30 fc ff ff       	call   800f23 <getuint>
			base = 8;
  8012f3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8012f8:	eb 3e                	jmp    801338 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8012fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012fe:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801305:	ff d6                	call   *%esi
			putch('x', putdat);
  801307:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80130b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801312:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801314:	8b 45 14             	mov    0x14(%ebp),%eax
  801317:	8d 50 04             	lea    0x4(%eax),%edx
  80131a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80131d:	8b 00                	mov    (%eax),%eax
  80131f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801324:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801329:	eb 0d                	jmp    801338 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80132b:	8d 45 14             	lea    0x14(%ebp),%eax
  80132e:	e8 f0 fb ff ff       	call   800f23 <getuint>
			base = 16;
  801333:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801338:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80133c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801340:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801343:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801347:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80134b:	89 04 24             	mov    %eax,(%esp)
  80134e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801352:	89 da                	mov    %ebx,%edx
  801354:	89 f0                	mov    %esi,%eax
  801356:	e8 d5 fa ff ff       	call   800e30 <printnum>
			break;
  80135b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80135e:	e9 64 fc ff ff       	jmp    800fc7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801363:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801367:	89 0c 24             	mov    %ecx,(%esp)
  80136a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80136f:	e9 53 fc ff ff       	jmp    800fc7 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801374:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801378:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80137f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801381:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801385:	0f 84 3c fc ff ff    	je     800fc7 <vprintfmt+0x25>
  80138b:	83 ef 01             	sub    $0x1,%edi
  80138e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801392:	75 f7                	jne    80138b <vprintfmt+0x3e9>
  801394:	e9 2e fc ff ff       	jmp    800fc7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  801399:	83 c4 4c             	add    $0x4c,%esp
  80139c:	5b                   	pop    %ebx
  80139d:	5e                   	pop    %esi
  80139e:	5f                   	pop    %edi
  80139f:	5d                   	pop    %ebp
  8013a0:	c3                   	ret    

008013a1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	83 ec 28             	sub    $0x28,%esp
  8013a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8013ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8013b0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8013b4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8013b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8013be:	85 d2                	test   %edx,%edx
  8013c0:	7e 30                	jle    8013f2 <vsnprintf+0x51>
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	74 2c                	je     8013f2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8013c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8013d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8013d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013db:	c7 04 24 5d 0f 80 00 	movl   $0x800f5d,(%esp)
  8013e2:	e8 bb fb ff ff       	call   800fa2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8013e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8013ea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8013ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f0:	eb 05                	jmp    8013f7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8013f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8013f7:	c9                   	leave  
  8013f8:	c3                   	ret    

008013f9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8013ff:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801402:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801406:	8b 45 10             	mov    0x10(%ebp),%eax
  801409:	89 44 24 08          	mov    %eax,0x8(%esp)
  80140d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801410:	89 44 24 04          	mov    %eax,0x4(%esp)
  801414:	8b 45 08             	mov    0x8(%ebp),%eax
  801417:	89 04 24             	mov    %eax,(%esp)
  80141a:	e8 82 ff ff ff       	call   8013a1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80141f:	c9                   	leave  
  801420:	c3                   	ret    
  801421:	66 90                	xchg   %ax,%ax
  801423:	66 90                	xchg   %ax,%ax
  801425:	66 90                	xchg   %ax,%ax
  801427:	66 90                	xchg   %ax,%ax
  801429:	66 90                	xchg   %ax,%ax
  80142b:	66 90                	xchg   %ax,%ax
  80142d:	66 90                	xchg   %ax,%ax
  80142f:	90                   	nop

00801430 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801436:	80 3a 00             	cmpb   $0x0,(%edx)
  801439:	74 10                	je     80144b <strlen+0x1b>
  80143b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801440:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801443:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801447:	75 f7                	jne    801440 <strlen+0x10>
  801449:	eb 05                	jmp    801450 <strlen+0x20>
  80144b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801450:	5d                   	pop    %ebp
  801451:	c3                   	ret    

00801452 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	53                   	push   %ebx
  801456:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801459:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80145c:	85 c9                	test   %ecx,%ecx
  80145e:	74 1c                	je     80147c <strnlen+0x2a>
  801460:	80 3b 00             	cmpb   $0x0,(%ebx)
  801463:	74 1e                	je     801483 <strnlen+0x31>
  801465:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80146a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80146c:	39 ca                	cmp    %ecx,%edx
  80146e:	74 18                	je     801488 <strnlen+0x36>
  801470:	83 c2 01             	add    $0x1,%edx
  801473:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  801478:	75 f0                	jne    80146a <strnlen+0x18>
  80147a:	eb 0c                	jmp    801488 <strnlen+0x36>
  80147c:	b8 00 00 00 00       	mov    $0x0,%eax
  801481:	eb 05                	jmp    801488 <strnlen+0x36>
  801483:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801488:	5b                   	pop    %ebx
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    

0080148b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	53                   	push   %ebx
  80148f:	8b 45 08             	mov    0x8(%ebp),%eax
  801492:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801495:	89 c2                	mov    %eax,%edx
  801497:	0f b6 19             	movzbl (%ecx),%ebx
  80149a:	88 1a                	mov    %bl,(%edx)
  80149c:	83 c2 01             	add    $0x1,%edx
  80149f:	83 c1 01             	add    $0x1,%ecx
  8014a2:	84 db                	test   %bl,%bl
  8014a4:	75 f1                	jne    801497 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8014a6:	5b                   	pop    %ebx
  8014a7:	5d                   	pop    %ebp
  8014a8:	c3                   	ret    

008014a9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	53                   	push   %ebx
  8014ad:	83 ec 08             	sub    $0x8,%esp
  8014b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8014b3:	89 1c 24             	mov    %ebx,(%esp)
  8014b6:	e8 75 ff ff ff       	call   801430 <strlen>
	strcpy(dst + len, src);
  8014bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014c2:	01 d8                	add    %ebx,%eax
  8014c4:	89 04 24             	mov    %eax,(%esp)
  8014c7:	e8 bf ff ff ff       	call   80148b <strcpy>
	return dst;
}
  8014cc:	89 d8                	mov    %ebx,%eax
  8014ce:	83 c4 08             	add    $0x8,%esp
  8014d1:	5b                   	pop    %ebx
  8014d2:	5d                   	pop    %ebp
  8014d3:	c3                   	ret    

008014d4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	56                   	push   %esi
  8014d8:	53                   	push   %ebx
  8014d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8014e2:	85 db                	test   %ebx,%ebx
  8014e4:	74 16                	je     8014fc <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  8014e6:	01 f3                	add    %esi,%ebx
  8014e8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8014ea:	0f b6 02             	movzbl (%edx),%eax
  8014ed:	88 01                	mov    %al,(%ecx)
  8014ef:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8014f2:	80 3a 01             	cmpb   $0x1,(%edx)
  8014f5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8014f8:	39 d9                	cmp    %ebx,%ecx
  8014fa:	75 ee                	jne    8014ea <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8014fc:	89 f0                	mov    %esi,%eax
  8014fe:	5b                   	pop    %ebx
  8014ff:	5e                   	pop    %esi
  801500:	5d                   	pop    %ebp
  801501:	c3                   	ret    

00801502 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	57                   	push   %edi
  801506:	56                   	push   %esi
  801507:	53                   	push   %ebx
  801508:	8b 7d 08             	mov    0x8(%ebp),%edi
  80150b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80150e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801511:	89 f8                	mov    %edi,%eax
  801513:	85 f6                	test   %esi,%esi
  801515:	74 33                	je     80154a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  801517:	83 fe 01             	cmp    $0x1,%esi
  80151a:	74 25                	je     801541 <strlcpy+0x3f>
  80151c:	0f b6 0b             	movzbl (%ebx),%ecx
  80151f:	84 c9                	test   %cl,%cl
  801521:	74 22                	je     801545 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801523:	83 ee 02             	sub    $0x2,%esi
  801526:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80152b:	88 08                	mov    %cl,(%eax)
  80152d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801530:	39 f2                	cmp    %esi,%edx
  801532:	74 13                	je     801547 <strlcpy+0x45>
  801534:	83 c2 01             	add    $0x1,%edx
  801537:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80153b:	84 c9                	test   %cl,%cl
  80153d:	75 ec                	jne    80152b <strlcpy+0x29>
  80153f:	eb 06                	jmp    801547 <strlcpy+0x45>
  801541:	89 f8                	mov    %edi,%eax
  801543:	eb 02                	jmp    801547 <strlcpy+0x45>
  801545:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801547:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80154a:	29 f8                	sub    %edi,%eax
}
  80154c:	5b                   	pop    %ebx
  80154d:	5e                   	pop    %esi
  80154e:	5f                   	pop    %edi
  80154f:	5d                   	pop    %ebp
  801550:	c3                   	ret    

00801551 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801557:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80155a:	0f b6 01             	movzbl (%ecx),%eax
  80155d:	84 c0                	test   %al,%al
  80155f:	74 15                	je     801576 <strcmp+0x25>
  801561:	3a 02                	cmp    (%edx),%al
  801563:	75 11                	jne    801576 <strcmp+0x25>
		p++, q++;
  801565:	83 c1 01             	add    $0x1,%ecx
  801568:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80156b:	0f b6 01             	movzbl (%ecx),%eax
  80156e:	84 c0                	test   %al,%al
  801570:	74 04                	je     801576 <strcmp+0x25>
  801572:	3a 02                	cmp    (%edx),%al
  801574:	74 ef                	je     801565 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801576:	0f b6 c0             	movzbl %al,%eax
  801579:	0f b6 12             	movzbl (%edx),%edx
  80157c:	29 d0                	sub    %edx,%eax
}
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    

00801580 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	56                   	push   %esi
  801584:	53                   	push   %ebx
  801585:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801588:	8b 55 0c             	mov    0xc(%ebp),%edx
  80158b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80158e:	85 f6                	test   %esi,%esi
  801590:	74 29                	je     8015bb <strncmp+0x3b>
  801592:	0f b6 03             	movzbl (%ebx),%eax
  801595:	84 c0                	test   %al,%al
  801597:	74 30                	je     8015c9 <strncmp+0x49>
  801599:	3a 02                	cmp    (%edx),%al
  80159b:	75 2c                	jne    8015c9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80159d:	8d 43 01             	lea    0x1(%ebx),%eax
  8015a0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8015a2:	89 c3                	mov    %eax,%ebx
  8015a4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8015a7:	39 f0                	cmp    %esi,%eax
  8015a9:	74 17                	je     8015c2 <strncmp+0x42>
  8015ab:	0f b6 08             	movzbl (%eax),%ecx
  8015ae:	84 c9                	test   %cl,%cl
  8015b0:	74 17                	je     8015c9 <strncmp+0x49>
  8015b2:	83 c0 01             	add    $0x1,%eax
  8015b5:	3a 0a                	cmp    (%edx),%cl
  8015b7:	74 e9                	je     8015a2 <strncmp+0x22>
  8015b9:	eb 0e                	jmp    8015c9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8015bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c0:	eb 0f                	jmp    8015d1 <strncmp+0x51>
  8015c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c7:	eb 08                	jmp    8015d1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8015c9:	0f b6 03             	movzbl (%ebx),%eax
  8015cc:	0f b6 12             	movzbl (%edx),%edx
  8015cf:	29 d0                	sub    %edx,%eax
}
  8015d1:	5b                   	pop    %ebx
  8015d2:	5e                   	pop    %esi
  8015d3:	5d                   	pop    %ebp
  8015d4:	c3                   	ret    

008015d5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	53                   	push   %ebx
  8015d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8015df:	0f b6 18             	movzbl (%eax),%ebx
  8015e2:	84 db                	test   %bl,%bl
  8015e4:	74 1d                	je     801603 <strchr+0x2e>
  8015e6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8015e8:	38 d3                	cmp    %dl,%bl
  8015ea:	75 06                	jne    8015f2 <strchr+0x1d>
  8015ec:	eb 1a                	jmp    801608 <strchr+0x33>
  8015ee:	38 ca                	cmp    %cl,%dl
  8015f0:	74 16                	je     801608 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8015f2:	83 c0 01             	add    $0x1,%eax
  8015f5:	0f b6 10             	movzbl (%eax),%edx
  8015f8:	84 d2                	test   %dl,%dl
  8015fa:	75 f2                	jne    8015ee <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  8015fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801601:	eb 05                	jmp    801608 <strchr+0x33>
  801603:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801608:	5b                   	pop    %ebx
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	53                   	push   %ebx
  80160f:	8b 45 08             	mov    0x8(%ebp),%eax
  801612:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801615:	0f b6 18             	movzbl (%eax),%ebx
  801618:	84 db                	test   %bl,%bl
  80161a:	74 16                	je     801632 <strfind+0x27>
  80161c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80161e:	38 d3                	cmp    %dl,%bl
  801620:	75 06                	jne    801628 <strfind+0x1d>
  801622:	eb 0e                	jmp    801632 <strfind+0x27>
  801624:	38 ca                	cmp    %cl,%dl
  801626:	74 0a                	je     801632 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801628:	83 c0 01             	add    $0x1,%eax
  80162b:	0f b6 10             	movzbl (%eax),%edx
  80162e:	84 d2                	test   %dl,%dl
  801630:	75 f2                	jne    801624 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  801632:	5b                   	pop    %ebx
  801633:	5d                   	pop    %ebp
  801634:	c3                   	ret    

00801635 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	83 ec 0c             	sub    $0xc,%esp
  80163b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80163e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801641:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801644:	8b 7d 08             	mov    0x8(%ebp),%edi
  801647:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80164a:	85 c9                	test   %ecx,%ecx
  80164c:	74 36                	je     801684 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80164e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801654:	75 28                	jne    80167e <memset+0x49>
  801656:	f6 c1 03             	test   $0x3,%cl
  801659:	75 23                	jne    80167e <memset+0x49>
		c &= 0xFF;
  80165b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80165f:	89 d3                	mov    %edx,%ebx
  801661:	c1 e3 08             	shl    $0x8,%ebx
  801664:	89 d6                	mov    %edx,%esi
  801666:	c1 e6 18             	shl    $0x18,%esi
  801669:	89 d0                	mov    %edx,%eax
  80166b:	c1 e0 10             	shl    $0x10,%eax
  80166e:	09 f0                	or     %esi,%eax
  801670:	09 c2                	or     %eax,%edx
  801672:	89 d0                	mov    %edx,%eax
  801674:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801676:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801679:	fc                   	cld    
  80167a:	f3 ab                	rep stos %eax,%es:(%edi)
  80167c:	eb 06                	jmp    801684 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80167e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801681:	fc                   	cld    
  801682:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  801684:	89 f8                	mov    %edi,%eax
  801686:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801689:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80168c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80168f:	89 ec                	mov    %ebp,%esp
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    

00801693 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	83 ec 08             	sub    $0x8,%esp
  801699:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80169c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80169f:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8016a8:	39 c6                	cmp    %eax,%esi
  8016aa:	73 36                	jae    8016e2 <memmove+0x4f>
  8016ac:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8016af:	39 d0                	cmp    %edx,%eax
  8016b1:	73 2f                	jae    8016e2 <memmove+0x4f>
		s += n;
		d += n;
  8016b3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8016b6:	f6 c2 03             	test   $0x3,%dl
  8016b9:	75 1b                	jne    8016d6 <memmove+0x43>
  8016bb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8016c1:	75 13                	jne    8016d6 <memmove+0x43>
  8016c3:	f6 c1 03             	test   $0x3,%cl
  8016c6:	75 0e                	jne    8016d6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8016c8:	83 ef 04             	sub    $0x4,%edi
  8016cb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8016ce:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8016d1:	fd                   	std    
  8016d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8016d4:	eb 09                	jmp    8016df <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8016d6:	83 ef 01             	sub    $0x1,%edi
  8016d9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8016dc:	fd                   	std    
  8016dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8016df:	fc                   	cld    
  8016e0:	eb 20                	jmp    801702 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8016e2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8016e8:	75 13                	jne    8016fd <memmove+0x6a>
  8016ea:	a8 03                	test   $0x3,%al
  8016ec:	75 0f                	jne    8016fd <memmove+0x6a>
  8016ee:	f6 c1 03             	test   $0x3,%cl
  8016f1:	75 0a                	jne    8016fd <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8016f3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8016f6:	89 c7                	mov    %eax,%edi
  8016f8:	fc                   	cld    
  8016f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8016fb:	eb 05                	jmp    801702 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8016fd:	89 c7                	mov    %eax,%edi
  8016ff:	fc                   	cld    
  801700:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801702:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801705:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801708:	89 ec                	mov    %ebp,%esp
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801712:	8b 45 10             	mov    0x10(%ebp),%eax
  801715:	89 44 24 08          	mov    %eax,0x8(%esp)
  801719:	8b 45 0c             	mov    0xc(%ebp),%eax
  80171c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801720:	8b 45 08             	mov    0x8(%ebp),%eax
  801723:	89 04 24             	mov    %eax,(%esp)
  801726:	e8 68 ff ff ff       	call   801693 <memmove>
}
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	57                   	push   %edi
  801731:	56                   	push   %esi
  801732:	53                   	push   %ebx
  801733:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801736:	8b 75 0c             	mov    0xc(%ebp),%esi
  801739:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80173c:	8d 78 ff             	lea    -0x1(%eax),%edi
  80173f:	85 c0                	test   %eax,%eax
  801741:	74 36                	je     801779 <memcmp+0x4c>
		if (*s1 != *s2)
  801743:	0f b6 03             	movzbl (%ebx),%eax
  801746:	0f b6 0e             	movzbl (%esi),%ecx
  801749:	38 c8                	cmp    %cl,%al
  80174b:	75 17                	jne    801764 <memcmp+0x37>
  80174d:	ba 00 00 00 00       	mov    $0x0,%edx
  801752:	eb 1a                	jmp    80176e <memcmp+0x41>
  801754:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801759:	83 c2 01             	add    $0x1,%edx
  80175c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801760:	38 c8                	cmp    %cl,%al
  801762:	74 0a                	je     80176e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801764:	0f b6 c0             	movzbl %al,%eax
  801767:	0f b6 c9             	movzbl %cl,%ecx
  80176a:	29 c8                	sub    %ecx,%eax
  80176c:	eb 10                	jmp    80177e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80176e:	39 fa                	cmp    %edi,%edx
  801770:	75 e2                	jne    801754 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801772:	b8 00 00 00 00       	mov    $0x0,%eax
  801777:	eb 05                	jmp    80177e <memcmp+0x51>
  801779:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5f                   	pop    %edi
  801781:	5d                   	pop    %ebp
  801782:	c3                   	ret    

00801783 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	53                   	push   %ebx
  801787:	8b 45 08             	mov    0x8(%ebp),%eax
  80178a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  80178d:	89 c2                	mov    %eax,%edx
  80178f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801792:	39 d0                	cmp    %edx,%eax
  801794:	73 13                	jae    8017a9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801796:	89 d9                	mov    %ebx,%ecx
  801798:	38 18                	cmp    %bl,(%eax)
  80179a:	75 06                	jne    8017a2 <memfind+0x1f>
  80179c:	eb 0b                	jmp    8017a9 <memfind+0x26>
  80179e:	38 08                	cmp    %cl,(%eax)
  8017a0:	74 07                	je     8017a9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8017a2:	83 c0 01             	add    $0x1,%eax
  8017a5:	39 d0                	cmp    %edx,%eax
  8017a7:	75 f5                	jne    80179e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8017a9:	5b                   	pop    %ebx
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	57                   	push   %edi
  8017b0:	56                   	push   %esi
  8017b1:	53                   	push   %ebx
  8017b2:	83 ec 04             	sub    $0x4,%esp
  8017b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8017bb:	0f b6 02             	movzbl (%edx),%eax
  8017be:	3c 09                	cmp    $0x9,%al
  8017c0:	74 04                	je     8017c6 <strtol+0x1a>
  8017c2:	3c 20                	cmp    $0x20,%al
  8017c4:	75 0e                	jne    8017d4 <strtol+0x28>
		s++;
  8017c6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8017c9:	0f b6 02             	movzbl (%edx),%eax
  8017cc:	3c 09                	cmp    $0x9,%al
  8017ce:	74 f6                	je     8017c6 <strtol+0x1a>
  8017d0:	3c 20                	cmp    $0x20,%al
  8017d2:	74 f2                	je     8017c6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8017d4:	3c 2b                	cmp    $0x2b,%al
  8017d6:	75 0a                	jne    8017e2 <strtol+0x36>
		s++;
  8017d8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8017db:	bf 00 00 00 00       	mov    $0x0,%edi
  8017e0:	eb 10                	jmp    8017f2 <strtol+0x46>
  8017e2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8017e7:	3c 2d                	cmp    $0x2d,%al
  8017e9:	75 07                	jne    8017f2 <strtol+0x46>
		s++, neg = 1;
  8017eb:	83 c2 01             	add    $0x1,%edx
  8017ee:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8017f2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8017f8:	75 15                	jne    80180f <strtol+0x63>
  8017fa:	80 3a 30             	cmpb   $0x30,(%edx)
  8017fd:	75 10                	jne    80180f <strtol+0x63>
  8017ff:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801803:	75 0a                	jne    80180f <strtol+0x63>
		s += 2, base = 16;
  801805:	83 c2 02             	add    $0x2,%edx
  801808:	bb 10 00 00 00       	mov    $0x10,%ebx
  80180d:	eb 10                	jmp    80181f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  80180f:	85 db                	test   %ebx,%ebx
  801811:	75 0c                	jne    80181f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801813:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801815:	80 3a 30             	cmpb   $0x30,(%edx)
  801818:	75 05                	jne    80181f <strtol+0x73>
		s++, base = 8;
  80181a:	83 c2 01             	add    $0x1,%edx
  80181d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80181f:	b8 00 00 00 00       	mov    $0x0,%eax
  801824:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801827:	0f b6 0a             	movzbl (%edx),%ecx
  80182a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80182d:	89 f3                	mov    %esi,%ebx
  80182f:	80 fb 09             	cmp    $0x9,%bl
  801832:	77 08                	ja     80183c <strtol+0x90>
			dig = *s - '0';
  801834:	0f be c9             	movsbl %cl,%ecx
  801837:	83 e9 30             	sub    $0x30,%ecx
  80183a:	eb 22                	jmp    80185e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  80183c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80183f:	89 f3                	mov    %esi,%ebx
  801841:	80 fb 19             	cmp    $0x19,%bl
  801844:	77 08                	ja     80184e <strtol+0xa2>
			dig = *s - 'a' + 10;
  801846:	0f be c9             	movsbl %cl,%ecx
  801849:	83 e9 57             	sub    $0x57,%ecx
  80184c:	eb 10                	jmp    80185e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  80184e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801851:	89 f3                	mov    %esi,%ebx
  801853:	80 fb 19             	cmp    $0x19,%bl
  801856:	77 16                	ja     80186e <strtol+0xc2>
			dig = *s - 'A' + 10;
  801858:	0f be c9             	movsbl %cl,%ecx
  80185b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80185e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801861:	7d 0f                	jge    801872 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801863:	83 c2 01             	add    $0x1,%edx
  801866:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  80186a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80186c:	eb b9                	jmp    801827 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80186e:	89 c1                	mov    %eax,%ecx
  801870:	eb 02                	jmp    801874 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801872:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801874:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801878:	74 05                	je     80187f <strtol+0xd3>
		*endptr = (char *) s;
  80187a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80187d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80187f:	89 ca                	mov    %ecx,%edx
  801881:	f7 da                	neg    %edx
  801883:	85 ff                	test   %edi,%edi
  801885:	0f 45 c2             	cmovne %edx,%eax
}
  801888:	83 c4 04             	add    $0x4,%esp
  80188b:	5b                   	pop    %ebx
  80188c:	5e                   	pop    %esi
  80188d:	5f                   	pop    %edi
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	56                   	push   %esi
  801894:	53                   	push   %ebx
  801895:	83 ec 10             	sub    $0x10,%esp
  801898:	8b 75 08             	mov    0x8(%ebp),%esi
  80189b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  80189e:	85 db                	test   %ebx,%ebx
  8018a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8018a5:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  8018a8:	89 1c 24             	mov    %ebx,(%esp)
  8018ab:	e8 f9 eb ff ff       	call   8004a9 <sys_ipc_recv>
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	78 2d                	js     8018e1 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  8018b4:	85 f6                	test   %esi,%esi
  8018b6:	74 0a                	je     8018c2 <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  8018b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8018bd:	8b 40 74             	mov    0x74(%eax),%eax
  8018c0:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  8018c2:	85 db                	test   %ebx,%ebx
  8018c4:	74 13                	je     8018d9 <ipc_recv+0x49>
  8018c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018ca:	74 0d                	je     8018d9 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  8018cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8018d1:	8b 40 78             	mov    0x78(%eax),%eax
  8018d4:	8b 55 10             	mov    0x10(%ebp),%edx
  8018d7:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  8018d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8018de:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	5b                   	pop    %ebx
  8018e5:	5e                   	pop    %esi
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    

008018e8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	57                   	push   %edi
  8018ec:	56                   	push   %esi
  8018ed:	53                   	push   %ebx
  8018ee:	83 ec 1c             	sub    $0x1c,%esp
  8018f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  8018fa:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  8018fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801901:	0f 44 d8             	cmove  %eax,%ebx
  801904:	eb 2a                	jmp    801930 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  801906:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801909:	74 20                	je     80192b <ipc_send+0x43>
            panic("Send message error %e\n",r);
  80190b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80190f:	c7 44 24 08 c0 20 80 	movl   $0x8020c0,0x8(%esp)
  801916:	00 
  801917:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80191e:	00 
  80191f:	c7 04 24 d7 20 80 00 	movl   $0x8020d7,(%esp)
  801926:	e8 e5 f3 ff ff       	call   800d10 <_panic>
		sys_yield();
  80192b:	e8 98 e8 ff ff       	call   8001c8 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801930:	8b 45 14             	mov    0x14(%ebp),%eax
  801933:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801937:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80193b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80193f:	89 3c 24             	mov    %edi,(%esp)
  801942:	e8 25 eb ff ff       	call   80046c <sys_ipc_try_send>
  801947:	85 c0                	test   %eax,%eax
  801949:	78 bb                	js     801906 <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  80194b:	83 c4 1c             	add    $0x1c,%esp
  80194e:	5b                   	pop    %ebx
  80194f:	5e                   	pop    %esi
  801950:	5f                   	pop    %edi
  801951:	5d                   	pop    %ebp
  801952:	c3                   	ret    

00801953 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801959:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80195e:	39 c8                	cmp    %ecx,%eax
  801960:	74 17                	je     801979 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801962:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801967:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80196a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801970:	8b 52 50             	mov    0x50(%edx),%edx
  801973:	39 ca                	cmp    %ecx,%edx
  801975:	75 14                	jne    80198b <ipc_find_env+0x38>
  801977:	eb 05                	jmp    80197e <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801979:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80197e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801981:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801986:	8b 40 40             	mov    0x40(%eax),%eax
  801989:	eb 0e                	jmp    801999 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80198b:	83 c0 01             	add    $0x1,%eax
  80198e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801993:	75 d2                	jne    801967 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801995:	66 b8 00 00          	mov    $0x0,%ax
}
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    
  80199b:	66 90                	xchg   %ax,%ax
  80199d:	66 90                	xchg   %ax,%ax
  80199f:	90                   	nop

008019a0 <__udivdi3>:
  8019a0:	83 ec 1c             	sub    $0x1c,%esp
  8019a3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8019a7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8019ab:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8019af:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8019b3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8019b7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	89 74 24 10          	mov    %esi,0x10(%esp)
  8019c1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8019c5:	89 ea                	mov    %ebp,%edx
  8019c7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019cb:	75 33                	jne    801a00 <__udivdi3+0x60>
  8019cd:	39 e9                	cmp    %ebp,%ecx
  8019cf:	77 6f                	ja     801a40 <__udivdi3+0xa0>
  8019d1:	85 c9                	test   %ecx,%ecx
  8019d3:	89 ce                	mov    %ecx,%esi
  8019d5:	75 0b                	jne    8019e2 <__udivdi3+0x42>
  8019d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019dc:	31 d2                	xor    %edx,%edx
  8019de:	f7 f1                	div    %ecx
  8019e0:	89 c6                	mov    %eax,%esi
  8019e2:	31 d2                	xor    %edx,%edx
  8019e4:	89 e8                	mov    %ebp,%eax
  8019e6:	f7 f6                	div    %esi
  8019e8:	89 c5                	mov    %eax,%ebp
  8019ea:	89 f8                	mov    %edi,%eax
  8019ec:	f7 f6                	div    %esi
  8019ee:	89 ea                	mov    %ebp,%edx
  8019f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8019f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8019f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8019fc:	83 c4 1c             	add    $0x1c,%esp
  8019ff:	c3                   	ret    
  801a00:	39 e8                	cmp    %ebp,%eax
  801a02:	77 24                	ja     801a28 <__udivdi3+0x88>
  801a04:	0f bd c8             	bsr    %eax,%ecx
  801a07:	83 f1 1f             	xor    $0x1f,%ecx
  801a0a:	89 0c 24             	mov    %ecx,(%esp)
  801a0d:	75 49                	jne    801a58 <__udivdi3+0xb8>
  801a0f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801a13:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801a17:	0f 86 ab 00 00 00    	jbe    801ac8 <__udivdi3+0x128>
  801a1d:	39 e8                	cmp    %ebp,%eax
  801a1f:	0f 82 a3 00 00 00    	jb     801ac8 <__udivdi3+0x128>
  801a25:	8d 76 00             	lea    0x0(%esi),%esi
  801a28:	31 d2                	xor    %edx,%edx
  801a2a:	31 c0                	xor    %eax,%eax
  801a2c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a30:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a34:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a38:	83 c4 1c             	add    $0x1c,%esp
  801a3b:	c3                   	ret    
  801a3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a40:	89 f8                	mov    %edi,%eax
  801a42:	f7 f1                	div    %ecx
  801a44:	31 d2                	xor    %edx,%edx
  801a46:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a4a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a4e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a52:	83 c4 1c             	add    $0x1c,%esp
  801a55:	c3                   	ret    
  801a56:	66 90                	xchg   %ax,%ax
  801a58:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a5c:	89 c6                	mov    %eax,%esi
  801a5e:	b8 20 00 00 00       	mov    $0x20,%eax
  801a63:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801a67:	2b 04 24             	sub    (%esp),%eax
  801a6a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801a6e:	d3 e6                	shl    %cl,%esi
  801a70:	89 c1                	mov    %eax,%ecx
  801a72:	d3 ed                	shr    %cl,%ebp
  801a74:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a78:	09 f5                	or     %esi,%ebp
  801a7a:	8b 74 24 04          	mov    0x4(%esp),%esi
  801a7e:	d3 e6                	shl    %cl,%esi
  801a80:	89 c1                	mov    %eax,%ecx
  801a82:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a86:	89 d6                	mov    %edx,%esi
  801a88:	d3 ee                	shr    %cl,%esi
  801a8a:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a8e:	d3 e2                	shl    %cl,%edx
  801a90:	89 c1                	mov    %eax,%ecx
  801a92:	d3 ef                	shr    %cl,%edi
  801a94:	09 d7                	or     %edx,%edi
  801a96:	89 f2                	mov    %esi,%edx
  801a98:	89 f8                	mov    %edi,%eax
  801a9a:	f7 f5                	div    %ebp
  801a9c:	89 d6                	mov    %edx,%esi
  801a9e:	89 c7                	mov    %eax,%edi
  801aa0:	f7 64 24 04          	mull   0x4(%esp)
  801aa4:	39 d6                	cmp    %edx,%esi
  801aa6:	72 30                	jb     801ad8 <__udivdi3+0x138>
  801aa8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801aac:	0f b6 0c 24          	movzbl (%esp),%ecx
  801ab0:	d3 e5                	shl    %cl,%ebp
  801ab2:	39 c5                	cmp    %eax,%ebp
  801ab4:	73 04                	jae    801aba <__udivdi3+0x11a>
  801ab6:	39 d6                	cmp    %edx,%esi
  801ab8:	74 1e                	je     801ad8 <__udivdi3+0x138>
  801aba:	89 f8                	mov    %edi,%eax
  801abc:	31 d2                	xor    %edx,%edx
  801abe:	e9 69 ff ff ff       	jmp    801a2c <__udivdi3+0x8c>
  801ac3:	90                   	nop
  801ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ac8:	31 d2                	xor    %edx,%edx
  801aca:	b8 01 00 00 00       	mov    $0x1,%eax
  801acf:	e9 58 ff ff ff       	jmp    801a2c <__udivdi3+0x8c>
  801ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ad8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801adb:	31 d2                	xor    %edx,%edx
  801add:	8b 74 24 10          	mov    0x10(%esp),%esi
  801ae1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801ae5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801ae9:	83 c4 1c             	add    $0x1c,%esp
  801aec:	c3                   	ret    
  801aed:	66 90                	xchg   %ax,%ax
  801aef:	90                   	nop

00801af0 <__umoddi3>:
  801af0:	83 ec 2c             	sub    $0x2c,%esp
  801af3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801af7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801afb:	89 74 24 20          	mov    %esi,0x20(%esp)
  801aff:	8b 74 24 38          	mov    0x38(%esp),%esi
  801b03:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801b07:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	89 c2                	mov    %eax,%edx
  801b0f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801b13:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801b17:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b1b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801b1f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b23:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801b27:	75 1f                	jne    801b48 <__umoddi3+0x58>
  801b29:	39 fe                	cmp    %edi,%esi
  801b2b:	76 63                	jbe    801b90 <__umoddi3+0xa0>
  801b2d:	89 c8                	mov    %ecx,%eax
  801b2f:	89 fa                	mov    %edi,%edx
  801b31:	f7 f6                	div    %esi
  801b33:	89 d0                	mov    %edx,%eax
  801b35:	31 d2                	xor    %edx,%edx
  801b37:	8b 74 24 20          	mov    0x20(%esp),%esi
  801b3b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801b3f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801b43:	83 c4 2c             	add    $0x2c,%esp
  801b46:	c3                   	ret    
  801b47:	90                   	nop
  801b48:	39 f8                	cmp    %edi,%eax
  801b4a:	77 64                	ja     801bb0 <__umoddi3+0xc0>
  801b4c:	0f bd e8             	bsr    %eax,%ebp
  801b4f:	83 f5 1f             	xor    $0x1f,%ebp
  801b52:	75 74                	jne    801bc8 <__umoddi3+0xd8>
  801b54:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b58:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801b5c:	0f 87 0e 01 00 00    	ja     801c70 <__umoddi3+0x180>
  801b62:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801b66:	29 f1                	sub    %esi,%ecx
  801b68:	19 c7                	sbb    %eax,%edi
  801b6a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b6e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801b72:	8b 44 24 14          	mov    0x14(%esp),%eax
  801b76:	8b 54 24 18          	mov    0x18(%esp),%edx
  801b7a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801b7e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801b82:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801b86:	83 c4 2c             	add    $0x2c,%esp
  801b89:	c3                   	ret    
  801b8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b90:	85 f6                	test   %esi,%esi
  801b92:	89 f5                	mov    %esi,%ebp
  801b94:	75 0b                	jne    801ba1 <__umoddi3+0xb1>
  801b96:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9b:	31 d2                	xor    %edx,%edx
  801b9d:	f7 f6                	div    %esi
  801b9f:	89 c5                	mov    %eax,%ebp
  801ba1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ba5:	31 d2                	xor    %edx,%edx
  801ba7:	f7 f5                	div    %ebp
  801ba9:	89 c8                	mov    %ecx,%eax
  801bab:	f7 f5                	div    %ebp
  801bad:	eb 84                	jmp    801b33 <__umoddi3+0x43>
  801baf:	90                   	nop
  801bb0:	89 c8                	mov    %ecx,%eax
  801bb2:	89 fa                	mov    %edi,%edx
  801bb4:	8b 74 24 20          	mov    0x20(%esp),%esi
  801bb8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801bbc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801bc0:	83 c4 2c             	add    $0x2c,%esp
  801bc3:	c3                   	ret    
  801bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bc8:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bcc:	be 20 00 00 00       	mov    $0x20,%esi
  801bd1:	89 e9                	mov    %ebp,%ecx
  801bd3:	29 ee                	sub    %ebp,%esi
  801bd5:	d3 e2                	shl    %cl,%edx
  801bd7:	89 f1                	mov    %esi,%ecx
  801bd9:	d3 e8                	shr    %cl,%eax
  801bdb:	89 e9                	mov    %ebp,%ecx
  801bdd:	09 d0                	or     %edx,%eax
  801bdf:	89 fa                	mov    %edi,%edx
  801be1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801be5:	8b 44 24 10          	mov    0x10(%esp),%eax
  801be9:	d3 e0                	shl    %cl,%eax
  801beb:	89 f1                	mov    %esi,%ecx
  801bed:	89 44 24 10          	mov    %eax,0x10(%esp)
  801bf1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801bf5:	d3 ea                	shr    %cl,%edx
  801bf7:	89 e9                	mov    %ebp,%ecx
  801bf9:	d3 e7                	shl    %cl,%edi
  801bfb:	89 f1                	mov    %esi,%ecx
  801bfd:	d3 e8                	shr    %cl,%eax
  801bff:	89 e9                	mov    %ebp,%ecx
  801c01:	09 f8                	or     %edi,%eax
  801c03:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801c07:	f7 74 24 0c          	divl   0xc(%esp)
  801c0b:	d3 e7                	shl    %cl,%edi
  801c0d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c11:	89 d7                	mov    %edx,%edi
  801c13:	f7 64 24 10          	mull   0x10(%esp)
  801c17:	39 d7                	cmp    %edx,%edi
  801c19:	89 c1                	mov    %eax,%ecx
  801c1b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801c1f:	72 3b                	jb     801c5c <__umoddi3+0x16c>
  801c21:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801c25:	72 31                	jb     801c58 <__umoddi3+0x168>
  801c27:	8b 44 24 18          	mov    0x18(%esp),%eax
  801c2b:	29 c8                	sub    %ecx,%eax
  801c2d:	19 d7                	sbb    %edx,%edi
  801c2f:	89 e9                	mov    %ebp,%ecx
  801c31:	89 fa                	mov    %edi,%edx
  801c33:	d3 e8                	shr    %cl,%eax
  801c35:	89 f1                	mov    %esi,%ecx
  801c37:	d3 e2                	shl    %cl,%edx
  801c39:	89 e9                	mov    %ebp,%ecx
  801c3b:	09 d0                	or     %edx,%eax
  801c3d:	89 fa                	mov    %edi,%edx
  801c3f:	d3 ea                	shr    %cl,%edx
  801c41:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c45:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c49:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c4d:	83 c4 2c             	add    $0x2c,%esp
  801c50:	c3                   	ret    
  801c51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c58:	39 d7                	cmp    %edx,%edi
  801c5a:	75 cb                	jne    801c27 <__umoddi3+0x137>
  801c5c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801c60:	89 c1                	mov    %eax,%ecx
  801c62:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801c66:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801c6a:	eb bb                	jmp    801c27 <__umoddi3+0x137>
  801c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c70:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801c74:	0f 82 e8 fe ff ff    	jb     801b62 <__umoddi3+0x72>
  801c7a:	e9 f3 fe ff ff       	jmp    801b72 <__umoddi3+0x82>
