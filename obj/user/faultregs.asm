
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 67 05 00 00       	call   800598 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	89 c6                	mov    %eax,%esi
  80003f:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800048:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004c:	c7 44 24 04 91 22 80 	movl   $0x802291,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 60 22 80 00 	movl   $0x802260,(%esp)
  80005b:	e8 9f 06 00 00       	call   8006ff <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 03                	mov    (%ebx),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 06                	mov    (%esi),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 70 22 80 	movl   $0x802270,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 74 22 80 00 	movl   $0x802274,(%esp)
  80007b:	e8 7f 06 00 00       	call   8006ff <cprintf>
  800080:	8b 03                	mov    (%ebx),%eax
  800082:	39 06                	cmp    %eax,(%esi)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  80008d:	e8 6d 06 00 00       	call   8006ff <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800092:	bf 00 00 00 00       	mov    $0x0,%edi
  800097:	eb 11                	jmp    8000aa <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800099:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  8000a0:	e8 5a 06 00 00       	call   8006ff <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 46 04             	mov    0x4(%esi),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 92 22 80 	movl   $0x802292,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 74 22 80 00 	movl   $0x802274,(%esp)
  8000c7:	e8 33 06 00 00       	call   8006ff <cprintf>
  8000cc:	8b 43 04             	mov    0x4(%ebx),%eax
  8000cf:	39 46 04             	cmp    %eax,0x4(%esi)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  8000db:	e8 1f 06 00 00       	call   8006ff <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  8000e9:	e8 11 06 00 00       	call   8006ff <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 43 08             	mov    0x8(%ebx),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 46 08             	mov    0x8(%esi),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 96 22 80 	movl   $0x802296,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 74 22 80 00 	movl   $0x802274,(%esp)
  800110:	e8 ea 05 00 00       	call   8006ff <cprintf>
  800115:	8b 43 08             	mov    0x8(%ebx),%eax
  800118:	39 46 08             	cmp    %eax,0x8(%esi)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  800124:	e8 d6 05 00 00       	call   8006ff <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  800132:	e8 c8 05 00 00       	call   8006ff <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 43 10             	mov    0x10(%ebx),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 46 10             	mov    0x10(%esi),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 9a 22 80 	movl   $0x80229a,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 74 22 80 00 	movl   $0x802274,(%esp)
  800159:	e8 a1 05 00 00       	call   8006ff <cprintf>
  80015e:	8b 43 10             	mov    0x10(%ebx),%eax
  800161:	39 46 10             	cmp    %eax,0x10(%esi)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  80016d:	e8 8d 05 00 00       	call   8006ff <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  80017b:	e8 7f 05 00 00       	call   8006ff <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 43 14             	mov    0x14(%ebx),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 46 14             	mov    0x14(%esi),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 9e 22 80 	movl   $0x80229e,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 74 22 80 00 	movl   $0x802274,(%esp)
  8001a2:	e8 58 05 00 00       	call   8006ff <cprintf>
  8001a7:	8b 43 14             	mov    0x14(%ebx),%eax
  8001aa:	39 46 14             	cmp    %eax,0x14(%esi)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  8001b6:	e8 44 05 00 00       	call   8006ff <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  8001c4:	e8 36 05 00 00       	call   8006ff <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 46 18             	mov    0x18(%esi),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 a2 22 80 	movl   $0x8022a2,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 74 22 80 00 	movl   $0x802274,(%esp)
  8001eb:	e8 0f 05 00 00       	call   8006ff <cprintf>
  8001f0:	8b 43 18             	mov    0x18(%ebx),%eax
  8001f3:	39 46 18             	cmp    %eax,0x18(%esi)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  8001ff:	e8 fb 04 00 00       	call   8006ff <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  80020d:	e8 ed 04 00 00       	call   8006ff <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 46 1c             	mov    0x1c(%esi),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 a6 22 80 	movl   $0x8022a6,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 74 22 80 00 	movl   $0x802274,(%esp)
  800234:	e8 c6 04 00 00       	call   8006ff <cprintf>
  800239:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80023c:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  800248:	e8 b2 04 00 00       	call   8006ff <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  800256:	e8 a4 04 00 00       	call   8006ff <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 43 20             	mov    0x20(%ebx),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 46 20             	mov    0x20(%esi),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 aa 22 80 	movl   $0x8022aa,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 74 22 80 00 	movl   $0x802274,(%esp)
  80027d:	e8 7d 04 00 00       	call   8006ff <cprintf>
  800282:	8b 43 20             	mov    0x20(%ebx),%eax
  800285:	39 46 20             	cmp    %eax,0x20(%esi)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  800291:	e8 69 04 00 00       	call   8006ff <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  80029f:	e8 5b 04 00 00       	call   8006ff <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 46 24             	mov    0x24(%esi),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 ae 22 80 	movl   $0x8022ae,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 74 22 80 00 	movl   $0x802274,(%esp)
  8002c6:	e8 34 04 00 00       	call   8006ff <cprintf>
  8002cb:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ce:	39 46 24             	cmp    %eax,0x24(%esi)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  8002da:	e8 20 04 00 00       	call   8006ff <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  8002e8:	e8 12 04 00 00       	call   8006ff <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 43 28             	mov    0x28(%ebx),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 46 28             	mov    0x28(%esi),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 b5 22 80 	movl   $0x8022b5,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 74 22 80 00 	movl   $0x802274,(%esp)
  80030f:	e8 eb 03 00 00       	call   8006ff <cprintf>
  800314:	8b 43 28             	mov    0x28(%ebx),%eax
  800317:	39 46 28             	cmp    %eax,0x28(%esi)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  800323:	e8 d7 03 00 00       	call   8006ff <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 b9 22 80 00 	movl   $0x8022b9,(%esp)
  800336:	e8 c4 03 00 00       	call   8006ff <cprintf>
	if (!mismatch)
  80033b:	85 ff                	test   %edi,%edi
  80033d:	74 23                	je     800362 <check_regs+0x32e>
  80033f:	eb 2f                	jmp    800370 <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800341:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  800348:	e8 b2 03 00 00       	call   8006ff <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 b9 22 80 00 	movl   $0x8022b9,(%esp)
  80035b:	e8 9f 03 00 00       	call   8006ff <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 84 22 80 00 	movl   $0x802284,(%esp)
  800369:	e8 91 03 00 00       	call   8006ff <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  800377:	e8 83 03 00 00       	call   8006ff <cprintf>
}
  80037c:	83 c4 1c             	add    $0x1c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 28             	sub    $0x28,%esp
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800395:	74 27                	je     8003be <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800397:	8b 40 28             	mov    0x28(%eax),%eax
  80039a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a2:	c7 44 24 08 20 23 80 	movl   $0x802320,0x8(%esp)
  8003a9:	00 
  8003aa:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b1:	00 
  8003b2:	c7 04 24 c7 22 80 00 	movl   $0x8022c7,(%esp)
  8003b9:	e8 46 02 00 00       	call   800604 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003be:	8b 50 08             	mov    0x8(%eax),%edx
  8003c1:	89 15 80 40 80 00    	mov    %edx,0x804080
  8003c7:	8b 50 0c             	mov    0xc(%eax),%edx
  8003ca:	89 15 84 40 80 00    	mov    %edx,0x804084
  8003d0:	8b 50 10             	mov    0x10(%eax),%edx
  8003d3:	89 15 88 40 80 00    	mov    %edx,0x804088
  8003d9:	8b 50 14             	mov    0x14(%eax),%edx
  8003dc:	89 15 8c 40 80 00    	mov    %edx,0x80408c
  8003e2:	8b 50 18             	mov    0x18(%eax),%edx
  8003e5:	89 15 90 40 80 00    	mov    %edx,0x804090
  8003eb:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ee:	89 15 94 40 80 00    	mov    %edx,0x804094
  8003f4:	8b 50 20             	mov    0x20(%eax),%edx
  8003f7:	89 15 98 40 80 00    	mov    %edx,0x804098
  8003fd:	8b 50 24             	mov    0x24(%eax),%edx
  800400:	89 15 9c 40 80 00    	mov    %edx,0x80409c
	during.eip = utf->utf_eip;
  800406:	8b 50 28             	mov    0x28(%eax),%edx
  800409:	89 15 a0 40 80 00    	mov    %edx,0x8040a0
	during.eflags = utf->utf_eflags;
  80040f:	8b 50 2c             	mov    0x2c(%eax),%edx
  800412:	89 15 a4 40 80 00    	mov    %edx,0x8040a4
	during.esp = utf->utf_esp;
  800418:	8b 40 30             	mov    0x30(%eax),%eax
  80041b:	a3 a8 40 80 00       	mov    %eax,0x8040a8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800420:	c7 44 24 04 df 22 80 	movl   $0x8022df,0x4(%esp)
  800427:	00 
  800428:	c7 04 24 ed 22 80 00 	movl   $0x8022ed,(%esp)
  80042f:	b9 80 40 80 00       	mov    $0x804080,%ecx
  800434:	ba d8 22 80 00       	mov    $0x8022d8,%edx
  800439:	b8 00 40 80 00       	mov    $0x804000,%eax
  80043e:	e8 f1 fb ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800443:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80044a:	00 
  80044b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800452:	00 
  800453:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80045a:	e8 6a 0e 00 00       	call   8012c9 <sys_page_alloc>
  80045f:	85 c0                	test   %eax,%eax
  800461:	79 20                	jns    800483 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800463:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800467:	c7 44 24 08 f4 22 80 	movl   $0x8022f4,0x8(%esp)
  80046e:	00 
  80046f:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800476:	00 
  800477:	c7 04 24 c7 22 80 00 	movl   $0x8022c7,(%esp)
  80047e:	e8 81 01 00 00       	call   800604 <_panic>
}
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <umain>:

void
umain(int argc, char **argv)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80048b:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800492:	e8 41 11 00 00       	call   8015d8 <set_pgfault_handler>

	__asm __volatile(
  800497:	50                   	push   %eax
  800498:	9c                   	pushf  
  800499:	58                   	pop    %eax
  80049a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80049f:	50                   	push   %eax
  8004a0:	9d                   	popf   
  8004a1:	a3 24 40 80 00       	mov    %eax,0x804024
  8004a6:	8d 05 e1 04 80 00    	lea    0x8004e1,%eax
  8004ac:	a3 20 40 80 00       	mov    %eax,0x804020
  8004b1:	58                   	pop    %eax
  8004b2:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004b8:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004be:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004c4:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004ca:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004d0:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  8004d6:	a3 1c 40 80 00       	mov    %eax,0x80401c
  8004db:	89 25 28 40 80 00    	mov    %esp,0x804028
  8004e1:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e8:	00 00 00 
  8004eb:	89 3d 40 40 80 00    	mov    %edi,0x804040
  8004f1:	89 35 44 40 80 00    	mov    %esi,0x804044
  8004f7:	89 2d 48 40 80 00    	mov    %ebp,0x804048
  8004fd:	89 1d 50 40 80 00    	mov    %ebx,0x804050
  800503:	89 15 54 40 80 00    	mov    %edx,0x804054
  800509:	89 0d 58 40 80 00    	mov    %ecx,0x804058
  80050f:	a3 5c 40 80 00       	mov    %eax,0x80405c
  800514:	89 25 68 40 80 00    	mov    %esp,0x804068
  80051a:	8b 3d 00 40 80 00    	mov    0x804000,%edi
  800520:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800526:	8b 2d 08 40 80 00    	mov    0x804008,%ebp
  80052c:	8b 1d 10 40 80 00    	mov    0x804010,%ebx
  800532:	8b 15 14 40 80 00    	mov    0x804014,%edx
  800538:	8b 0d 18 40 80 00    	mov    0x804018,%ecx
  80053e:	a1 1c 40 80 00       	mov    0x80401c,%eax
  800543:	8b 25 28 40 80 00    	mov    0x804028,%esp
  800549:	50                   	push   %eax
  80054a:	9c                   	pushf  
  80054b:	58                   	pop    %eax
  80054c:	a3 64 40 80 00       	mov    %eax,0x804064
  800551:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800552:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800559:	74 0c                	je     800567 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80055b:	c7 04 24 54 23 80 00 	movl   $0x802354,(%esp)
  800562:	e8 98 01 00 00       	call   8006ff <cprintf>
	after.eip = before.eip;
  800567:	a1 20 40 80 00       	mov    0x804020,%eax
  80056c:	a3 60 40 80 00       	mov    %eax,0x804060

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	c7 44 24 04 07 23 80 	movl   $0x802307,0x4(%esp)
  800578:	00 
  800579:	c7 04 24 18 23 80 00 	movl   $0x802318,(%esp)
  800580:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800585:	ba d8 22 80 00       	mov    $0x8022d8,%edx
  80058a:	b8 00 40 80 00       	mov    $0x804000,%eax
  80058f:	e8 a0 fa ff ff       	call   800034 <check_regs>
}
  800594:	c9                   	leave  
  800595:	c3                   	ret    
  800596:	66 90                	xchg   %ax,%ax

00800598 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	83 ec 18             	sub    $0x18,%esp
  80059e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005a1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  8005aa:	e8 a8 0c 00 00       	call   801257 <sys_getenvid>
  8005af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005bc:	a3 b0 40 80 00       	mov    %eax,0x8040b0
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005c1:	85 db                	test   %ebx,%ebx
  8005c3:	7e 07                	jle    8005cc <libmain+0x34>
		binaryname = argv[0];
  8005c5:	8b 06                	mov    (%esi),%eax
  8005c7:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d0:	89 1c 24             	mov    %ebx,(%esp)
  8005d3:	e8 ad fe ff ff       	call   800485 <umain>

	// exit gracefully
	exit();
  8005d8:	e8 0b 00 00 00       	call   8005e8 <exit>
}
  8005dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005e3:	89 ec                	mov    %ebp,%esp
  8005e5:	5d                   	pop    %ebp
  8005e6:	c3                   	ret    
  8005e7:	90                   	nop

008005e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8005ee:	e8 80 12 00 00       	call   801873 <close_all>
	sys_env_destroy(0);
  8005f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005fa:	e8 f2 0b 00 00       	call   8011f1 <sys_env_destroy>
}
  8005ff:	c9                   	leave  
  800600:	c3                   	ret    
  800601:	66 90                	xchg   %ax,%ax
  800603:	90                   	nop

00800604 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800604:	55                   	push   %ebp
  800605:	89 e5                	mov    %esp,%ebp
  800607:	56                   	push   %esi
  800608:	53                   	push   %ebx
  800609:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80060c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80060f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800615:	e8 3d 0c 00 00       	call   801257 <sys_getenvid>
  80061a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80061d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800621:	8b 55 08             	mov    0x8(%ebp),%edx
  800624:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800628:	89 74 24 08          	mov    %esi,0x8(%esp)
  80062c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800630:	c7 04 24 80 23 80 00 	movl   $0x802380,(%esp)
  800637:	e8 c3 00 00 00       	call   8006ff <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80063c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800640:	8b 45 10             	mov    0x10(%ebp),%eax
  800643:	89 04 24             	mov    %eax,(%esp)
  800646:	e8 53 00 00 00       	call   80069e <vcprintf>
	cprintf("\n");
  80064b:	c7 04 24 90 22 80 00 	movl   $0x802290,(%esp)
  800652:	e8 a8 00 00 00       	call   8006ff <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800657:	cc                   	int3   
  800658:	eb fd                	jmp    800657 <_panic+0x53>
  80065a:	66 90                	xchg   %ax,%ax

0080065c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80065c:	55                   	push   %ebp
  80065d:	89 e5                	mov    %esp,%ebp
  80065f:	53                   	push   %ebx
  800660:	83 ec 14             	sub    $0x14,%esp
  800663:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800666:	8b 03                	mov    (%ebx),%eax
  800668:	8b 55 08             	mov    0x8(%ebp),%edx
  80066b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80066f:	83 c0 01             	add    $0x1,%eax
  800672:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800674:	3d ff 00 00 00       	cmp    $0xff,%eax
  800679:	75 19                	jne    800694 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80067b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800682:	00 
  800683:	8d 43 08             	lea    0x8(%ebx),%eax
  800686:	89 04 24             	mov    %eax,(%esp)
  800689:	e8 f2 0a 00 00       	call   801180 <sys_cputs>
		b->idx = 0;
  80068e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800694:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800698:	83 c4 14             	add    $0x14,%esp
  80069b:	5b                   	pop    %ebx
  80069c:	5d                   	pop    %ebp
  80069d:	c3                   	ret    

0080069e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8006a7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006ae:	00 00 00 
	b.cnt = 0;
  8006b1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006b8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d3:	c7 04 24 5c 06 80 00 	movl   $0x80065c,(%esp)
  8006da:	e8 b3 01 00 00       	call   800892 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006df:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	e8 89 0a 00 00       	call   801180 <sys_cputs>

	return b.cnt;
}
  8006f7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800705:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800708:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	89 04 24             	mov    %eax,(%esp)
  800712:	e8 87 ff ff ff       	call   80069e <vcprintf>
	va_end(ap);

	return cnt;
}
  800717:	c9                   	leave  
  800718:	c3                   	ret    
  800719:	66 90                	xchg   %ax,%ax
  80071b:	66 90                	xchg   %ax,%ax
  80071d:	66 90                	xchg   %ax,%ax
  80071f:	90                   	nop

00800720 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	57                   	push   %edi
  800724:	56                   	push   %esi
  800725:	53                   	push   %ebx
  800726:	83 ec 4c             	sub    $0x4c,%esp
  800729:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80072c:	89 d7                	mov    %edx,%edi
  80072e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800731:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800734:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800737:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
  80073f:	39 d8                	cmp    %ebx,%eax
  800741:	72 17                	jb     80075a <printnum+0x3a>
  800743:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800746:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800749:	76 0f                	jbe    80075a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80074b:	8b 75 14             	mov    0x14(%ebp),%esi
  80074e:	83 ee 01             	sub    $0x1,%esi
  800751:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800754:	85 f6                	test   %esi,%esi
  800756:	7f 63                	jg     8007bb <printnum+0x9b>
  800758:	eb 75                	jmp    8007cf <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80075a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80075d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	83 e8 01             	sub    $0x1,%eax
  800767:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80076e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800772:	8b 44 24 08          	mov    0x8(%esp),%eax
  800776:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80077a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80077d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800780:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800787:	00 
  800788:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80078b:	89 1c 24             	mov    %ebx,(%esp)
  80078e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800791:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800795:	e8 e6 17 00 00       	call   801f80 <__udivdi3>
  80079a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80079d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007a0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007a4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007af:	89 fa                	mov    %edi,%edx
  8007b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007b4:	e8 67 ff ff ff       	call   800720 <printnum>
  8007b9:	eb 14                	jmp    8007cf <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007bb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007bf:	8b 45 18             	mov    0x18(%ebp),%eax
  8007c2:	89 04 24             	mov    %eax,(%esp)
  8007c5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007c7:	83 ee 01             	sub    $0x1,%esi
  8007ca:	75 ef                	jne    8007bb <printnum+0x9b>
  8007cc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007cf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007de:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007e5:	00 
  8007e6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8007e9:	89 1c 24             	mov    %ebx,(%esp)
  8007ec:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8007ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f3:	e8 d8 18 00 00       	call   8020d0 <__umoddi3>
  8007f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007fc:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  800803:	89 04 24             	mov    %eax,(%esp)
  800806:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800809:	ff d0                	call   *%eax
}
  80080b:	83 c4 4c             	add    $0x4c,%esp
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5f                   	pop    %edi
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800816:	83 fa 01             	cmp    $0x1,%edx
  800819:	7e 0e                	jle    800829 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80081b:	8b 10                	mov    (%eax),%edx
  80081d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800820:	89 08                	mov    %ecx,(%eax)
  800822:	8b 02                	mov    (%edx),%eax
  800824:	8b 52 04             	mov    0x4(%edx),%edx
  800827:	eb 22                	jmp    80084b <getuint+0x38>
	else if (lflag)
  800829:	85 d2                	test   %edx,%edx
  80082b:	74 10                	je     80083d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80082d:	8b 10                	mov    (%eax),%edx
  80082f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800832:	89 08                	mov    %ecx,(%eax)
  800834:	8b 02                	mov    (%edx),%eax
  800836:	ba 00 00 00 00       	mov    $0x0,%edx
  80083b:	eb 0e                	jmp    80084b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80083d:	8b 10                	mov    (%eax),%edx
  80083f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800842:	89 08                	mov    %ecx,(%eax)
  800844:	8b 02                	mov    (%edx),%eax
  800846:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800853:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800857:	8b 10                	mov    (%eax),%edx
  800859:	3b 50 04             	cmp    0x4(%eax),%edx
  80085c:	73 0a                	jae    800868 <sprintputch+0x1b>
		*b->buf++ = ch;
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	88 0a                	mov    %cl,(%edx)
  800863:	83 c2 01             	add    $0x1,%edx
  800866:	89 10                	mov    %edx,(%eax)
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800870:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800873:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800877:	8b 45 10             	mov    0x10(%ebp),%eax
  80087a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800881:	89 44 24 04          	mov    %eax,0x4(%esp)
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	89 04 24             	mov    %eax,(%esp)
  80088b:	e8 02 00 00 00       	call   800892 <vprintfmt>
	va_end(ap);
}
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	83 ec 4c             	sub    $0x4c,%esp
  80089b:	8b 75 08             	mov    0x8(%ebp),%esi
  80089e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008a4:	eb 11                	jmp    8008b7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	0f 84 db 03 00 00    	je     800c89 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  8008ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b2:	89 04 24             	mov    %eax,(%esp)
  8008b5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008b7:	0f b6 07             	movzbl (%edi),%eax
  8008ba:	83 c7 01             	add    $0x1,%edi
  8008bd:	83 f8 25             	cmp    $0x25,%eax
  8008c0:	75 e4                	jne    8008a6 <vprintfmt+0x14>
  8008c2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  8008c6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8008cd:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8008d4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008db:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e0:	eb 2b                	jmp    80090d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008e5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  8008e9:	eb 22                	jmp    80090d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008eb:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008ee:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8008f2:	eb 19                	jmp    80090d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8008f7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008fe:	eb 0d                	jmp    80090d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800900:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800903:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800906:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090d:	0f b6 0f             	movzbl (%edi),%ecx
  800910:	8d 47 01             	lea    0x1(%edi),%eax
  800913:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800916:	0f b6 07             	movzbl (%edi),%eax
  800919:	83 e8 23             	sub    $0x23,%eax
  80091c:	3c 55                	cmp    $0x55,%al
  80091e:	0f 87 40 03 00 00    	ja     800c64 <vprintfmt+0x3d2>
  800924:	0f b6 c0             	movzbl %al,%eax
  800927:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80092e:	83 e9 30             	sub    $0x30,%ecx
  800931:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800934:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800938:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80093b:	83 f9 09             	cmp    $0x9,%ecx
  80093e:	77 57                	ja     800997 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800940:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800943:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800946:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800949:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80094c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80094f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800953:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800956:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800959:	83 f9 09             	cmp    $0x9,%ecx
  80095c:	76 eb                	jbe    800949 <vprintfmt+0xb7>
  80095e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800961:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800964:	eb 34                	jmp    80099a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800966:	8b 45 14             	mov    0x14(%ebp),%eax
  800969:	8d 48 04             	lea    0x4(%eax),%ecx
  80096c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80096f:	8b 00                	mov    (%eax),%eax
  800971:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800974:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800977:	eb 21                	jmp    80099a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800979:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80097d:	0f 88 71 ff ff ff    	js     8008f4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800983:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800986:	eb 85                	jmp    80090d <vprintfmt+0x7b>
  800988:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80098b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800992:	e9 76 ff ff ff       	jmp    80090d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800997:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80099a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80099e:	0f 89 69 ff ff ff    	jns    80090d <vprintfmt+0x7b>
  8009a4:	e9 57 ff ff ff       	jmp    800900 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009a9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009af:	e9 59 ff ff ff       	jmp    80090d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b7:	8d 50 04             	lea    0x4(%eax),%edx
  8009ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8009bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c1:	8b 00                	mov    (%eax),%eax
  8009c3:	89 04 24             	mov    %eax,(%esp)
  8009c6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009cb:	e9 e7 fe ff ff       	jmp    8008b7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d3:	8d 50 04             	lea    0x4(%eax),%edx
  8009d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8009d9:	8b 00                	mov    (%eax),%eax
  8009db:	89 c2                	mov    %eax,%edx
  8009dd:	c1 fa 1f             	sar    $0x1f,%edx
  8009e0:	31 d0                	xor    %edx,%eax
  8009e2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009e4:	83 f8 0f             	cmp    $0xf,%eax
  8009e7:	7f 0b                	jg     8009f4 <vprintfmt+0x162>
  8009e9:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8009f0:	85 d2                	test   %edx,%edx
  8009f2:	75 20                	jne    800a14 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8009f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f8:	c7 44 24 08 bb 23 80 	movl   $0x8023bb,0x8(%esp)
  8009ff:	00 
  800a00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a04:	89 34 24             	mov    %esi,(%esp)
  800a07:	e8 5e fe ff ff       	call   80086a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800a0f:	e9 a3 fe ff ff       	jmp    8008b7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800a14:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a18:	c7 44 24 08 c4 23 80 	movl   $0x8023c4,0x8(%esp)
  800a1f:	00 
  800a20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a24:	89 34 24             	mov    %esi,(%esp)
  800a27:	e8 3e fe ff ff       	call   80086a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a2c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800a2f:	e9 83 fe ff ff       	jmp    8008b7 <vprintfmt+0x25>
  800a34:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800a37:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a3a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a3d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a40:	8d 50 04             	lea    0x4(%eax),%edx
  800a43:	89 55 14             	mov    %edx,0x14(%ebp)
  800a46:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a48:	85 ff                	test   %edi,%edi
  800a4a:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  800a4f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a52:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800a56:	74 06                	je     800a5e <vprintfmt+0x1cc>
  800a58:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a5c:	7f 16                	jg     800a74 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a5e:	0f b6 17             	movzbl (%edi),%edx
  800a61:	0f be c2             	movsbl %dl,%eax
  800a64:	83 c7 01             	add    $0x1,%edi
  800a67:	85 c0                	test   %eax,%eax
  800a69:	0f 85 9f 00 00 00    	jne    800b0e <vprintfmt+0x27c>
  800a6f:	e9 8b 00 00 00       	jmp    800aff <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a74:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a78:	89 3c 24             	mov    %edi,(%esp)
  800a7b:	e8 c2 02 00 00       	call   800d42 <strnlen>
  800a80:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800a83:	29 c2                	sub    %eax,%edx
  800a85:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800a88:	85 d2                	test   %edx,%edx
  800a8a:	7e d2                	jle    800a5e <vprintfmt+0x1cc>
					putch(padc, putdat);
  800a8c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800a90:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800a93:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800a96:	89 d7                	mov    %edx,%edi
  800a98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a9f:	89 04 24             	mov    %eax,(%esp)
  800aa2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800aa4:	83 ef 01             	sub    $0x1,%edi
  800aa7:	75 ef                	jne    800a98 <vprintfmt+0x206>
  800aa9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800aac:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800aaf:	eb ad                	jmp    800a5e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ab1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800ab5:	74 20                	je     800ad7 <vprintfmt+0x245>
  800ab7:	0f be d2             	movsbl %dl,%edx
  800aba:	83 ea 20             	sub    $0x20,%edx
  800abd:	83 fa 5e             	cmp    $0x5e,%edx
  800ac0:	76 15                	jbe    800ad7 <vprintfmt+0x245>
					putch('?', putdat);
  800ac2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ac5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ac9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ad0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800ad3:	ff d1                	call   *%ecx
  800ad5:	eb 0f                	jmp    800ae6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800ad7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ada:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ade:	89 04 24             	mov    %eax,(%esp)
  800ae1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800ae4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ae6:	83 eb 01             	sub    $0x1,%ebx
  800ae9:	0f b6 17             	movzbl (%edi),%edx
  800aec:	0f be c2             	movsbl %dl,%eax
  800aef:	83 c7 01             	add    $0x1,%edi
  800af2:	85 c0                	test   %eax,%eax
  800af4:	75 24                	jne    800b1a <vprintfmt+0x288>
  800af6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800af9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800afc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aff:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b02:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b06:	0f 8e ab fd ff ff    	jle    8008b7 <vprintfmt+0x25>
  800b0c:	eb 20                	jmp    800b2e <vprintfmt+0x29c>
  800b0e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800b11:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800b14:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800b17:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b1a:	85 f6                	test   %esi,%esi
  800b1c:	78 93                	js     800ab1 <vprintfmt+0x21f>
  800b1e:	83 ee 01             	sub    $0x1,%esi
  800b21:	79 8e                	jns    800ab1 <vprintfmt+0x21f>
  800b23:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800b26:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800b29:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800b2c:	eb d1                	jmp    800aff <vprintfmt+0x26d>
  800b2e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b35:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b3c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b3e:	83 ef 01             	sub    $0x1,%edi
  800b41:	75 ee                	jne    800b31 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b43:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800b46:	e9 6c fd ff ff       	jmp    8008b7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b4b:	83 fa 01             	cmp    $0x1,%edx
  800b4e:	66 90                	xchg   %ax,%ax
  800b50:	7e 16                	jle    800b68 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800b52:	8b 45 14             	mov    0x14(%ebp),%eax
  800b55:	8d 50 08             	lea    0x8(%eax),%edx
  800b58:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5b:	8b 10                	mov    (%eax),%edx
  800b5d:	8b 48 04             	mov    0x4(%eax),%ecx
  800b60:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800b63:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800b66:	eb 32                	jmp    800b9a <vprintfmt+0x308>
	else if (lflag)
  800b68:	85 d2                	test   %edx,%edx
  800b6a:	74 18                	je     800b84 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  800b6c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6f:	8d 50 04             	lea    0x4(%eax),%edx
  800b72:	89 55 14             	mov    %edx,0x14(%ebp)
  800b75:	8b 00                	mov    (%eax),%eax
  800b77:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b7a:	89 c1                	mov    %eax,%ecx
  800b7c:	c1 f9 1f             	sar    $0x1f,%ecx
  800b7f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800b82:	eb 16                	jmp    800b9a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800b84:	8b 45 14             	mov    0x14(%ebp),%eax
  800b87:	8d 50 04             	lea    0x4(%eax),%edx
  800b8a:	89 55 14             	mov    %edx,0x14(%ebp)
  800b8d:	8b 00                	mov    (%eax),%eax
  800b8f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b92:	89 c7                	mov    %eax,%edi
  800b94:	c1 ff 1f             	sar    $0x1f,%edi
  800b97:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b9a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b9d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ba0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ba5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800ba9:	79 7d                	jns    800c28 <vprintfmt+0x396>
				putch('-', putdat);
  800bab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800baf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800bb6:	ff d6                	call   *%esi
				num = -(long long) num;
  800bb8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800bbb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800bbe:	f7 d8                	neg    %eax
  800bc0:	83 d2 00             	adc    $0x0,%edx
  800bc3:	f7 da                	neg    %edx
			}
			base = 10;
  800bc5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bca:	eb 5c                	jmp    800c28 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bcc:	8d 45 14             	lea    0x14(%ebp),%eax
  800bcf:	e8 3f fc ff ff       	call   800813 <getuint>
			base = 10;
  800bd4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800bd9:	eb 4d                	jmp    800c28 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800bdb:	8d 45 14             	lea    0x14(%ebp),%eax
  800bde:	e8 30 fc ff ff       	call   800813 <getuint>
			base = 8;
  800be3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800be8:	eb 3e                	jmp    800c28 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800bea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bee:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800bf5:	ff d6                	call   *%esi
			putch('x', putdat);
  800bf7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bfb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c02:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c04:	8b 45 14             	mov    0x14(%ebp),%eax
  800c07:	8d 50 04             	lea    0x4(%eax),%edx
  800c0a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800c0d:	8b 00                	mov    (%eax),%eax
  800c0f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800c14:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800c19:	eb 0d                	jmp    800c28 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c1b:	8d 45 14             	lea    0x14(%ebp),%eax
  800c1e:	e8 f0 fb ff ff       	call   800813 <getuint>
			base = 16;
  800c23:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c28:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  800c2c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800c30:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800c33:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c37:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c3b:	89 04 24             	mov    %eax,(%esp)
  800c3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c42:	89 da                	mov    %ebx,%edx
  800c44:	89 f0                	mov    %esi,%eax
  800c46:	e8 d5 fa ff ff       	call   800720 <printnum>
			break;
  800c4b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800c4e:	e9 64 fc ff ff       	jmp    8008b7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c57:	89 0c 24             	mov    %ecx,(%esp)
  800c5a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c5c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c5f:	e9 53 fc ff ff       	jmp    8008b7 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c64:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c68:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c6f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c71:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c75:	0f 84 3c fc ff ff    	je     8008b7 <vprintfmt+0x25>
  800c7b:	83 ef 01             	sub    $0x1,%edi
  800c7e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c82:	75 f7                	jne    800c7b <vprintfmt+0x3e9>
  800c84:	e9 2e fc ff ff       	jmp    8008b7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800c89:	83 c4 4c             	add    $0x4c,%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	83 ec 28             	sub    $0x28,%esp
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ca4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ca7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cae:	85 d2                	test   %edx,%edx
  800cb0:	7e 30                	jle    800ce2 <vsnprintf+0x51>
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	74 2c                	je     800ce2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cb6:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cbd:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cc4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ccb:	c7 04 24 4d 08 80 00 	movl   $0x80084d,(%esp)
  800cd2:	e8 bb fb ff ff       	call   800892 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cda:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce0:	eb 05                	jmp    800ce7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ce2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ce7:	c9                   	leave  
  800ce8:	c3                   	ret    

00800ce9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cf6:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	89 04 24             	mov    %eax,(%esp)
  800d0a:	e8 82 ff ff ff       	call   800c91 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d0f:	c9                   	leave  
  800d10:	c3                   	ret    
  800d11:	66 90                	xchg   %ax,%ax
  800d13:	66 90                	xchg   %ax,%ax
  800d15:	66 90                	xchg   %ax,%ax
  800d17:	66 90                	xchg   %ax,%ax
  800d19:	66 90                	xchg   %ax,%ax
  800d1b:	66 90                	xchg   %ax,%ax
  800d1d:	66 90                	xchg   %ax,%ax
  800d1f:	90                   	nop

00800d20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d26:	80 3a 00             	cmpb   $0x0,(%edx)
  800d29:	74 10                	je     800d3b <strlen+0x1b>
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d30:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d33:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d37:	75 f7                	jne    800d30 <strlen+0x10>
  800d39:	eb 05                	jmp    800d40 <strlen+0x20>
  800d3b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	53                   	push   %ebx
  800d46:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d4c:	85 c9                	test   %ecx,%ecx
  800d4e:	74 1c                	je     800d6c <strnlen+0x2a>
  800d50:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d53:	74 1e                	je     800d73 <strnlen+0x31>
  800d55:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d5a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d5c:	39 ca                	cmp    %ecx,%edx
  800d5e:	74 18                	je     800d78 <strnlen+0x36>
  800d60:	83 c2 01             	add    $0x1,%edx
  800d63:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d68:	75 f0                	jne    800d5a <strnlen+0x18>
  800d6a:	eb 0c                	jmp    800d78 <strnlen+0x36>
  800d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d71:	eb 05                	jmp    800d78 <strnlen+0x36>
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d78:	5b                   	pop    %ebx
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	53                   	push   %ebx
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d85:	89 c2                	mov    %eax,%edx
  800d87:	0f b6 19             	movzbl (%ecx),%ebx
  800d8a:	88 1a                	mov    %bl,(%edx)
  800d8c:	83 c2 01             	add    $0x1,%edx
  800d8f:	83 c1 01             	add    $0x1,%ecx
  800d92:	84 db                	test   %bl,%bl
  800d94:	75 f1                	jne    800d87 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d96:	5b                   	pop    %ebx
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 08             	sub    $0x8,%esp
  800da0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800da3:	89 1c 24             	mov    %ebx,(%esp)
  800da6:	e8 75 ff ff ff       	call   800d20 <strlen>
	strcpy(dst + len, src);
  800dab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dae:	89 54 24 04          	mov    %edx,0x4(%esp)
  800db2:	01 d8                	add    %ebx,%eax
  800db4:	89 04 24             	mov    %eax,(%esp)
  800db7:	e8 bf ff ff ff       	call   800d7b <strcpy>
	return dst;
}
  800dbc:	89 d8                	mov    %ebx,%eax
  800dbe:	83 c4 08             	add    $0x8,%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	8b 75 08             	mov    0x8(%ebp),%esi
  800dcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dd2:	85 db                	test   %ebx,%ebx
  800dd4:	74 16                	je     800dec <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800dd6:	01 f3                	add    %esi,%ebx
  800dd8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800dda:	0f b6 02             	movzbl (%edx),%eax
  800ddd:	88 01                	mov    %al,(%ecx)
  800ddf:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800de2:	80 3a 01             	cmpb   $0x1,(%edx)
  800de5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800de8:	39 d9                	cmp    %ebx,%ecx
  800dea:	75 ee                	jne    800dda <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dec:	89 f0                	mov    %esi,%eax
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dfb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dfe:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e01:	89 f8                	mov    %edi,%eax
  800e03:	85 f6                	test   %esi,%esi
  800e05:	74 33                	je     800e3a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800e07:	83 fe 01             	cmp    $0x1,%esi
  800e0a:	74 25                	je     800e31 <strlcpy+0x3f>
  800e0c:	0f b6 0b             	movzbl (%ebx),%ecx
  800e0f:	84 c9                	test   %cl,%cl
  800e11:	74 22                	je     800e35 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800e13:	83 ee 02             	sub    $0x2,%esi
  800e16:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e1b:	88 08                	mov    %cl,(%eax)
  800e1d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e20:	39 f2                	cmp    %esi,%edx
  800e22:	74 13                	je     800e37 <strlcpy+0x45>
  800e24:	83 c2 01             	add    $0x1,%edx
  800e27:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800e2b:	84 c9                	test   %cl,%cl
  800e2d:	75 ec                	jne    800e1b <strlcpy+0x29>
  800e2f:	eb 06                	jmp    800e37 <strlcpy+0x45>
  800e31:	89 f8                	mov    %edi,%eax
  800e33:	eb 02                	jmp    800e37 <strlcpy+0x45>
  800e35:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e37:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e3a:	29 f8                	sub    %edi,%eax
}
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e47:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e4a:	0f b6 01             	movzbl (%ecx),%eax
  800e4d:	84 c0                	test   %al,%al
  800e4f:	74 15                	je     800e66 <strcmp+0x25>
  800e51:	3a 02                	cmp    (%edx),%al
  800e53:	75 11                	jne    800e66 <strcmp+0x25>
		p++, q++;
  800e55:	83 c1 01             	add    $0x1,%ecx
  800e58:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e5b:	0f b6 01             	movzbl (%ecx),%eax
  800e5e:	84 c0                	test   %al,%al
  800e60:	74 04                	je     800e66 <strcmp+0x25>
  800e62:	3a 02                	cmp    (%edx),%al
  800e64:	74 ef                	je     800e55 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e66:	0f b6 c0             	movzbl %al,%eax
  800e69:	0f b6 12             	movzbl (%edx),%edx
  800e6c:	29 d0                	sub    %edx,%eax
}
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    

00800e70 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e7e:	85 f6                	test   %esi,%esi
  800e80:	74 29                	je     800eab <strncmp+0x3b>
  800e82:	0f b6 03             	movzbl (%ebx),%eax
  800e85:	84 c0                	test   %al,%al
  800e87:	74 30                	je     800eb9 <strncmp+0x49>
  800e89:	3a 02                	cmp    (%edx),%al
  800e8b:	75 2c                	jne    800eb9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800e8d:	8d 43 01             	lea    0x1(%ebx),%eax
  800e90:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800e92:	89 c3                	mov    %eax,%ebx
  800e94:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e97:	39 f0                	cmp    %esi,%eax
  800e99:	74 17                	je     800eb2 <strncmp+0x42>
  800e9b:	0f b6 08             	movzbl (%eax),%ecx
  800e9e:	84 c9                	test   %cl,%cl
  800ea0:	74 17                	je     800eb9 <strncmp+0x49>
  800ea2:	83 c0 01             	add    $0x1,%eax
  800ea5:	3a 0a                	cmp    (%edx),%cl
  800ea7:	74 e9                	je     800e92 <strncmp+0x22>
  800ea9:	eb 0e                	jmp    800eb9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800eab:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb0:	eb 0f                	jmp    800ec1 <strncmp+0x51>
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	eb 08                	jmp    800ec1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800eb9:	0f b6 03             	movzbl (%ebx),%eax
  800ebc:	0f b6 12             	movzbl (%edx),%edx
  800ebf:	29 d0                	sub    %edx,%eax
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	53                   	push   %ebx
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecc:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ecf:	0f b6 18             	movzbl (%eax),%ebx
  800ed2:	84 db                	test   %bl,%bl
  800ed4:	74 1d                	je     800ef3 <strchr+0x2e>
  800ed6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800ed8:	38 d3                	cmp    %dl,%bl
  800eda:	75 06                	jne    800ee2 <strchr+0x1d>
  800edc:	eb 1a                	jmp    800ef8 <strchr+0x33>
  800ede:	38 ca                	cmp    %cl,%dl
  800ee0:	74 16                	je     800ef8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ee2:	83 c0 01             	add    $0x1,%eax
  800ee5:	0f b6 10             	movzbl (%eax),%edx
  800ee8:	84 d2                	test   %dl,%dl
  800eea:	75 f2                	jne    800ede <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800eec:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef1:	eb 05                	jmp    800ef8 <strchr+0x33>
  800ef3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef8:	5b                   	pop    %ebx
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	53                   	push   %ebx
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
  800f02:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800f05:	0f b6 18             	movzbl (%eax),%ebx
  800f08:	84 db                	test   %bl,%bl
  800f0a:	74 16                	je     800f22 <strfind+0x27>
  800f0c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800f0e:	38 d3                	cmp    %dl,%bl
  800f10:	75 06                	jne    800f18 <strfind+0x1d>
  800f12:	eb 0e                	jmp    800f22 <strfind+0x27>
  800f14:	38 ca                	cmp    %cl,%dl
  800f16:	74 0a                	je     800f22 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f18:	83 c0 01             	add    $0x1,%eax
  800f1b:	0f b6 10             	movzbl (%eax),%edx
  800f1e:	84 d2                	test   %dl,%dl
  800f20:	75 f2                	jne    800f14 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800f22:	5b                   	pop    %ebx
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f2e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f31:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f34:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f3a:	85 c9                	test   %ecx,%ecx
  800f3c:	74 36                	je     800f74 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f44:	75 28                	jne    800f6e <memset+0x49>
  800f46:	f6 c1 03             	test   $0x3,%cl
  800f49:	75 23                	jne    800f6e <memset+0x49>
		c &= 0xFF;
  800f4b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f4f:	89 d3                	mov    %edx,%ebx
  800f51:	c1 e3 08             	shl    $0x8,%ebx
  800f54:	89 d6                	mov    %edx,%esi
  800f56:	c1 e6 18             	shl    $0x18,%esi
  800f59:	89 d0                	mov    %edx,%eax
  800f5b:	c1 e0 10             	shl    $0x10,%eax
  800f5e:	09 f0                	or     %esi,%eax
  800f60:	09 c2                	or     %eax,%edx
  800f62:	89 d0                	mov    %edx,%eax
  800f64:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f66:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f69:	fc                   	cld    
  800f6a:	f3 ab                	rep stos %eax,%es:(%edi)
  800f6c:	eb 06                	jmp    800f74 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f71:	fc                   	cld    
  800f72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  800f74:	89 f8                	mov    %edi,%eax
  800f76:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f79:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f7c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f7f:	89 ec                	mov    %ebp,%esp
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f92:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f98:	39 c6                	cmp    %eax,%esi
  800f9a:	73 36                	jae    800fd2 <memmove+0x4f>
  800f9c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f9f:	39 d0                	cmp    %edx,%eax
  800fa1:	73 2f                	jae    800fd2 <memmove+0x4f>
		s += n;
		d += n;
  800fa3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fa6:	f6 c2 03             	test   $0x3,%dl
  800fa9:	75 1b                	jne    800fc6 <memmove+0x43>
  800fab:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fb1:	75 13                	jne    800fc6 <memmove+0x43>
  800fb3:	f6 c1 03             	test   $0x3,%cl
  800fb6:	75 0e                	jne    800fc6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800fb8:	83 ef 04             	sub    $0x4,%edi
  800fbb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fbe:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800fc1:	fd                   	std    
  800fc2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fc4:	eb 09                	jmp    800fcf <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800fc6:	83 ef 01             	sub    $0x1,%edi
  800fc9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fcc:	fd                   	std    
  800fcd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fcf:	fc                   	cld    
  800fd0:	eb 20                	jmp    800ff2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fd2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fd8:	75 13                	jne    800fed <memmove+0x6a>
  800fda:	a8 03                	test   $0x3,%al
  800fdc:	75 0f                	jne    800fed <memmove+0x6a>
  800fde:	f6 c1 03             	test   $0x3,%cl
  800fe1:	75 0a                	jne    800fed <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800fe3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800fe6:	89 c7                	mov    %eax,%edi
  800fe8:	fc                   	cld    
  800fe9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800feb:	eb 05                	jmp    800ff2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fed:	89 c7                	mov    %eax,%edi
  800fef:	fc                   	cld    
  800ff0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ff2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff8:	89 ec                	mov    %ebp,%esp
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801002:	8b 45 10             	mov    0x10(%ebp),%eax
  801005:	89 44 24 08          	mov    %eax,0x8(%esp)
  801009:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801010:	8b 45 08             	mov    0x8(%ebp),%eax
  801013:	89 04 24             	mov    %eax,(%esp)
  801016:	e8 68 ff ff ff       	call   800f83 <memmove>
}
  80101b:	c9                   	leave  
  80101c:	c3                   	ret    

0080101d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	57                   	push   %edi
  801021:	56                   	push   %esi
  801022:	53                   	push   %ebx
  801023:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801026:	8b 75 0c             	mov    0xc(%ebp),%esi
  801029:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80102c:	8d 78 ff             	lea    -0x1(%eax),%edi
  80102f:	85 c0                	test   %eax,%eax
  801031:	74 36                	je     801069 <memcmp+0x4c>
		if (*s1 != *s2)
  801033:	0f b6 03             	movzbl (%ebx),%eax
  801036:	0f b6 0e             	movzbl (%esi),%ecx
  801039:	38 c8                	cmp    %cl,%al
  80103b:	75 17                	jne    801054 <memcmp+0x37>
  80103d:	ba 00 00 00 00       	mov    $0x0,%edx
  801042:	eb 1a                	jmp    80105e <memcmp+0x41>
  801044:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801049:	83 c2 01             	add    $0x1,%edx
  80104c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801050:	38 c8                	cmp    %cl,%al
  801052:	74 0a                	je     80105e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801054:	0f b6 c0             	movzbl %al,%eax
  801057:	0f b6 c9             	movzbl %cl,%ecx
  80105a:	29 c8                	sub    %ecx,%eax
  80105c:	eb 10                	jmp    80106e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80105e:	39 fa                	cmp    %edi,%edx
  801060:	75 e2                	jne    801044 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801062:	b8 00 00 00 00       	mov    $0x0,%eax
  801067:	eb 05                	jmp    80106e <memcmp+0x51>
  801069:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80106e:	5b                   	pop    %ebx
  80106f:	5e                   	pop    %esi
  801070:	5f                   	pop    %edi
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	53                   	push   %ebx
  801077:	8b 45 08             	mov    0x8(%ebp),%eax
  80107a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  80107d:	89 c2                	mov    %eax,%edx
  80107f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801082:	39 d0                	cmp    %edx,%eax
  801084:	73 13                	jae    801099 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801086:	89 d9                	mov    %ebx,%ecx
  801088:	38 18                	cmp    %bl,(%eax)
  80108a:	75 06                	jne    801092 <memfind+0x1f>
  80108c:	eb 0b                	jmp    801099 <memfind+0x26>
  80108e:	38 08                	cmp    %cl,(%eax)
  801090:	74 07                	je     801099 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801092:	83 c0 01             	add    $0x1,%eax
  801095:	39 d0                	cmp    %edx,%eax
  801097:	75 f5                	jne    80108e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801099:	5b                   	pop    %ebx
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	57                   	push   %edi
  8010a0:	56                   	push   %esi
  8010a1:	53                   	push   %ebx
  8010a2:	83 ec 04             	sub    $0x4,%esp
  8010a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010ab:	0f b6 02             	movzbl (%edx),%eax
  8010ae:	3c 09                	cmp    $0x9,%al
  8010b0:	74 04                	je     8010b6 <strtol+0x1a>
  8010b2:	3c 20                	cmp    $0x20,%al
  8010b4:	75 0e                	jne    8010c4 <strtol+0x28>
		s++;
  8010b6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010b9:	0f b6 02             	movzbl (%edx),%eax
  8010bc:	3c 09                	cmp    $0x9,%al
  8010be:	74 f6                	je     8010b6 <strtol+0x1a>
  8010c0:	3c 20                	cmp    $0x20,%al
  8010c2:	74 f2                	je     8010b6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010c4:	3c 2b                	cmp    $0x2b,%al
  8010c6:	75 0a                	jne    8010d2 <strtol+0x36>
		s++;
  8010c8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010cb:	bf 00 00 00 00       	mov    $0x0,%edi
  8010d0:	eb 10                	jmp    8010e2 <strtol+0x46>
  8010d2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010d7:	3c 2d                	cmp    $0x2d,%al
  8010d9:	75 07                	jne    8010e2 <strtol+0x46>
		s++, neg = 1;
  8010db:	83 c2 01             	add    $0x1,%edx
  8010de:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010e2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010e8:	75 15                	jne    8010ff <strtol+0x63>
  8010ea:	80 3a 30             	cmpb   $0x30,(%edx)
  8010ed:	75 10                	jne    8010ff <strtol+0x63>
  8010ef:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8010f3:	75 0a                	jne    8010ff <strtol+0x63>
		s += 2, base = 16;
  8010f5:	83 c2 02             	add    $0x2,%edx
  8010f8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010fd:	eb 10                	jmp    80110f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  8010ff:	85 db                	test   %ebx,%ebx
  801101:	75 0c                	jne    80110f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801103:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801105:	80 3a 30             	cmpb   $0x30,(%edx)
  801108:	75 05                	jne    80110f <strtol+0x73>
		s++, base = 8;
  80110a:	83 c2 01             	add    $0x1,%edx
  80110d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80110f:	b8 00 00 00 00       	mov    $0x0,%eax
  801114:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801117:	0f b6 0a             	movzbl (%edx),%ecx
  80111a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80111d:	89 f3                	mov    %esi,%ebx
  80111f:	80 fb 09             	cmp    $0x9,%bl
  801122:	77 08                	ja     80112c <strtol+0x90>
			dig = *s - '0';
  801124:	0f be c9             	movsbl %cl,%ecx
  801127:	83 e9 30             	sub    $0x30,%ecx
  80112a:	eb 22                	jmp    80114e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  80112c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80112f:	89 f3                	mov    %esi,%ebx
  801131:	80 fb 19             	cmp    $0x19,%bl
  801134:	77 08                	ja     80113e <strtol+0xa2>
			dig = *s - 'a' + 10;
  801136:	0f be c9             	movsbl %cl,%ecx
  801139:	83 e9 57             	sub    $0x57,%ecx
  80113c:	eb 10                	jmp    80114e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  80113e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801141:	89 f3                	mov    %esi,%ebx
  801143:	80 fb 19             	cmp    $0x19,%bl
  801146:	77 16                	ja     80115e <strtol+0xc2>
			dig = *s - 'A' + 10;
  801148:	0f be c9             	movsbl %cl,%ecx
  80114b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80114e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801151:	7d 0f                	jge    801162 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801153:	83 c2 01             	add    $0x1,%edx
  801156:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  80115a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80115c:	eb b9                	jmp    801117 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80115e:	89 c1                	mov    %eax,%ecx
  801160:	eb 02                	jmp    801164 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801162:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801164:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801168:	74 05                	je     80116f <strtol+0xd3>
		*endptr = (char *) s;
  80116a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80116d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80116f:	89 ca                	mov    %ecx,%edx
  801171:	f7 da                	neg    %edx
  801173:	85 ff                	test   %edi,%edi
  801175:	0f 45 c2             	cmovne %edx,%eax
}
  801178:	83 c4 04             	add    $0x4,%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	83 ec 0c             	sub    $0xc,%esp
  801186:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801189:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80118c:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  80118f:	b8 01 00 00 00       	mov    $0x1,%eax
  801194:	0f a2                	cpuid  
  801196:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801198:	b8 00 00 00 00       	mov    $0x0,%eax
  80119d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a3:	89 c3                	mov    %eax,%ebx
  8011a5:	89 c7                	mov    %eax,%edi
  8011a7:	89 c6                	mov    %eax,%esi
  8011a9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8011ab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011ae:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011b1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011b4:	89 ec                	mov    %ebp,%esp
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	83 ec 0c             	sub    $0xc,%esp
  8011be:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011c1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011c4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8011c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8011cc:	0f a2                	cpuid  
  8011ce:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8011da:	89 d1                	mov    %edx,%ecx
  8011dc:	89 d3                	mov    %edx,%ebx
  8011de:	89 d7                	mov    %edx,%edi
  8011e0:	89 d6                	mov    %edx,%esi
  8011e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011e4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011e7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011ea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ed:	89 ec                	mov    %ebp,%esp
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	83 ec 38             	sub    $0x38,%esp
  8011f7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011fa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011fd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801200:	b8 01 00 00 00       	mov    $0x1,%eax
  801205:	0f a2                	cpuid  
  801207:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801209:	b9 00 00 00 00       	mov    $0x0,%ecx
  80120e:	b8 03 00 00 00       	mov    $0x3,%eax
  801213:	8b 55 08             	mov    0x8(%ebp),%edx
  801216:	89 cb                	mov    %ecx,%ebx
  801218:	89 cf                	mov    %ecx,%edi
  80121a:	89 ce                	mov    %ecx,%esi
  80121c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80121e:	85 c0                	test   %eax,%eax
  801220:	7e 28                	jle    80124a <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801222:	89 44 24 10          	mov    %eax,0x10(%esp)
  801226:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80122d:	00 
  80122e:	c7 44 24 08 9f 26 80 	movl   $0x80269f,0x8(%esp)
  801235:	00 
  801236:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80123d:	00 
  80123e:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  801245:	e8 ba f3 ff ff       	call   800604 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80124a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80124d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801250:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801253:	89 ec                	mov    %ebp,%esp
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	83 ec 0c             	sub    $0xc,%esp
  80125d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801260:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801263:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801266:	b8 01 00 00 00       	mov    $0x1,%eax
  80126b:	0f a2                	cpuid  
  80126d:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80126f:	ba 00 00 00 00       	mov    $0x0,%edx
  801274:	b8 02 00 00 00       	mov    $0x2,%eax
  801279:	89 d1                	mov    %edx,%ecx
  80127b:	89 d3                	mov    %edx,%ebx
  80127d:	89 d7                	mov    %edx,%edi
  80127f:	89 d6                	mov    %edx,%esi
  801281:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801283:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801286:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801289:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80128c:	89 ec                	mov    %ebp,%esp
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <sys_yield>:

void
sys_yield(void)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	83 ec 0c             	sub    $0xc,%esp
  801296:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801299:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80129c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80129f:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a4:	0f a2                	cpuid  
  8012a6:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ad:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012b2:	89 d1                	mov    %edx,%ecx
  8012b4:	89 d3                	mov    %edx,%ebx
  8012b6:	89 d7                	mov    %edx,%edi
  8012b8:	89 d6                	mov    %edx,%esi
  8012ba:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012bc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012bf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012c2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012c5:	89 ec                	mov    %ebp,%esp
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	83 ec 38             	sub    $0x38,%esp
  8012cf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012d2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012d5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8012d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8012dd:	0f a2                	cpuid  
  8012df:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012e1:	be 00 00 00 00       	mov    $0x0,%esi
  8012e6:	b8 04 00 00 00       	mov    $0x4,%eax
  8012eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012f4:	89 f7                	mov    %esi,%edi
  8012f6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	7e 28                	jle    801324 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801300:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801307:	00 
  801308:	c7 44 24 08 9f 26 80 	movl   $0x80269f,0x8(%esp)
  80130f:	00 
  801310:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801317:	00 
  801318:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  80131f:	e8 e0 f2 ff ff       	call   800604 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801324:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801327:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80132a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80132d:	89 ec                	mov    %ebp,%esp
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	83 ec 38             	sub    $0x38,%esp
  801337:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80133a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80133d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801340:	b8 01 00 00 00       	mov    $0x1,%eax
  801345:	0f a2                	cpuid  
  801347:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801349:	b8 05 00 00 00       	mov    $0x5,%eax
  80134e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801351:	8b 55 08             	mov    0x8(%ebp),%edx
  801354:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801357:	8b 7d 14             	mov    0x14(%ebp),%edi
  80135a:	8b 75 18             	mov    0x18(%ebp),%esi
  80135d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80135f:	85 c0                	test   %eax,%eax
  801361:	7e 28                	jle    80138b <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801363:	89 44 24 10          	mov    %eax,0x10(%esp)
  801367:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80136e:	00 
  80136f:	c7 44 24 08 9f 26 80 	movl   $0x80269f,0x8(%esp)
  801376:	00 
  801377:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80137e:	00 
  80137f:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  801386:	e8 79 f2 ff ff       	call   800604 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80138b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80138e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801391:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801394:	89 ec                	mov    %ebp,%esp
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    

00801398 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	83 ec 38             	sub    $0x38,%esp
  80139e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013a1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013a4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ac:	0f a2                	cpuid  
  8013ae:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b5:	b8 06 00 00 00       	mov    $0x6,%eax
  8013ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c0:	89 df                	mov    %ebx,%edi
  8013c2:	89 de                	mov    %ebx,%esi
  8013c4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	7e 28                	jle    8013f2 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013ce:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8013d5:	00 
  8013d6:	c7 44 24 08 9f 26 80 	movl   $0x80269f,0x8(%esp)
  8013dd:	00 
  8013de:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8013e5:	00 
  8013e6:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  8013ed:	e8 12 f2 ff ff       	call   800604 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013f5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013fb:	89 ec                	mov    %ebp,%esp
  8013fd:	5d                   	pop    %ebp
  8013fe:	c3                   	ret    

008013ff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	83 ec 38             	sub    $0x38,%esp
  801405:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801408:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80140b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80140e:	b8 01 00 00 00       	mov    $0x1,%eax
  801413:	0f a2                	cpuid  
  801415:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801417:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141c:	b8 08 00 00 00       	mov    $0x8,%eax
  801421:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801424:	8b 55 08             	mov    0x8(%ebp),%edx
  801427:	89 df                	mov    %ebx,%edi
  801429:	89 de                	mov    %ebx,%esi
  80142b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80142d:	85 c0                	test   %eax,%eax
  80142f:	7e 28                	jle    801459 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801431:	89 44 24 10          	mov    %eax,0x10(%esp)
  801435:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80143c:	00 
  80143d:	c7 44 24 08 9f 26 80 	movl   $0x80269f,0x8(%esp)
  801444:	00 
  801445:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80144c:	00 
  80144d:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  801454:	e8 ab f1 ff ff       	call   800604 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801459:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80145c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80145f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801462:	89 ec                	mov    %ebp,%esp
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    

00801466 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	83 ec 38             	sub    $0x38,%esp
  80146c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80146f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801472:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801475:	b8 01 00 00 00       	mov    $0x1,%eax
  80147a:	0f a2                	cpuid  
  80147c:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80147e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801483:	b8 09 00 00 00       	mov    $0x9,%eax
  801488:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148b:	8b 55 08             	mov    0x8(%ebp),%edx
  80148e:	89 df                	mov    %ebx,%edi
  801490:	89 de                	mov    %ebx,%esi
  801492:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801494:	85 c0                	test   %eax,%eax
  801496:	7e 28                	jle    8014c0 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801498:	89 44 24 10          	mov    %eax,0x10(%esp)
  80149c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8014a3:	00 
  8014a4:	c7 44 24 08 9f 26 80 	movl   $0x80269f,0x8(%esp)
  8014ab:	00 
  8014ac:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8014b3:	00 
  8014b4:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  8014bb:	e8 44 f1 ff ff       	call   800604 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8014c0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014c3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014c6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014c9:	89 ec                	mov    %ebp,%esp
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    

008014cd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	83 ec 38             	sub    $0x38,%esp
  8014d3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014d6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014d9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e1:	0f a2                	cpuid  
  8014e3:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f5:	89 df                	mov    %ebx,%edi
  8014f7:	89 de                	mov    %ebx,%esi
  8014f9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	7e 28                	jle    801527 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  801503:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80150a:	00 
  80150b:	c7 44 24 08 9f 26 80 	movl   $0x80269f,0x8(%esp)
  801512:	00 
  801513:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80151a:	00 
  80151b:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  801522:	e8 dd f0 ff ff       	call   800604 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801527:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80152a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80152d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801530:	89 ec                	mov    %ebp,%esp
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    

00801534 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	83 ec 0c             	sub    $0xc,%esp
  80153a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80153d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801540:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801543:	b8 01 00 00 00       	mov    $0x1,%eax
  801548:	0f a2                	cpuid  
  80154a:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80154c:	be 00 00 00 00       	mov    $0x0,%esi
  801551:	b8 0c 00 00 00       	mov    $0xc,%eax
  801556:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801559:	8b 55 08             	mov    0x8(%ebp),%edx
  80155c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80155f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801562:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801564:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801567:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80156a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80156d:	89 ec                	mov    %ebp,%esp
  80156f:	5d                   	pop    %ebp
  801570:	c3                   	ret    

00801571 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	83 ec 38             	sub    $0x38,%esp
  801577:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80157a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80157d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801580:	b8 01 00 00 00       	mov    $0x1,%eax
  801585:	0f a2                	cpuid  
  801587:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801589:	b9 00 00 00 00       	mov    $0x0,%ecx
  80158e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801593:	8b 55 08             	mov    0x8(%ebp),%edx
  801596:	89 cb                	mov    %ecx,%ebx
  801598:	89 cf                	mov    %ecx,%edi
  80159a:	89 ce                	mov    %ecx,%esi
  80159c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	7e 28                	jle    8015ca <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015a6:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8015ad:	00 
  8015ae:	c7 44 24 08 9f 26 80 	movl   $0x80269f,0x8(%esp)
  8015b5:	00 
  8015b6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8015bd:	00 
  8015be:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  8015c5:	e8 3a f0 ff ff       	call   800604 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8015ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015d3:	89 ec                	mov    %ebp,%esp
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    
  8015d7:	90                   	nop

008015d8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8015de:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8015e5:	75 54                	jne    80163b <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  8015e7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015ee:	00 
  8015ef:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015f6:	ee 
  8015f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015fe:	e8 c6 fc ff ff       	call   8012c9 <sys_page_alloc>
  801603:	85 c0                	test   %eax,%eax
  801605:	74 20                	je     801627 <set_pgfault_handler+0x4f>
			panic("sys_page_alloc() failed in set_pgfault_handler()[%e]\n", r);
  801607:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80160b:	c7 44 24 08 cc 26 80 	movl   $0x8026cc,0x8(%esp)
  801612:	00 
  801613:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80161a:	00 
  80161b:	c7 04 24 02 27 80 00 	movl   $0x802702,(%esp)
  801622:	e8 dd ef ff ff       	call   800604 <_panic>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801627:	c7 44 24 04 48 16 80 	movl   $0x801648,0x4(%esp)
  80162e:	00 
  80162f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801636:	e8 92 fe ff ff       	call   8014cd <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80163b:	8b 45 08             	mov    0x8(%ebp),%eax
  80163e:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  801643:	c9                   	leave  
  801644:	c3                   	ret    
  801645:	66 90                	xchg   %ax,%ax
  801647:	90                   	nop

00801648 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801648:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801649:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  80164e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801650:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// @yuhangj: get reserved place under old esp
	addl $0x08, %esp;
  801653:	83 c4 08             	add    $0x8,%esp

	movl 0x28(%esp), %eax;
  801656:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x04, %eax;
  80165a:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x28(%esp);
  80165d:	89 44 24 28          	mov    %eax,0x28(%esp)

    // @yuhangj: store old eip into the reserved place under old esp
	movl 0x20(%esp), %ebx;
  801661:	8b 5c 24 20          	mov    0x20(%esp),%ebx
	movl %ebx, (%eax);
  801665:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801667:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp;
  801668:	83 c4 04             	add    $0x4,%esp
	popfl
  80166b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  80166c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80166d:	c3                   	ret    
  80166e:	66 90                	xchg   %ax,%ax

00801670 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801673:	8b 45 08             	mov    0x8(%ebp),%eax
  801676:	05 00 00 00 30       	add    $0x30000000,%eax
  80167b:	c1 e8 0c             	shr    $0xc,%eax
}
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801686:	8b 45 08             	mov    0x8(%ebp),%eax
  801689:	89 04 24             	mov    %eax,(%esp)
  80168c:	e8 df ff ff ff       	call   801670 <fd2num>
  801691:	c1 e0 0c             	shl    $0xc,%eax
  801694:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801699:	c9                   	leave  
  80169a:	c3                   	ret    

0080169b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80169e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8016a3:	a8 01                	test   $0x1,%al
  8016a5:	74 34                	je     8016db <fd_alloc+0x40>
  8016a7:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8016ac:	a8 01                	test   $0x1,%al
  8016ae:	74 32                	je     8016e2 <fd_alloc+0x47>
  8016b0:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8016b5:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	c1 ea 16             	shr    $0x16,%edx
  8016bc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016c3:	f6 c2 01             	test   $0x1,%dl
  8016c6:	74 1f                	je     8016e7 <fd_alloc+0x4c>
  8016c8:	89 c2                	mov    %eax,%edx
  8016ca:	c1 ea 0c             	shr    $0xc,%edx
  8016cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016d4:	f6 c2 01             	test   $0x1,%dl
  8016d7:	75 1a                	jne    8016f3 <fd_alloc+0x58>
  8016d9:	eb 0c                	jmp    8016e7 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8016db:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8016e0:	eb 05                	jmp    8016e7 <fd_alloc+0x4c>
  8016e2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8016e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ea:	89 08                	mov    %ecx,(%eax)
			return 0;
  8016ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f1:	eb 1a                	jmp    80170d <fd_alloc+0x72>
  8016f3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016f8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016fd:	75 b6                	jne    8016b5 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801708:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801715:	83 f8 1f             	cmp    $0x1f,%eax
  801718:	77 36                	ja     801750 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80171a:	c1 e0 0c             	shl    $0xc,%eax
  80171d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801722:	89 c2                	mov    %eax,%edx
  801724:	c1 ea 16             	shr    $0x16,%edx
  801727:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80172e:	f6 c2 01             	test   $0x1,%dl
  801731:	74 24                	je     801757 <fd_lookup+0x48>
  801733:	89 c2                	mov    %eax,%edx
  801735:	c1 ea 0c             	shr    $0xc,%edx
  801738:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80173f:	f6 c2 01             	test   $0x1,%dl
  801742:	74 1a                	je     80175e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801744:	8b 55 0c             	mov    0xc(%ebp),%edx
  801747:	89 02                	mov    %eax,(%edx)
	return 0;
  801749:	b8 00 00 00 00       	mov    $0x0,%eax
  80174e:	eb 13                	jmp    801763 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801750:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801755:	eb 0c                	jmp    801763 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801757:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80175c:	eb 05                	jmp    801763 <fd_lookup+0x54>
  80175e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	83 ec 18             	sub    $0x18,%esp
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80176e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801774:	75 10                	jne    801786 <dev_lookup+0x21>
			*dev = devtab[i];
  801776:	8b 45 0c             	mov    0xc(%ebp),%eax
  801779:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80177f:	b8 00 00 00 00       	mov    $0x0,%eax
  801784:	eb 2b                	jmp    8017b1 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801786:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  80178c:	8b 52 48             	mov    0x48(%edx),%edx
  80178f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801793:	89 54 24 04          	mov    %edx,0x4(%esp)
  801797:	c7 04 24 10 27 80 00 	movl   $0x802710,(%esp)
  80179e:	e8 5c ef ff ff       	call   8006ff <cprintf>
	*dev = 0;
  8017a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a6:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  8017ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	83 ec 38             	sub    $0x38,%esp
  8017b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8017bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8017bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8017c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017c8:	89 3c 24             	mov    %edi,(%esp)
  8017cb:	e8 a0 fe ff ff       	call   801670 <fd2num>
  8017d0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8017d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017d7:	89 04 24             	mov    %eax,(%esp)
  8017da:	e8 30 ff ff ff       	call   80170f <fd_lookup>
  8017df:	89 c3                	mov    %eax,%ebx
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 05                	js     8017ea <fd_close+0x37>
	    || fd != fd2)
  8017e5:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8017e8:	74 0c                	je     8017f6 <fd_close+0x43>
		return (must_exist ? r : 0);
  8017ea:	85 f6                	test   %esi,%esi
  8017ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f1:	0f 44 d8             	cmove  %eax,%ebx
  8017f4:	eb 3d                	jmp    801833 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017f6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8017f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fd:	8b 07                	mov    (%edi),%eax
  8017ff:	89 04 24             	mov    %eax,(%esp)
  801802:	e8 5e ff ff ff       	call   801765 <dev_lookup>
  801807:	89 c3                	mov    %eax,%ebx
  801809:	85 c0                	test   %eax,%eax
  80180b:	78 16                	js     801823 <fd_close+0x70>
		if (dev->dev_close)
  80180d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801810:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801813:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801818:	85 c0                	test   %eax,%eax
  80181a:	74 07                	je     801823 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80181c:	89 3c 24             	mov    %edi,(%esp)
  80181f:	ff d0                	call   *%eax
  801821:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801823:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801827:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80182e:	e8 65 fb ff ff       	call   801398 <sys_page_unmap>
	return r;
}
  801833:	89 d8                	mov    %ebx,%eax
  801835:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801838:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80183b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80183e:	89 ec                	mov    %ebp,%esp
  801840:	5d                   	pop    %ebp
  801841:	c3                   	ret    

00801842 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801848:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184f:	8b 45 08             	mov    0x8(%ebp),%eax
  801852:	89 04 24             	mov    %eax,(%esp)
  801855:	e8 b5 fe ff ff       	call   80170f <fd_lookup>
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 13                	js     801871 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80185e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801865:	00 
  801866:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801869:	89 04 24             	mov    %eax,(%esp)
  80186c:	e8 42 ff ff ff       	call   8017b3 <fd_close>
}
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <close_all>:

void
close_all(void)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	53                   	push   %ebx
  801877:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80187a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80187f:	89 1c 24             	mov    %ebx,(%esp)
  801882:	e8 bb ff ff ff       	call   801842 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801887:	83 c3 01             	add    $0x1,%ebx
  80188a:	83 fb 20             	cmp    $0x20,%ebx
  80188d:	75 f0                	jne    80187f <close_all+0xc>
		close(i);
}
  80188f:	83 c4 14             	add    $0x14,%esp
  801892:	5b                   	pop    %ebx
  801893:	5d                   	pop    %ebp
  801894:	c3                   	ret    

00801895 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	83 ec 58             	sub    $0x58,%esp
  80189b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80189e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8018a1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8018a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8018a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b1:	89 04 24             	mov    %eax,(%esp)
  8018b4:	e8 56 fe ff ff       	call   80170f <fd_lookup>
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	0f 88 e3 00 00 00    	js     8019a4 <dup+0x10f>
		return r;
	close(newfdnum);
  8018c1:	89 1c 24             	mov    %ebx,(%esp)
  8018c4:	e8 79 ff ff ff       	call   801842 <close>

	newfd = INDEX2FD(newfdnum);
  8018c9:	89 de                	mov    %ebx,%esi
  8018cb:	c1 e6 0c             	shl    $0xc,%esi
  8018ce:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8018d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018d7:	89 04 24             	mov    %eax,(%esp)
  8018da:	e8 a1 fd ff ff       	call   801680 <fd2data>
  8018df:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8018e1:	89 34 24             	mov    %esi,(%esp)
  8018e4:	e8 97 fd ff ff       	call   801680 <fd2data>
  8018e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8018ec:	89 f8                	mov    %edi,%eax
  8018ee:	c1 e8 16             	shr    $0x16,%eax
  8018f1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018f8:	a8 01                	test   $0x1,%al
  8018fa:	74 46                	je     801942 <dup+0xad>
  8018fc:	89 f8                	mov    %edi,%eax
  8018fe:	c1 e8 0c             	shr    $0xc,%eax
  801901:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801908:	f6 c2 01             	test   $0x1,%dl
  80190b:	74 35                	je     801942 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80190d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801914:	25 07 0e 00 00       	and    $0xe07,%eax
  801919:	89 44 24 10          	mov    %eax,0x10(%esp)
  80191d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801920:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801924:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80192b:	00 
  80192c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801930:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801937:	e8 f5 f9 ff ff       	call   801331 <sys_page_map>
  80193c:	89 c7                	mov    %eax,%edi
  80193e:	85 c0                	test   %eax,%eax
  801940:	78 3b                	js     80197d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801942:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801945:	89 c2                	mov    %eax,%edx
  801947:	c1 ea 0c             	shr    $0xc,%edx
  80194a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801951:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801957:	89 54 24 10          	mov    %edx,0x10(%esp)
  80195b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80195f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801966:	00 
  801967:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801972:	e8 ba f9 ff ff       	call   801331 <sys_page_map>
  801977:	89 c7                	mov    %eax,%edi
  801979:	85 c0                	test   %eax,%eax
  80197b:	79 29                	jns    8019a6 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80197d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801981:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801988:	e8 0b fa ff ff       	call   801398 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80198d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801990:	89 44 24 04          	mov    %eax,0x4(%esp)
  801994:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199b:	e8 f8 f9 ff ff       	call   801398 <sys_page_unmap>
	return r;
  8019a0:	89 fb                	mov    %edi,%ebx
  8019a2:	eb 02                	jmp    8019a6 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  8019a4:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8019a6:	89 d8                	mov    %ebx,%eax
  8019a8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8019ab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8019ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8019b1:	89 ec                	mov    %ebp,%esp
  8019b3:	5d                   	pop    %ebp
  8019b4:	c3                   	ret    

008019b5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	53                   	push   %ebx
  8019b9:	83 ec 24             	sub    $0x24,%esp
  8019bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c6:	89 1c 24             	mov    %ebx,(%esp)
  8019c9:	e8 41 fd ff ff       	call   80170f <fd_lookup>
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	78 6d                	js     801a3f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019dc:	8b 00                	mov    (%eax),%eax
  8019de:	89 04 24             	mov    %eax,(%esp)
  8019e1:	e8 7f fd ff ff       	call   801765 <dev_lookup>
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	78 55                	js     801a3f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ed:	8b 50 08             	mov    0x8(%eax),%edx
  8019f0:	83 e2 03             	and    $0x3,%edx
  8019f3:	83 fa 01             	cmp    $0x1,%edx
  8019f6:	75 23                	jne    801a1b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019f8:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8019fd:	8b 40 48             	mov    0x48(%eax),%eax
  801a00:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a08:	c7 04 24 54 27 80 00 	movl   $0x802754,(%esp)
  801a0f:	e8 eb ec ff ff       	call   8006ff <cprintf>
		return -E_INVAL;
  801a14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a19:	eb 24                	jmp    801a3f <read+0x8a>
	}
	if (!dev->dev_read)
  801a1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a1e:	8b 52 08             	mov    0x8(%edx),%edx
  801a21:	85 d2                	test   %edx,%edx
  801a23:	74 15                	je     801a3a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a25:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a2f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a33:	89 04 24             	mov    %eax,(%esp)
  801a36:	ff d2                	call   *%edx
  801a38:	eb 05                	jmp    801a3f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801a3a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801a3f:	83 c4 24             	add    $0x24,%esp
  801a42:	5b                   	pop    %ebx
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    

00801a45 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	57                   	push   %edi
  801a49:	56                   	push   %esi
  801a4a:	53                   	push   %ebx
  801a4b:	83 ec 1c             	sub    $0x1c,%esp
  801a4e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a51:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a54:	85 f6                	test   %esi,%esi
  801a56:	74 33                	je     801a8b <readn+0x46>
  801a58:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a62:	89 f2                	mov    %esi,%edx
  801a64:	29 c2                	sub    %eax,%edx
  801a66:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a6a:	03 45 0c             	add    0xc(%ebp),%eax
  801a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a71:	89 3c 24             	mov    %edi,(%esp)
  801a74:	e8 3c ff ff ff       	call   8019b5 <read>
		if (m < 0)
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	78 17                	js     801a94 <readn+0x4f>
			return m;
		if (m == 0)
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	74 11                	je     801a92 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a81:	01 c3                	add    %eax,%ebx
  801a83:	89 d8                	mov    %ebx,%eax
  801a85:	39 f3                	cmp    %esi,%ebx
  801a87:	72 d9                	jb     801a62 <readn+0x1d>
  801a89:	eb 09                	jmp    801a94 <readn+0x4f>
  801a8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a90:	eb 02                	jmp    801a94 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801a92:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801a94:	83 c4 1c             	add    $0x1c,%esp
  801a97:	5b                   	pop    %ebx
  801a98:	5e                   	pop    %esi
  801a99:	5f                   	pop    %edi
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	53                   	push   %ebx
  801aa0:	83 ec 24             	sub    $0x24,%esp
  801aa3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aa6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aad:	89 1c 24             	mov    %ebx,(%esp)
  801ab0:	e8 5a fc ff ff       	call   80170f <fd_lookup>
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	78 68                	js     801b21 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ab9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac3:	8b 00                	mov    (%eax),%eax
  801ac5:	89 04 24             	mov    %eax,(%esp)
  801ac8:	e8 98 fc ff ff       	call   801765 <dev_lookup>
  801acd:	85 c0                	test   %eax,%eax
  801acf:	78 50                	js     801b21 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ad8:	75 23                	jne    801afd <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801ada:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801adf:	8b 40 48             	mov    0x48(%eax),%eax
  801ae2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aea:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  801af1:	e8 09 ec ff ff       	call   8006ff <cprintf>
		return -E_INVAL;
  801af6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801afb:	eb 24                	jmp    801b21 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801afd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b00:	8b 52 0c             	mov    0xc(%edx),%edx
  801b03:	85 d2                	test   %edx,%edx
  801b05:	74 15                	je     801b1c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b07:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b0a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b11:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b15:	89 04 24             	mov    %eax,(%esp)
  801b18:	ff d2                	call   *%edx
  801b1a:	eb 05                	jmp    801b21 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b1c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801b21:	83 c4 24             	add    $0x24,%esp
  801b24:	5b                   	pop    %ebx
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <seek>:

int
seek(int fdnum, off_t offset)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b2d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b34:	8b 45 08             	mov    0x8(%ebp),%eax
  801b37:	89 04 24             	mov    %eax,(%esp)
  801b3a:	e8 d0 fb ff ff       	call   80170f <fd_lookup>
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	78 0e                	js     801b51 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801b43:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b46:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b49:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    

00801b53 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	53                   	push   %ebx
  801b57:	83 ec 24             	sub    $0x24,%esp
  801b5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b5d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b64:	89 1c 24             	mov    %ebx,(%esp)
  801b67:	e8 a3 fb ff ff       	call   80170f <fd_lookup>
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	78 61                	js     801bd1 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b7a:	8b 00                	mov    (%eax),%eax
  801b7c:	89 04 24             	mov    %eax,(%esp)
  801b7f:	e8 e1 fb ff ff       	call   801765 <dev_lookup>
  801b84:	85 c0                	test   %eax,%eax
  801b86:	78 49                	js     801bd1 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b8b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b8f:	75 23                	jne    801bb4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b91:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b96:	8b 40 48             	mov    0x48(%eax),%eax
  801b99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba1:	c7 04 24 30 27 80 00 	movl   $0x802730,(%esp)
  801ba8:	e8 52 eb ff ff       	call   8006ff <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801bad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bb2:	eb 1d                	jmp    801bd1 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801bb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bb7:	8b 52 18             	mov    0x18(%edx),%edx
  801bba:	85 d2                	test   %edx,%edx
  801bbc:	74 0e                	je     801bcc <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801bbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801bc5:	89 04 24             	mov    %eax,(%esp)
  801bc8:	ff d2                	call   *%edx
  801bca:	eb 05                	jmp    801bd1 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801bcc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801bd1:	83 c4 24             	add    $0x24,%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    

00801bd7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	53                   	push   %ebx
  801bdb:	83 ec 24             	sub    $0x24,%esp
  801bde:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801be1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be8:	8b 45 08             	mov    0x8(%ebp),%eax
  801beb:	89 04 24             	mov    %eax,(%esp)
  801bee:	e8 1c fb ff ff       	call   80170f <fd_lookup>
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	78 52                	js     801c49 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c01:	8b 00                	mov    (%eax),%eax
  801c03:	89 04 24             	mov    %eax,(%esp)
  801c06:	e8 5a fb ff ff       	call   801765 <dev_lookup>
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	78 3a                	js     801c49 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c12:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c16:	74 2c                	je     801c44 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c18:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c1b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c22:	00 00 00 
	stat->st_isdir = 0;
  801c25:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c2c:	00 00 00 
	stat->st_dev = dev;
  801c2f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c35:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c39:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c3c:	89 14 24             	mov    %edx,(%esp)
  801c3f:	ff 50 14             	call   *0x14(%eax)
  801c42:	eb 05                	jmp    801c49 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801c44:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801c49:	83 c4 24             	add    $0x24,%esp
  801c4c:	5b                   	pop    %ebx
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    

00801c4f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	83 ec 18             	sub    $0x18,%esp
  801c55:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c58:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c62:	00 
  801c63:	8b 45 08             	mov    0x8(%ebp),%eax
  801c66:	89 04 24             	mov    %eax,(%esp)
  801c69:	e8 84 01 00 00       	call   801df2 <open>
  801c6e:	89 c3                	mov    %eax,%ebx
  801c70:	85 c0                	test   %eax,%eax
  801c72:	78 1b                	js     801c8f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801c74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c7b:	89 1c 24             	mov    %ebx,(%esp)
  801c7e:	e8 54 ff ff ff       	call   801bd7 <fstat>
  801c83:	89 c6                	mov    %eax,%esi
	close(fd);
  801c85:	89 1c 24             	mov    %ebx,(%esp)
  801c88:	e8 b5 fb ff ff       	call   801842 <close>
	return r;
  801c8d:	89 f3                	mov    %esi,%ebx
}
  801c8f:	89 d8                	mov    %ebx,%eax
  801c91:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c94:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c97:	89 ec                	mov    %ebp,%esp
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    
  801c9b:	90                   	nop

00801c9c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	83 ec 18             	sub    $0x18,%esp
  801ca2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ca5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ca8:	89 c6                	mov    %eax,%esi
  801caa:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801cac:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801cb3:	75 11                	jne    801cc6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801cb5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801cbc:	e8 72 02 00 00       	call   801f33 <ipc_find_env>
  801cc1:	a3 ac 40 80 00       	mov    %eax,0x8040ac
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801cc6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ccd:	00 
  801cce:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801cd5:	00 
  801cd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cda:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  801cdf:	89 04 24             	mov    %eax,(%esp)
  801ce2:	e8 e1 01 00 00       	call   801ec8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ce7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cee:	00 
  801cef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cfa:	e8 71 01 00 00       	call   801e70 <ipc_recv>
}
  801cff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d02:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d05:	89 ec                	mov    %ebp,%esp
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    

00801d09 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d12:	8b 40 0c             	mov    0xc(%eax),%eax
  801d15:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d22:	ba 00 00 00 00       	mov    $0x0,%edx
  801d27:	b8 02 00 00 00       	mov    $0x2,%eax
  801d2c:	e8 6b ff ff ff       	call   801c9c <fsipc>
}
  801d31:	c9                   	leave  
  801d32:	c3                   	ret    

00801d33 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d39:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d3f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d44:	ba 00 00 00 00       	mov    $0x0,%edx
  801d49:	b8 06 00 00 00       	mov    $0x6,%eax
  801d4e:	e8 49 ff ff ff       	call   801c9c <fsipc>
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	53                   	push   %ebx
  801d59:	83 ec 14             	sub    $0x14,%esp
  801d5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d62:	8b 40 0c             	mov    0xc(%eax),%eax
  801d65:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d6a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d6f:	b8 05 00 00 00       	mov    $0x5,%eax
  801d74:	e8 23 ff ff ff       	call   801c9c <fsipc>
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	78 2b                	js     801da8 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d7d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d84:	00 
  801d85:	89 1c 24             	mov    %ebx,(%esp)
  801d88:	e8 ee ef ff ff       	call   800d7b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d8d:	a1 80 50 80 00       	mov    0x805080,%eax
  801d92:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d98:	a1 84 50 80 00       	mov    0x805084,%eax
  801d9d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801da3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801da8:	83 c4 14             	add    $0x14,%esp
  801dab:	5b                   	pop    %ebx
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801db4:	c7 44 24 08 8d 27 80 	movl   $0x80278d,0x8(%esp)
  801dbb:	00 
  801dbc:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  801dc3:	00 
  801dc4:	c7 04 24 ab 27 80 00 	movl   $0x8027ab,(%esp)
  801dcb:	e8 34 e8 ff ff       	call   800604 <_panic>

00801dd0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  801dd6:	c7 44 24 08 b6 27 80 	movl   $0x8027b6,0x8(%esp)
  801ddd:	00 
  801dde:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801de5:	00 
  801de6:	c7 04 24 ab 27 80 00 	movl   $0x8027ab,(%esp)
  801ded:	e8 12 e8 ff ff       	call   800604 <_panic>

00801df2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801df8:	c7 44 24 08 d3 27 80 	movl   $0x8027d3,0x8(%esp)
  801dff:	00 
  801e00:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801e07:	00 
  801e08:	c7 04 24 ab 27 80 00 	movl   $0x8027ab,(%esp)
  801e0f:	e8 f0 e7 ff ff       	call   800604 <_panic>

00801e14 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	53                   	push   %ebx
  801e18:	83 ec 14             	sub    $0x14,%esp
  801e1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e1e:	89 1c 24             	mov    %ebx,(%esp)
  801e21:	e8 fa ee ff ff       	call   800d20 <strlen>
  801e26:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e2b:	7f 21                	jg     801e4e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801e2d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e31:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e38:	e8 3e ef ff ff       	call   800d7b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801e3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e42:	b8 07 00 00 00       	mov    $0x7,%eax
  801e47:	e8 50 fe ff ff       	call   801c9c <fsipc>
  801e4c:	eb 05                	jmp    801e53 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e4e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801e53:	83 c4 14             	add    $0x14,%esp
  801e56:	5b                   	pop    %ebx
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    

00801e59 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801e64:	b8 08 00 00 00       	mov    $0x8,%eax
  801e69:	e8 2e fe ff ff       	call   801c9c <fsipc>
}
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    

00801e70 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	56                   	push   %esi
  801e74:	53                   	push   %ebx
  801e75:	83 ec 10             	sub    $0x10,%esp
  801e78:	8b 75 08             	mov    0x8(%ebp),%esi
  801e7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  801e7e:	85 db                	test   %ebx,%ebx
  801e80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801e85:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  801e88:	89 1c 24             	mov    %ebx,(%esp)
  801e8b:	e8 e1 f6 ff ff       	call   801571 <sys_ipc_recv>
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 2d                	js     801ec1 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  801e94:	85 f6                	test   %esi,%esi
  801e96:	74 0a                	je     801ea2 <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  801e98:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801e9d:	8b 40 74             	mov    0x74(%eax),%eax
  801ea0:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  801ea2:	85 db                	test   %ebx,%ebx
  801ea4:	74 13                	je     801eb9 <ipc_recv+0x49>
  801ea6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eaa:	74 0d                	je     801eb9 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  801eac:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801eb1:	8b 40 78             	mov    0x78(%eax),%eax
  801eb4:	8b 55 10             	mov    0x10(%ebp),%edx
  801eb7:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801eb9:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801ebe:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	5b                   	pop    %ebx
  801ec5:	5e                   	pop    %esi
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    

00801ec8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	57                   	push   %edi
  801ecc:	56                   	push   %esi
  801ecd:	53                   	push   %ebx
  801ece:	83 ec 1c             	sub    $0x1c,%esp
  801ed1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ed4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801eda:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801edc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ee1:	0f 44 d8             	cmove  %eax,%ebx
  801ee4:	eb 2a                	jmp    801f10 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  801ee6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ee9:	74 20                	je     801f0b <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801eeb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eef:	c7 44 24 08 e8 27 80 	movl   $0x8027e8,0x8(%esp)
  801ef6:	00 
  801ef7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801efe:	00 
  801eff:	c7 04 24 ff 27 80 00 	movl   $0x8027ff,(%esp)
  801f06:	e8 f9 e6 ff ff       	call   800604 <_panic>
		sys_yield();
  801f0b:	e8 80 f3 ff ff       	call   801290 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801f10:	8b 45 14             	mov    0x14(%ebp),%eax
  801f13:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f17:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f1b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f1f:	89 3c 24             	mov    %edi,(%esp)
  801f22:	e8 0d f6 ff ff       	call   801534 <sys_ipc_try_send>
  801f27:	85 c0                	test   %eax,%eax
  801f29:	78 bb                	js     801ee6 <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801f2b:	83 c4 1c             	add    $0x1c,%esp
  801f2e:	5b                   	pop    %ebx
  801f2f:	5e                   	pop    %esi
  801f30:	5f                   	pop    %edi
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    

00801f33 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f39:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801f3e:	39 c8                	cmp    %ecx,%eax
  801f40:	74 17                	je     801f59 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f42:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801f47:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f4a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f50:	8b 52 50             	mov    0x50(%edx),%edx
  801f53:	39 ca                	cmp    %ecx,%edx
  801f55:	75 14                	jne    801f6b <ipc_find_env+0x38>
  801f57:	eb 05                	jmp    801f5e <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f59:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801f5e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f61:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f66:	8b 40 40             	mov    0x40(%eax),%eax
  801f69:	eb 0e                	jmp    801f79 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f6b:	83 c0 01             	add    $0x1,%eax
  801f6e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f73:	75 d2                	jne    801f47 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f75:	66 b8 00 00          	mov    $0x0,%ax
}
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    
  801f7b:	66 90                	xchg   %ax,%ax
  801f7d:	66 90                	xchg   %ax,%ax
  801f7f:	90                   	nop

00801f80 <__udivdi3>:
  801f80:	83 ec 1c             	sub    $0x1c,%esp
  801f83:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801f87:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801f8b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801f8f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801f93:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801f97:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801fa1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801fa5:	89 ea                	mov    %ebp,%edx
  801fa7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801fab:	75 33                	jne    801fe0 <__udivdi3+0x60>
  801fad:	39 e9                	cmp    %ebp,%ecx
  801faf:	77 6f                	ja     802020 <__udivdi3+0xa0>
  801fb1:	85 c9                	test   %ecx,%ecx
  801fb3:	89 ce                	mov    %ecx,%esi
  801fb5:	75 0b                	jne    801fc2 <__udivdi3+0x42>
  801fb7:	b8 01 00 00 00       	mov    $0x1,%eax
  801fbc:	31 d2                	xor    %edx,%edx
  801fbe:	f7 f1                	div    %ecx
  801fc0:	89 c6                	mov    %eax,%esi
  801fc2:	31 d2                	xor    %edx,%edx
  801fc4:	89 e8                	mov    %ebp,%eax
  801fc6:	f7 f6                	div    %esi
  801fc8:	89 c5                	mov    %eax,%ebp
  801fca:	89 f8                	mov    %edi,%eax
  801fcc:	f7 f6                	div    %esi
  801fce:	89 ea                	mov    %ebp,%edx
  801fd0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801fd4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801fd8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801fdc:	83 c4 1c             	add    $0x1c,%esp
  801fdf:	c3                   	ret    
  801fe0:	39 e8                	cmp    %ebp,%eax
  801fe2:	77 24                	ja     802008 <__udivdi3+0x88>
  801fe4:	0f bd c8             	bsr    %eax,%ecx
  801fe7:	83 f1 1f             	xor    $0x1f,%ecx
  801fea:	89 0c 24             	mov    %ecx,(%esp)
  801fed:	75 49                	jne    802038 <__udivdi3+0xb8>
  801fef:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ff3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801ff7:	0f 86 ab 00 00 00    	jbe    8020a8 <__udivdi3+0x128>
  801ffd:	39 e8                	cmp    %ebp,%eax
  801fff:	0f 82 a3 00 00 00    	jb     8020a8 <__udivdi3+0x128>
  802005:	8d 76 00             	lea    0x0(%esi),%esi
  802008:	31 d2                	xor    %edx,%edx
  80200a:	31 c0                	xor    %eax,%eax
  80200c:	8b 74 24 10          	mov    0x10(%esp),%esi
  802010:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802014:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802018:	83 c4 1c             	add    $0x1c,%esp
  80201b:	c3                   	ret    
  80201c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802020:	89 f8                	mov    %edi,%eax
  802022:	f7 f1                	div    %ecx
  802024:	31 d2                	xor    %edx,%edx
  802026:	8b 74 24 10          	mov    0x10(%esp),%esi
  80202a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80202e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802032:	83 c4 1c             	add    $0x1c,%esp
  802035:	c3                   	ret    
  802036:	66 90                	xchg   %ax,%ax
  802038:	0f b6 0c 24          	movzbl (%esp),%ecx
  80203c:	89 c6                	mov    %eax,%esi
  80203e:	b8 20 00 00 00       	mov    $0x20,%eax
  802043:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  802047:	2b 04 24             	sub    (%esp),%eax
  80204a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80204e:	d3 e6                	shl    %cl,%esi
  802050:	89 c1                	mov    %eax,%ecx
  802052:	d3 ed                	shr    %cl,%ebp
  802054:	0f b6 0c 24          	movzbl (%esp),%ecx
  802058:	09 f5                	or     %esi,%ebp
  80205a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80205e:	d3 e6                	shl    %cl,%esi
  802060:	89 c1                	mov    %eax,%ecx
  802062:	89 74 24 04          	mov    %esi,0x4(%esp)
  802066:	89 d6                	mov    %edx,%esi
  802068:	d3 ee                	shr    %cl,%esi
  80206a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80206e:	d3 e2                	shl    %cl,%edx
  802070:	89 c1                	mov    %eax,%ecx
  802072:	d3 ef                	shr    %cl,%edi
  802074:	09 d7                	or     %edx,%edi
  802076:	89 f2                	mov    %esi,%edx
  802078:	89 f8                	mov    %edi,%eax
  80207a:	f7 f5                	div    %ebp
  80207c:	89 d6                	mov    %edx,%esi
  80207e:	89 c7                	mov    %eax,%edi
  802080:	f7 64 24 04          	mull   0x4(%esp)
  802084:	39 d6                	cmp    %edx,%esi
  802086:	72 30                	jb     8020b8 <__udivdi3+0x138>
  802088:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  80208c:	0f b6 0c 24          	movzbl (%esp),%ecx
  802090:	d3 e5                	shl    %cl,%ebp
  802092:	39 c5                	cmp    %eax,%ebp
  802094:	73 04                	jae    80209a <__udivdi3+0x11a>
  802096:	39 d6                	cmp    %edx,%esi
  802098:	74 1e                	je     8020b8 <__udivdi3+0x138>
  80209a:	89 f8                	mov    %edi,%eax
  80209c:	31 d2                	xor    %edx,%edx
  80209e:	e9 69 ff ff ff       	jmp    80200c <__udivdi3+0x8c>
  8020a3:	90                   	nop
  8020a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	31 d2                	xor    %edx,%edx
  8020aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8020af:	e9 58 ff ff ff       	jmp    80200c <__udivdi3+0x8c>
  8020b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8020bb:	31 d2                	xor    %edx,%edx
  8020bd:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020c1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8020c5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8020c9:	83 c4 1c             	add    $0x1c,%esp
  8020cc:	c3                   	ret    
  8020cd:	66 90                	xchg   %ax,%ax
  8020cf:	90                   	nop

008020d0 <__umoddi3>:
  8020d0:	83 ec 2c             	sub    $0x2c,%esp
  8020d3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020d7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020db:	89 74 24 20          	mov    %esi,0x20(%esp)
  8020df:	8b 74 24 38          	mov    0x38(%esp),%esi
  8020e3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  8020e7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	89 c2                	mov    %eax,%edx
  8020ef:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  8020f3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8020f7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020fb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8020ff:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802103:	89 7c 24 18          	mov    %edi,0x18(%esp)
  802107:	75 1f                	jne    802128 <__umoddi3+0x58>
  802109:	39 fe                	cmp    %edi,%esi
  80210b:	76 63                	jbe    802170 <__umoddi3+0xa0>
  80210d:	89 c8                	mov    %ecx,%eax
  80210f:	89 fa                	mov    %edi,%edx
  802111:	f7 f6                	div    %esi
  802113:	89 d0                	mov    %edx,%eax
  802115:	31 d2                	xor    %edx,%edx
  802117:	8b 74 24 20          	mov    0x20(%esp),%esi
  80211b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80211f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  802123:	83 c4 2c             	add    $0x2c,%esp
  802126:	c3                   	ret    
  802127:	90                   	nop
  802128:	39 f8                	cmp    %edi,%eax
  80212a:	77 64                	ja     802190 <__umoddi3+0xc0>
  80212c:	0f bd e8             	bsr    %eax,%ebp
  80212f:	83 f5 1f             	xor    $0x1f,%ebp
  802132:	75 74                	jne    8021a8 <__umoddi3+0xd8>
  802134:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802138:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80213c:	0f 87 0e 01 00 00    	ja     802250 <__umoddi3+0x180>
  802142:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  802146:	29 f1                	sub    %esi,%ecx
  802148:	19 c7                	sbb    %eax,%edi
  80214a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80214e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  802152:	8b 44 24 14          	mov    0x14(%esp),%eax
  802156:	8b 54 24 18          	mov    0x18(%esp),%edx
  80215a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80215e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802162:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  802166:	83 c4 2c             	add    $0x2c,%esp
  802169:	c3                   	ret    
  80216a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802170:	85 f6                	test   %esi,%esi
  802172:	89 f5                	mov    %esi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0xb1>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f6                	div    %esi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802185:	31 d2                	xor    %edx,%edx
  802187:	f7 f5                	div    %ebp
  802189:	89 c8                	mov    %ecx,%eax
  80218b:	f7 f5                	div    %ebp
  80218d:	eb 84                	jmp    802113 <__umoddi3+0x43>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 fa                	mov    %edi,%edx
  802194:	8b 74 24 20          	mov    0x20(%esp),%esi
  802198:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80219c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8021a0:	83 c4 2c             	add    $0x2c,%esp
  8021a3:	c3                   	ret    
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	8b 44 24 10          	mov    0x10(%esp),%eax
  8021ac:	be 20 00 00 00       	mov    $0x20,%esi
  8021b1:	89 e9                	mov    %ebp,%ecx
  8021b3:	29 ee                	sub    %ebp,%esi
  8021b5:	d3 e2                	shl    %cl,%edx
  8021b7:	89 f1                	mov    %esi,%ecx
  8021b9:	d3 e8                	shr    %cl,%eax
  8021bb:	89 e9                	mov    %ebp,%ecx
  8021bd:	09 d0                	or     %edx,%eax
  8021bf:	89 fa                	mov    %edi,%edx
  8021c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021c5:	8b 44 24 10          	mov    0x10(%esp),%eax
  8021c9:	d3 e0                	shl    %cl,%eax
  8021cb:	89 f1                	mov    %esi,%ecx
  8021cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021d1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8021d5:	d3 ea                	shr    %cl,%edx
  8021d7:	89 e9                	mov    %ebp,%ecx
  8021d9:	d3 e7                	shl    %cl,%edi
  8021db:	89 f1                	mov    %esi,%ecx
  8021dd:	d3 e8                	shr    %cl,%eax
  8021df:	89 e9                	mov    %ebp,%ecx
  8021e1:	09 f8                	or     %edi,%eax
  8021e3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8021e7:	f7 74 24 0c          	divl   0xc(%esp)
  8021eb:	d3 e7                	shl    %cl,%edi
  8021ed:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8021f1:	89 d7                	mov    %edx,%edi
  8021f3:	f7 64 24 10          	mull   0x10(%esp)
  8021f7:	39 d7                	cmp    %edx,%edi
  8021f9:	89 c1                	mov    %eax,%ecx
  8021fb:	89 54 24 14          	mov    %edx,0x14(%esp)
  8021ff:	72 3b                	jb     80223c <__umoddi3+0x16c>
  802201:	39 44 24 18          	cmp    %eax,0x18(%esp)
  802205:	72 31                	jb     802238 <__umoddi3+0x168>
  802207:	8b 44 24 18          	mov    0x18(%esp),%eax
  80220b:	29 c8                	sub    %ecx,%eax
  80220d:	19 d7                	sbb    %edx,%edi
  80220f:	89 e9                	mov    %ebp,%ecx
  802211:	89 fa                	mov    %edi,%edx
  802213:	d3 e8                	shr    %cl,%eax
  802215:	89 f1                	mov    %esi,%ecx
  802217:	d3 e2                	shl    %cl,%edx
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	09 d0                	or     %edx,%eax
  80221d:	89 fa                	mov    %edi,%edx
  80221f:	d3 ea                	shr    %cl,%edx
  802221:	8b 74 24 20          	mov    0x20(%esp),%esi
  802225:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802229:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80222d:	83 c4 2c             	add    $0x2c,%esp
  802230:	c3                   	ret    
  802231:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802238:	39 d7                	cmp    %edx,%edi
  80223a:	75 cb                	jne    802207 <__umoddi3+0x137>
  80223c:	8b 54 24 14          	mov    0x14(%esp),%edx
  802240:	89 c1                	mov    %eax,%ecx
  802242:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  802246:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80224a:	eb bb                	jmp    802207 <__umoddi3+0x137>
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	3b 44 24 18          	cmp    0x18(%esp),%eax
  802254:	0f 82 e8 fe ff ff    	jb     802142 <__umoddi3+0x72>
  80225a:	e9 f3 fe ff ff       	jmp    802152 <__umoddi3+0x82>
