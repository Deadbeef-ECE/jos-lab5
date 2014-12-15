
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 53 07 00 00       	call   800784 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800041:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800048:	e8 1e 0f 00 00       	call   800f6b <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004d:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  800053:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80005a:	e8 2c 18 00 00       	call   80188b <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800066:	00 
  800067:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800076:	00 
  800077:	89 04 24             	mov    %eax,(%esp)
  80007a:	e8 a1 17 00 00       	call   801820 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80007f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80008e:	cc 
  80008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800096:	e8 2d 17 00 00       	call   8017c8 <ipc_recv>
}
  80009b:	83 c4 14             	add    $0x14,%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <umain>:

void
umain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	81 ec cc 02 00 00    	sub    $0x2cc,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b2:	b8 c0 23 80 00       	mov    $0x8023c0,%eax
  8000b7:	e8 78 ff ff ff       	call   800034 <xopen>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	79 25                	jns    8000e5 <umain+0x44>
  8000c0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c3:	74 3c                	je     800101 <umain+0x60>
		panic("serve_open /not-found: %e", r);
  8000c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c9:	c7 44 24 08 cb 23 80 	movl   $0x8023cb,0x8(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d8:	00 
  8000d9:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  8000e0:	e8 0b 07 00 00       	call   8007f0 <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e5:	c7 44 24 08 80 25 80 	movl   $0x802580,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  8000fc:	e8 ef 06 00 00       	call   8007f0 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 f5 23 80 00       	mov    $0x8023f5,%eax
  80010b:	e8 24 ff ff ff       	call   800034 <xopen>
  800110:	85 c0                	test   %eax,%eax
  800112:	79 20                	jns    800134 <umain+0x93>
		panic("serve_open /newmotd: %e", r);
  800114:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800118:	c7 44 24 08 fe 23 80 	movl   $0x8023fe,0x8(%esp)
  80011f:	00 
  800120:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800127:	00 
  800128:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  80012f:	e8 bc 06 00 00       	call   8007f0 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800134:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013b:	75 12                	jne    80014f <umain+0xae>
  80013d:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800144:	75 09                	jne    80014f <umain+0xae>
  800146:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80014d:	74 1c                	je     80016b <umain+0xca>
		panic("serve_open did not fill struct Fd correctly\n");
  80014f:	c7 44 24 08 a4 25 80 	movl   $0x8025a4,0x8(%esp)
  800156:	00 
  800157:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  800166:	e8 85 06 00 00       	call   8007f0 <_panic>
	cprintf("serve_open is good\n");
  80016b:	c7 04 24 16 24 80 00 	movl   $0x802416,(%esp)
  800172:	e8 74 07 00 00       	call   8008eb <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800177:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800188:	ff 15 1c 30 80 00    	call   *0x80301c
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 20                	jns    8001b2 <umain+0x111>
		panic("file_stat: %e", r);
  800192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800196:	c7 44 24 08 2a 24 80 	movl   $0x80242a,0x8(%esp)
  80019d:	00 
  80019e:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001a5:	00 
  8001a6:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  8001ad:	e8 3e 06 00 00       	call   8007f0 <_panic>
	if (strlen(msg) != st.st_size)
  8001b2:	a1 00 30 80 00       	mov    0x803000,%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 51 0d 00 00       	call   800f10 <strlen>
  8001bf:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  8001c2:	74 34                	je     8001f8 <umain+0x157>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c4:	a1 00 30 80 00       	mov    0x803000,%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 3f 0d 00 00       	call   800f10 <strlen>
  8001d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001dc:	c7 44 24 08 d4 25 80 	movl   $0x8025d4,0x8(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8001eb:	00 
  8001ec:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  8001f3:	e8 f8 05 00 00       	call   8007f0 <_panic>
	cprintf("file_stat is good\n");
  8001f8:	c7 04 24 38 24 80 00 	movl   $0x802438,(%esp)
  8001ff:	e8 e7 06 00 00       	call   8008eb <cprintf>

	memset(buf, 0, sizeof buf);
  800204:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800213:	00 
  800214:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80021a:	89 1c 24             	mov    %ebx,(%esp)
  80021d:	e8 f3 0e 00 00       	call   801115 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800222:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800229:	00 
  80022a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80022e:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800235:	ff 15 10 30 80 00    	call   *0x803010
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 20                	jns    80025f <umain+0x1be>
		panic("file_read: %e", r);
  80023f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800243:	c7 44 24 08 4b 24 80 	movl   $0x80244b,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  80025a:	e8 91 05 00 00       	call   8007f0 <_panic>
	if (strcmp(buf, msg) != 0)
  80025f:	a1 00 30 80 00       	mov    0x803000,%eax
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	e8 bb 0d 00 00       	call   801031 <strcmp>
  800276:	85 c0                	test   %eax,%eax
  800278:	74 1c                	je     800296 <umain+0x1f5>
		panic("file_read returned wrong data");
  80027a:	c7 44 24 08 59 24 80 	movl   $0x802459,0x8(%esp)
  800281:	00 
  800282:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800289:	00 
  80028a:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  800291:	e8 5a 05 00 00       	call   8007f0 <_panic>
	cprintf("file_read is good\n");
  800296:	c7 04 24 77 24 80 00 	movl   $0x802477,(%esp)
  80029d:	e8 49 06 00 00       	call   8008eb <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a9:	ff 15 18 30 80 00    	call   *0x803018
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	79 20                	jns    8002d3 <umain+0x232>
		panic("file_close: %e", r);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  8002ce:	e8 1d 05 00 00       	call   8007f0 <_panic>
	cprintf("file_close is good\n");
  8002d3:	c7 04 24 99 24 80 00 	movl   $0x802499,(%esp)
  8002da:	e8 0c 06 00 00       	call   8008eb <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002df:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  8002e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e7:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  8002ec:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002ef:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  8002f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f7:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  8002fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  8002ff:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  800306:	cc 
  800307:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80030e:	e8 75 12 00 00       	call   801588 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800313:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80031a:	00 
  80031b:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800321:	89 44 24 04          	mov    %eax,0x4(%esp)
  800325:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	ff 15 10 30 80 00    	call   *0x803010
  800331:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800334:	74 20                	je     800356 <umain+0x2b5>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800336:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80033a:	c7 44 24 08 fc 25 80 	movl   $0x8025fc,0x8(%esp)
  800341:	00 
  800342:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800349:	00 
  80034a:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  800351:	e8 9a 04 00 00       	call   8007f0 <_panic>
	cprintf("stale fileid is good\n");
  800356:	c7 04 24 ad 24 80 00 	movl   $0x8024ad,(%esp)
  80035d:	e8 89 05 00 00       	call   8008eb <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800362:	ba 02 01 00 00       	mov    $0x102,%edx
  800367:	b8 c3 24 80 00       	mov    $0x8024c3,%eax
  80036c:	e8 c3 fc ff ff       	call   800034 <xopen>
  800371:	85 c0                	test   %eax,%eax
  800373:	79 20                	jns    800395 <umain+0x2f4>
		panic("serve_open /new-file: %e", r);
  800375:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800379:	c7 44 24 08 cd 24 80 	movl   $0x8024cd,0x8(%esp)
  800380:	00 
  800381:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800388:	00 
  800389:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  800390:	e8 5b 04 00 00       	call   8007f0 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800395:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  80039b:	a1 00 30 80 00       	mov    0x803000,%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	e8 68 0b 00 00       	call   800f10 <strlen>
  8003a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ac:	a1 00 30 80 00       	mov    0x803000,%eax
  8003b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b5:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003bc:	ff d3                	call   *%ebx
  8003be:	89 c3                	mov    %eax,%ebx
  8003c0:	a1 00 30 80 00       	mov    0x803000,%eax
  8003c5:	89 04 24             	mov    %eax,(%esp)
  8003c8:	e8 43 0b 00 00       	call   800f10 <strlen>
  8003cd:	39 c3                	cmp    %eax,%ebx
  8003cf:	74 20                	je     8003f1 <umain+0x350>
		panic("file_write: %e", r);
  8003d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d5:	c7 44 24 08 e6 24 80 	movl   $0x8024e6,0x8(%esp)
  8003dc:	00 
  8003dd:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8003e4:	00 
  8003e5:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  8003ec:	e8 ff 03 00 00       	call   8007f0 <_panic>
	cprintf("file_write is good\n");
  8003f1:	c7 04 24 f5 24 80 00 	movl   $0x8024f5,(%esp)
  8003f8:	e8 ee 04 00 00       	call   8008eb <cprintf>

	FVA->fd_offset = 0;
  8003fd:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800404:	00 00 00 
	memset(buf, 0, sizeof buf);
  800407:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80040e:	00 
  80040f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800416:	00 
  800417:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80041d:	89 1c 24             	mov    %ebx,(%esp)
  800420:	e8 f0 0c 00 00       	call   801115 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800425:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80042c:	00 
  80042d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800431:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800438:	ff 15 10 30 80 00    	call   *0x803010
  80043e:	89 c3                	mov    %eax,%ebx
  800440:	85 c0                	test   %eax,%eax
  800442:	79 20                	jns    800464 <umain+0x3c3>
		panic("file_read after file_write: %e", r);
  800444:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800448:	c7 44 24 08 34 26 80 	movl   $0x802634,0x8(%esp)
  80044f:	00 
  800450:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800457:	00 
  800458:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  80045f:	e8 8c 03 00 00       	call   8007f0 <_panic>
	if (r != strlen(msg))
  800464:	a1 00 30 80 00       	mov    0x803000,%eax
  800469:	89 04 24             	mov    %eax,(%esp)
  80046c:	e8 9f 0a 00 00       	call   800f10 <strlen>
  800471:	39 d8                	cmp    %ebx,%eax
  800473:	74 20                	je     800495 <umain+0x3f4>
		panic("file_read after file_write returned wrong length: %d", r);
  800475:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800479:	c7 44 24 08 54 26 80 	movl   $0x802654,0x8(%esp)
  800480:	00 
  800481:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800488:	00 
  800489:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  800490:	e8 5b 03 00 00       	call   8007f0 <_panic>
	if (strcmp(buf, msg) != 0)
  800495:	a1 00 30 80 00       	mov    0x803000,%eax
  80049a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049e:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	e8 85 0b 00 00       	call   801031 <strcmp>
  8004ac:	85 c0                	test   %eax,%eax
  8004ae:	74 1c                	je     8004cc <umain+0x42b>
		panic("file_read after file_write returned wrong data");
  8004b0:	c7 44 24 08 8c 26 80 	movl   $0x80268c,0x8(%esp)
  8004b7:	00 
  8004b8:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8004bf:	00 
  8004c0:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  8004c7:	e8 24 03 00 00       	call   8007f0 <_panic>
	cprintf("file_read after file_write is good\n");
  8004cc:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  8004d3:	e8 13 04 00 00       	call   8008eb <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004df:	00 
  8004e0:	c7 04 24 c0 23 80 00 	movl   $0x8023c0,(%esp)
  8004e7:	e8 76 1b 00 00       	call   802062 <open>
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	79 25                	jns    800515 <umain+0x474>
  8004f0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004f3:	74 3c                	je     800531 <umain+0x490>
		panic("open /not-found: %e", r);
  8004f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f9:	c7 44 24 08 d1 23 80 	movl   $0x8023d1,0x8(%esp)
  800500:	00 
  800501:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800508:	00 
  800509:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  800510:	e8 db 02 00 00       	call   8007f0 <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800515:	c7 44 24 08 09 25 80 	movl   $0x802509,0x8(%esp)
  80051c:	00 
  80051d:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800524:	00 
  800525:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  80052c:	e8 bf 02 00 00       	call   8007f0 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800531:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800538:	00 
  800539:	c7 04 24 f5 23 80 00 	movl   $0x8023f5,(%esp)
  800540:	e8 1d 1b 00 00       	call   802062 <open>
  800545:	85 c0                	test   %eax,%eax
  800547:	79 20                	jns    800569 <umain+0x4c8>
		panic("open /newmotd: %e", r);
  800549:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80054d:	c7 44 24 08 04 24 80 	movl   $0x802404,0x8(%esp)
  800554:	00 
  800555:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80055c:	00 
  80055d:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  800564:	e8 87 02 00 00       	call   8007f0 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800569:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  80056c:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  800573:	75 12                	jne    800587 <umain+0x4e6>
  800575:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  80057c:	75 09                	jne    800587 <umain+0x4e6>
  80057e:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  800585:	74 1c                	je     8005a3 <umain+0x502>
		panic("open did not fill struct Fd correctly\n");
  800587:	c7 44 24 08 e0 26 80 	movl   $0x8026e0,0x8(%esp)
  80058e:	00 
  80058f:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  800596:	00 
  800597:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  80059e:	e8 4d 02 00 00       	call   8007f0 <_panic>
	cprintf("open is good\n");
  8005a3:	c7 04 24 1c 24 80 00 	movl   $0x80241c,(%esp)
  8005aa:	e8 3c 03 00 00       	call   8008eb <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8005af:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8005b6:	00 
  8005b7:	c7 04 24 24 25 80 00 	movl   $0x802524,(%esp)
  8005be:	e8 9f 1a 00 00       	call   802062 <open>
  8005c3:	89 c6                	mov    %eax,%esi
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	79 20                	jns    8005e9 <umain+0x548>
		panic("creat /big: %e", f);
  8005c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005cd:	c7 44 24 08 29 25 80 	movl   $0x802529,0x8(%esp)
  8005d4:	00 
  8005d5:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8005dc:	00 
  8005dd:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  8005e4:	e8 07 02 00 00       	call   8007f0 <_panic>
	memset(buf, 0, sizeof(buf));
  8005e9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8005f0:	00 
  8005f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8005f8:	00 
  8005f9:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	e8 0e 0b 00 00       	call   801115 <memset>
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800607:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  80060c:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800612:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800618:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80061f:	00 
  800620:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800624:	89 34 24             	mov    %esi,(%esp)
  800627:	e8 e0 16 00 00       	call   801d0c <write>
  80062c:	85 c0                	test   %eax,%eax
  80062e:	79 24                	jns    800654 <umain+0x5b3>
			panic("write /big@%d: %e", i, r);
  800630:	89 44 24 10          	mov    %eax,0x10(%esp)
  800634:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800638:	c7 44 24 08 38 25 80 	movl   $0x802538,0x8(%esp)
  80063f:	00 
  800640:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800647:	00 
  800648:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  80064f:	e8 9c 01 00 00       	call   8007f0 <_panic>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
	return ipc_recv(NULL, FVA, NULL);
}

void
umain(int argc, char **argv)
  800654:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80065a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80065c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800661:	75 af                	jne    800612 <umain+0x571>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800663:	89 34 24             	mov    %esi,(%esp)
  800666:	e8 47 14 00 00       	call   801ab2 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80066b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800672:	00 
  800673:	c7 04 24 24 25 80 00 	movl   $0x802524,(%esp)
  80067a:	e8 e3 19 00 00       	call   802062 <open>
  80067f:	89 c6                	mov    %eax,%esi
  800681:	85 c0                	test   %eax,%eax
  800683:	79 20                	jns    8006a5 <umain+0x604>
		panic("open /big: %e", f);
  800685:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800689:	c7 44 24 08 4a 25 80 	movl   $0x80254a,0x8(%esp)
  800690:	00 
  800691:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  800698:	00 
  800699:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  8006a0:	e8 4b 01 00 00       	call   8007f0 <_panic>
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
  8006a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006aa:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  8006b0:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006b6:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8006bd:	00 
  8006be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c2:	89 34 24             	mov    %esi,(%esp)
  8006c5:	e8 eb 15 00 00       	call   801cb5 <readn>
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	79 24                	jns    8006f2 <umain+0x651>
			panic("read /big@%d: %e", i, r);
  8006ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006d6:	c7 44 24 08 58 25 80 	movl   $0x802558,0x8(%esp)
  8006dd:	00 
  8006de:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  8006e5:	00 
  8006e6:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  8006ed:	e8 fe 00 00 00       	call   8007f0 <_panic>
		if (r != sizeof(buf))
  8006f2:	3d 00 02 00 00       	cmp    $0x200,%eax
  8006f7:	74 2c                	je     800725 <umain+0x684>
			panic("read /big from %d returned %d < %d bytes",
  8006f9:	c7 44 24 14 00 02 00 	movl   $0x200,0x14(%esp)
  800700:	00 
  800701:	89 44 24 10          	mov    %eax,0x10(%esp)
  800705:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800709:	c7 44 24 08 08 27 80 	movl   $0x802708,0x8(%esp)
  800710:	00 
  800711:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  800718:	00 
  800719:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  800720:	e8 cb 00 00 00       	call   8007f0 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  800725:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  80072b:	39 d8                	cmp    %ebx,%eax
  80072d:	74 24                	je     800753 <umain+0x6b2>
			panic("read /big from %d returned bad data %d",
  80072f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800733:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800737:	c7 44 24 08 34 27 80 	movl   $0x802734,0x8(%esp)
  80073e:	00 
  80073f:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  800746:	00 
  800747:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  80074e:	e8 9d 00 00 00       	call   8007f0 <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800753:	8d 98 00 02 00 00    	lea    0x200(%eax),%ebx
  800759:	81 fb ff df 01 00    	cmp    $0x1dfff,%ebx
  80075f:	0f 8e 4b ff ff ff    	jle    8006b0 <umain+0x60f>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800765:	89 34 24             	mov    %esi,(%esp)
  800768:	e8 45 13 00 00       	call   801ab2 <close>
	cprintf("large file is good\n");
  80076d:	c7 04 24 69 25 80 00 	movl   $0x802569,(%esp)
  800774:	e8 72 01 00 00       	call   8008eb <cprintf>
}
  800779:	81 c4 cc 02 00 00    	add    $0x2cc,%esp
  80077f:	5b                   	pop    %ebx
  800780:	5e                   	pop    %esi
  800781:	5f                   	pop    %edi
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	83 ec 18             	sub    $0x18,%esp
  80078a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80078d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800790:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800793:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  800796:	e8 ac 0c 00 00       	call   801447 <sys_getenvid>
  80079b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8007a0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8007a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8007a8:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8007ad:	85 db                	test   %ebx,%ebx
  8007af:	7e 07                	jle    8007b8 <libmain+0x34>
		binaryname = argv[0];
  8007b1:	8b 06                	mov    (%esi),%eax
  8007b3:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8007b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007bc:	89 1c 24             	mov    %ebx,(%esp)
  8007bf:	e8 dd f8 ff ff       	call   8000a1 <umain>

	// exit gracefully
	exit();
  8007c4:	e8 0b 00 00 00       	call   8007d4 <exit>
}
  8007c9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8007cc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8007cf:	89 ec                	mov    %ebp,%esp
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    
  8007d3:	90                   	nop

008007d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8007da:	e8 04 13 00 00       	call   801ae3 <close_all>
	sys_env_destroy(0);
  8007df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007e6:	e8 f6 0b 00 00       	call   8013e1 <sys_env_destroy>
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    
  8007ed:	66 90                	xchg   %ax,%ax
  8007ef:	90                   	nop

008007f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	56                   	push   %esi
  8007f4:	53                   	push   %ebx
  8007f5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8007f8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007fb:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800801:	e8 41 0c 00 00       	call   801447 <sys_getenvid>
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
  800809:	89 54 24 10          	mov    %edx,0x10(%esp)
  80080d:	8b 55 08             	mov    0x8(%ebp),%edx
  800810:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800814:	89 74 24 08          	mov    %esi,0x8(%esp)
  800818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081c:	c7 04 24 8c 27 80 00 	movl   $0x80278c,(%esp)
  800823:	e8 c3 00 00 00       	call   8008eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800828:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082c:	8b 45 10             	mov    0x10(%ebp),%eax
  80082f:	89 04 24             	mov    %eax,(%esp)
  800832:	e8 53 00 00 00       	call   80088a <vcprintf>
	cprintf("\n");
  800837:	c7 04 24 88 24 80 00 	movl   $0x802488,(%esp)
  80083e:	e8 a8 00 00 00       	call   8008eb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800843:	cc                   	int3   
  800844:	eb fd                	jmp    800843 <_panic+0x53>
  800846:	66 90                	xchg   %ax,%ax

00800848 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 14             	sub    $0x14,%esp
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800852:	8b 03                	mov    (%ebx),%eax
  800854:	8b 55 08             	mov    0x8(%ebp),%edx
  800857:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80085b:	83 c0 01             	add    $0x1,%eax
  80085e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800860:	3d ff 00 00 00       	cmp    $0xff,%eax
  800865:	75 19                	jne    800880 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800867:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80086e:	00 
  80086f:	8d 43 08             	lea    0x8(%ebx),%eax
  800872:	89 04 24             	mov    %eax,(%esp)
  800875:	e8 f6 0a 00 00       	call   801370 <sys_cputs>
		b->idx = 0;
  80087a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800880:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800884:	83 c4 14             	add    $0x14,%esp
  800887:	5b                   	pop    %ebx
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800893:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80089a:	00 00 00 
	b.cnt = 0;
  80089d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8008a4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8008a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bf:	c7 04 24 48 08 80 00 	movl   $0x800848,(%esp)
  8008c6:	e8 b7 01 00 00       	call   800a82 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008cb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8008d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008db:	89 04 24             	mov    %eax,(%esp)
  8008de:	e8 8d 0a 00 00       	call   801370 <sys_cputs>

	return b.cnt;
}
  8008e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8008f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8008f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	89 04 24             	mov    %eax,(%esp)
  8008fe:	e8 87 ff ff ff       	call   80088a <vcprintf>
	va_end(ap);

	return cnt;
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    
  800905:	66 90                	xchg   %ax,%ax
  800907:	66 90                	xchg   %ax,%ax
  800909:	66 90                	xchg   %ax,%ax
  80090b:	66 90                	xchg   %ax,%ax
  80090d:	66 90                	xchg   %ax,%ax
  80090f:	90                   	nop

00800910 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	57                   	push   %edi
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	83 ec 4c             	sub    $0x4c,%esp
  800919:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80091c:	89 d7                	mov    %edx,%edi
  80091e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800921:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800924:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800927:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
  80092f:	39 d8                	cmp    %ebx,%eax
  800931:	72 17                	jb     80094a <printnum+0x3a>
  800933:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800936:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800939:	76 0f                	jbe    80094a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80093b:	8b 75 14             	mov    0x14(%ebp),%esi
  80093e:	83 ee 01             	sub    $0x1,%esi
  800941:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800944:	85 f6                	test   %esi,%esi
  800946:	7f 63                	jg     8009ab <printnum+0x9b>
  800948:	eb 75                	jmp    8009bf <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80094a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80094d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800951:	8b 45 14             	mov    0x14(%ebp),%eax
  800954:	83 e8 01             	sub    $0x1,%eax
  800957:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80095b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80095e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800962:	8b 44 24 08          	mov    0x8(%esp),%eax
  800966:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80096a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80096d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800970:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800977:	00 
  800978:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80097b:	89 1c 24             	mov    %ebx,(%esp)
  80097e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800981:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800985:	e8 56 17 00 00       	call   8020e0 <__udivdi3>
  80098a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80098d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800990:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800994:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800998:	89 04 24             	mov    %eax,(%esp)
  80099b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80099f:	89 fa                	mov    %edi,%edx
  8009a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8009a4:	e8 67 ff ff ff       	call   800910 <printnum>
  8009a9:	eb 14                	jmp    8009bf <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8009ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009af:	8b 45 18             	mov    0x18(%ebp),%eax
  8009b2:	89 04 24             	mov    %eax,(%esp)
  8009b5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8009b7:	83 ee 01             	sub    $0x1,%esi
  8009ba:	75 ef                	jne    8009ab <printnum+0x9b>
  8009bc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009bf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009c3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009ce:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009d5:	00 
  8009d6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8009d9:	89 1c 24             	mov    %ebx,(%esp)
  8009dc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e3:	e8 48 18 00 00       	call   802230 <__umoddi3>
  8009e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ec:	0f be 80 af 27 80 00 	movsbl 0x8027af(%eax),%eax
  8009f3:	89 04 24             	mov    %eax,(%esp)
  8009f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8009f9:	ff d0                	call   *%eax
}
  8009fb:	83 c4 4c             	add    $0x4c,%esp
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5f                   	pop    %edi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800a06:	83 fa 01             	cmp    $0x1,%edx
  800a09:	7e 0e                	jle    800a19 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800a0b:	8b 10                	mov    (%eax),%edx
  800a0d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800a10:	89 08                	mov    %ecx,(%eax)
  800a12:	8b 02                	mov    (%edx),%eax
  800a14:	8b 52 04             	mov    0x4(%edx),%edx
  800a17:	eb 22                	jmp    800a3b <getuint+0x38>
	else if (lflag)
  800a19:	85 d2                	test   %edx,%edx
  800a1b:	74 10                	je     800a2d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800a1d:	8b 10                	mov    (%eax),%edx
  800a1f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a22:	89 08                	mov    %ecx,(%eax)
  800a24:	8b 02                	mov    (%edx),%eax
  800a26:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2b:	eb 0e                	jmp    800a3b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800a2d:	8b 10                	mov    (%eax),%edx
  800a2f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a32:	89 08                	mov    %ecx,(%eax)
  800a34:	8b 02                	mov    (%edx),%eax
  800a36:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800a43:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800a47:	8b 10                	mov    (%eax),%edx
  800a49:	3b 50 04             	cmp    0x4(%eax),%edx
  800a4c:	73 0a                	jae    800a58 <sprintputch+0x1b>
		*b->buf++ = ch;
  800a4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a51:	88 0a                	mov    %cl,(%edx)
  800a53:	83 c2 01             	add    $0x1,%edx
  800a56:	89 10                	mov    %edx,(%eax)
}
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800a60:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a67:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	89 04 24             	mov    %eax,(%esp)
  800a7b:	e8 02 00 00 00       	call   800a82 <vprintfmt>
	va_end(ap);
}
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	83 ec 4c             	sub    $0x4c,%esp
  800a8b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a91:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a94:	eb 11                	jmp    800aa7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a96:	85 c0                	test   %eax,%eax
  800a98:	0f 84 db 03 00 00    	je     800e79 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  800a9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aa2:	89 04 24             	mov    %eax,(%esp)
  800aa5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800aa7:	0f b6 07             	movzbl (%edi),%eax
  800aaa:	83 c7 01             	add    $0x1,%edi
  800aad:	83 f8 25             	cmp    $0x25,%eax
  800ab0:	75 e4                	jne    800a96 <vprintfmt+0x14>
  800ab2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800ab6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800abd:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800ac4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800acb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad0:	eb 2b                	jmp    800afd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ad2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800ad5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800ad9:	eb 22                	jmp    800afd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800adb:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ade:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800ae2:	eb 19                	jmp    800afd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ae4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800ae7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800aee:	eb 0d                	jmp    800afd <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800af0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800af3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800af6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800afd:	0f b6 0f             	movzbl (%edi),%ecx
  800b00:	8d 47 01             	lea    0x1(%edi),%eax
  800b03:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b06:	0f b6 07             	movzbl (%edi),%eax
  800b09:	83 e8 23             	sub    $0x23,%eax
  800b0c:	3c 55                	cmp    $0x55,%al
  800b0e:	0f 87 40 03 00 00    	ja     800e54 <vprintfmt+0x3d2>
  800b14:	0f b6 c0             	movzbl %al,%eax
  800b17:	ff 24 85 00 29 80 00 	jmp    *0x802900(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800b1e:	83 e9 30             	sub    $0x30,%ecx
  800b21:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800b24:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800b28:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800b2b:	83 f9 09             	cmp    $0x9,%ecx
  800b2e:	77 57                	ja     800b87 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b30:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800b33:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b36:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800b39:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800b3c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800b3f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800b43:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800b46:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800b49:	83 f9 09             	cmp    $0x9,%ecx
  800b4c:	76 eb                	jbe    800b39 <vprintfmt+0xb7>
  800b4e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b51:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800b54:	eb 34                	jmp    800b8a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800b56:	8b 45 14             	mov    0x14(%ebp),%eax
  800b59:	8d 48 04             	lea    0x4(%eax),%ecx
  800b5c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800b5f:	8b 00                	mov    (%eax),%eax
  800b61:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b64:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800b67:	eb 21                	jmp    800b8a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800b69:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b6d:	0f 88 71 ff ff ff    	js     800ae4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b73:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800b76:	eb 85                	jmp    800afd <vprintfmt+0x7b>
  800b78:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800b7b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800b82:	e9 76 ff ff ff       	jmp    800afd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b87:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800b8a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b8e:	0f 89 69 ff ff ff    	jns    800afd <vprintfmt+0x7b>
  800b94:	e9 57 ff ff ff       	jmp    800af0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b99:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b9c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b9f:	e9 59 ff ff ff       	jmp    800afd <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800ba4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba7:	8d 50 04             	lea    0x4(%eax),%edx
  800baa:	89 55 14             	mov    %edx,0x14(%ebp)
  800bad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bb1:	8b 00                	mov    (%eax),%eax
  800bb3:	89 04 24             	mov    %eax,(%esp)
  800bb6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bb8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800bbb:	e9 e7 fe ff ff       	jmp    800aa7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800bc0:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc3:	8d 50 04             	lea    0x4(%eax),%edx
  800bc6:	89 55 14             	mov    %edx,0x14(%ebp)
  800bc9:	8b 00                	mov    (%eax),%eax
  800bcb:	89 c2                	mov    %eax,%edx
  800bcd:	c1 fa 1f             	sar    $0x1f,%edx
  800bd0:	31 d0                	xor    %edx,%eax
  800bd2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800bd4:	83 f8 0f             	cmp    $0xf,%eax
  800bd7:	7f 0b                	jg     800be4 <vprintfmt+0x162>
  800bd9:	8b 14 85 60 2a 80 00 	mov    0x802a60(,%eax,4),%edx
  800be0:	85 d2                	test   %edx,%edx
  800be2:	75 20                	jne    800c04 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800be4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800be8:	c7 44 24 08 c7 27 80 	movl   $0x8027c7,0x8(%esp)
  800bef:	00 
  800bf0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bf4:	89 34 24             	mov    %esi,(%esp)
  800bf7:	e8 5e fe ff ff       	call   800a5a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bfc:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800bff:	e9 a3 fe ff ff       	jmp    800aa7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800c04:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c08:	c7 44 24 08 d0 27 80 	movl   $0x8027d0,0x8(%esp)
  800c0f:	00 
  800c10:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c14:	89 34 24             	mov    %esi,(%esp)
  800c17:	e8 3e fe ff ff       	call   800a5a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c1c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800c1f:	e9 83 fe ff ff       	jmp    800aa7 <vprintfmt+0x25>
  800c24:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800c27:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800c2a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800c2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c30:	8d 50 04             	lea    0x4(%eax),%edx
  800c33:	89 55 14             	mov    %edx,0x14(%ebp)
  800c36:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800c38:	85 ff                	test   %edi,%edi
  800c3a:	b8 c0 27 80 00       	mov    $0x8027c0,%eax
  800c3f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800c42:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800c46:	74 06                	je     800c4e <vprintfmt+0x1cc>
  800c48:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800c4c:	7f 16                	jg     800c64 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c4e:	0f b6 17             	movzbl (%edi),%edx
  800c51:	0f be c2             	movsbl %dl,%eax
  800c54:	83 c7 01             	add    $0x1,%edi
  800c57:	85 c0                	test   %eax,%eax
  800c59:	0f 85 9f 00 00 00    	jne    800cfe <vprintfmt+0x27c>
  800c5f:	e9 8b 00 00 00       	jmp    800cef <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c64:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c68:	89 3c 24             	mov    %edi,(%esp)
  800c6b:	e8 c2 02 00 00       	call   800f32 <strnlen>
  800c70:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800c73:	29 c2                	sub    %eax,%edx
  800c75:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800c78:	85 d2                	test   %edx,%edx
  800c7a:	7e d2                	jle    800c4e <vprintfmt+0x1cc>
					putch(padc, putdat);
  800c7c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800c80:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800c83:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800c86:	89 d7                	mov    %edx,%edi
  800c88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c8f:	89 04 24             	mov    %eax,(%esp)
  800c92:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c94:	83 ef 01             	sub    $0x1,%edi
  800c97:	75 ef                	jne    800c88 <vprintfmt+0x206>
  800c99:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800c9c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800c9f:	eb ad                	jmp    800c4e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ca1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800ca5:	74 20                	je     800cc7 <vprintfmt+0x245>
  800ca7:	0f be d2             	movsbl %dl,%edx
  800caa:	83 ea 20             	sub    $0x20,%edx
  800cad:	83 fa 5e             	cmp    $0x5e,%edx
  800cb0:	76 15                	jbe    800cc7 <vprintfmt+0x245>
					putch('?', putdat);
  800cb2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800cb5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cb9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800cc0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800cc3:	ff d1                	call   *%ecx
  800cc5:	eb 0f                	jmp    800cd6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800cc7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800cca:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cce:	89 04 24             	mov    %eax,(%esp)
  800cd1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800cd4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800cd6:	83 eb 01             	sub    $0x1,%ebx
  800cd9:	0f b6 17             	movzbl (%edi),%edx
  800cdc:	0f be c2             	movsbl %dl,%eax
  800cdf:	83 c7 01             	add    $0x1,%edi
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	75 24                	jne    800d0a <vprintfmt+0x288>
  800ce6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800ce9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800cec:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cef:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800cf2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800cf6:	0f 8e ab fd ff ff    	jle    800aa7 <vprintfmt+0x25>
  800cfc:	eb 20                	jmp    800d1e <vprintfmt+0x29c>
  800cfe:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800d01:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800d04:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800d07:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800d0a:	85 f6                	test   %esi,%esi
  800d0c:	78 93                	js     800ca1 <vprintfmt+0x21f>
  800d0e:	83 ee 01             	sub    $0x1,%esi
  800d11:	79 8e                	jns    800ca1 <vprintfmt+0x21f>
  800d13:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800d16:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800d19:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800d1c:	eb d1                	jmp    800cef <vprintfmt+0x26d>
  800d1e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800d21:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d25:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800d2c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800d2e:	83 ef 01             	sub    $0x1,%edi
  800d31:	75 ee                	jne    800d21 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d33:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800d36:	e9 6c fd ff ff       	jmp    800aa7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800d3b:	83 fa 01             	cmp    $0x1,%edx
  800d3e:	66 90                	xchg   %ax,%ax
  800d40:	7e 16                	jle    800d58 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800d42:	8b 45 14             	mov    0x14(%ebp),%eax
  800d45:	8d 50 08             	lea    0x8(%eax),%edx
  800d48:	89 55 14             	mov    %edx,0x14(%ebp)
  800d4b:	8b 10                	mov    (%eax),%edx
  800d4d:	8b 48 04             	mov    0x4(%eax),%ecx
  800d50:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800d53:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800d56:	eb 32                	jmp    800d8a <vprintfmt+0x308>
	else if (lflag)
  800d58:	85 d2                	test   %edx,%edx
  800d5a:	74 18                	je     800d74 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  800d5c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d5f:	8d 50 04             	lea    0x4(%eax),%edx
  800d62:	89 55 14             	mov    %edx,0x14(%ebp)
  800d65:	8b 00                	mov    (%eax),%eax
  800d67:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800d6a:	89 c1                	mov    %eax,%ecx
  800d6c:	c1 f9 1f             	sar    $0x1f,%ecx
  800d6f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800d72:	eb 16                	jmp    800d8a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800d74:	8b 45 14             	mov    0x14(%ebp),%eax
  800d77:	8d 50 04             	lea    0x4(%eax),%edx
  800d7a:	89 55 14             	mov    %edx,0x14(%ebp)
  800d7d:	8b 00                	mov    (%eax),%eax
  800d7f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800d82:	89 c7                	mov    %eax,%edi
  800d84:	c1 ff 1f             	sar    $0x1f,%edi
  800d87:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800d8a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d8d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800d90:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800d95:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800d99:	79 7d                	jns    800e18 <vprintfmt+0x396>
				putch('-', putdat);
  800d9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d9f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800da6:	ff d6                	call   *%esi
				num = -(long long) num;
  800da8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800dab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800dae:	f7 d8                	neg    %eax
  800db0:	83 d2 00             	adc    $0x0,%edx
  800db3:	f7 da                	neg    %edx
			}
			base = 10;
  800db5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800dba:	eb 5c                	jmp    800e18 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800dbc:	8d 45 14             	lea    0x14(%ebp),%eax
  800dbf:	e8 3f fc ff ff       	call   800a03 <getuint>
			base = 10;
  800dc4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800dc9:	eb 4d                	jmp    800e18 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800dcb:	8d 45 14             	lea    0x14(%ebp),%eax
  800dce:	e8 30 fc ff ff       	call   800a03 <getuint>
			base = 8;
  800dd3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800dd8:	eb 3e                	jmp    800e18 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800dda:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dde:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800de5:	ff d6                	call   *%esi
			putch('x', putdat);
  800de7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800deb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800df2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800df4:	8b 45 14             	mov    0x14(%ebp),%eax
  800df7:	8d 50 04             	lea    0x4(%eax),%edx
  800dfa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800dfd:	8b 00                	mov    (%eax),%eax
  800dff:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e04:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800e09:	eb 0d                	jmp    800e18 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e0b:	8d 45 14             	lea    0x14(%ebp),%eax
  800e0e:	e8 f0 fb ff ff       	call   800a03 <getuint>
			base = 16;
  800e13:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800e18:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  800e1c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800e20:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800e23:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e27:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e2b:	89 04 24             	mov    %eax,(%esp)
  800e2e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e32:	89 da                	mov    %ebx,%edx
  800e34:	89 f0                	mov    %esi,%eax
  800e36:	e8 d5 fa ff ff       	call   800910 <printnum>
			break;
  800e3b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800e3e:	e9 64 fc ff ff       	jmp    800aa7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800e43:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e47:	89 0c 24             	mov    %ecx,(%esp)
  800e4a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e4c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800e4f:	e9 53 fc ff ff       	jmp    800aa7 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800e54:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e58:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800e5f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e61:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800e65:	0f 84 3c fc ff ff    	je     800aa7 <vprintfmt+0x25>
  800e6b:	83 ef 01             	sub    $0x1,%edi
  800e6e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800e72:	75 f7                	jne    800e6b <vprintfmt+0x3e9>
  800e74:	e9 2e fc ff ff       	jmp    800aa7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800e79:	83 c4 4c             	add    $0x4c,%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 28             	sub    $0x28,%esp
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e90:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e94:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e9e:	85 d2                	test   %edx,%edx
  800ea0:	7e 30                	jle    800ed2 <vsnprintf+0x51>
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	74 2c                	je     800ed2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ea6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ead:	8b 45 10             	mov    0x10(%ebp),%eax
  800eb0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eb4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800eb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ebb:	c7 04 24 3d 0a 80 00 	movl   $0x800a3d,(%esp)
  800ec2:	e8 bb fb ff ff       	call   800a82 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ec7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed0:	eb 05                	jmp    800ed7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ed2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    

00800ed9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800edf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ee2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ee6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef7:	89 04 24             	mov    %eax,(%esp)
  800efa:	e8 82 ff ff ff       	call   800e81 <vsnprintf>
	va_end(ap);

	return rc;
}
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    
  800f01:	66 90                	xchg   %ax,%ax
  800f03:	66 90                	xchg   %ax,%ax
  800f05:	66 90                	xchg   %ax,%ax
  800f07:	66 90                	xchg   %ax,%ax
  800f09:	66 90                	xchg   %ax,%ax
  800f0b:	66 90                	xchg   %ax,%ax
  800f0d:	66 90                	xchg   %ax,%ax
  800f0f:	90                   	nop

00800f10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f16:	80 3a 00             	cmpb   $0x0,(%edx)
  800f19:	74 10                	je     800f2b <strlen+0x1b>
  800f1b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800f20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800f23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f27:	75 f7                	jne    800f20 <strlen+0x10>
  800f29:	eb 05                	jmp    800f30 <strlen+0x20>
  800f2b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	53                   	push   %ebx
  800f36:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f3c:	85 c9                	test   %ecx,%ecx
  800f3e:	74 1c                	je     800f5c <strnlen+0x2a>
  800f40:	80 3b 00             	cmpb   $0x0,(%ebx)
  800f43:	74 1e                	je     800f63 <strnlen+0x31>
  800f45:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800f4a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f4c:	39 ca                	cmp    %ecx,%edx
  800f4e:	74 18                	je     800f68 <strnlen+0x36>
  800f50:	83 c2 01             	add    $0x1,%edx
  800f53:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800f58:	75 f0                	jne    800f4a <strnlen+0x18>
  800f5a:	eb 0c                	jmp    800f68 <strnlen+0x36>
  800f5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f61:	eb 05                	jmp    800f68 <strnlen+0x36>
  800f63:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800f68:	5b                   	pop    %ebx
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	53                   	push   %ebx
  800f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800f75:	89 c2                	mov    %eax,%edx
  800f77:	0f b6 19             	movzbl (%ecx),%ebx
  800f7a:	88 1a                	mov    %bl,(%edx)
  800f7c:	83 c2 01             	add    $0x1,%edx
  800f7f:	83 c1 01             	add    $0x1,%ecx
  800f82:	84 db                	test   %bl,%bl
  800f84:	75 f1                	jne    800f77 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800f86:	5b                   	pop    %ebx
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 08             	sub    $0x8,%esp
  800f90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800f93:	89 1c 24             	mov    %ebx,(%esp)
  800f96:	e8 75 ff ff ff       	call   800f10 <strlen>
	strcpy(dst + len, src);
  800f9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fa2:	01 d8                	add    %ebx,%eax
  800fa4:	89 04 24             	mov    %eax,(%esp)
  800fa7:	e8 bf ff ff ff       	call   800f6b <strcpy>
	return dst;
}
  800fac:	89 d8                	mov    %ebx,%eax
  800fae:	83 c4 08             	add    $0x8,%esp
  800fb1:	5b                   	pop    %ebx
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	56                   	push   %esi
  800fb8:	53                   	push   %ebx
  800fb9:	8b 75 08             	mov    0x8(%ebp),%esi
  800fbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800fc2:	85 db                	test   %ebx,%ebx
  800fc4:	74 16                	je     800fdc <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800fc6:	01 f3                	add    %esi,%ebx
  800fc8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800fca:	0f b6 02             	movzbl (%edx),%eax
  800fcd:	88 01                	mov    %al,(%ecx)
  800fcf:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800fd2:	80 3a 01             	cmpb   $0x1,(%edx)
  800fd5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800fd8:	39 d9                	cmp    %ebx,%ecx
  800fda:	75 ee                	jne    800fca <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800fdc:	89 f0                	mov    %esi,%eax
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    

00800fe2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	57                   	push   %edi
  800fe6:	56                   	push   %esi
  800fe7:	53                   	push   %ebx
  800fe8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800feb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fee:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ff1:	89 f8                	mov    %edi,%eax
  800ff3:	85 f6                	test   %esi,%esi
  800ff5:	74 33                	je     80102a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800ff7:	83 fe 01             	cmp    $0x1,%esi
  800ffa:	74 25                	je     801021 <strlcpy+0x3f>
  800ffc:	0f b6 0b             	movzbl (%ebx),%ecx
  800fff:	84 c9                	test   %cl,%cl
  801001:	74 22                	je     801025 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801003:	83 ee 02             	sub    $0x2,%esi
  801006:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80100b:	88 08                	mov    %cl,(%eax)
  80100d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801010:	39 f2                	cmp    %esi,%edx
  801012:	74 13                	je     801027 <strlcpy+0x45>
  801014:	83 c2 01             	add    $0x1,%edx
  801017:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80101b:	84 c9                	test   %cl,%cl
  80101d:	75 ec                	jne    80100b <strlcpy+0x29>
  80101f:	eb 06                	jmp    801027 <strlcpy+0x45>
  801021:	89 f8                	mov    %edi,%eax
  801023:	eb 02                	jmp    801027 <strlcpy+0x45>
  801025:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801027:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80102a:	29 f8                	sub    %edi,%eax
}
  80102c:	5b                   	pop    %ebx
  80102d:	5e                   	pop    %esi
  80102e:	5f                   	pop    %edi
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801037:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80103a:	0f b6 01             	movzbl (%ecx),%eax
  80103d:	84 c0                	test   %al,%al
  80103f:	74 15                	je     801056 <strcmp+0x25>
  801041:	3a 02                	cmp    (%edx),%al
  801043:	75 11                	jne    801056 <strcmp+0x25>
		p++, q++;
  801045:	83 c1 01             	add    $0x1,%ecx
  801048:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80104b:	0f b6 01             	movzbl (%ecx),%eax
  80104e:	84 c0                	test   %al,%al
  801050:	74 04                	je     801056 <strcmp+0x25>
  801052:	3a 02                	cmp    (%edx),%al
  801054:	74 ef                	je     801045 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801056:	0f b6 c0             	movzbl %al,%eax
  801059:	0f b6 12             	movzbl (%edx),%edx
  80105c:	29 d0                	sub    %edx,%eax
}
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	56                   	push   %esi
  801064:	53                   	push   %ebx
  801065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801068:	8b 55 0c             	mov    0xc(%ebp),%edx
  80106b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80106e:	85 f6                	test   %esi,%esi
  801070:	74 29                	je     80109b <strncmp+0x3b>
  801072:	0f b6 03             	movzbl (%ebx),%eax
  801075:	84 c0                	test   %al,%al
  801077:	74 30                	je     8010a9 <strncmp+0x49>
  801079:	3a 02                	cmp    (%edx),%al
  80107b:	75 2c                	jne    8010a9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80107d:	8d 43 01             	lea    0x1(%ebx),%eax
  801080:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  801082:	89 c3                	mov    %eax,%ebx
  801084:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801087:	39 f0                	cmp    %esi,%eax
  801089:	74 17                	je     8010a2 <strncmp+0x42>
  80108b:	0f b6 08             	movzbl (%eax),%ecx
  80108e:	84 c9                	test   %cl,%cl
  801090:	74 17                	je     8010a9 <strncmp+0x49>
  801092:	83 c0 01             	add    $0x1,%eax
  801095:	3a 0a                	cmp    (%edx),%cl
  801097:	74 e9                	je     801082 <strncmp+0x22>
  801099:	eb 0e                	jmp    8010a9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80109b:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a0:	eb 0f                	jmp    8010b1 <strncmp+0x51>
  8010a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a7:	eb 08                	jmp    8010b1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8010a9:	0f b6 03             	movzbl (%ebx),%eax
  8010ac:	0f b6 12             	movzbl (%edx),%edx
  8010af:	29 d0                	sub    %edx,%eax
}
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	53                   	push   %ebx
  8010b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8010bf:	0f b6 18             	movzbl (%eax),%ebx
  8010c2:	84 db                	test   %bl,%bl
  8010c4:	74 1d                	je     8010e3 <strchr+0x2e>
  8010c6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8010c8:	38 d3                	cmp    %dl,%bl
  8010ca:	75 06                	jne    8010d2 <strchr+0x1d>
  8010cc:	eb 1a                	jmp    8010e8 <strchr+0x33>
  8010ce:	38 ca                	cmp    %cl,%dl
  8010d0:	74 16                	je     8010e8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8010d2:	83 c0 01             	add    $0x1,%eax
  8010d5:	0f b6 10             	movzbl (%eax),%edx
  8010d8:	84 d2                	test   %dl,%dl
  8010da:	75 f2                	jne    8010ce <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  8010dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e1:	eb 05                	jmp    8010e8 <strchr+0x33>
  8010e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010e8:	5b                   	pop    %ebx
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    

008010eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	53                   	push   %ebx
  8010ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8010f5:	0f b6 18             	movzbl (%eax),%ebx
  8010f8:	84 db                	test   %bl,%bl
  8010fa:	74 16                	je     801112 <strfind+0x27>
  8010fc:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8010fe:	38 d3                	cmp    %dl,%bl
  801100:	75 06                	jne    801108 <strfind+0x1d>
  801102:	eb 0e                	jmp    801112 <strfind+0x27>
  801104:	38 ca                	cmp    %cl,%dl
  801106:	74 0a                	je     801112 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801108:	83 c0 01             	add    $0x1,%eax
  80110b:	0f b6 10             	movzbl (%eax),%edx
  80110e:	84 d2                	test   %dl,%dl
  801110:	75 f2                	jne    801104 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  801112:	5b                   	pop    %ebx
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80111e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801121:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801124:	8b 7d 08             	mov    0x8(%ebp),%edi
  801127:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80112a:	85 c9                	test   %ecx,%ecx
  80112c:	74 36                	je     801164 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80112e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801134:	75 28                	jne    80115e <memset+0x49>
  801136:	f6 c1 03             	test   $0x3,%cl
  801139:	75 23                	jne    80115e <memset+0x49>
		c &= 0xFF;
  80113b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80113f:	89 d3                	mov    %edx,%ebx
  801141:	c1 e3 08             	shl    $0x8,%ebx
  801144:	89 d6                	mov    %edx,%esi
  801146:	c1 e6 18             	shl    $0x18,%esi
  801149:	89 d0                	mov    %edx,%eax
  80114b:	c1 e0 10             	shl    $0x10,%eax
  80114e:	09 f0                	or     %esi,%eax
  801150:	09 c2                	or     %eax,%edx
  801152:	89 d0                	mov    %edx,%eax
  801154:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801156:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801159:	fc                   	cld    
  80115a:	f3 ab                	rep stos %eax,%es:(%edi)
  80115c:	eb 06                	jmp    801164 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80115e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801161:	fc                   	cld    
  801162:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  801164:	89 f8                	mov    %edi,%eax
  801166:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801169:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80116c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80116f:	89 ec                	mov    %ebp,%esp
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	83 ec 08             	sub    $0x8,%esp
  801179:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80117c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80117f:	8b 45 08             	mov    0x8(%ebp),%eax
  801182:	8b 75 0c             	mov    0xc(%ebp),%esi
  801185:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801188:	39 c6                	cmp    %eax,%esi
  80118a:	73 36                	jae    8011c2 <memmove+0x4f>
  80118c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80118f:	39 d0                	cmp    %edx,%eax
  801191:	73 2f                	jae    8011c2 <memmove+0x4f>
		s += n;
		d += n;
  801193:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801196:	f6 c2 03             	test   $0x3,%dl
  801199:	75 1b                	jne    8011b6 <memmove+0x43>
  80119b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8011a1:	75 13                	jne    8011b6 <memmove+0x43>
  8011a3:	f6 c1 03             	test   $0x3,%cl
  8011a6:	75 0e                	jne    8011b6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8011a8:	83 ef 04             	sub    $0x4,%edi
  8011ab:	8d 72 fc             	lea    -0x4(%edx),%esi
  8011ae:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8011b1:	fd                   	std    
  8011b2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011b4:	eb 09                	jmp    8011bf <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8011b6:	83 ef 01             	sub    $0x1,%edi
  8011b9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8011bc:	fd                   	std    
  8011bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8011bf:	fc                   	cld    
  8011c0:	eb 20                	jmp    8011e2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8011c2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8011c8:	75 13                	jne    8011dd <memmove+0x6a>
  8011ca:	a8 03                	test   $0x3,%al
  8011cc:	75 0f                	jne    8011dd <memmove+0x6a>
  8011ce:	f6 c1 03             	test   $0x3,%cl
  8011d1:	75 0a                	jne    8011dd <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8011d3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8011d6:	89 c7                	mov    %eax,%edi
  8011d8:	fc                   	cld    
  8011d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011db:	eb 05                	jmp    8011e2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8011dd:	89 c7                	mov    %eax,%edi
  8011df:	fc                   	cld    
  8011e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8011e2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011e5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011e8:	89 ec                	mov    %ebp,%esp
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801200:	8b 45 08             	mov    0x8(%ebp),%eax
  801203:	89 04 24             	mov    %eax,(%esp)
  801206:	e8 68 ff ff ff       	call   801173 <memmove>
}
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	57                   	push   %edi
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801216:	8b 75 0c             	mov    0xc(%ebp),%esi
  801219:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80121c:	8d 78 ff             	lea    -0x1(%eax),%edi
  80121f:	85 c0                	test   %eax,%eax
  801221:	74 36                	je     801259 <memcmp+0x4c>
		if (*s1 != *s2)
  801223:	0f b6 03             	movzbl (%ebx),%eax
  801226:	0f b6 0e             	movzbl (%esi),%ecx
  801229:	38 c8                	cmp    %cl,%al
  80122b:	75 17                	jne    801244 <memcmp+0x37>
  80122d:	ba 00 00 00 00       	mov    $0x0,%edx
  801232:	eb 1a                	jmp    80124e <memcmp+0x41>
  801234:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801239:	83 c2 01             	add    $0x1,%edx
  80123c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801240:	38 c8                	cmp    %cl,%al
  801242:	74 0a                	je     80124e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801244:	0f b6 c0             	movzbl %al,%eax
  801247:	0f b6 c9             	movzbl %cl,%ecx
  80124a:	29 c8                	sub    %ecx,%eax
  80124c:	eb 10                	jmp    80125e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80124e:	39 fa                	cmp    %edi,%edx
  801250:	75 e2                	jne    801234 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801252:	b8 00 00 00 00       	mov    $0x0,%eax
  801257:	eb 05                	jmp    80125e <memcmp+0x51>
  801259:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80125e:	5b                   	pop    %ebx
  80125f:	5e                   	pop    %esi
  801260:	5f                   	pop    %edi
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	53                   	push   %ebx
  801267:	8b 45 08             	mov    0x8(%ebp),%eax
  80126a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  80126d:	89 c2                	mov    %eax,%edx
  80126f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801272:	39 d0                	cmp    %edx,%eax
  801274:	73 13                	jae    801289 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801276:	89 d9                	mov    %ebx,%ecx
  801278:	38 18                	cmp    %bl,(%eax)
  80127a:	75 06                	jne    801282 <memfind+0x1f>
  80127c:	eb 0b                	jmp    801289 <memfind+0x26>
  80127e:	38 08                	cmp    %cl,(%eax)
  801280:	74 07                	je     801289 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801282:	83 c0 01             	add    $0x1,%eax
  801285:	39 d0                	cmp    %edx,%eax
  801287:	75 f5                	jne    80127e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801289:	5b                   	pop    %ebx
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	57                   	push   %edi
  801290:	56                   	push   %esi
  801291:	53                   	push   %ebx
  801292:	83 ec 04             	sub    $0x4,%esp
  801295:	8b 55 08             	mov    0x8(%ebp),%edx
  801298:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80129b:	0f b6 02             	movzbl (%edx),%eax
  80129e:	3c 09                	cmp    $0x9,%al
  8012a0:	74 04                	je     8012a6 <strtol+0x1a>
  8012a2:	3c 20                	cmp    $0x20,%al
  8012a4:	75 0e                	jne    8012b4 <strtol+0x28>
		s++;
  8012a6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012a9:	0f b6 02             	movzbl (%edx),%eax
  8012ac:	3c 09                	cmp    $0x9,%al
  8012ae:	74 f6                	je     8012a6 <strtol+0x1a>
  8012b0:	3c 20                	cmp    $0x20,%al
  8012b2:	74 f2                	je     8012a6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8012b4:	3c 2b                	cmp    $0x2b,%al
  8012b6:	75 0a                	jne    8012c2 <strtol+0x36>
		s++;
  8012b8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8012bb:	bf 00 00 00 00       	mov    $0x0,%edi
  8012c0:	eb 10                	jmp    8012d2 <strtol+0x46>
  8012c2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8012c7:	3c 2d                	cmp    $0x2d,%al
  8012c9:	75 07                	jne    8012d2 <strtol+0x46>
		s++, neg = 1;
  8012cb:	83 c2 01             	add    $0x1,%edx
  8012ce:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8012d2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8012d8:	75 15                	jne    8012ef <strtol+0x63>
  8012da:	80 3a 30             	cmpb   $0x30,(%edx)
  8012dd:	75 10                	jne    8012ef <strtol+0x63>
  8012df:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8012e3:	75 0a                	jne    8012ef <strtol+0x63>
		s += 2, base = 16;
  8012e5:	83 c2 02             	add    $0x2,%edx
  8012e8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8012ed:	eb 10                	jmp    8012ff <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  8012ef:	85 db                	test   %ebx,%ebx
  8012f1:	75 0c                	jne    8012ff <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8012f3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8012f5:	80 3a 30             	cmpb   $0x30,(%edx)
  8012f8:	75 05                	jne    8012ff <strtol+0x73>
		s++, base = 8;
  8012fa:	83 c2 01             	add    $0x1,%edx
  8012fd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8012ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801304:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801307:	0f b6 0a             	movzbl (%edx),%ecx
  80130a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80130d:	89 f3                	mov    %esi,%ebx
  80130f:	80 fb 09             	cmp    $0x9,%bl
  801312:	77 08                	ja     80131c <strtol+0x90>
			dig = *s - '0';
  801314:	0f be c9             	movsbl %cl,%ecx
  801317:	83 e9 30             	sub    $0x30,%ecx
  80131a:	eb 22                	jmp    80133e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  80131c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80131f:	89 f3                	mov    %esi,%ebx
  801321:	80 fb 19             	cmp    $0x19,%bl
  801324:	77 08                	ja     80132e <strtol+0xa2>
			dig = *s - 'a' + 10;
  801326:	0f be c9             	movsbl %cl,%ecx
  801329:	83 e9 57             	sub    $0x57,%ecx
  80132c:	eb 10                	jmp    80133e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  80132e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801331:	89 f3                	mov    %esi,%ebx
  801333:	80 fb 19             	cmp    $0x19,%bl
  801336:	77 16                	ja     80134e <strtol+0xc2>
			dig = *s - 'A' + 10;
  801338:	0f be c9             	movsbl %cl,%ecx
  80133b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80133e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801341:	7d 0f                	jge    801352 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801343:	83 c2 01             	add    $0x1,%edx
  801346:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  80134a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80134c:	eb b9                	jmp    801307 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80134e:	89 c1                	mov    %eax,%ecx
  801350:	eb 02                	jmp    801354 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801352:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801354:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801358:	74 05                	je     80135f <strtol+0xd3>
		*endptr = (char *) s;
  80135a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80135d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80135f:	89 ca                	mov    %ecx,%edx
  801361:	f7 da                	neg    %edx
  801363:	85 ff                	test   %edi,%edi
  801365:	0f 45 c2             	cmovne %edx,%eax
}
  801368:	83 c4 04             	add    $0x4,%esp
  80136b:	5b                   	pop    %ebx
  80136c:	5e                   	pop    %esi
  80136d:	5f                   	pop    %edi
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    

00801370 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	83 ec 0c             	sub    $0xc,%esp
  801376:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801379:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80137c:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  80137f:	b8 01 00 00 00       	mov    $0x1,%eax
  801384:	0f a2                	cpuid  
  801386:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801388:	b8 00 00 00 00       	mov    $0x0,%eax
  80138d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801390:	8b 55 08             	mov    0x8(%ebp),%edx
  801393:	89 c3                	mov    %eax,%ebx
  801395:	89 c7                	mov    %eax,%edi
  801397:	89 c6                	mov    %eax,%esi
  801399:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80139b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80139e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013a1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013a4:	89 ec                	mov    %ebp,%esp
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	83 ec 0c             	sub    $0xc,%esp
  8013ae:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013b1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013b4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8013bc:	0f a2                	cpuid  
  8013be:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ca:	89 d1                	mov    %edx,%ecx
  8013cc:	89 d3                	mov    %edx,%ebx
  8013ce:	89 d7                	mov    %edx,%edi
  8013d0:	89 d6                	mov    %edx,%esi
  8013d2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8013d4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013d7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013da:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013dd:	89 ec                	mov    %ebp,%esp
  8013df:	5d                   	pop    %ebp
  8013e0:	c3                   	ret    

008013e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	83 ec 38             	sub    $0x38,%esp
  8013e7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013ea:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013ed:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8013f5:	0f a2                	cpuid  
  8013f7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013fe:	b8 03 00 00 00       	mov    $0x3,%eax
  801403:	8b 55 08             	mov    0x8(%ebp),%edx
  801406:	89 cb                	mov    %ecx,%ebx
  801408:	89 cf                	mov    %ecx,%edi
  80140a:	89 ce                	mov    %ecx,%esi
  80140c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80140e:	85 c0                	test   %eax,%eax
  801410:	7e 28                	jle    80143a <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801412:	89 44 24 10          	mov    %eax,0x10(%esp)
  801416:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80141d:	00 
  80141e:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  801425:	00 
  801426:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80142d:	00 
  80142e:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801435:	e8 b6 f3 ff ff       	call   8007f0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80143a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80143d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801440:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801443:	89 ec                	mov    %ebp,%esp
  801445:	5d                   	pop    %ebp
  801446:	c3                   	ret    

00801447 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	83 ec 0c             	sub    $0xc,%esp
  80144d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801450:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801453:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801456:	b8 01 00 00 00       	mov    $0x1,%eax
  80145b:	0f a2                	cpuid  
  80145d:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80145f:	ba 00 00 00 00       	mov    $0x0,%edx
  801464:	b8 02 00 00 00       	mov    $0x2,%eax
  801469:	89 d1                	mov    %edx,%ecx
  80146b:	89 d3                	mov    %edx,%ebx
  80146d:	89 d7                	mov    %edx,%edi
  80146f:	89 d6                	mov    %edx,%esi
  801471:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801473:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801476:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801479:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80147c:	89 ec                	mov    %ebp,%esp
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    

00801480 <sys_yield>:

void
sys_yield(void)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	83 ec 0c             	sub    $0xc,%esp
  801486:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801489:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80148c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80148f:	b8 01 00 00 00       	mov    $0x1,%eax
  801494:	0f a2                	cpuid  
  801496:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801498:	ba 00 00 00 00       	mov    $0x0,%edx
  80149d:	b8 0b 00 00 00       	mov    $0xb,%eax
  8014a2:	89 d1                	mov    %edx,%ecx
  8014a4:	89 d3                	mov    %edx,%ebx
  8014a6:	89 d7                	mov    %edx,%edi
  8014a8:	89 d6                	mov    %edx,%esi
  8014aa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8014ac:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014af:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014b2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014b5:	89 ec                	mov    %ebp,%esp
  8014b7:	5d                   	pop    %ebp
  8014b8:	c3                   	ret    

008014b9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	83 ec 38             	sub    $0x38,%esp
  8014bf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014c2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014c5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8014cd:	0f a2                	cpuid  
  8014cf:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d1:	be 00 00 00 00       	mov    $0x0,%esi
  8014d6:	b8 04 00 00 00       	mov    $0x4,%eax
  8014db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014de:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014e4:	89 f7                	mov    %esi,%edi
  8014e6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	7e 28                	jle    801514 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014f0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8014f7:	00 
  8014f8:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  8014ff:	00 
  801500:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801507:	00 
  801508:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  80150f:	e8 dc f2 ff ff       	call   8007f0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801514:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801517:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80151a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80151d:	89 ec                	mov    %ebp,%esp
  80151f:	5d                   	pop    %ebp
  801520:	c3                   	ret    

00801521 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	83 ec 38             	sub    $0x38,%esp
  801527:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80152a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80152d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801530:	b8 01 00 00 00       	mov    $0x1,%eax
  801535:	0f a2                	cpuid  
  801537:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801539:	b8 05 00 00 00       	mov    $0x5,%eax
  80153e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801541:	8b 55 08             	mov    0x8(%ebp),%edx
  801544:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801547:	8b 7d 14             	mov    0x14(%ebp),%edi
  80154a:	8b 75 18             	mov    0x18(%ebp),%esi
  80154d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80154f:	85 c0                	test   %eax,%eax
  801551:	7e 28                	jle    80157b <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801553:	89 44 24 10          	mov    %eax,0x10(%esp)
  801557:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80155e:	00 
  80155f:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  801566:	00 
  801567:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80156e:	00 
  80156f:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801576:	e8 75 f2 ff ff       	call   8007f0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80157b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80157e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801581:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801584:	89 ec                	mov    %ebp,%esp
  801586:	5d                   	pop    %ebp
  801587:	c3                   	ret    

00801588 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	83 ec 38             	sub    $0x38,%esp
  80158e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801591:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801594:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801597:	b8 01 00 00 00       	mov    $0x1,%eax
  80159c:	0f a2                	cpuid  
  80159e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a5:	b8 06 00 00 00       	mov    $0x6,%eax
  8015aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b0:	89 df                	mov    %ebx,%edi
  8015b2:	89 de                	mov    %ebx,%esi
  8015b4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	7e 28                	jle    8015e2 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015be:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8015c5:	00 
  8015c6:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  8015cd:	00 
  8015ce:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8015d5:	00 
  8015d6:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  8015dd:	e8 0e f2 ff ff       	call   8007f0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8015e2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015e5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015e8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015eb:	89 ec                	mov    %ebp,%esp
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    

008015ef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	83 ec 38             	sub    $0x38,%esp
  8015f5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8015f8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015fb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8015fe:	b8 01 00 00 00       	mov    $0x1,%eax
  801603:	0f a2                	cpuid  
  801605:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801607:	bb 00 00 00 00       	mov    $0x0,%ebx
  80160c:	b8 08 00 00 00       	mov    $0x8,%eax
  801611:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801614:	8b 55 08             	mov    0x8(%ebp),%edx
  801617:	89 df                	mov    %ebx,%edi
  801619:	89 de                	mov    %ebx,%esi
  80161b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80161d:	85 c0                	test   %eax,%eax
  80161f:	7e 28                	jle    801649 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801621:	89 44 24 10          	mov    %eax,0x10(%esp)
  801625:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80162c:	00 
  80162d:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  801634:	00 
  801635:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80163c:	00 
  80163d:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801644:	e8 a7 f1 ff ff       	call   8007f0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801649:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80164c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80164f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801652:	89 ec                	mov    %ebp,%esp
  801654:	5d                   	pop    %ebp
  801655:	c3                   	ret    

00801656 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	83 ec 38             	sub    $0x38,%esp
  80165c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80165f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801662:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801665:	b8 01 00 00 00       	mov    $0x1,%eax
  80166a:	0f a2                	cpuid  
  80166c:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80166e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801673:	b8 09 00 00 00       	mov    $0x9,%eax
  801678:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80167b:	8b 55 08             	mov    0x8(%ebp),%edx
  80167e:	89 df                	mov    %ebx,%edi
  801680:	89 de                	mov    %ebx,%esi
  801682:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801684:	85 c0                	test   %eax,%eax
  801686:	7e 28                	jle    8016b0 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801688:	89 44 24 10          	mov    %eax,0x10(%esp)
  80168c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801693:	00 
  801694:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  80169b:	00 
  80169c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8016a3:	00 
  8016a4:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  8016ab:	e8 40 f1 ff ff       	call   8007f0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016b0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016b3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016b9:	89 ec                	mov    %ebp,%esp
  8016bb:	5d                   	pop    %ebp
  8016bc:	c3                   	ret    

008016bd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	83 ec 38             	sub    $0x38,%esp
  8016c3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8016c6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016c9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8016cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8016d1:	0f a2                	cpuid  
  8016d3:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8016e5:	89 df                	mov    %ebx,%edi
  8016e7:	89 de                	mov    %ebx,%esi
  8016e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	7e 28                	jle    801717 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016f3:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8016fa:	00 
  8016fb:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  801702:	00 
  801703:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80170a:	00 
  80170b:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801712:	e8 d9 f0 ff ff       	call   8007f0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801717:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80171a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80171d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801720:	89 ec                	mov    %ebp,%esp
  801722:	5d                   	pop    %ebp
  801723:	c3                   	ret    

00801724 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	83 ec 0c             	sub    $0xc,%esp
  80172a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80172d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801730:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801733:	b8 01 00 00 00       	mov    $0x1,%eax
  801738:	0f a2                	cpuid  
  80173a:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80173c:	be 00 00 00 00       	mov    $0x0,%esi
  801741:	b8 0c 00 00 00       	mov    $0xc,%eax
  801746:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801749:	8b 55 08             	mov    0x8(%ebp),%edx
  80174c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80174f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801752:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801754:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801757:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80175a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80175d:	89 ec                	mov    %ebp,%esp
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	83 ec 38             	sub    $0x38,%esp
  801767:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80176a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80176d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801770:	b8 01 00 00 00       	mov    $0x1,%eax
  801775:	0f a2                	cpuid  
  801777:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801779:	b9 00 00 00 00       	mov    $0x0,%ecx
  80177e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801783:	8b 55 08             	mov    0x8(%ebp),%edx
  801786:	89 cb                	mov    %ecx,%ebx
  801788:	89 cf                	mov    %ecx,%edi
  80178a:	89 ce                	mov    %ecx,%esi
  80178c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80178e:	85 c0                	test   %eax,%eax
  801790:	7e 28                	jle    8017ba <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801792:	89 44 24 10          	mov    %eax,0x10(%esp)
  801796:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80179d:	00 
  80179e:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  8017a5:	00 
  8017a6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8017ad:	00 
  8017ae:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  8017b5:	e8 36 f0 ff ff       	call   8007f0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8017ba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8017bd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8017c0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8017c3:	89 ec                	mov    %ebp,%esp
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    
  8017c7:	90                   	nop

008017c8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	56                   	push   %esi
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 10             	sub    $0x10,%esp
  8017d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8017d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  8017d6:	85 db                	test   %ebx,%ebx
  8017d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8017dd:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  8017e0:	89 1c 24             	mov    %ebx,(%esp)
  8017e3:	e8 79 ff ff ff       	call   801761 <sys_ipc_recv>
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 2d                	js     801819 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  8017ec:	85 f6                	test   %esi,%esi
  8017ee:	74 0a                	je     8017fa <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  8017f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8017f5:	8b 40 74             	mov    0x74(%eax),%eax
  8017f8:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  8017fa:	85 db                	test   %ebx,%ebx
  8017fc:	74 13                	je     801811 <ipc_recv+0x49>
  8017fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801802:	74 0d                	je     801811 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  801804:	a1 04 40 80 00       	mov    0x804004,%eax
  801809:	8b 40 78             	mov    0x78(%eax),%eax
  80180c:	8b 55 10             	mov    0x10(%ebp),%edx
  80180f:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801811:	a1 04 40 80 00       	mov    0x804004,%eax
  801816:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801819:	83 c4 10             	add    $0x10,%esp
  80181c:	5b                   	pop    %ebx
  80181d:	5e                   	pop    %esi
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	57                   	push   %edi
  801824:	56                   	push   %esi
  801825:	53                   	push   %ebx
  801826:	83 ec 1c             	sub    $0x1c,%esp
  801829:	8b 7d 08             	mov    0x8(%ebp),%edi
  80182c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80182f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801832:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801834:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801839:	0f 44 d8             	cmove  %eax,%ebx
  80183c:	eb 2a                	jmp    801868 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  80183e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801841:	74 20                	je     801863 <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801843:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801847:	c7 44 24 08 ea 2a 80 	movl   $0x802aea,0x8(%esp)
  80184e:	00 
  80184f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801856:	00 
  801857:	c7 04 24 01 2b 80 00 	movl   $0x802b01,(%esp)
  80185e:	e8 8d ef ff ff       	call   8007f0 <_panic>
		sys_yield();
  801863:	e8 18 fc ff ff       	call   801480 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801868:	8b 45 14             	mov    0x14(%ebp),%eax
  80186b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80186f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801873:	89 74 24 04          	mov    %esi,0x4(%esp)
  801877:	89 3c 24             	mov    %edi,(%esp)
  80187a:	e8 a5 fe ff ff       	call   801724 <sys_ipc_try_send>
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 bb                	js     80183e <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801883:	83 c4 1c             	add    $0x1c,%esp
  801886:	5b                   	pop    %ebx
  801887:	5e                   	pop    %esi
  801888:	5f                   	pop    %edi
  801889:	5d                   	pop    %ebp
  80188a:	c3                   	ret    

0080188b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801891:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801896:	39 c8                	cmp    %ecx,%eax
  801898:	74 17                	je     8018b1 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80189a:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80189f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8018a2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8018a8:	8b 52 50             	mov    0x50(%edx),%edx
  8018ab:	39 ca                	cmp    %ecx,%edx
  8018ad:	75 14                	jne    8018c3 <ipc_find_env+0x38>
  8018af:	eb 05                	jmp    8018b6 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8018b1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8018b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018b9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8018be:	8b 40 40             	mov    0x40(%eax),%eax
  8018c1:	eb 0e                	jmp    8018d1 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8018c3:	83 c0 01             	add    $0x1,%eax
  8018c6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8018cb:	75 d2                	jne    80189f <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8018cd:	66 b8 00 00          	mov    $0x0,%ax
}
  8018d1:	5d                   	pop    %ebp
  8018d2:	c3                   	ret    
  8018d3:	66 90                	xchg   %ax,%ax
  8018d5:	66 90                	xchg   %ax,%ax
  8018d7:	66 90                	xchg   %ax,%ax
  8018d9:	66 90                	xchg   %ax,%ax
  8018db:	66 90                	xchg   %ax,%ax
  8018dd:	66 90                	xchg   %ax,%ax
  8018df:	90                   	nop

008018e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8018e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8018eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8018ee:	5d                   	pop    %ebp
  8018ef:	c3                   	ret    

008018f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8018f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f9:	89 04 24             	mov    %eax,(%esp)
  8018fc:	e8 df ff ff ff       	call   8018e0 <fd2num>
  801901:	c1 e0 0c             	shl    $0xc,%eax
  801904:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801909:	c9                   	leave  
  80190a:	c3                   	ret    

0080190b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80190e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801913:	a8 01                	test   $0x1,%al
  801915:	74 34                	je     80194b <fd_alloc+0x40>
  801917:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80191c:	a8 01                	test   $0x1,%al
  80191e:	74 32                	je     801952 <fd_alloc+0x47>
  801920:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801925:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801927:	89 c2                	mov    %eax,%edx
  801929:	c1 ea 16             	shr    $0x16,%edx
  80192c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801933:	f6 c2 01             	test   $0x1,%dl
  801936:	74 1f                	je     801957 <fd_alloc+0x4c>
  801938:	89 c2                	mov    %eax,%edx
  80193a:	c1 ea 0c             	shr    $0xc,%edx
  80193d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801944:	f6 c2 01             	test   $0x1,%dl
  801947:	75 1a                	jne    801963 <fd_alloc+0x58>
  801949:	eb 0c                	jmp    801957 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80194b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801950:	eb 05                	jmp    801957 <fd_alloc+0x4c>
  801952:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801957:	8b 45 08             	mov    0x8(%ebp),%eax
  80195a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80195c:	b8 00 00 00 00       	mov    $0x0,%eax
  801961:	eb 1a                	jmp    80197d <fd_alloc+0x72>
  801963:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801968:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80196d:	75 b6                	jne    801925 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80196f:	8b 45 08             	mov    0x8(%ebp),%eax
  801972:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801978:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80197d:	5d                   	pop    %ebp
  80197e:	c3                   	ret    

0080197f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801985:	83 f8 1f             	cmp    $0x1f,%eax
  801988:	77 36                	ja     8019c0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80198a:	c1 e0 0c             	shl    $0xc,%eax
  80198d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801992:	89 c2                	mov    %eax,%edx
  801994:	c1 ea 16             	shr    $0x16,%edx
  801997:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80199e:	f6 c2 01             	test   $0x1,%dl
  8019a1:	74 24                	je     8019c7 <fd_lookup+0x48>
  8019a3:	89 c2                	mov    %eax,%edx
  8019a5:	c1 ea 0c             	shr    $0xc,%edx
  8019a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019af:	f6 c2 01             	test   $0x1,%dl
  8019b2:	74 1a                	je     8019ce <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8019b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b7:	89 02                	mov    %eax,(%edx)
	return 0;
  8019b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019be:	eb 13                	jmp    8019d3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8019c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019c5:	eb 0c                	jmp    8019d3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8019c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019cc:	eb 05                	jmp    8019d3 <fd_lookup+0x54>
  8019ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8019d3:	5d                   	pop    %ebp
  8019d4:	c3                   	ret    

008019d5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 18             	sub    $0x18,%esp
  8019db:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8019de:	39 05 08 30 80 00    	cmp    %eax,0x803008
  8019e4:	75 10                	jne    8019f6 <dev_lookup+0x21>
			*dev = devtab[i];
  8019e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e9:	c7 00 08 30 80 00    	movl   $0x803008,(%eax)
			return 0;
  8019ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f4:	eb 2b                	jmp    801a21 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8019f6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019fc:	8b 52 48             	mov    0x48(%edx),%edx
  8019ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a03:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a07:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  801a0e:	e8 d8 ee ff ff       	call   8008eb <cprintf>
	*dev = 0;
  801a13:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a16:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  801a1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801a21:	c9                   	leave  
  801a22:	c3                   	ret    

00801a23 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	83 ec 38             	sub    $0x38,%esp
  801a29:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a2c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a2f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a32:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a35:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a38:	89 3c 24             	mov    %edi,(%esp)
  801a3b:	e8 a0 fe ff ff       	call   8018e0 <fd2num>
  801a40:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801a43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a47:	89 04 24             	mov    %eax,(%esp)
  801a4a:	e8 30 ff ff ff       	call   80197f <fd_lookup>
  801a4f:	89 c3                	mov    %eax,%ebx
  801a51:	85 c0                	test   %eax,%eax
  801a53:	78 05                	js     801a5a <fd_close+0x37>
	    || fd != fd2)
  801a55:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801a58:	74 0c                	je     801a66 <fd_close+0x43>
		return (must_exist ? r : 0);
  801a5a:	85 f6                	test   %esi,%esi
  801a5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a61:	0f 44 d8             	cmove  %eax,%ebx
  801a64:	eb 3d                	jmp    801aa3 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a66:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6d:	8b 07                	mov    (%edi),%eax
  801a6f:	89 04 24             	mov    %eax,(%esp)
  801a72:	e8 5e ff ff ff       	call   8019d5 <dev_lookup>
  801a77:	89 c3                	mov    %eax,%ebx
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	78 16                	js     801a93 <fd_close+0x70>
		if (dev->dev_close)
  801a7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a80:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801a83:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	74 07                	je     801a93 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  801a8c:	89 3c 24             	mov    %edi,(%esp)
  801a8f:	ff d0                	call   *%eax
  801a91:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801a93:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a9e:	e8 e5 fa ff ff       	call   801588 <sys_page_unmap>
	return r;
}
  801aa3:	89 d8                	mov    %ebx,%eax
  801aa5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801aa8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801aab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801aae:	89 ec                	mov    %ebp,%esp
  801ab0:	5d                   	pop    %ebp
  801ab1:	c3                   	ret    

00801ab2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ab8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac2:	89 04 24             	mov    %eax,(%esp)
  801ac5:	e8 b5 fe ff ff       	call   80197f <fd_lookup>
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 13                	js     801ae1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801ace:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ad5:	00 
  801ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad9:	89 04 24             	mov    %eax,(%esp)
  801adc:	e8 42 ff ff ff       	call   801a23 <fd_close>
}
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <close_all>:

void
close_all(void)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	53                   	push   %ebx
  801ae7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801aea:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801aef:	89 1c 24             	mov    %ebx,(%esp)
  801af2:	e8 bb ff ff ff       	call   801ab2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801af7:	83 c3 01             	add    $0x1,%ebx
  801afa:	83 fb 20             	cmp    $0x20,%ebx
  801afd:	75 f0                	jne    801aef <close_all+0xc>
		close(i);
}
  801aff:	83 c4 14             	add    $0x14,%esp
  801b02:	5b                   	pop    %ebx
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    

00801b05 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	83 ec 58             	sub    $0x58,%esp
  801b0b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b0e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b11:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b17:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b21:	89 04 24             	mov    %eax,(%esp)
  801b24:	e8 56 fe ff ff       	call   80197f <fd_lookup>
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	0f 88 e3 00 00 00    	js     801c14 <dup+0x10f>
		return r;
	close(newfdnum);
  801b31:	89 1c 24             	mov    %ebx,(%esp)
  801b34:	e8 79 ff ff ff       	call   801ab2 <close>

	newfd = INDEX2FD(newfdnum);
  801b39:	89 de                	mov    %ebx,%esi
  801b3b:	c1 e6 0c             	shl    $0xc,%esi
  801b3e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801b44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b47:	89 04 24             	mov    %eax,(%esp)
  801b4a:	e8 a1 fd ff ff       	call   8018f0 <fd2data>
  801b4f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801b51:	89 34 24             	mov    %esi,(%esp)
  801b54:	e8 97 fd ff ff       	call   8018f0 <fd2data>
  801b59:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801b5c:	89 f8                	mov    %edi,%eax
  801b5e:	c1 e8 16             	shr    $0x16,%eax
  801b61:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b68:	a8 01                	test   $0x1,%al
  801b6a:	74 46                	je     801bb2 <dup+0xad>
  801b6c:	89 f8                	mov    %edi,%eax
  801b6e:	c1 e8 0c             	shr    $0xc,%eax
  801b71:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801b78:	f6 c2 01             	test   $0x1,%dl
  801b7b:	74 35                	je     801bb2 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801b7d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b84:	25 07 0e 00 00       	and    $0xe07,%eax
  801b89:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b8d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b94:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b9b:	00 
  801b9c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ba0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba7:	e8 75 f9 ff ff       	call   801521 <sys_page_map>
  801bac:	89 c7                	mov    %eax,%edi
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	78 3b                	js     801bed <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801bb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb5:	89 c2                	mov    %eax,%edx
  801bb7:	c1 ea 0c             	shr    $0xc,%edx
  801bba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801bc1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801bc7:	89 54 24 10          	mov    %edx,0x10(%esp)
  801bcb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801bcf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bd6:	00 
  801bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be2:	e8 3a f9 ff ff       	call   801521 <sys_page_map>
  801be7:	89 c7                	mov    %eax,%edi
  801be9:	85 c0                	test   %eax,%eax
  801beb:	79 29                	jns    801c16 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801bed:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bf1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf8:	e8 8b f9 ff ff       	call   801588 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801bfd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0b:	e8 78 f9 ff ff       	call   801588 <sys_page_unmap>
	return r;
  801c10:	89 fb                	mov    %edi,%ebx
  801c12:	eb 02                	jmp    801c16 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  801c14:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801c16:	89 d8                	mov    %ebx,%eax
  801c18:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c1b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c1e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c21:	89 ec                	mov    %ebp,%esp
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	53                   	push   %ebx
  801c29:	83 ec 24             	sub    $0x24,%esp
  801c2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c2f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c36:	89 1c 24             	mov    %ebx,(%esp)
  801c39:	e8 41 fd ff ff       	call   80197f <fd_lookup>
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	78 6d                	js     801caf <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4c:	8b 00                	mov    (%eax),%eax
  801c4e:	89 04 24             	mov    %eax,(%esp)
  801c51:	e8 7f fd ff ff       	call   8019d5 <dev_lookup>
  801c56:	85 c0                	test   %eax,%eax
  801c58:	78 55                	js     801caf <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c5d:	8b 50 08             	mov    0x8(%eax),%edx
  801c60:	83 e2 03             	and    $0x3,%edx
  801c63:	83 fa 01             	cmp    $0x1,%edx
  801c66:	75 23                	jne    801c8b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801c68:	a1 04 40 80 00       	mov    0x804004,%eax
  801c6d:	8b 40 48             	mov    0x48(%eax),%eax
  801c70:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c78:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  801c7f:	e8 67 ec ff ff       	call   8008eb <cprintf>
		return -E_INVAL;
  801c84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c89:	eb 24                	jmp    801caf <read+0x8a>
	}
	if (!dev->dev_read)
  801c8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c8e:	8b 52 08             	mov    0x8(%edx),%edx
  801c91:	85 d2                	test   %edx,%edx
  801c93:	74 15                	je     801caa <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801c95:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801c98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c9f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ca3:	89 04 24             	mov    %eax,(%esp)
  801ca6:	ff d2                	call   *%edx
  801ca8:	eb 05                	jmp    801caf <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801caa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801caf:	83 c4 24             	add    $0x24,%esp
  801cb2:	5b                   	pop    %ebx
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    

00801cb5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	57                   	push   %edi
  801cb9:	56                   	push   %esi
  801cba:	53                   	push   %ebx
  801cbb:	83 ec 1c             	sub    $0x1c,%esp
  801cbe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cc1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801cc4:	85 f6                	test   %esi,%esi
  801cc6:	74 33                	je     801cfb <readn+0x46>
  801cc8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801cd2:	89 f2                	mov    %esi,%edx
  801cd4:	29 c2                	sub    %eax,%edx
  801cd6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cda:	03 45 0c             	add    0xc(%ebp),%eax
  801cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce1:	89 3c 24             	mov    %edi,(%esp)
  801ce4:	e8 3c ff ff ff       	call   801c25 <read>
		if (m < 0)
  801ce9:	85 c0                	test   %eax,%eax
  801ceb:	78 17                	js     801d04 <readn+0x4f>
			return m;
		if (m == 0)
  801ced:	85 c0                	test   %eax,%eax
  801cef:	74 11                	je     801d02 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801cf1:	01 c3                	add    %eax,%ebx
  801cf3:	89 d8                	mov    %ebx,%eax
  801cf5:	39 f3                	cmp    %esi,%ebx
  801cf7:	72 d9                	jb     801cd2 <readn+0x1d>
  801cf9:	eb 09                	jmp    801d04 <readn+0x4f>
  801cfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801d00:	eb 02                	jmp    801d04 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801d02:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801d04:	83 c4 1c             	add    $0x1c,%esp
  801d07:	5b                   	pop    %ebx
  801d08:	5e                   	pop    %esi
  801d09:	5f                   	pop    %edi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    

00801d0c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	53                   	push   %ebx
  801d10:	83 ec 24             	sub    $0x24,%esp
  801d13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d16:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1d:	89 1c 24             	mov    %ebx,(%esp)
  801d20:	e8 5a fc ff ff       	call   80197f <fd_lookup>
  801d25:	85 c0                	test   %eax,%eax
  801d27:	78 68                	js     801d91 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d33:	8b 00                	mov    (%eax),%eax
  801d35:	89 04 24             	mov    %eax,(%esp)
  801d38:	e8 98 fc ff ff       	call   8019d5 <dev_lookup>
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	78 50                	js     801d91 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d44:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801d48:	75 23                	jne    801d6d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801d4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801d4f:	8b 40 48             	mov    0x48(%eax),%eax
  801d52:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d5a:	c7 04 24 6c 2b 80 00 	movl   $0x802b6c,(%esp)
  801d61:	e8 85 eb ff ff       	call   8008eb <cprintf>
		return -E_INVAL;
  801d66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d6b:	eb 24                	jmp    801d91 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801d6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d70:	8b 52 0c             	mov    0xc(%edx),%edx
  801d73:	85 d2                	test   %edx,%edx
  801d75:	74 15                	je     801d8c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801d77:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801d7a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d81:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d85:	89 04 24             	mov    %eax,(%esp)
  801d88:	ff d2                	call   *%edx
  801d8a:	eb 05                	jmp    801d91 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801d8c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801d91:	83 c4 24             	add    $0x24,%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    

00801d97 <seek>:

int
seek(int fdnum, off_t offset)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d9d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801da0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da4:	8b 45 08             	mov    0x8(%ebp),%eax
  801da7:	89 04 24             	mov    %eax,(%esp)
  801daa:	e8 d0 fb ff ff       	call   80197f <fd_lookup>
  801daf:	85 c0                	test   %eax,%eax
  801db1:	78 0e                	js     801dc1 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801db3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801db6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801dbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	53                   	push   %ebx
  801dc7:	83 ec 24             	sub    $0x24,%esp
  801dca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801dcd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd4:	89 1c 24             	mov    %ebx,(%esp)
  801dd7:	e8 a3 fb ff ff       	call   80197f <fd_lookup>
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	78 61                	js     801e41 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801de0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dea:	8b 00                	mov    (%eax),%eax
  801dec:	89 04 24             	mov    %eax,(%esp)
  801def:	e8 e1 fb ff ff       	call   8019d5 <dev_lookup>
  801df4:	85 c0                	test   %eax,%eax
  801df6:	78 49                	js     801e41 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dfb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801dff:	75 23                	jne    801e24 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801e01:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801e06:	8b 40 48             	mov    0x48(%eax),%eax
  801e09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e11:	c7 04 24 2c 2b 80 00 	movl   $0x802b2c,(%esp)
  801e18:	e8 ce ea ff ff       	call   8008eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801e1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e22:	eb 1d                	jmp    801e41 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801e24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e27:	8b 52 18             	mov    0x18(%edx),%edx
  801e2a:	85 d2                	test   %edx,%edx
  801e2c:	74 0e                	je     801e3c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801e2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e31:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801e35:	89 04 24             	mov    %eax,(%esp)
  801e38:	ff d2                	call   *%edx
  801e3a:	eb 05                	jmp    801e41 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801e3c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801e41:	83 c4 24             	add    $0x24,%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5d                   	pop    %ebp
  801e46:	c3                   	ret    

00801e47 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	53                   	push   %ebx
  801e4b:	83 ec 24             	sub    $0x24,%esp
  801e4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e51:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e58:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5b:	89 04 24             	mov    %eax,(%esp)
  801e5e:	e8 1c fb ff ff       	call   80197f <fd_lookup>
  801e63:	85 c0                	test   %eax,%eax
  801e65:	78 52                	js     801eb9 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e71:	8b 00                	mov    (%eax),%eax
  801e73:	89 04 24             	mov    %eax,(%esp)
  801e76:	e8 5a fb ff ff       	call   8019d5 <dev_lookup>
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	78 3a                	js     801eb9 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e82:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801e86:	74 2c                	je     801eb4 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801e88:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801e8b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801e92:	00 00 00 
	stat->st_isdir = 0;
  801e95:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e9c:	00 00 00 
	stat->st_dev = dev;
  801e9f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ea5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ea9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801eac:	89 14 24             	mov    %edx,(%esp)
  801eaf:	ff 50 14             	call   *0x14(%eax)
  801eb2:	eb 05                	jmp    801eb9 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801eb4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801eb9:	83 c4 24             	add    $0x24,%esp
  801ebc:	5b                   	pop    %ebx
  801ebd:	5d                   	pop    %ebp
  801ebe:	c3                   	ret    

00801ebf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	83 ec 18             	sub    $0x18,%esp
  801ec5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ec8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ecb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ed2:	00 
  801ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed6:	89 04 24             	mov    %eax,(%esp)
  801ed9:	e8 84 01 00 00       	call   802062 <open>
  801ede:	89 c3                	mov    %eax,%ebx
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	78 1b                	js     801eff <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eeb:	89 1c 24             	mov    %ebx,(%esp)
  801eee:	e8 54 ff ff ff       	call   801e47 <fstat>
  801ef3:	89 c6                	mov    %eax,%esi
	close(fd);
  801ef5:	89 1c 24             	mov    %ebx,(%esp)
  801ef8:	e8 b5 fb ff ff       	call   801ab2 <close>
	return r;
  801efd:	89 f3                	mov    %esi,%ebx
}
  801eff:	89 d8                	mov    %ebx,%eax
  801f01:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f04:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f07:	89 ec                	mov    %ebp,%esp
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    
  801f0b:	90                   	nop

00801f0c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	83 ec 18             	sub    $0x18,%esp
  801f12:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f15:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f18:	89 c6                	mov    %eax,%esi
  801f1a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801f1c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801f23:	75 11                	jne    801f36 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801f25:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801f2c:	e8 5a f9 ff ff       	call   80188b <ipc_find_env>
  801f31:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801f36:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f3d:	00 
  801f3e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801f45:	00 
  801f46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f4a:	a1 00 40 80 00       	mov    0x804000,%eax
  801f4f:	89 04 24             	mov    %eax,(%esp)
  801f52:	e8 c9 f8 ff ff       	call   801820 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801f57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f5e:	00 
  801f5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f6a:	e8 59 f8 ff ff       	call   8017c8 <ipc_recv>
}
  801f6f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f72:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f75:	89 ec                	mov    %ebp,%esp
  801f77:	5d                   	pop    %ebp
  801f78:	c3                   	ret    

00801f79 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f82:	8b 40 0c             	mov    0xc(%eax),%eax
  801f85:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801f92:	ba 00 00 00 00       	mov    $0x0,%edx
  801f97:	b8 02 00 00 00       	mov    $0x2,%eax
  801f9c:	e8 6b ff ff ff       	call   801f0c <fsipc>
}
  801fa1:	c9                   	leave  
  801fa2:	c3                   	ret    

00801fa3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801fa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fac:	8b 40 0c             	mov    0xc(%eax),%eax
  801faf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801fb4:	ba 00 00 00 00       	mov    $0x0,%edx
  801fb9:	b8 06 00 00 00       	mov    $0x6,%eax
  801fbe:	e8 49 ff ff ff       	call   801f0c <fsipc>
}
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	53                   	push   %ebx
  801fc9:	83 ec 14             	sub    $0x14,%esp
  801fcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd2:	8b 40 0c             	mov    0xc(%eax),%eax
  801fd5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801fda:	ba 00 00 00 00       	mov    $0x0,%edx
  801fdf:	b8 05 00 00 00       	mov    $0x5,%eax
  801fe4:	e8 23 ff ff ff       	call   801f0c <fsipc>
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	78 2b                	js     802018 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801fed:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ff4:	00 
  801ff5:	89 1c 24             	mov    %ebx,(%esp)
  801ff8:	e8 6e ef ff ff       	call   800f6b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ffd:	a1 80 50 80 00       	mov    0x805080,%eax
  802002:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802008:	a1 84 50 80 00       	mov    0x805084,%eax
  80200d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802013:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802018:	83 c4 14             	add    $0x14,%esp
  80201b:	5b                   	pop    %ebx
  80201c:	5d                   	pop    %ebp
  80201d:	c3                   	ret    

0080201e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80201e:	55                   	push   %ebp
  80201f:	89 e5                	mov    %esp,%ebp
  802021:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  802024:	c7 44 24 08 89 2b 80 	movl   $0x802b89,0x8(%esp)
  80202b:	00 
  80202c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  802033:	00 
  802034:	c7 04 24 a7 2b 80 00 	movl   $0x802ba7,(%esp)
  80203b:	e8 b0 e7 ff ff       	call   8007f0 <_panic>

00802040 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  802046:	c7 44 24 08 b2 2b 80 	movl   $0x802bb2,0x8(%esp)
  80204d:	00 
  80204e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  802055:	00 
  802056:	c7 04 24 a7 2b 80 00 	movl   $0x802ba7,(%esp)
  80205d:	e8 8e e7 ff ff       	call   8007f0 <_panic>

00802062 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  802068:	c7 44 24 08 cf 2b 80 	movl   $0x802bcf,0x8(%esp)
  80206f:	00 
  802070:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  802077:	00 
  802078:	c7 04 24 a7 2b 80 00 	movl   $0x802ba7,(%esp)
  80207f:	e8 6c e7 ff ff       	call   8007f0 <_panic>

00802084 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	53                   	push   %ebx
  802088:	83 ec 14             	sub    $0x14,%esp
  80208b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80208e:	89 1c 24             	mov    %ebx,(%esp)
  802091:	e8 7a ee ff ff       	call   800f10 <strlen>
  802096:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80209b:	7f 21                	jg     8020be <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80209d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020a1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8020a8:	e8 be ee ff ff       	call   800f6b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8020ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8020b2:	b8 07 00 00 00       	mov    $0x7,%eax
  8020b7:	e8 50 fe ff ff       	call   801f0c <fsipc>
  8020bc:	eb 05                	jmp    8020c3 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8020be:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  8020c3:	83 c4 14             	add    $0x14,%esp
  8020c6:	5b                   	pop    %ebx
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    

008020c9 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8020cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8020d4:	b8 08 00 00 00       	mov    $0x8,%eax
  8020d9:	e8 2e fe ff ff       	call   801f0c <fsipc>
}
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    

008020e0 <__udivdi3>:
  8020e0:	83 ec 1c             	sub    $0x1c,%esp
  8020e3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8020e7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8020eb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8020ef:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8020f3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8020f7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	89 74 24 10          	mov    %esi,0x10(%esp)
  802101:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802105:	89 ea                	mov    %ebp,%edx
  802107:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80210b:	75 33                	jne    802140 <__udivdi3+0x60>
  80210d:	39 e9                	cmp    %ebp,%ecx
  80210f:	77 6f                	ja     802180 <__udivdi3+0xa0>
  802111:	85 c9                	test   %ecx,%ecx
  802113:	89 ce                	mov    %ecx,%esi
  802115:	75 0b                	jne    802122 <__udivdi3+0x42>
  802117:	b8 01 00 00 00       	mov    $0x1,%eax
  80211c:	31 d2                	xor    %edx,%edx
  80211e:	f7 f1                	div    %ecx
  802120:	89 c6                	mov    %eax,%esi
  802122:	31 d2                	xor    %edx,%edx
  802124:	89 e8                	mov    %ebp,%eax
  802126:	f7 f6                	div    %esi
  802128:	89 c5                	mov    %eax,%ebp
  80212a:	89 f8                	mov    %edi,%eax
  80212c:	f7 f6                	div    %esi
  80212e:	89 ea                	mov    %ebp,%edx
  802130:	8b 74 24 10          	mov    0x10(%esp),%esi
  802134:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802138:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80213c:	83 c4 1c             	add    $0x1c,%esp
  80213f:	c3                   	ret    
  802140:	39 e8                	cmp    %ebp,%eax
  802142:	77 24                	ja     802168 <__udivdi3+0x88>
  802144:	0f bd c8             	bsr    %eax,%ecx
  802147:	83 f1 1f             	xor    $0x1f,%ecx
  80214a:	89 0c 24             	mov    %ecx,(%esp)
  80214d:	75 49                	jne    802198 <__udivdi3+0xb8>
  80214f:	8b 74 24 08          	mov    0x8(%esp),%esi
  802153:	39 74 24 04          	cmp    %esi,0x4(%esp)
  802157:	0f 86 ab 00 00 00    	jbe    802208 <__udivdi3+0x128>
  80215d:	39 e8                	cmp    %ebp,%eax
  80215f:	0f 82 a3 00 00 00    	jb     802208 <__udivdi3+0x128>
  802165:	8d 76 00             	lea    0x0(%esi),%esi
  802168:	31 d2                	xor    %edx,%edx
  80216a:	31 c0                	xor    %eax,%eax
  80216c:	8b 74 24 10          	mov    0x10(%esp),%esi
  802170:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802174:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802178:	83 c4 1c             	add    $0x1c,%esp
  80217b:	c3                   	ret    
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 f8                	mov    %edi,%eax
  802182:	f7 f1                	div    %ecx
  802184:	31 d2                	xor    %edx,%edx
  802186:	8b 74 24 10          	mov    0x10(%esp),%esi
  80218a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80218e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802192:	83 c4 1c             	add    $0x1c,%esp
  802195:	c3                   	ret    
  802196:	66 90                	xchg   %ax,%ax
  802198:	0f b6 0c 24          	movzbl (%esp),%ecx
  80219c:	89 c6                	mov    %eax,%esi
  80219e:	b8 20 00 00 00       	mov    $0x20,%eax
  8021a3:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  8021a7:	2b 04 24             	sub    (%esp),%eax
  8021aa:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8021ae:	d3 e6                	shl    %cl,%esi
  8021b0:	89 c1                	mov    %eax,%ecx
  8021b2:	d3 ed                	shr    %cl,%ebp
  8021b4:	0f b6 0c 24          	movzbl (%esp),%ecx
  8021b8:	09 f5                	or     %esi,%ebp
  8021ba:	8b 74 24 04          	mov    0x4(%esp),%esi
  8021be:	d3 e6                	shl    %cl,%esi
  8021c0:	89 c1                	mov    %eax,%ecx
  8021c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021c6:	89 d6                	mov    %edx,%esi
  8021c8:	d3 ee                	shr    %cl,%esi
  8021ca:	0f b6 0c 24          	movzbl (%esp),%ecx
  8021ce:	d3 e2                	shl    %cl,%edx
  8021d0:	89 c1                	mov    %eax,%ecx
  8021d2:	d3 ef                	shr    %cl,%edi
  8021d4:	09 d7                	or     %edx,%edi
  8021d6:	89 f2                	mov    %esi,%edx
  8021d8:	89 f8                	mov    %edi,%eax
  8021da:	f7 f5                	div    %ebp
  8021dc:	89 d6                	mov    %edx,%esi
  8021de:	89 c7                	mov    %eax,%edi
  8021e0:	f7 64 24 04          	mull   0x4(%esp)
  8021e4:	39 d6                	cmp    %edx,%esi
  8021e6:	72 30                	jb     802218 <__udivdi3+0x138>
  8021e8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8021ec:	0f b6 0c 24          	movzbl (%esp),%ecx
  8021f0:	d3 e5                	shl    %cl,%ebp
  8021f2:	39 c5                	cmp    %eax,%ebp
  8021f4:	73 04                	jae    8021fa <__udivdi3+0x11a>
  8021f6:	39 d6                	cmp    %edx,%esi
  8021f8:	74 1e                	je     802218 <__udivdi3+0x138>
  8021fa:	89 f8                	mov    %edi,%eax
  8021fc:	31 d2                	xor    %edx,%edx
  8021fe:	e9 69 ff ff ff       	jmp    80216c <__udivdi3+0x8c>
  802203:	90                   	nop
  802204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802208:	31 d2                	xor    %edx,%edx
  80220a:	b8 01 00 00 00       	mov    $0x1,%eax
  80220f:	e9 58 ff ff ff       	jmp    80216c <__udivdi3+0x8c>
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	8d 47 ff             	lea    -0x1(%edi),%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	8b 74 24 10          	mov    0x10(%esp),%esi
  802221:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802225:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802229:	83 c4 1c             	add    $0x1c,%esp
  80222c:	c3                   	ret    
  80222d:	66 90                	xchg   %ax,%ax
  80222f:	90                   	nop

00802230 <__umoddi3>:
  802230:	83 ec 2c             	sub    $0x2c,%esp
  802233:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802237:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80223b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80223f:	8b 74 24 38          	mov    0x38(%esp),%esi
  802243:	89 7c 24 24          	mov    %edi,0x24(%esp)
  802247:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80224b:	85 c0                	test   %eax,%eax
  80224d:	89 c2                	mov    %eax,%edx
  80224f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  802253:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802257:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80225b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80225f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802263:	89 7c 24 18          	mov    %edi,0x18(%esp)
  802267:	75 1f                	jne    802288 <__umoddi3+0x58>
  802269:	39 fe                	cmp    %edi,%esi
  80226b:	76 63                	jbe    8022d0 <__umoddi3+0xa0>
  80226d:	89 c8                	mov    %ecx,%eax
  80226f:	89 fa                	mov    %edi,%edx
  802271:	f7 f6                	div    %esi
  802273:	89 d0                	mov    %edx,%eax
  802275:	31 d2                	xor    %edx,%edx
  802277:	8b 74 24 20          	mov    0x20(%esp),%esi
  80227b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80227f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  802283:	83 c4 2c             	add    $0x2c,%esp
  802286:	c3                   	ret    
  802287:	90                   	nop
  802288:	39 f8                	cmp    %edi,%eax
  80228a:	77 64                	ja     8022f0 <__umoddi3+0xc0>
  80228c:	0f bd e8             	bsr    %eax,%ebp
  80228f:	83 f5 1f             	xor    $0x1f,%ebp
  802292:	75 74                	jne    802308 <__umoddi3+0xd8>
  802294:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802298:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80229c:	0f 87 0e 01 00 00    	ja     8023b0 <__umoddi3+0x180>
  8022a2:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  8022a6:	29 f1                	sub    %esi,%ecx
  8022a8:	19 c7                	sbb    %eax,%edi
  8022aa:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8022ae:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8022b2:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022b6:	8b 54 24 18          	mov    0x18(%esp),%edx
  8022ba:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022be:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8022c2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8022c6:	83 c4 2c             	add    $0x2c,%esp
  8022c9:	c3                   	ret    
  8022ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d0:	85 f6                	test   %esi,%esi
  8022d2:	89 f5                	mov    %esi,%ebp
  8022d4:	75 0b                	jne    8022e1 <__umoddi3+0xb1>
  8022d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	f7 f6                	div    %esi
  8022df:	89 c5                	mov    %eax,%ebp
  8022e1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022e5:	31 d2                	xor    %edx,%edx
  8022e7:	f7 f5                	div    %ebp
  8022e9:	89 c8                	mov    %ecx,%eax
  8022eb:	f7 f5                	div    %ebp
  8022ed:	eb 84                	jmp    802273 <__umoddi3+0x43>
  8022ef:	90                   	nop
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 fa                	mov    %edi,%edx
  8022f4:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022f8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8022fc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  802300:	83 c4 2c             	add    $0x2c,%esp
  802303:	c3                   	ret    
  802304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802308:	8b 44 24 10          	mov    0x10(%esp),%eax
  80230c:	be 20 00 00 00       	mov    $0x20,%esi
  802311:	89 e9                	mov    %ebp,%ecx
  802313:	29 ee                	sub    %ebp,%esi
  802315:	d3 e2                	shl    %cl,%edx
  802317:	89 f1                	mov    %esi,%ecx
  802319:	d3 e8                	shr    %cl,%eax
  80231b:	89 e9                	mov    %ebp,%ecx
  80231d:	09 d0                	or     %edx,%eax
  80231f:	89 fa                	mov    %edi,%edx
  802321:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802325:	8b 44 24 10          	mov    0x10(%esp),%eax
  802329:	d3 e0                	shl    %cl,%eax
  80232b:	89 f1                	mov    %esi,%ecx
  80232d:	89 44 24 10          	mov    %eax,0x10(%esp)
  802331:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802335:	d3 ea                	shr    %cl,%edx
  802337:	89 e9                	mov    %ebp,%ecx
  802339:	d3 e7                	shl    %cl,%edi
  80233b:	89 f1                	mov    %esi,%ecx
  80233d:	d3 e8                	shr    %cl,%eax
  80233f:	89 e9                	mov    %ebp,%ecx
  802341:	09 f8                	or     %edi,%eax
  802343:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  802347:	f7 74 24 0c          	divl   0xc(%esp)
  80234b:	d3 e7                	shl    %cl,%edi
  80234d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  802351:	89 d7                	mov    %edx,%edi
  802353:	f7 64 24 10          	mull   0x10(%esp)
  802357:	39 d7                	cmp    %edx,%edi
  802359:	89 c1                	mov    %eax,%ecx
  80235b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80235f:	72 3b                	jb     80239c <__umoddi3+0x16c>
  802361:	39 44 24 18          	cmp    %eax,0x18(%esp)
  802365:	72 31                	jb     802398 <__umoddi3+0x168>
  802367:	8b 44 24 18          	mov    0x18(%esp),%eax
  80236b:	29 c8                	sub    %ecx,%eax
  80236d:	19 d7                	sbb    %edx,%edi
  80236f:	89 e9                	mov    %ebp,%ecx
  802371:	89 fa                	mov    %edi,%edx
  802373:	d3 e8                	shr    %cl,%eax
  802375:	89 f1                	mov    %esi,%ecx
  802377:	d3 e2                	shl    %cl,%edx
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	09 d0                	or     %edx,%eax
  80237d:	89 fa                	mov    %edi,%edx
  80237f:	d3 ea                	shr    %cl,%edx
  802381:	8b 74 24 20          	mov    0x20(%esp),%esi
  802385:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802389:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80238d:	83 c4 2c             	add    $0x2c,%esp
  802390:	c3                   	ret    
  802391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802398:	39 d7                	cmp    %edx,%edi
  80239a:	75 cb                	jne    802367 <__umoddi3+0x137>
  80239c:	8b 54 24 14          	mov    0x14(%esp),%edx
  8023a0:	89 c1                	mov    %eax,%ecx
  8023a2:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  8023a6:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8023aa:	eb bb                	jmp    802367 <__umoddi3+0x137>
  8023ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8023b4:	0f 82 e8 fe ff ff    	jb     8022a2 <__umoddi3+0x72>
  8023ba:	e9 f3 fe ff ff       	jmp    8022b2 <__umoddi3+0x82>
