
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 fb 15 00 00       	call   80162c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80003a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003f:	ec                   	in     (%dx),%al
  800040:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800042:	83 e0 c0             	and    $0xffffffc0,%eax
  800045:	3c 40                	cmp    $0x40,%al
  800047:	75 f6                	jne    80003f <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800049:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004e:	85 c9                	test   %ecx,%ecx
  800050:	74 0a                	je     80005c <ide_wait_ready+0x28>
  800052:	83 e3 21             	and    $0x21,%ebx
		return -1;
	return 0;
  800055:	80 fb 01             	cmp    $0x1,%bl
  800058:	19 c0                	sbb    %eax,%eax
  80005a:	f7 d0                	not    %eax
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 14             	sub    $0x14,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c4 ff ff ff       	call   800034 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80007b:	b2 f7                	mov    $0xf7,%dl
  80007d:	ec                   	in     (%dx),%al
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  80007e:	b9 01 00 00 00       	mov    $0x1,%ecx
	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800083:	a8 a1                	test   $0xa1,%al
  800085:	75 0f                	jne    800096 <ide_probe_disk1+0x37>

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800087:	b1 00                	mov    $0x0,%cl
  800089:	eb 10                	jmp    80009b <ide_probe_disk1+0x3c>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  80008b:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008e:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800094:	74 05                	je     80009b <ide_probe_disk1+0x3c>
  800096:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800097:	a8 a1                	test   $0xa1,%al
  800099:	75 f0                	jne    80008b <ide_probe_disk1+0x2c>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80009b:	ba f6 01 00 00       	mov    $0x1f6,%edx
  8000a0:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a5:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a6:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000ac:	0f 9e c3             	setle  %bl
  8000af:	0f b6 db             	movzbl %bl,%ebx
  8000b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b6:	c7 04 24 40 33 80 00 	movl   $0x803340,(%esp)
  8000bd:	e8 d1 16 00 00       	call   801793 <cprintf>
	return (x < 1000);
}
  8000c2:	89 d8                	mov    %ebx,%eax
  8000c4:	83 c4 14             	add    $0x14,%esp
  8000c7:	5b                   	pop    %ebx
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	83 ec 18             	sub    $0x18,%esp
  8000d0:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000d3:	83 f8 01             	cmp    $0x1,%eax
  8000d6:	76 1c                	jbe    8000f4 <ide_set_disk+0x2a>
		panic("bad disk number");
  8000d8:	c7 44 24 08 57 33 80 	movl   $0x803357,0x8(%esp)
  8000df:	00 
  8000e0:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8000e7:	00 
  8000e8:	c7 04 24 67 33 80 00 	movl   $0x803367,(%esp)
  8000ef:	e8 a4 15 00 00       	call   801698 <_panic>
	diskno = d;
  8000f4:	a3 00 40 80 00       	mov    %eax,0x804000
}
  8000f9:	c9                   	leave  
  8000fa:	c3                   	ret    

008000fb <ide_read>:

int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	57                   	push   %edi
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 1c             	sub    $0x1c,%esp
  800104:	8b 7d 08             	mov    0x8(%ebp),%edi
  800107:	8b 75 0c             	mov    0xc(%ebp),%esi
  80010a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  80010d:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  800113:	76 24                	jbe    800139 <ide_read+0x3e>
  800115:	c7 44 24 0c 70 33 80 	movl   $0x803370,0xc(%esp)
  80011c:	00 
  80011d:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  800124:	00 
  800125:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  80012c:	00 
  80012d:	c7 04 24 67 33 80 00 	movl   $0x803367,(%esp)
  800134:	e8 5f 15 00 00       	call   801698 <_panic>

	ide_wait_ready(0);
  800139:	b8 00 00 00 00       	mov    $0x0,%eax
  80013e:	e8 f1 fe ff ff       	call   800034 <ide_wait_ready>
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
}
  800143:	0f b6 c3             	movzbl %bl,%eax
  800146:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	89 f8                	mov    %edi,%eax
  80014e:	25 ff 00 00 00       	and    $0xff,%eax
  800153:	b2 f3                	mov    $0xf3,%dl
  800155:	ee                   	out    %al,(%dx)
  800156:	89 fa                	mov    %edi,%edx
  800158:	0f b6 c6             	movzbl %dh,%eax
  80015b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800160:	ee                   	out    %al,(%dx)
	ide_wait_ready(0);

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
  800161:	89 f8                	mov    %edi,%eax
  800163:	c1 e8 10             	shr    $0x10,%eax
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
}
  800166:	25 ff 00 00 00       	and    $0xff,%eax
  80016b:	b2 f5                	mov    $0xf5,%dl
  80016d:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80016e:	a1 00 40 80 00       	mov    0x804000,%eax
  800173:	83 e0 01             	and    $0x1,%eax
  800176:	c1 e0 04             	shl    $0x4,%eax
  800179:	83 c8 e0             	or     $0xffffffe0,%eax
  80017c:	c1 ef 18             	shr    $0x18,%edi
  80017f:	83 e7 0f             	and    $0xf,%edi
  800182:	09 f8                	or     %edi,%eax
  800184:	b2 f6                	mov    $0xf6,%dl
  800186:	ee                   	out    %al,(%dx)
  800187:	b2 f7                	mov    $0xf7,%dl
  800189:	b8 20 00 00 00       	mov    $0x20,%eax
  80018e:	ee                   	out    %al,(%dx)
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  80018f:	85 db                	test   %ebx,%ebx
  800191:	74 2f                	je     8001c2 <ide_read+0xc7>
		if ((r = ide_wait_ready(1)) < 0)
  800193:	b8 01 00 00 00       	mov    $0x1,%eax
  800198:	e8 97 fe ff ff       	call   800034 <ide_wait_ready>
  80019d:	85 c0                	test   %eax,%eax
  80019f:	78 26                	js     8001c7 <ide_read+0xcc>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  8001a1:	89 f7                	mov    %esi,%edi
  8001a3:	b9 80 00 00 00       	mov    $0x80,%ecx
  8001a8:	ba f0 01 00 00       	mov    $0x1f0,%edx
  8001ad:	fc                   	cld    
  8001ae:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001b0:	81 c6 00 02 00 00    	add    $0x200,%esi
  8001b6:	83 eb 01             	sub    $0x1,%ebx
  8001b9:	75 d8                	jne    800193 <ide_read+0x98>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8001c0:	eb 05                	jmp    8001c7 <ide_read+0xcc>
  8001c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001c7:	83 c4 1c             	add    $0x1c,%esp
  8001ca:	5b                   	pop    %ebx
  8001cb:	5e                   	pop    %esi
  8001cc:	5f                   	pop    %edi
  8001cd:	5d                   	pop    %ebp
  8001ce:	c3                   	ret    

008001cf <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	57                   	push   %edi
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
  8001d5:	83 ec 1c             	sub    $0x1c,%esp
  8001d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001db:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  8001e1:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  8001e7:	76 24                	jbe    80020d <ide_write+0x3e>
  8001e9:	c7 44 24 0c 70 33 80 	movl   $0x803370,0xc(%esp)
  8001f0:	00 
  8001f1:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  8001f8:	00 
  8001f9:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800200:	00 
  800201:	c7 04 24 67 33 80 00 	movl   $0x803367,(%esp)
  800208:	e8 8b 14 00 00       	call   801698 <_panic>

	ide_wait_ready(0);
  80020d:	b8 00 00 00 00       	mov    $0x0,%eax
  800212:	e8 1d fe ff ff       	call   800034 <ide_wait_ready>
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
}
  800217:	0f b6 c3             	movzbl %bl,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80021a:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80021f:	ee                   	out    %al,(%dx)
  800220:	89 f0                	mov    %esi,%eax
  800222:	25 ff 00 00 00       	and    $0xff,%eax
  800227:	b2 f3                	mov    $0xf3,%dl
  800229:	ee                   	out    %al,(%dx)
  80022a:	89 f2                	mov    %esi,%edx
  80022c:	0f b6 c6             	movzbl %dh,%eax
  80022f:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800234:	ee                   	out    %al,(%dx)
	ide_wait_ready(0);

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
  800235:	89 f0                	mov    %esi,%eax
  800237:	c1 e8 10             	shr    $0x10,%eax
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
}
  80023a:	25 ff 00 00 00       	and    $0xff,%eax
  80023f:	b2 f5                	mov    $0xf5,%dl
  800241:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800242:	a1 00 40 80 00       	mov    0x804000,%eax
  800247:	83 e0 01             	and    $0x1,%eax
  80024a:	c1 e0 04             	shl    $0x4,%eax
  80024d:	83 c8 e0             	or     $0xffffffe0,%eax
  800250:	c1 ee 18             	shr    $0x18,%esi
  800253:	83 e6 0f             	and    $0xf,%esi
  800256:	09 f0                	or     %esi,%eax
  800258:	b2 f6                	mov    $0xf6,%dl
  80025a:	ee                   	out    %al,(%dx)
  80025b:	b2 f7                	mov    $0xf7,%dl
  80025d:	b8 30 00 00 00       	mov    $0x30,%eax
  800262:	ee                   	out    %al,(%dx)
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800263:	85 db                	test   %ebx,%ebx
  800265:	74 2f                	je     800296 <ide_write+0xc7>
		if ((r = ide_wait_ready(1)) < 0)
  800267:	b8 01 00 00 00       	mov    $0x1,%eax
  80026c:	e8 c3 fd ff ff       	call   800034 <ide_wait_ready>
  800271:	85 c0                	test   %eax,%eax
  800273:	78 26                	js     80029b <ide_write+0xcc>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  800275:	89 fe                	mov    %edi,%esi
  800277:	b9 80 00 00 00       	mov    $0x80,%ecx
  80027c:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800281:	fc                   	cld    
  800282:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800284:	81 c7 00 02 00 00    	add    $0x200,%edi
  80028a:	83 eb 01             	sub    $0x1,%ebx
  80028d:	75 d8                	jne    800267 <ide_write+0x98>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  80028f:	b8 00 00 00 00       	mov    $0x0,%eax
  800294:	eb 05                	jmp    80029b <ide_write+0xcc>
  800296:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80029b:	83 c4 1c             	add    $0x1c,%esp
  80029e:	5b                   	pop    %ebx
  80029f:	5e                   	pop    %esi
  8002a0:	5f                   	pop    %edi
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    
  8002a3:	90                   	nop

008002a4 <bc_pgfault>:
// Fault any disk block that is read or written in to memory by
// loading it from disk.
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	83 ec 28             	sub    $0x28,%esp
  8002aa:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  8002ad:	8b 02                	mov    (%edx),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8002af:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
  8002b5:	81 f9 ff ff ff bf    	cmp    $0xbfffffff,%ecx
  8002bb:	76 2e                	jbe    8002eb <bc_pgfault+0x47>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  8002bd:	8b 4a 04             	mov    0x4(%edx),%ecx
  8002c0:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8002c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c8:	8b 42 28             	mov    0x28(%edx),%eax
  8002cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002cf:	c7 44 24 08 94 33 80 	movl   $0x803394,0x8(%esp)
  8002d6:	00 
  8002d7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8002de:	00 
  8002df:	c7 04 24 0a 34 80 00 	movl   $0x80340a,(%esp)
  8002e6:	e8 ad 13 00 00       	call   801698 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002eb:	8b 15 08 90 80 00    	mov    0x809008,%edx
  8002f1:	85 d2                	test   %edx,%edx
  8002f3:	74 2d                	je     800322 <bc_pgfault+0x7e>
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8002f5:	2d 00 00 00 10       	sub    $0x10000000,%eax
  8002fa:	c1 e8 0c             	shr    $0xc,%eax
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002fd:	3b 42 04             	cmp    0x4(%edx),%eax
  800300:	72 20                	jb     800322 <bc_pgfault+0x7e>
		panic("reading non-existent block %08x\n", blockno);
  800302:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800306:	c7 44 24 08 c4 33 80 	movl   $0x8033c4,0x8(%esp)
  80030d:	00 
  80030e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800315:	00 
  800316:	c7 04 24 0a 34 80 00 	movl   $0x80340a,(%esp)
  80031d:	e8 76 13 00 00       	call   801698 <_panic>
	// of the block from the disk into that page, and mark the
	// page not-dirty (since reading the data from disk will mark
	// the page dirty).
	//
	// LAB 5: Your code here
	panic("bc_pgfault not implemented");
  800322:	c7 44 24 08 12 34 80 	movl   $0x803412,0x8(%esp)
  800329:	00 
  80032a:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800331:	00 
  800332:	c7 04 24 0a 34 80 00 	movl   $0x80340a,(%esp)
  800339:	e8 5a 13 00 00       	call   801698 <_panic>

0080033e <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 18             	sub    $0x18,%esp
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800347:	85 c0                	test   %eax,%eax
  800349:	74 0f                	je     80035a <diskaddr+0x1c>
  80034b:	8b 15 08 90 80 00    	mov    0x809008,%edx
  800351:	85 d2                	test   %edx,%edx
  800353:	74 25                	je     80037a <diskaddr+0x3c>
  800355:	3b 42 04             	cmp    0x4(%edx),%eax
  800358:	72 20                	jb     80037a <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  80035a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80035e:	c7 44 24 08 e8 33 80 	movl   $0x8033e8,0x8(%esp)
  800365:	00 
  800366:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80036d:	00 
  80036e:	c7 04 24 0a 34 80 00 	movl   $0x80340a,(%esp)
  800375:	e8 1e 13 00 00       	call   801698 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  80037a:	05 00 00 01 00       	add    $0x10000,%eax
  80037f:	c1 e0 0c             	shl    $0xc,%eax
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	8b 55 08             	mov    0x8(%ebp),%edx
	return (vpd[PDX(va)] & PTE_P) && (vpt[PGNUM(va)] & PTE_P);
  80038a:	89 d0                	mov    %edx,%eax
  80038c:	c1 e8 16             	shr    $0x16,%eax
  80038f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  800396:	b8 00 00 00 00       	mov    $0x0,%eax
  80039b:	f6 c1 01             	test   $0x1,%cl
  80039e:	74 0d                	je     8003ad <va_is_mapped+0x29>
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003aa:	83 e0 01             	and    $0x1,%eax
}
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
	return (vpt[PGNUM(va)] & PTE_D) != 0;
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b5:	c1 e8 0c             	shr    $0xc,%eax
  8003b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003bf:	c1 e8 06             	shr    $0x6,%eax
  8003c2:	83 e0 01             	and    $0x1,%eax
}
  8003c5:	5d                   	pop    %ebp
  8003c6:	c3                   	ret    

008003c7 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	83 ec 18             	sub    $0x18,%esp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8003d0:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
  8003d6:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  8003dc:	76 20                	jbe    8003fe <flush_block+0x37>
		panic("flush_block of bad va %08x", addr);
  8003de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e2:	c7 44 24 08 2d 34 80 	movl   $0x80342d,0x8(%esp)
  8003e9:	00 
  8003ea:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8003f1:	00 
  8003f2:	c7 04 24 0a 34 80 00 	movl   $0x80340a,(%esp)
  8003f9:	e8 9a 12 00 00       	call   801698 <_panic>

	// LAB 5: Your code here.
	panic("flush_block not implemented");
  8003fe:	c7 44 24 08 48 34 80 	movl   $0x803448,0x8(%esp)
  800405:	00 
  800406:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80040d:	00 
  80040e:	c7 04 24 0a 34 80 00 	movl   $0x80340a,(%esp)
  800415:	e8 7e 12 00 00       	call   801698 <_panic>

0080041a <check_bc>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800423:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80042a:	e8 0f ff ff ff       	call   80033e <diskaddr>
  80042f:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800436:	00 
  800437:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800441:	89 04 24             	mov    %eax,(%esp)
  800444:	e8 ca 1b 00 00       	call   802013 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800449:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800450:	e8 e9 fe ff ff       	call   80033e <diskaddr>
  800455:	c7 44 24 04 64 34 80 	movl   $0x803464,0x4(%esp)
  80045c:	00 
  80045d:	89 04 24             	mov    %eax,(%esp)
  800460:	e8 a6 19 00 00       	call   801e0b <strcpy>
	flush_block(diskaddr(1));
  800465:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80046c:	e8 cd fe ff ff       	call   80033e <diskaddr>
  800471:	89 04 24             	mov    %eax,(%esp)
  800474:	e8 4e ff ff ff       	call   8003c7 <flush_block>

00800479 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  800479:	55                   	push   %ebp
  80047a:	89 e5                	mov    %esp,%ebp
  80047c:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(bc_pgfault);
  80047f:	c7 04 24 a4 02 80 00 	movl   $0x8002a4,(%esp)
  800486:	e8 dd 21 00 00       	call   802668 <set_pgfault_handler>
	check_bc();
  80048b:	e8 8a ff ff ff       	call   80041a <check_bc>

00800490 <skip_slash>:
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  800493:	80 38 2f             	cmpb   $0x2f,(%eax)
  800496:	75 08                	jne    8004a0 <skip_slash+0x10>
		p++;
  800498:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  80049b:	80 38 2f             	cmpb   $0x2f,(%eax)
  80049e:	74 f8                	je     800498 <skip_slash+0x8>
		p++;
	return p;
}
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    

008004a2 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	83 ec 18             	sub    $0x18,%esp
	// LAB 5: Your code here.
	panic("file_block_walk not implemented");
  8004a8:	c7 44 24 08 6c 34 80 	movl   $0x80346c,0x8(%esp)
  8004af:	00 
  8004b0:	c7 44 24 04 87 00 00 	movl   $0x87,0x4(%esp)
  8004b7:	00 
  8004b8:	c7 04 24 ab 34 80 00 	movl   $0x8034ab,(%esp)
  8004bf:	e8 d4 11 00 00       	call   801698 <_panic>

008004c4 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  8004ca:	a1 08 90 80 00       	mov    0x809008,%eax
  8004cf:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8004d5:	74 1c                	je     8004f3 <check_super+0x2f>
		panic("bad file system magic number");
  8004d7:	c7 44 24 08 b3 34 80 	movl   $0x8034b3,0x8(%esp)
  8004de:	00 
  8004df:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  8004e6:	00 
  8004e7:	c7 04 24 ab 34 80 00 	movl   $0x8034ab,(%esp)
  8004ee:	e8 a5 11 00 00       	call   801698 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8004f3:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8004fa:	76 1c                	jbe    800518 <check_super+0x54>
		panic("file system is too large");
  8004fc:	c7 44 24 08 d0 34 80 	movl   $0x8034d0,0x8(%esp)
  800503:	00 
  800504:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  80050b:	00 
  80050c:	c7 04 24 ab 34 80 00 	movl   $0x8034ab,(%esp)
  800513:	e8 80 11 00 00       	call   801698 <_panic>

	cprintf("superblock is good\n");
  800518:	c7 04 24 e9 34 80 00 	movl   $0x8034e9,(%esp)
  80051f:	e8 6f 12 00 00       	call   801793 <cprintf>
}
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  80052c:	8b 15 08 90 80 00    	mov    0x809008,%edx
  800532:	85 d2                	test   %edx,%edx
  800534:	74 22                	je     800558 <block_is_free+0x32>
		return 0;
  800536:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  80053b:	39 4a 04             	cmp    %ecx,0x4(%edx)
  80053e:	76 1d                	jbe    80055d <block_is_free+0x37>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  800540:	b0 01                	mov    $0x1,%al
  800542:	d3 e0                	shl    %cl,%eax
  800544:	c1 e9 05             	shr    $0x5,%ecx
  800547:	8b 15 04 90 80 00    	mov    0x809004,%edx
  80054d:	85 04 8a             	test   %eax,(%edx,%ecx,4)
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800550:	0f 95 c0             	setne  %al
  800553:	0f b6 c0             	movzbl %al,%eax
  800556:	eb 05                	jmp    80055d <block_is_free+0x37>
  800558:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80055d:	5d                   	pop    %ebp
  80055e:	c3                   	ret    

0080055f <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	53                   	push   %ebx
  800563:	83 ec 14             	sub    $0x14,%esp
  800566:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800569:	85 c9                	test   %ecx,%ecx
  80056b:	75 1c                	jne    800589 <free_block+0x2a>
		panic("attempt to free zero block");
  80056d:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  800574:	00 
  800575:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80057c:	00 
  80057d:	c7 04 24 ab 34 80 00 	movl   $0x8034ab,(%esp)
  800584:	e8 0f 11 00 00       	call   801698 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800589:	89 ca                	mov    %ecx,%edx
  80058b:	c1 ea 05             	shr    $0x5,%edx
  80058e:	a1 04 90 80 00       	mov    0x809004,%eax
  800593:	bb 01 00 00 00       	mov    $0x1,%ebx
  800598:	d3 e3                	shl    %cl,%ebx
  80059a:	09 1c 90             	or     %ebx,(%eax,%edx,4)
}
  80059d:	83 c4 14             	add    $0x14,%esp
  8005a0:	5b                   	pop    %ebx
  8005a1:	5d                   	pop    %ebp
  8005a2:	c3                   	ret    

008005a3 <file_truncate_blocks>:
// (Remember to clear the f->f_indirect pointer so you'll know
// whether it's valid!)
// Do not change f->f_size.
static void
file_truncate_blocks(struct File *f, off_t newsize)
{
  8005a3:	55                   	push   %ebp
  8005a4:	89 e5                	mov    %esp,%ebp
  8005a6:	53                   	push   %ebx
  8005a7:	83 ec 24             	sub    $0x24,%esp
  8005aa:	89 c3                	mov    %eax,%ebx
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  8005ac:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  8005b2:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  8005b8:	0f 48 d0             	cmovs  %eax,%edx
  8005bb:	c1 fa 0c             	sar    $0xc,%edx
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  8005be:	8b 8b 80 00 00 00    	mov    0x80(%ebx),%ecx
  8005c4:	8d 81 fe 1f 00 00    	lea    0x1ffe(%ecx),%eax
  8005ca:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
  8005d0:	0f 48 c8             	cmovs  %eax,%ecx
  8005d3:	c1 f9 0c             	sar    $0xc,%ecx
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  8005d6:	39 d1                	cmp    %edx,%ecx
  8005d8:	76 11                	jbe    8005eb <file_truncate_blocks+0x48>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  8005da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005e1:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  8005e4:	89 d8                	mov    %ebx,%eax
  8005e6:	e8 b7 fe ff ff       	call   8004a2 <file_block_walk>
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  8005eb:	83 fa 0a             	cmp    $0xa,%edx
  8005ee:	77 1c                	ja     80060c <file_truncate_blocks+0x69>
  8005f0:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  8005f6:	85 c0                	test   %eax,%eax
  8005f8:	74 12                	je     80060c <file_truncate_blocks+0x69>
		free_block(f->f_indirect);
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	e8 5d ff ff ff       	call   80055f <free_block>
		f->f_indirect = 0;
  800602:	c7 83 b0 00 00 00 00 	movl   $0x0,0xb0(%ebx)
  800609:	00 00 00 
	}
}
  80060c:	83 c4 24             	add    $0x24,%esp
  80060f:	5b                   	pop    %ebx
  800610:	5d                   	pop    %ebp
  800611:	c3                   	ret    

00800612 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800612:	55                   	push   %ebp
  800613:	89 e5                	mov    %esp,%ebp
  800615:	83 ec 18             	sub    $0x18,%esp
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	panic("alloc_block not implemented");
  800618:	c7 44 24 08 18 35 80 	movl   $0x803518,0x8(%esp)
  80061f:	00 
  800620:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800627:	00 
  800628:	c7 04 24 ab 34 80 00 	movl   $0x8034ab,(%esp)
  80062f:	e8 64 10 00 00       	call   801698 <_panic>

00800634 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800634:	55                   	push   %ebp
  800635:	89 e5                	mov    %esp,%ebp
  800637:	56                   	push   %esi
  800638:	53                   	push   %ebx
  800639:	83 ec 10             	sub    $0x10,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80063c:	a1 08 90 80 00       	mov    0x809008,%eax
  800641:	8b 70 04             	mov    0x4(%eax),%esi
  800644:	85 f6                	test   %esi,%esi
  800646:	74 44                	je     80068c <check_bitmap+0x58>
  800648:	bb 00 00 00 00       	mov    $0x0,%ebx
// Validate the file system bitmap.
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
  80064d:	8d 43 02             	lea    0x2(%ebx),%eax
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
		assert(!block_is_free(2+i));
  800650:	89 04 24             	mov    %eax,(%esp)
  800653:	e8 ce fe ff ff       	call   800526 <block_is_free>
  800658:	85 c0                	test   %eax,%eax
  80065a:	74 24                	je     800680 <check_bitmap+0x4c>
  80065c:	c7 44 24 0c 34 35 80 	movl   $0x803534,0xc(%esp)
  800663:	00 
  800664:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  80066b:	00 
  80066c:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  800673:	00 
  800674:	c7 04 24 ab 34 80 00 	movl   $0x8034ab,(%esp)
  80067b:	e8 18 10 00 00       	call   801698 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800680:	83 c3 01             	add    $0x1,%ebx
  800683:	89 d8                	mov    %ebx,%eax
  800685:	c1 e0 0f             	shl    $0xf,%eax
  800688:	39 f0                	cmp    %esi,%eax
  80068a:	72 c1                	jb     80064d <check_bitmap+0x19>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  80068c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800693:	e8 8e fe ff ff       	call   800526 <block_is_free>
  800698:	85 c0                	test   %eax,%eax
  80069a:	74 24                	je     8006c0 <check_bitmap+0x8c>
  80069c:	c7 44 24 0c 48 35 80 	movl   $0x803548,0xc(%esp)
  8006a3:	00 
  8006a4:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  8006ab:	00 
  8006ac:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8006b3:	00 
  8006b4:	c7 04 24 ab 34 80 00 	movl   $0x8034ab,(%esp)
  8006bb:	e8 d8 0f 00 00       	call   801698 <_panic>
	assert(!block_is_free(1));
  8006c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006c7:	e8 5a fe ff ff       	call   800526 <block_is_free>
  8006cc:	85 c0                	test   %eax,%eax
  8006ce:	74 24                	je     8006f4 <check_bitmap+0xc0>
  8006d0:	c7 44 24 0c 5a 35 80 	movl   $0x80355a,0xc(%esp)
  8006d7:	00 
  8006d8:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  8006df:	00 
  8006e0:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8006e7:	00 
  8006e8:	c7 04 24 ab 34 80 00 	movl   $0x8034ab,(%esp)
  8006ef:	e8 a4 0f 00 00       	call   801698 <_panic>

	cprintf("bitmap is good\n");
  8006f4:	c7 04 24 6c 35 80 00 	movl   $0x80356c,(%esp)
  8006fb:	e8 93 10 00 00       	call   801793 <cprintf>
}
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	5b                   	pop    %ebx
  800704:	5e                   	pop    %esi
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <fs_init>:
// --------------------------------------------------------------

// Initialize the file system
void
fs_init(void)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available.
	if (ide_probe_disk1())
  80070d:	e8 4d f9 ff ff       	call   80005f <ide_probe_disk1>
  800712:	85 c0                	test   %eax,%eax
  800714:	74 0e                	je     800724 <fs_init+0x1d>
		ide_set_disk(1);
  800716:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80071d:	e8 a8 f9 ff ff       	call   8000ca <ide_set_disk>
  800722:	eb 0c                	jmp    800730 <fs_init+0x29>
	else
		ide_set_disk(0);
  800724:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80072b:	e8 9a f9 ff ff       	call   8000ca <ide_set_disk>

	bc_init();
  800730:	e8 44 fd ff ff       	call   800479 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800735:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80073c:	e8 fd fb ff ff       	call   80033e <diskaddr>
  800741:	a3 08 90 80 00       	mov    %eax,0x809008
	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800746:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80074d:	e8 ec fb ff ff       	call   80033e <diskaddr>
  800752:	a3 04 90 80 00       	mov    %eax,0x809004

	check_super();
  800757:	e8 68 fd ff ff       	call   8004c4 <check_super>
	check_bitmap();
  80075c:	e8 d3 fe ff ff       	call   800634 <check_bitmap>
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 18             	sub    $0x18,%esp
	// LAB 5: Your code here.
	panic("file_get_block not implemented");
  800769:	c7 44 24 08 8c 34 80 	movl   $0x80348c,0x8(%esp)
  800770:	00 
  800771:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
  800778:	00 
  800779:	c7 04 24 ab 34 80 00 	movl   $0x8034ab,(%esp)
  800780:	e8 13 0f 00 00       	call   801698 <_panic>

00800785 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	57                   	push   %edi
  800789:	56                   	push   %esi
  80078a:	53                   	push   %ebx
  80078b:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800791:	89 95 54 ff ff ff    	mov    %edx,-0xac(%ebp)
  800797:	89 8d 50 ff ff ff    	mov    %ecx,-0xb0(%ebp)
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  80079d:	e8 ee fc ff ff       	call   800490 <skip_slash>
	f = &super->s_root;
  8007a2:	8b 3d 08 90 80 00    	mov    0x809008,%edi
  8007a8:	8d 57 08             	lea    0x8(%edi),%edx
  8007ab:	89 95 4c ff ff ff    	mov    %edx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  8007b1:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  8007b8:	83 bd 54 ff ff ff 00 	cmpl   $0x0,-0xac(%ebp)
  8007bf:	0f 84 62 01 00 00    	je     800927 <walk_path+0x1a2>
		*pdir = 0;
  8007c5:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  8007cb:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	*pf = 0;
  8007d1:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  8007d7:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	while (*path != '\0') {
  8007dd:	0f b6 10             	movzbl (%eax),%edx
  8007e0:	84 d2                	test   %dl,%dl
  8007e2:	0f 84 10 01 00 00    	je     8008f8 <walk_path+0x173>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  8007e8:	80 fa 2f             	cmp    $0x2f,%dl
  8007eb:	74 13                	je     800800 <walk_path+0x7b>
  8007ed:	89 c3                	mov    %eax,%ebx
			path++;
  8007ef:	83 c3 01             	add    $0x1,%ebx
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  8007f2:	0f b6 13             	movzbl (%ebx),%edx
  8007f5:	84 d2                	test   %dl,%dl
  8007f7:	74 09                	je     800802 <walk_path+0x7d>
  8007f9:	80 fa 2f             	cmp    $0x2f,%dl
  8007fc:	75 f1                	jne    8007ef <walk_path+0x6a>
  8007fe:	eb 02                	jmp    800802 <walk_path+0x7d>
  800800:	89 c3                	mov    %eax,%ebx
			path++;
		if (path - p >= MAXNAMELEN)
  800802:	89 de                	mov    %ebx,%esi
  800804:	29 c6                	sub    %eax,%esi
  800806:	83 fe 7f             	cmp    $0x7f,%esi
  800809:	0f 8f 0a 01 00 00    	jg     800919 <walk_path+0x194>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  80080f:	89 74 24 08          	mov    %esi,0x8(%esp)
  800813:	89 44 24 04          	mov    %eax,0x4(%esp)
  800817:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80081d:	89 04 24             	mov    %eax,(%esp)
  800820:	e8 ee 17 00 00       	call   802013 <memmove>
		name[path - p] = '\0';
  800825:	c6 84 35 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%esi,1)
  80082c:	00 
		path = skip_slash(path);
  80082d:	89 d8                	mov    %ebx,%eax
  80082f:	e8 5c fc ff ff       	call   800490 <skip_slash>

		if (dir->f_type != FTYPE_DIR)
  800834:	83 bf 8c 00 00 00 01 	cmpl   $0x1,0x8c(%edi)
  80083b:	0f 85 df 00 00 00    	jne    800920 <walk_path+0x19b>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800841:	8b 97 88 00 00 00    	mov    0x88(%edi),%edx
  800847:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
  80084d:	74 24                	je     800873 <walk_path+0xee>
  80084f:	c7 44 24 0c 7c 35 80 	movl   $0x80357c,0xc(%esp)
  800856:	00 
  800857:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  80085e:	00 
  80085f:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
  800866:	00 
  800867:	c7 04 24 ab 34 80 00 	movl   $0x8034ab,(%esp)
  80086e:	e8 25 0e 00 00       	call   801698 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800873:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800879:	85 d2                	test   %edx,%edx
  80087b:	0f 48 d1             	cmovs  %ecx,%edx
  80087e:	c1 fa 0c             	sar    $0xc,%edx
	for (i = 0; i < nblock; i++) {
  800881:	85 d2                	test   %edx,%edx
  800883:	74 20                	je     8008a5 <walk_path+0x120>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800885:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  80088b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800896:	00 
  800897:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  80089d:	89 04 24             	mov    %eax,(%esp)
  8008a0:	e8 be fe ff ff       	call   800763 <file_get_block>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  8008a5:	ba f5 ff ff ff       	mov    $0xfffffff5,%edx

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  8008aa:	80 38 00             	cmpb   $0x0,(%eax)
  8008ad:	0f 85 8d 00 00 00    	jne    800940 <walk_path+0x1bb>
				if (pdir)
  8008b3:	83 bd 54 ff ff ff 00 	cmpl   $0x0,-0xac(%ebp)
  8008ba:	74 0e                	je     8008ca <walk_path+0x145>
					*pdir = dir;
  8008bc:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  8008c2:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  8008c8:	89 02                	mov    %eax,(%edx)
				if (lastelem)
  8008ca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008ce:	74 15                	je     8008e5 <walk_path+0x160>
					strcpy(lastelem, name);
  8008d0:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8008d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008da:	8b 55 08             	mov    0x8(%ebp),%edx
  8008dd:	89 14 24             	mov    %edx,(%esp)
  8008e0:	e8 26 15 00 00       	call   801e0b <strcpy>
				*pf = 0;
  8008e5:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  8008eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  8008f1:	ba f5 ff ff ff       	mov    $0xfffffff5,%edx
  8008f6:	eb 48                	jmp    800940 <walk_path+0x1bb>
		}
	}

	if (pdir)
		*pdir = dir;
  8008f8:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  8008fe:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	*pf = f;
  800904:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  80090a:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800910:	89 10                	mov    %edx,(%eax)
	return 0;
  800912:	ba 00 00 00 00       	mov    $0x0,%edx
  800917:	eb 27                	jmp    800940 <walk_path+0x1bb>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800919:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  80091e:	eb 20                	jmp    800940 <walk_path+0x1bb>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800920:	ba f5 ff ff ff       	mov    $0xfffffff5,%edx
  800925:	eb 19                	jmp    800940 <walk_path+0x1bb>
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
  800927:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  80092d:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	while (*path != '\0') {
  800933:	0f b6 10             	movzbl (%eax),%edx
  800936:	84 d2                	test   %dl,%dl
  800938:	0f 85 aa fe ff ff    	jne    8007e8 <walk_path+0x63>
  80093e:	eb c4                	jmp    800904 <walk_path+0x17f>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800940:	89 d0                	mov    %edx,%eax
  800942:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5f                   	pop    %edi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	81 ec b8 00 00 00    	sub    $0xb8,%esp
  800956:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800959:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80095c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  80095f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800965:	89 04 24             	mov    %eax,(%esp)
  800968:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  80096e:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	e8 09 fe ff ff       	call   800785 <walk_path>
  80097c:	85 c0                	test   %eax,%eax
  80097e:	0f 84 9b 00 00 00    	je     800a1f <file_create+0xd2>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800984:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800987:	0f 85 97 00 00 00    	jne    800a24 <file_create+0xd7>
  80098d:	8b 8d 64 ff ff ff    	mov    -0x9c(%ebp),%ecx
  800993:	85 c9                	test   %ecx,%ecx
  800995:	0f 84 89 00 00 00    	je     800a24 <file_create+0xd7>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  80099b:	8b 99 80 00 00 00    	mov    0x80(%ecx),%ebx
  8009a1:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
  8009a7:	74 24                	je     8009cd <file_create+0x80>
  8009a9:	c7 44 24 0c 7c 35 80 	movl   $0x80357c,0xc(%esp)
  8009b0:	00 
  8009b1:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  8009b8:	00 
  8009b9:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
  8009c0:	00 
  8009c1:	c7 04 24 ab 34 80 00 	movl   $0x8034ab,(%esp)
  8009c8:	e8 cb 0c 00 00       	call   801698 <_panic>
	nblock = dir->f_size / BLKSIZE;
  8009cd:	bf 00 10 00 00       	mov    $0x1000,%edi
  8009d2:	89 d8                	mov    %ebx,%eax
  8009d4:	89 da                	mov    %ebx,%edx
  8009d6:	c1 fa 1f             	sar    $0x1f,%edx
  8009d9:	f7 ff                	idiv   %edi
	for (i = 0; i < nblock; i++) {
  8009db:	85 c0                	test   %eax,%eax
  8009dd:	74 1a                	je     8009f9 <file_create+0xac>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8009df:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  8009e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009f0:	00 
  8009f1:	89 0c 24             	mov    %ecx,(%esp)
  8009f4:	e8 6a fd ff ff       	call   800763 <file_get_block>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  8009f9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8009ff:	89 99 80 00 00 00    	mov    %ebx,0x80(%ecx)
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800a05:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800a0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a16:	00 
  800a17:	89 0c 24             	mov    %ecx,(%esp)
  800a1a:	e8 44 fd ff ff       	call   800763 <file_get_block>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  800a1f:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
		return r;
	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  800a24:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a27:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a2a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a2d:	89 ec                	mov    %ebp,%esp
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  800a37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a41:	ba 00 00 00 00       	mov    $0x0,%edx
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	e8 37 fd ff ff       	call   800785 <walk_path>
}
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	53                   	push   %ebx
  800a54:	83 ec 24             	sub    $0x24,%esp
  800a57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5a:	8b 55 14             	mov    0x14(%ebp),%edx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800a5d:	8b 81 80 00 00 00    	mov    0x80(%ecx),%eax
  800a63:	39 d0                	cmp    %edx,%eax
  800a65:	7e 2f                	jle    800a96 <file_read+0x46>
		return 0;

	count = MIN(count, f->f_size - offset);
  800a67:	29 d0                	sub    %edx,%eax
  800a69:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a6c:	0f 47 45 10          	cmova  0x10(%ebp),%eax

	for (pos = offset; pos < offset + count; ) {
  800a70:	8d 1c 10             	lea    (%eax,%edx,1),%ebx
  800a73:	39 da                	cmp    %ebx,%edx
  800a75:	73 24                	jae    800a9b <file_read+0x4b>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a7e:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800a83:	89 d0                	mov    %edx,%eax
  800a85:	c1 fa 1f             	sar    $0x1f,%edx
  800a88:	f7 fb                	idiv   %ebx
  800a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8e:	89 0c 24             	mov    %ecx,(%esp)
  800a91:	e8 cd fc ff ff       	call   800763 <file_get_block>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  800a9b:	83 c4 24             	add    $0x24,%esp
  800a9e:	5b                   	pop    %ebx
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 18             	sub    $0x18,%esp
  800aa7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800aaa:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800aad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ab0:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  800ab3:	39 b3 80 00 00 00    	cmp    %esi,0x80(%ebx)
  800ab9:	7e 09                	jle    800ac4 <file_set_size+0x23>
		file_truncate_blocks(f, newsize);
  800abb:	89 f2                	mov    %esi,%edx
  800abd:	89 d8                	mov    %ebx,%eax
  800abf:	e8 df fa ff ff       	call   8005a3 <file_truncate_blocks>
	f->f_size = newsize;
  800ac4:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  800aca:	89 1c 24             	mov    %ebx,(%esp)
  800acd:	e8 f5 f8 ff ff       	call   8003c7 <flush_block>
	return 0;
}
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ada:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800add:	89 ec                	mov    %ebp,%esp
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	83 ec 38             	sub    $0x38,%esp
  800ae7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800aea:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800aed:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800af0:	8b 7d 10             	mov    0x10(%ebp),%edi
  800af3:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800af6:	8d 1c 3e             	lea    (%esi,%edi,1),%ebx
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	3b 98 80 00 00 00    	cmp    0x80(%eax),%ebx
  800b02:	76 10                	jbe    800b14 <file_write+0x33>
		if ((r = file_set_size(f, offset + count)) < 0)
  800b04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b08:	89 04 24             	mov    %eax,(%esp)
  800b0b:	e8 91 ff ff ff       	call   800aa1 <file_set_size>
  800b10:	85 c0                	test   %eax,%eax
  800b12:	78 2a                	js     800b3e <file_write+0x5d>
			return r;

	for (pos = offset; pos < offset + count; ) {
  800b14:	39 de                	cmp    %ebx,%esi
  800b16:	73 24                	jae    800b3c <file_write+0x5b>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800b18:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1f:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800b24:	89 f0                	mov    %esi,%eax
  800b26:	89 f2                	mov    %esi,%edx
  800b28:	c1 fa 1f             	sar    $0x1f,%edx
  800b2b:	f7 f9                	idiv   %ecx
  800b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	89 04 24             	mov    %eax,(%esp)
  800b37:	e8 27 fc ff ff       	call   800763 <file_get_block>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800b3c:	89 f8                	mov    %edi,%eax
}
  800b3e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b41:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b44:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b47:	89 ec                	mov    %ebp,%esp
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	53                   	push   %ebx
  800b4f:	83 ec 24             	sub    $0x24,%esp
  800b52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800b55:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800b5b:	05 ff 0f 00 00       	add    $0xfff,%eax
  800b60:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  800b65:	7e 16                	jle    800b7d <file_flush+0x32>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800b67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b6e:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800b71:	ba 00 00 00 00       	mov    $0x0,%edx
  800b76:	89 d8                	mov    %ebx,%eax
  800b78:	e8 25 f9 ff ff       	call   8004a2 <file_block_walk>
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800b7d:	89 1c 24             	mov    %ebx,(%esp)
  800b80:	e8 42 f8 ff ff       	call   8003c7 <flush_block>
	if (f->f_indirect)
  800b85:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	74 10                	je     800b9f <file_flush+0x54>
		flush_block(diskaddr(f->f_indirect));
  800b8f:	89 04 24             	mov    %eax,(%esp)
  800b92:	e8 a7 f7 ff ff       	call   80033e <diskaddr>
  800b97:	89 04 24             	mov    %eax,(%esp)
  800b9a:	e8 28 f8 ff ff       	call   8003c7 <flush_block>
}
  800b9f:	83 c4 24             	add    $0x24,%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <file_remove>:

// Remove a file by truncating it and then zeroing the name.
int
file_remove(const char *path)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct File *f;

	if ((r = walk_path(path, 0, &f, 0)) < 0)
  800bab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800bb2:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	e8 c3 fb ff ff       	call   800785 <walk_path>
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	78 2d                	js     800bf3 <file_remove+0x4e>
		return r;

	file_truncate_blocks(f, 0);
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bce:	e8 d0 f9 ff ff       	call   8005a3 <file_truncate_blocks>
	f->f_name[0] = '\0';
  800bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bd6:	c6 00 00             	movb   $0x0,(%eax)
	f->f_size = 0;
  800bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bdc:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  800be3:	00 00 00 
	flush_block(f);
  800be6:	89 04 24             	mov    %eax,(%esp)
  800be9:	e8 d9 f7 ff ff       	call   8003c7 <flush_block>

	return 0;
  800bee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <fs_sync>:
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800bf5:	a1 08 90 80 00       	mov    0x809008,%eax
  800bfa:	83 78 04 01          	cmpl   $0x1,0x4(%eax)
  800bfe:	76 36                	jbe    800c36 <fs_sync+0x41>
}

// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	53                   	push   %ebx
  800c04:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800c07:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0c:	bb 01 00 00 00       	mov    $0x1,%ebx
		flush_block(diskaddr(i));
  800c11:	89 04 24             	mov    %eax,(%esp)
  800c14:	e8 25 f7 ff ff       	call   80033e <diskaddr>
  800c19:	89 04 24             	mov    %eax,(%esp)
  800c1c:	e8 a6 f7 ff ff       	call   8003c7 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800c21:	83 c3 01             	add    $0x1,%ebx
  800c24:	89 d8                	mov    %ebx,%eax
  800c26:	8b 15 08 90 80 00    	mov    0x809008,%edx
  800c2c:	3b 5a 04             	cmp    0x4(%edx),%ebx
  800c2f:	72 e0                	jb     800c11 <fs_sync+0x1c>
		flush_block(diskaddr(i));
}
  800c31:	83 c4 14             	add    $0x14,%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5d                   	pop    %ebp
  800c36:	f3 c3                	repz ret 
  800c38:	66 90                	xchg   %ax,%ax
  800c3a:	66 90                	xchg   %ax,%ax
  800c3c:	66 90                	xchg   %ax,%ax
  800c3e:	66 90                	xchg   %ax,%ax

00800c40 <serve_sync>:
}

// Sync the file system.
int
serve_sync(envid_t envid, union Fsipc *req)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  800c46:	e8 aa ff ff ff       	call   800bf5 <fs_sync>
	return 0;
}
  800c4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c50:	c9                   	leave  
  800c51:	c3                   	ret    

00800c52 <serve_remove>:
}

// Remove the file req->req_path.
int
serve_remove(envid_t envid, struct Fsreq_remove *req)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	53                   	push   %ebx
  800c56:	81 ec 14 04 00 00    	sub    $0x414,%esp

	// Delete the named file.
	// Note: This request doesn't refer to an open file.

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  800c5c:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  800c63:	00 
  800c64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c67:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6b:	8d 9d f8 fb ff ff    	lea    -0x408(%ebp),%ebx
  800c71:	89 1c 24             	mov    %ebx,(%esp)
  800c74:	e8 9a 13 00 00       	call   802013 <memmove>
	path[MAXPATHLEN-1] = 0;
  800c79:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Delete the specified file
	return file_remove(path);
  800c7d:	89 1c 24             	mov    %ebx,(%esp)
  800c80:	e8 20 ff ff ff       	call   800ba5 <file_remove>
}
  800c85:	81 c4 14 04 00 00    	add    $0x414,%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	panic("serve_write not implemented");
  800c94:	c7 44 24 08 99 35 80 	movl   $0x803599,0x8(%esp)
  800c9b:	00 
  800c9c:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  800ca3:	00 
  800ca4:	c7 04 24 b5 35 80 00 	movl   $0x8035b5,(%esp)
  800cab:	e8 e8 09 00 00       	call   801698 <_panic>

00800cb0 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 18             	sub    $0x18,%esp
	// so filling in ret will overwrite req.
	//
	// Hint: Use file_read.
	// Hint: The seek position is stored in the struct Fd.
	// LAB 5: Your code here
	panic("serve_read not implemented");
  800cb6:	c7 44 24 08 bf 35 80 	movl   $0x8035bf,0x8(%esp)
  800cbd:	00 
  800cbe:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  800cc5:	00 
  800cc6:	c7 04 24 b5 35 80 00 	movl   $0x8035b5,(%esp)
  800ccd:	e8 c6 09 00 00       	call   801698 <_panic>

00800cd2 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	ba 60 40 80 00       	mov    $0x804060,%edx
	int i;
	uintptr_t va = FILEVA;
  800cda:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  800ce4:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  800ce6:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  800ce9:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  800cef:	83 c0 01             	add    $0x1,%eax
  800cf2:	83 c2 10             	add    $0x10,%edx
  800cf5:	3d 00 04 00 00       	cmp    $0x400,%eax
  800cfa:	75 e8                	jne    800ce4 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 10             	sub    $0x10,%esp
  800d06:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800d09:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
  800d0e:	89 d8                	mov    %ebx,%eax
  800d10:	c1 e0 04             	shl    $0x4,%eax
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  800d13:	8b 80 6c 40 80 00    	mov    0x80406c(%eax),%eax
  800d19:	89 04 24             	mov    %eax,(%esp)
  800d1c:	e8 ef 22 00 00       	call   803010 <pageref>
  800d21:	85 c0                	test   %eax,%eax
  800d23:	74 0d                	je     800d32 <openfile_alloc+0x34>
  800d25:	83 f8 01             	cmp    $0x1,%eax
  800d28:	75 68                	jne    800d92 <openfile_alloc+0x94>
  800d2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d30:	eb 27                	jmp    800d59 <openfile_alloc+0x5b>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  800d32:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800d39:	00 
  800d3a:	89 d8                	mov    %ebx,%eax
  800d3c:	c1 e0 04             	shl    $0x4,%eax
  800d3f:	8b 80 6c 40 80 00    	mov    0x80406c(%eax),%eax
  800d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d50:	e8 04 16 00 00       	call   802359 <sys_page_alloc>
  800d55:	85 c0                	test   %eax,%eax
  800d57:	78 4d                	js     800da6 <openfile_alloc+0xa8>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  800d59:	c1 e3 04             	shl    $0x4,%ebx
  800d5c:	8d 83 60 40 80 00    	lea    0x804060(%ebx),%eax
  800d62:	81 83 60 40 80 00 00 	addl   $0x400,0x804060(%ebx)
  800d69:	04 00 00 
			*o = &opentab[i];
  800d6c:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  800d6e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800d75:	00 
  800d76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d7d:	00 
  800d7e:	8b 83 6c 40 80 00    	mov    0x80406c(%ebx),%eax
  800d84:	89 04 24             	mov    %eax,(%esp)
  800d87:	e8 29 12 00 00       	call   801fb5 <memset>
			return (*o)->o_fileid;
  800d8c:	8b 06                	mov    (%esi),%eax
  800d8e:	8b 00                	mov    (%eax),%eax
  800d90:	eb 14                	jmp    800da6 <openfile_alloc+0xa8>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800d92:	83 c3 01             	add    $0x1,%ebx
  800d95:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800d9b:	0f 85 6d ff ff ff    	jne    800d0e <openfile_alloc+0x10>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  800da1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800da6:	83 c4 10             	add    $0x10,%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	83 ec 28             	sub    $0x28,%esp
  800db3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800dbf:	89 de                	mov    %ebx,%esi
  800dc1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800dc7:	c1 e6 04             	shl    $0x4,%esi
  800dca:	8d be 60 40 80 00    	lea    0x804060(%esi),%edi
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
  800dd0:	8b 86 6c 40 80 00    	mov    0x80406c(%esi),%eax
  800dd6:	89 04 24             	mov    %eax,(%esp)
  800dd9:	e8 32 22 00 00       	call   803010 <pageref>
  800dde:	83 f8 01             	cmp    $0x1,%eax
  800de1:	74 14                	je     800df7 <openfile_lookup+0x4a>
  800de3:	39 9e 60 40 80 00    	cmp    %ebx,0x804060(%esi)
  800de9:	75 13                	jne    800dfe <openfile_lookup+0x51>
		return -E_INVAL;
	*po = o;
  800deb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dee:	89 38                	mov    %edi,(%eax)
	return 0;
  800df0:	b8 00 00 00 00       	mov    $0x0,%eax
  800df5:	eb 0c                	jmp    800e03 <openfile_lookup+0x56>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
		return -E_INVAL;
  800df7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dfc:	eb 05                	jmp    800e03 <openfile_lookup+0x56>
  800dfe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  800e03:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e06:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e09:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e0c:	89 ec                	mov    %ebp,%esp
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <serve_flush>:
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800e16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e19:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e20:	8b 00                	mov    (%eax),%eax
  800e22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e26:	8b 45 08             	mov    0x8(%ebp),%eax
  800e29:	89 04 24             	mov    %eax,(%esp)
  800e2c:	e8 7c ff ff ff       	call   800dad <openfile_lookup>
  800e31:	85 c0                	test   %eax,%eax
  800e33:	78 13                	js     800e48 <serve_flush+0x38>
		return r;
	file_flush(o->o_file);
  800e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e38:	8b 40 04             	mov    0x4(%eax),%eax
  800e3b:	89 04 24             	mov    %eax,(%esp)
  800e3e:	e8 08 fd ff ff       	call   800b4b <file_flush>
	return 0;
  800e43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	53                   	push   %ebx
  800e4e:	83 ec 24             	sub    $0x24,%esp
  800e51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800e54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e5b:	8b 03                	mov    (%ebx),%eax
  800e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e61:	8b 45 08             	mov    0x8(%ebp),%eax
  800e64:	89 04 24             	mov    %eax,(%esp)
  800e67:	e8 41 ff ff ff       	call   800dad <openfile_lookup>
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	78 3f                	js     800eaf <serve_stat+0x65>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  800e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e73:	8b 40 04             	mov    0x4(%eax),%eax
  800e76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7a:	89 1c 24             	mov    %ebx,(%esp)
  800e7d:	e8 89 0f 00 00       	call   801e0b <strcpy>
	ret->ret_size = o->o_file->f_size;
  800e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e85:	8b 50 04             	mov    0x4(%eax),%edx
  800e88:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  800e8e:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  800e94:	8b 40 04             	mov    0x4(%eax),%eax
  800e97:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800e9e:	0f 94 c0             	sete   %al
  800ea1:	0f b6 c0             	movzbl %al,%eax
  800ea4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800eaa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eaf:	83 c4 24             	add    $0x24,%esp
  800eb2:	5b                   	pop    %ebx
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 24             	sub    $0x24,%esp
  800ebc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800ebf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ec6:	8b 03                	mov    (%ebx),%eax
  800ec8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecf:	89 04 24             	mov    %eax,(%esp)
  800ed2:	e8 d6 fe ff ff       	call   800dad <openfile_lookup>
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	78 15                	js     800ef0 <serve_set_size+0x3b>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  800edb:	8b 43 04             	mov    0x4(%ebx),%eax
  800ede:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee5:	8b 40 04             	mov    0x4(%eax),%eax
  800ee8:	89 04 24             	mov    %eax,(%esp)
  800eeb:	e8 b1 fb ff ff       	call   800aa1 <file_set_size>
}
  800ef0:	83 c4 24             	add    $0x24,%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	53                   	push   %ebx
  800efa:	81 ec 24 04 00 00    	sub    $0x424,%esp
  800f00:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  800f03:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  800f0a:	00 
  800f0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f0f:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800f15:	89 04 24             	mov    %eax,(%esp)
  800f18:	e8 f6 10 00 00       	call   802013 <memmove>
	path[MAXPATHLEN-1] = 0;
  800f1d:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  800f21:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  800f27:	89 04 24             	mov    %eax,(%esp)
  800f2a:	e8 cf fd ff ff       	call   800cfe <openfile_alloc>
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	0f 88 d0 00 00 00    	js     801007 <serve_open+0x111>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  800f37:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  800f3e:	74 32                	je     800f72 <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  800f40:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800f46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4a:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800f50:	89 04 24             	mov    %eax,(%esp)
  800f53:	e8 f5 f9 ff ff       	call   80094d <file_create>
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	79 32                	jns    800f8e <serve_open+0x98>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  800f5c:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  800f63:	0f 85 9e 00 00 00    	jne    801007 <serve_open+0x111>
  800f69:	83 f8 f3             	cmp    $0xfffffff3,%eax
  800f6c:	0f 85 95 00 00 00    	jne    801007 <serve_open+0x111>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  800f72:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800f78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800f82:	89 04 24             	mov    %eax,(%esp)
  800f85:	e8 a7 fa ff ff       	call   800a31 <file_open>
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	78 79                	js     801007 <serve_open+0x111>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  800f8e:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  800f95:	74 1a                	je     800fb1 <serve_open+0xbb>
		if ((r = file_set_size(f, 0)) < 0) {
  800f97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f9e:	00 
  800f9f:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  800fa5:	89 04 24             	mov    %eax,(%esp)
  800fa8:	e8 f4 fa ff ff       	call   800aa1 <file_set_size>
  800fad:	85 c0                	test   %eax,%eax
  800faf:	78 56                	js     801007 <serve_open+0x111>
			return r;
		}
	}

	// Save the file pointer
	o->o_file = f;
  800fb1:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800fb7:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  800fbd:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  800fc0:	8b 50 0c             	mov    0xc(%eax),%edx
  800fc3:	8b 08                	mov    (%eax),%ecx
  800fc5:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  800fc8:	8b 50 0c             	mov    0xc(%eax),%edx
  800fcb:	8b 8b 00 04 00 00    	mov    0x400(%ebx),%ecx
  800fd1:	83 e1 03             	and    $0x3,%ecx
  800fd4:	89 4a 08             	mov    %ecx,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  800fd7:	8b 40 0c             	mov    0xc(%eax),%eax
  800fda:	8b 15 64 80 80 00    	mov    0x808064,%edx
  800fe0:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  800fe2:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800fe8:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  800fee:	89 50 08             	mov    %edx,0x8(%eax)

	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller
	*pg_store = o->o_fd;
  800ff1:	8b 50 0c             	mov    0xc(%eax),%edx
  800ff4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff7:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W;
  800ff9:	8b 45 14             	mov    0x14(%ebp),%eax
  800ffc:	c7 00 07 00 00 00    	movl   $0x7,(%eax)
	return 0;
  801002:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801007:	81 c4 24 04 00 00    	add    $0x424,%esp
  80100d:	5b                   	pop    %ebx
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	56                   	push   %esi
  801014:	53                   	push   %ebx
  801015:	83 ec 20             	sub    $0x20,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801018:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  80101b:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  80101e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801025:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801029:	a1 44 40 80 00       	mov    0x804044,%eax
  80102e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801032:	89 34 24             	mov    %esi,(%esp)
  801035:	e8 c6 16 00 00       	call   802700 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, vpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  80103a:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  80103e:	75 15                	jne    801055 <serve+0x45>
			cprintf("Invalid request from %08x: no argument page\n",
  801040:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801043:	89 44 24 04          	mov    %eax,0x4(%esp)
  801047:	c7 04 24 fc 35 80 00 	movl   $0x8035fc,(%esp)
  80104e:	e8 40 07 00 00       	call   801793 <cprintf>
				whom);
			continue; // just leave it hanging...
  801053:	eb c9                	jmp    80101e <serve+0xe>
		}

		pg = NULL;
  801055:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  80105c:	83 f8 01             	cmp    $0x1,%eax
  80105f:	75 21                	jne    801082 <serve+0x72>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801061:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801065:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80106c:	a1 44 40 80 00       	mov    0x804044,%eax
  801071:	89 44 24 04          	mov    %eax,0x4(%esp)
  801075:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801078:	89 04 24             	mov    %eax,(%esp)
  80107b:	e8 76 fe ff ff       	call   800ef6 <serve_open>
  801080:	eb 3f                	jmp    8010c1 <serve+0xb1>
		} else if (req < NHANDLERS && handlers[req]) {
  801082:	83 f8 08             	cmp    $0x8,%eax
  801085:	77 1e                	ja     8010a5 <serve+0x95>
  801087:	8b 14 85 20 40 80 00 	mov    0x804020(,%eax,4),%edx
  80108e:	85 d2                	test   %edx,%edx
  801090:	74 13                	je     8010a5 <serve+0x95>
			r = handlers[req](whom, fsreq);
  801092:	a1 44 40 80 00       	mov    0x804044,%eax
  801097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109e:	89 04 24             	mov    %eax,(%esp)
  8010a1:	ff d2                	call   *%edx
  8010a3:	eb 1c                	jmp    8010c1 <serve+0xb1>
		} else {
			cprintf("Invalid request code %d from %08x\n", whom, req);
  8010a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b0:	c7 04 24 2c 36 80 00 	movl   $0x80362c,(%esp)
  8010b7:	e8 d7 06 00 00       	call   801793 <cprintf>
			r = -E_INVAL;
  8010bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8010c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8010cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8010cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d6:	89 04 24             	mov    %eax,(%esp)
  8010d9:	e8 7a 16 00 00       	call   802758 <ipc_send>
		sys_page_unmap(0, fsreq);
  8010de:	a1 44 40 80 00       	mov    0x804044,%eax
  8010e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ee:	e8 35 13 00 00       	call   802428 <sys_page_unmap>
  8010f3:	e9 26 ff ff ff       	jmp    80101e <serve+0xe>

008010f8 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  8010fe:	c7 05 60 80 80 00 da 	movl   $0x8035da,0x808060
  801105:	35 80 00 
	cprintf("FS is running\n");
  801108:	c7 04 24 dd 35 80 00 	movl   $0x8035dd,(%esp)
  80110f:	e8 7f 06 00 00       	call   801793 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801114:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801119:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80111e:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801120:	c7 04 24 ec 35 80 00 	movl   $0x8035ec,(%esp)
  801127:	e8 67 06 00 00       	call   801793 <cprintf>

	serve_init();
  80112c:	e8 a1 fb ff ff       	call   800cd2 <serve_init>
	fs_init();
  801131:	e8 d1 f5 ff ff       	call   800707 <fs_init>
	fs_test();
  801136:	e8 0d 00 00 00       	call   801148 <fs_test>
	serve();
  80113b:	90                   	nop
  80113c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801140:	e8 cb fe ff ff       	call   801010 <serve>
  801145:	66 90                	xchg   %ax,%ax
  801147:	90                   	nop

00801148 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	53                   	push   %ebx
  80114c:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80114f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801156:	00 
  801157:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  80115e:	00 
  80115f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801166:	e8 ee 11 00 00       	call   802359 <sys_page_alloc>
  80116b:	85 c0                	test   %eax,%eax
  80116d:	79 20                	jns    80118f <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  80116f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801173:	c7 44 24 08 4f 36 80 	movl   $0x80364f,0x8(%esp)
  80117a:	00 
  80117b:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  801182:	00 
  801183:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  80118a:	e8 09 05 00 00       	call   801698 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80118f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801196:	00 
  801197:	a1 04 90 80 00       	mov    0x809004,%eax
  80119c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a0:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  8011a7:	e8 67 0e 00 00       	call   802013 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8011ac:	e8 61 f4 ff ff       	call   800612 <alloc_block>
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	79 20                	jns    8011d5 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  8011b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011b9:	c7 44 24 08 6c 36 80 	movl   $0x80366c,0x8(%esp)
  8011c0:	00 
  8011c1:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  8011c8:	00 
  8011c9:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  8011d0:	e8 c3 04 00 00       	call   801698 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8011d5:	8d 58 1f             	lea    0x1f(%eax),%ebx
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	0f 49 d8             	cmovns %eax,%ebx
  8011dd:	c1 fb 05             	sar    $0x5,%ebx
  8011e0:	89 c2                	mov    %eax,%edx
  8011e2:	c1 fa 1f             	sar    $0x1f,%edx
  8011e5:	c1 ea 1b             	shr    $0x1b,%edx
  8011e8:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8011eb:	83 e1 1f             	and    $0x1f,%ecx
  8011ee:	29 d1                	sub    %edx,%ecx
  8011f0:	ba 01 00 00 00       	mov    $0x1,%edx
  8011f5:	d3 e2                	shl    %cl,%edx
  8011f7:	85 14 9d 00 10 00 00 	test   %edx,0x1000(,%ebx,4)
  8011fe:	75 24                	jne    801224 <fs_test+0xdc>
  801200:	c7 44 24 0c 7c 36 80 	movl   $0x80367c,0xc(%esp)
  801207:	00 
  801208:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  80120f:	00 
  801210:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801217:	00 
  801218:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  80121f:	e8 74 04 00 00       	call   801698 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801224:	a1 04 90 80 00       	mov    0x809004,%eax
  801229:	85 14 98             	test   %edx,(%eax,%ebx,4)
  80122c:	74 24                	je     801252 <fs_test+0x10a>
  80122e:	c7 44 24 0c f4 37 80 	movl   $0x8037f4,0xc(%esp)
  801235:	00 
  801236:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  80123d:	00 
  80123e:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801245:	00 
  801246:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  80124d:	e8 46 04 00 00       	call   801698 <_panic>
	cprintf("alloc_block is good\n");
  801252:	c7 04 24 97 36 80 00 	movl   $0x803697,(%esp)
  801259:	e8 35 05 00 00       	call   801793 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80125e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801261:	89 44 24 04          	mov    %eax,0x4(%esp)
  801265:	c7 04 24 ac 36 80 00 	movl   $0x8036ac,(%esp)
  80126c:	e8 c0 f7 ff ff       	call   800a31 <file_open>
  801271:	85 c0                	test   %eax,%eax
  801273:	79 25                	jns    80129a <fs_test+0x152>
  801275:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801278:	74 40                	je     8012ba <fs_test+0x172>
		panic("file_open /not-found: %e", r);
  80127a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80127e:	c7 44 24 08 b7 36 80 	movl   $0x8036b7,0x8(%esp)
  801285:	00 
  801286:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80128d:	00 
  80128e:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  801295:	e8 fe 03 00 00       	call   801698 <_panic>
	else if (r == 0)
  80129a:	85 c0                	test   %eax,%eax
  80129c:	75 1c                	jne    8012ba <fs_test+0x172>
		panic("file_open /not-found succeeded!");
  80129e:	c7 44 24 08 14 38 80 	movl   $0x803814,0x8(%esp)
  8012a5:	00 
  8012a6:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8012ad:	00 
  8012ae:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  8012b5:	e8 de 03 00 00       	call   801698 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  8012ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c1:	c7 04 24 d0 36 80 00 	movl   $0x8036d0,(%esp)
  8012c8:	e8 64 f7 ff ff       	call   800a31 <file_open>
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	79 20                	jns    8012f1 <fs_test+0x1a9>
		panic("file_open /newmotd: %e", r);
  8012d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d5:	c7 44 24 08 d9 36 80 	movl   $0x8036d9,0x8(%esp)
  8012dc:	00 
  8012dd:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8012e4:	00 
  8012e5:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  8012ec:	e8 a7 03 00 00       	call   801698 <_panic>
	cprintf("file_open is good\n");
  8012f1:	c7 04 24 f0 36 80 00 	movl   $0x8036f0,(%esp)
  8012f8:	e8 96 04 00 00       	call   801793 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8012fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801300:	89 44 24 08          	mov    %eax,0x8(%esp)
  801304:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80130b:	00 
  80130c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130f:	89 04 24             	mov    %eax,(%esp)
  801312:	e8 4c f4 ff ff       	call   800763 <file_get_block>
  801317:	85 c0                	test   %eax,%eax
  801319:	79 20                	jns    80133b <fs_test+0x1f3>
		panic("file_get_block: %e", r);
  80131b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80131f:	c7 44 24 08 03 37 80 	movl   $0x803703,0x8(%esp)
  801326:	00 
  801327:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80132e:	00 
  80132f:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  801336:	e8 5d 03 00 00       	call   801698 <_panic>
	if (strcmp(blk, msg) != 0)
  80133b:	c7 44 24 04 34 38 80 	movl   $0x803834,0x4(%esp)
  801342:	00 
  801343:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801346:	89 04 24             	mov    %eax,(%esp)
  801349:	e8 83 0b 00 00       	call   801ed1 <strcmp>
  80134e:	85 c0                	test   %eax,%eax
  801350:	74 1c                	je     80136e <fs_test+0x226>
		panic("file_get_block returned wrong data");
  801352:	c7 44 24 08 5c 38 80 	movl   $0x80385c,0x8(%esp)
  801359:	00 
  80135a:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801361:	00 
  801362:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  801369:	e8 2a 03 00 00       	call   801698 <_panic>
	cprintf("file_get_block is good\n");
  80136e:	c7 04 24 16 37 80 00 	movl   $0x803716,(%esp)
  801375:	e8 19 04 00 00       	call   801793 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80137a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137d:	0f b6 10             	movzbl (%eax),%edx
  801380:	88 10                	mov    %dl,(%eax)
	assert((vpt[PGNUM(blk)] & PTE_D));
  801382:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801385:	c1 e8 0c             	shr    $0xc,%eax
  801388:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80138f:	a8 40                	test   $0x40,%al
  801391:	75 24                	jne    8013b7 <fs_test+0x26f>
  801393:	c7 44 24 0c 2f 37 80 	movl   $0x80372f,0xc(%esp)
  80139a:	00 
  80139b:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  8013a2:	00 
  8013a3:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8013aa:	00 
  8013ab:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  8013b2:	e8 e1 02 00 00       	call   801698 <_panic>
	file_flush(f);
  8013b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ba:	89 04 24             	mov    %eax,(%esp)
  8013bd:	e8 89 f7 ff ff       	call   800b4b <file_flush>
	assert(!(vpt[PGNUM(blk)] & PTE_D));
  8013c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c5:	c1 e8 0c             	shr    $0xc,%eax
  8013c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013cf:	a8 40                	test   $0x40,%al
  8013d1:	74 24                	je     8013f7 <fs_test+0x2af>
  8013d3:	c7 44 24 0c 2e 37 80 	movl   $0x80372e,0xc(%esp)
  8013da:	00 
  8013db:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  8013e2:	00 
  8013e3:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8013ea:	00 
  8013eb:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  8013f2:	e8 a1 02 00 00       	call   801698 <_panic>
	cprintf("file_flush is good\n");
  8013f7:	c7 04 24 49 37 80 00 	movl   $0x803749,(%esp)
  8013fe:	e8 90 03 00 00       	call   801793 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801403:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80140a:	00 
  80140b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140e:	89 04 24             	mov    %eax,(%esp)
  801411:	e8 8b f6 ff ff       	call   800aa1 <file_set_size>
  801416:	85 c0                	test   %eax,%eax
  801418:	79 20                	jns    80143a <fs_test+0x2f2>
		panic("file_set_size: %e", r);
  80141a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80141e:	c7 44 24 08 5d 37 80 	movl   $0x80375d,0x8(%esp)
  801425:	00 
  801426:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  80142d:	00 
  80142e:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  801435:	e8 5e 02 00 00       	call   801698 <_panic>
	assert(f->f_direct[0] == 0);
  80143a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143d:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801444:	74 24                	je     80146a <fs_test+0x322>
  801446:	c7 44 24 0c 6f 37 80 	movl   $0x80376f,0xc(%esp)
  80144d:	00 
  80144e:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  801455:	00 
  801456:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  80145d:	00 
  80145e:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  801465:	e8 2e 02 00 00       	call   801698 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  80146a:	c1 e8 0c             	shr    $0xc,%eax
  80146d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801474:	a8 40                	test   $0x40,%al
  801476:	74 24                	je     80149c <fs_test+0x354>
  801478:	c7 44 24 0c 83 37 80 	movl   $0x803783,0xc(%esp)
  80147f:	00 
  801480:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  801487:	00 
  801488:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  80148f:	00 
  801490:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  801497:	e8 fc 01 00 00       	call   801698 <_panic>
	cprintf("file_truncate is good\n");
  80149c:	c7 04 24 9c 37 80 00 	movl   $0x80379c,(%esp)
  8014a3:	e8 eb 02 00 00       	call   801793 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8014a8:	c7 04 24 34 38 80 00 	movl   $0x803834,(%esp)
  8014af:	e8 fc 08 00 00       	call   801db0 <strlen>
  8014b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bb:	89 04 24             	mov    %eax,(%esp)
  8014be:	e8 de f5 ff ff       	call   800aa1 <file_set_size>
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	79 20                	jns    8014e7 <fs_test+0x39f>
		panic("file_set_size 2: %e", r);
  8014c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014cb:	c7 44 24 08 b3 37 80 	movl   $0x8037b3,0x8(%esp)
  8014d2:	00 
  8014d3:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8014da:	00 
  8014db:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  8014e2:	e8 b1 01 00 00       	call   801698 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  8014e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ea:	89 c2                	mov    %eax,%edx
  8014ec:	c1 ea 0c             	shr    $0xc,%edx
  8014ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f6:	f6 c2 40             	test   $0x40,%dl
  8014f9:	74 24                	je     80151f <fs_test+0x3d7>
  8014fb:	c7 44 24 0c 83 37 80 	movl   $0x803783,0xc(%esp)
  801502:	00 
  801503:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  80150a:	00 
  80150b:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  801512:	00 
  801513:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  80151a:	e8 79 01 00 00       	call   801698 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  80151f:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801522:	89 54 24 08          	mov    %edx,0x8(%esp)
  801526:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80152d:	00 
  80152e:	89 04 24             	mov    %eax,(%esp)
  801531:	e8 2d f2 ff ff       	call   800763 <file_get_block>
  801536:	85 c0                	test   %eax,%eax
  801538:	79 20                	jns    80155a <fs_test+0x412>
		panic("file_get_block 2: %e", r);
  80153a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80153e:	c7 44 24 08 c7 37 80 	movl   $0x8037c7,0x8(%esp)
  801545:	00 
  801546:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  80154d:	00 
  80154e:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  801555:	e8 3e 01 00 00       	call   801698 <_panic>
	strcpy(blk, msg);
  80155a:	c7 44 24 04 34 38 80 	movl   $0x803834,0x4(%esp)
  801561:	00 
  801562:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801565:	89 04 24             	mov    %eax,(%esp)
  801568:	e8 9e 08 00 00       	call   801e0b <strcpy>
	assert((vpt[PGNUM(blk)] & PTE_D));
  80156d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801570:	c1 e8 0c             	shr    $0xc,%eax
  801573:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80157a:	a8 40                	test   $0x40,%al
  80157c:	75 24                	jne    8015a2 <fs_test+0x45a>
  80157e:	c7 44 24 0c 2f 37 80 	movl   $0x80372f,0xc(%esp)
  801585:	00 
  801586:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  80158d:	00 
  80158e:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  801595:	00 
  801596:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  80159d:	e8 f6 00 00 00       	call   801698 <_panic>
	file_flush(f);
  8015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a5:	89 04 24             	mov    %eax,(%esp)
  8015a8:	e8 9e f5 ff ff       	call   800b4b <file_flush>
	assert(!(vpt[PGNUM(blk)] & PTE_D));
  8015ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b0:	c1 e8 0c             	shr    $0xc,%eax
  8015b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ba:	a8 40                	test   $0x40,%al
  8015bc:	74 24                	je     8015e2 <fs_test+0x49a>
  8015be:	c7 44 24 0c 2e 37 80 	movl   $0x80372e,0xc(%esp)
  8015c5:	00 
  8015c6:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  8015cd:	00 
  8015ce:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8015d5:	00 
  8015d6:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  8015dd:	e8 b6 00 00 00       	call   801698 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  8015e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e5:	c1 e8 0c             	shr    $0xc,%eax
  8015e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ef:	a8 40                	test   $0x40,%al
  8015f1:	74 24                	je     801617 <fs_test+0x4cf>
  8015f3:	c7 44 24 0c 83 37 80 	movl   $0x803783,0xc(%esp)
  8015fa:	00 
  8015fb:	c7 44 24 08 7d 33 80 	movl   $0x80337d,0x8(%esp)
  801602:	00 
  801603:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  80160a:	00 
  80160b:	c7 04 24 62 36 80 00 	movl   $0x803662,(%esp)
  801612:	e8 81 00 00 00       	call   801698 <_panic>
	cprintf("file rewrite is good\n");
  801617:	c7 04 24 dc 37 80 00 	movl   $0x8037dc,(%esp)
  80161e:	e8 70 01 00 00       	call   801793 <cprintf>
}
  801623:	83 c4 24             	add    $0x24,%esp
  801626:	5b                   	pop    %ebx
  801627:	5d                   	pop    %ebp
  801628:	c3                   	ret    
  801629:	66 90                	xchg   %ax,%ax
  80162b:	90                   	nop

0080162c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	83 ec 18             	sub    $0x18,%esp
  801632:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801635:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801638:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80163b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  80163e:	e8 a4 0c 00 00       	call   8022e7 <sys_getenvid>
  801643:	25 ff 03 00 00       	and    $0x3ff,%eax
  801648:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80164b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801650:	a3 0c 90 80 00       	mov    %eax,0x80900c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  801655:	85 db                	test   %ebx,%ebx
  801657:	7e 07                	jle    801660 <libmain+0x34>
		binaryname = argv[0];
  801659:	8b 06                	mov    (%esi),%eax
  80165b:	a3 60 80 80 00       	mov    %eax,0x808060

	// call user main routine
	umain(argc, argv);
  801660:	89 74 24 04          	mov    %esi,0x4(%esp)
  801664:	89 1c 24             	mov    %ebx,(%esp)
  801667:	e8 8c fa ff ff       	call   8010f8 <umain>

	// exit gracefully
	exit();
  80166c:	e8 0b 00 00 00       	call   80167c <exit>
}
  801671:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801674:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801677:	89 ec                	mov    %ebp,%esp
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    
  80167b:	90                   	nop

0080167c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  801682:	e8 8c 13 00 00       	call   802a13 <close_all>
	sys_env_destroy(0);
  801687:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80168e:	e8 ee 0b 00 00       	call   802281 <sys_env_destroy>
}
  801693:	c9                   	leave  
  801694:	c3                   	ret    
  801695:	66 90                	xchg   %ax,%ax
  801697:	90                   	nop

00801698 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	56                   	push   %esi
  80169c:	53                   	push   %ebx
  80169d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8016a0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8016a3:	8b 35 60 80 80 00    	mov    0x808060,%esi
  8016a9:	e8 39 0c 00 00       	call   8022e7 <sys_getenvid>
  8016ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8016b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016bc:	89 74 24 08          	mov    %esi,0x8(%esp)
  8016c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c4:	c7 04 24 8c 38 80 00 	movl   $0x80388c,(%esp)
  8016cb:	e8 c3 00 00 00       	call   801793 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8016d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8016d7:	89 04 24             	mov    %eax,(%esp)
  8016da:	e8 53 00 00 00       	call   801732 <vcprintf>
	cprintf("\n");
  8016df:	c7 04 24 69 34 80 00 	movl   $0x803469,(%esp)
  8016e6:	e8 a8 00 00 00       	call   801793 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8016eb:	cc                   	int3   
  8016ec:	eb fd                	jmp    8016eb <_panic+0x53>
  8016ee:	66 90                	xchg   %ax,%ax

008016f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	53                   	push   %ebx
  8016f4:	83 ec 14             	sub    $0x14,%esp
  8016f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8016fa:	8b 03                	mov    (%ebx),%eax
  8016fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801703:	83 c0 01             	add    $0x1,%eax
  801706:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801708:	3d ff 00 00 00       	cmp    $0xff,%eax
  80170d:	75 19                	jne    801728 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80170f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801716:	00 
  801717:	8d 43 08             	lea    0x8(%ebx),%eax
  80171a:	89 04 24             	mov    %eax,(%esp)
  80171d:	e8 ee 0a 00 00       	call   802210 <sys_cputs>
		b->idx = 0;
  801722:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801728:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80172c:	83 c4 14             	add    $0x14,%esp
  80172f:	5b                   	pop    %ebx
  801730:	5d                   	pop    %ebp
  801731:	c3                   	ret    

00801732 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80173b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801742:	00 00 00 
	b.cnt = 0;
  801745:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80174c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80174f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801752:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801756:	8b 45 08             	mov    0x8(%ebp),%eax
  801759:	89 44 24 08          	mov    %eax,0x8(%esp)
  80175d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801763:	89 44 24 04          	mov    %eax,0x4(%esp)
  801767:	c7 04 24 f0 16 80 00 	movl   $0x8016f0,(%esp)
  80176e:	e8 af 01 00 00       	call   801922 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801773:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801779:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801783:	89 04 24             	mov    %eax,(%esp)
  801786:	e8 85 0a 00 00       	call   802210 <sys_cputs>

	return b.cnt;
}
  80178b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801799:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80179c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	89 04 24             	mov    %eax,(%esp)
  8017a6:	e8 87 ff ff ff       	call   801732 <vcprintf>
	va_end(ap);

	return cnt;
}
  8017ab:	c9                   	leave  
  8017ac:	c3                   	ret    
  8017ad:	66 90                	xchg   %ax,%ax
  8017af:	90                   	nop

008017b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	57                   	push   %edi
  8017b4:	56                   	push   %esi
  8017b5:	53                   	push   %ebx
  8017b6:	83 ec 4c             	sub    $0x4c,%esp
  8017b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8017bc:	89 d7                	mov    %edx,%edi
  8017be:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8017c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8017c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017c7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8017cf:	39 d8                	cmp    %ebx,%eax
  8017d1:	72 17                	jb     8017ea <printnum+0x3a>
  8017d3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8017d6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8017d9:	76 0f                	jbe    8017ea <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8017db:	8b 75 14             	mov    0x14(%ebp),%esi
  8017de:	83 ee 01             	sub    $0x1,%esi
  8017e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8017e4:	85 f6                	test   %esi,%esi
  8017e6:	7f 63                	jg     80184b <printnum+0x9b>
  8017e8:	eb 75                	jmp    80185f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8017ea:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8017ed:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8017f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f4:	83 e8 01             	sub    $0x1,%eax
  8017f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801802:	8b 44 24 08          	mov    0x8(%esp),%eax
  801806:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80180a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80180d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801810:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801817:	00 
  801818:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80181b:	89 1c 24             	mov    %ebx,(%esp)
  80181e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801821:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801825:	e8 26 18 00 00       	call   803050 <__udivdi3>
  80182a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80182d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801830:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801834:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801838:	89 04 24             	mov    %eax,(%esp)
  80183b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80183f:	89 fa                	mov    %edi,%edx
  801841:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801844:	e8 67 ff ff ff       	call   8017b0 <printnum>
  801849:	eb 14                	jmp    80185f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80184b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80184f:	8b 45 18             	mov    0x18(%ebp),%eax
  801852:	89 04 24             	mov    %eax,(%esp)
  801855:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801857:	83 ee 01             	sub    $0x1,%esi
  80185a:	75 ef                	jne    80184b <printnum+0x9b>
  80185c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80185f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801863:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801867:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80186a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80186e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801875:	00 
  801876:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801879:	89 1c 24             	mov    %ebx,(%esp)
  80187c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80187f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801883:	e8 18 19 00 00       	call   8031a0 <__umoddi3>
  801888:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80188c:	0f be 80 af 38 80 00 	movsbl 0x8038af(%eax),%eax
  801893:	89 04 24             	mov    %eax,(%esp)
  801896:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801899:	ff d0                	call   *%eax
}
  80189b:	83 c4 4c             	add    $0x4c,%esp
  80189e:	5b                   	pop    %ebx
  80189f:	5e                   	pop    %esi
  8018a0:	5f                   	pop    %edi
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    

008018a3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8018a6:	83 fa 01             	cmp    $0x1,%edx
  8018a9:	7e 0e                	jle    8018b9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8018ab:	8b 10                	mov    (%eax),%edx
  8018ad:	8d 4a 08             	lea    0x8(%edx),%ecx
  8018b0:	89 08                	mov    %ecx,(%eax)
  8018b2:	8b 02                	mov    (%edx),%eax
  8018b4:	8b 52 04             	mov    0x4(%edx),%edx
  8018b7:	eb 22                	jmp    8018db <getuint+0x38>
	else if (lflag)
  8018b9:	85 d2                	test   %edx,%edx
  8018bb:	74 10                	je     8018cd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8018bd:	8b 10                	mov    (%eax),%edx
  8018bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018c2:	89 08                	mov    %ecx,(%eax)
  8018c4:	8b 02                	mov    (%edx),%eax
  8018c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cb:	eb 0e                	jmp    8018db <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8018cd:	8b 10                	mov    (%eax),%edx
  8018cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018d2:	89 08                	mov    %ecx,(%eax)
  8018d4:	8b 02                	mov    (%edx),%eax
  8018d6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8018db:	5d                   	pop    %ebp
  8018dc:	c3                   	ret    

008018dd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8018e3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8018e7:	8b 10                	mov    (%eax),%edx
  8018e9:	3b 50 04             	cmp    0x4(%eax),%edx
  8018ec:	73 0a                	jae    8018f8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8018ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f1:	88 0a                	mov    %cl,(%edx)
  8018f3:	83 c2 01             	add    $0x1,%edx
  8018f6:	89 10                	mov    %edx,(%eax)
}
  8018f8:	5d                   	pop    %ebp
  8018f9:	c3                   	ret    

008018fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801900:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801903:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801907:	8b 45 10             	mov    0x10(%ebp),%eax
  80190a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80190e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801911:	89 44 24 04          	mov    %eax,0x4(%esp)
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	89 04 24             	mov    %eax,(%esp)
  80191b:	e8 02 00 00 00       	call   801922 <vprintfmt>
	va_end(ap);
}
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	57                   	push   %edi
  801926:	56                   	push   %esi
  801927:	53                   	push   %ebx
  801928:	83 ec 4c             	sub    $0x4c,%esp
  80192b:	8b 75 08             	mov    0x8(%ebp),%esi
  80192e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801931:	8b 7d 10             	mov    0x10(%ebp),%edi
  801934:	eb 11                	jmp    801947 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801936:	85 c0                	test   %eax,%eax
  801938:	0f 84 db 03 00 00    	je     801d19 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80193e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801942:	89 04 24             	mov    %eax,(%esp)
  801945:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801947:	0f b6 07             	movzbl (%edi),%eax
  80194a:	83 c7 01             	add    $0x1,%edi
  80194d:	83 f8 25             	cmp    $0x25,%eax
  801950:	75 e4                	jne    801936 <vprintfmt+0x14>
  801952:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  801956:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80195d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801964:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80196b:	ba 00 00 00 00       	mov    $0x0,%edx
  801970:	eb 2b                	jmp    80199d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801972:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801975:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  801979:	eb 22                	jmp    80199d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80197b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80197e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  801982:	eb 19                	jmp    80199d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801984:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801987:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80198e:	eb 0d                	jmp    80199d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801990:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801993:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801996:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80199d:	0f b6 0f             	movzbl (%edi),%ecx
  8019a0:	8d 47 01             	lea    0x1(%edi),%eax
  8019a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019a6:	0f b6 07             	movzbl (%edi),%eax
  8019a9:	83 e8 23             	sub    $0x23,%eax
  8019ac:	3c 55                	cmp    $0x55,%al
  8019ae:	0f 87 40 03 00 00    	ja     801cf4 <vprintfmt+0x3d2>
  8019b4:	0f b6 c0             	movzbl %al,%eax
  8019b7:	ff 24 85 00 3a 80 00 	jmp    *0x803a00(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8019be:	83 e9 30             	sub    $0x30,%ecx
  8019c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8019c4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8019c8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8019cb:	83 f9 09             	cmp    $0x9,%ecx
  8019ce:	77 57                	ja     801a27 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019d0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8019d3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8019d6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8019d9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8019dc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8019df:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8019e3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8019e6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8019e9:	83 f9 09             	cmp    $0x9,%ecx
  8019ec:	76 eb                	jbe    8019d9 <vprintfmt+0xb7>
  8019ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8019f4:	eb 34                	jmp    801a2a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8019f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f9:	8d 48 04             	lea    0x4(%eax),%ecx
  8019fc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8019ff:	8b 00                	mov    (%eax),%eax
  801a01:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a04:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801a07:	eb 21                	jmp    801a2a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  801a09:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a0d:	0f 88 71 ff ff ff    	js     801984 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a13:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801a16:	eb 85                	jmp    80199d <vprintfmt+0x7b>
  801a18:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801a1b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  801a22:	e9 76 ff ff ff       	jmp    80199d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a27:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801a2a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a2e:	0f 89 69 ff ff ff    	jns    80199d <vprintfmt+0x7b>
  801a34:	e9 57 ff ff ff       	jmp    801990 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801a39:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a3c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801a3f:	e9 59 ff ff ff       	jmp    80199d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801a44:	8b 45 14             	mov    0x14(%ebp),%eax
  801a47:	8d 50 04             	lea    0x4(%eax),%edx
  801a4a:	89 55 14             	mov    %edx,0x14(%ebp)
  801a4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a51:	8b 00                	mov    (%eax),%eax
  801a53:	89 04 24             	mov    %eax,(%esp)
  801a56:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a58:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801a5b:	e9 e7 fe ff ff       	jmp    801947 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801a60:	8b 45 14             	mov    0x14(%ebp),%eax
  801a63:	8d 50 04             	lea    0x4(%eax),%edx
  801a66:	89 55 14             	mov    %edx,0x14(%ebp)
  801a69:	8b 00                	mov    (%eax),%eax
  801a6b:	89 c2                	mov    %eax,%edx
  801a6d:	c1 fa 1f             	sar    $0x1f,%edx
  801a70:	31 d0                	xor    %edx,%eax
  801a72:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801a74:	83 f8 0f             	cmp    $0xf,%eax
  801a77:	7f 0b                	jg     801a84 <vprintfmt+0x162>
  801a79:	8b 14 85 60 3b 80 00 	mov    0x803b60(,%eax,4),%edx
  801a80:	85 d2                	test   %edx,%edx
  801a82:	75 20                	jne    801aa4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  801a84:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a88:	c7 44 24 08 c7 38 80 	movl   $0x8038c7,0x8(%esp)
  801a8f:	00 
  801a90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a94:	89 34 24             	mov    %esi,(%esp)
  801a97:	e8 5e fe ff ff       	call   8018fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a9c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801a9f:	e9 a3 fe ff ff       	jmp    801947 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  801aa4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801aa8:	c7 44 24 08 8f 33 80 	movl   $0x80338f,0x8(%esp)
  801aaf:	00 
  801ab0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ab4:	89 34 24             	mov    %esi,(%esp)
  801ab7:	e8 3e fe ff ff       	call   8018fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801abc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801abf:	e9 83 fe ff ff       	jmp    801947 <vprintfmt+0x25>
  801ac4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801ac7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801aca:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801acd:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad0:	8d 50 04             	lea    0x4(%eax),%edx
  801ad3:	89 55 14             	mov    %edx,0x14(%ebp)
  801ad6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801ad8:	85 ff                	test   %edi,%edi
  801ada:	b8 c0 38 80 00       	mov    $0x8038c0,%eax
  801adf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801ae2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  801ae6:	74 06                	je     801aee <vprintfmt+0x1cc>
  801ae8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801aec:	7f 16                	jg     801b04 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801aee:	0f b6 17             	movzbl (%edi),%edx
  801af1:	0f be c2             	movsbl %dl,%eax
  801af4:	83 c7 01             	add    $0x1,%edi
  801af7:	85 c0                	test   %eax,%eax
  801af9:	0f 85 9f 00 00 00    	jne    801b9e <vprintfmt+0x27c>
  801aff:	e9 8b 00 00 00       	jmp    801b8f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b04:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b08:	89 3c 24             	mov    %edi,(%esp)
  801b0b:	e8 c2 02 00 00       	call   801dd2 <strnlen>
  801b10:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801b13:	29 c2                	sub    %eax,%edx
  801b15:	89 55 d8             	mov    %edx,-0x28(%ebp)
  801b18:	85 d2                	test   %edx,%edx
  801b1a:	7e d2                	jle    801aee <vprintfmt+0x1cc>
					putch(padc, putdat);
  801b1c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  801b20:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  801b23:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801b26:	89 d7                	mov    %edx,%edi
  801b28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b2f:	89 04 24             	mov    %eax,(%esp)
  801b32:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b34:	83 ef 01             	sub    $0x1,%edi
  801b37:	75 ef                	jne    801b28 <vprintfmt+0x206>
  801b39:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801b3c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801b3f:	eb ad                	jmp    801aee <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801b41:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801b45:	74 20                	je     801b67 <vprintfmt+0x245>
  801b47:	0f be d2             	movsbl %dl,%edx
  801b4a:	83 ea 20             	sub    $0x20,%edx
  801b4d:	83 fa 5e             	cmp    $0x5e,%edx
  801b50:	76 15                	jbe    801b67 <vprintfmt+0x245>
					putch('?', putdat);
  801b52:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b55:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b59:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801b60:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801b63:	ff d1                	call   *%ecx
  801b65:	eb 0f                	jmp    801b76 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  801b67:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b6a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b6e:	89 04 24             	mov    %eax,(%esp)
  801b71:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801b74:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801b76:	83 eb 01             	sub    $0x1,%ebx
  801b79:	0f b6 17             	movzbl (%edi),%edx
  801b7c:	0f be c2             	movsbl %dl,%eax
  801b7f:	83 c7 01             	add    $0x1,%edi
  801b82:	85 c0                	test   %eax,%eax
  801b84:	75 24                	jne    801baa <vprintfmt+0x288>
  801b86:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801b89:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801b8c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b8f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801b92:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801b96:	0f 8e ab fd ff ff    	jle    801947 <vprintfmt+0x25>
  801b9c:	eb 20                	jmp    801bbe <vprintfmt+0x29c>
  801b9e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801ba1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801ba4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801ba7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801baa:	85 f6                	test   %esi,%esi
  801bac:	78 93                	js     801b41 <vprintfmt+0x21f>
  801bae:	83 ee 01             	sub    $0x1,%esi
  801bb1:	79 8e                	jns    801b41 <vprintfmt+0x21f>
  801bb3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801bb6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801bb9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801bbc:	eb d1                	jmp    801b8f <vprintfmt+0x26d>
  801bbe:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801bc1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bc5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801bcc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801bce:	83 ef 01             	sub    $0x1,%edi
  801bd1:	75 ee                	jne    801bc1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bd3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801bd6:	e9 6c fd ff ff       	jmp    801947 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801bdb:	83 fa 01             	cmp    $0x1,%edx
  801bde:	66 90                	xchg   %ax,%ax
  801be0:	7e 16                	jle    801bf8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  801be2:	8b 45 14             	mov    0x14(%ebp),%eax
  801be5:	8d 50 08             	lea    0x8(%eax),%edx
  801be8:	89 55 14             	mov    %edx,0x14(%ebp)
  801beb:	8b 10                	mov    (%eax),%edx
  801bed:	8b 48 04             	mov    0x4(%eax),%ecx
  801bf0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801bf3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801bf6:	eb 32                	jmp    801c2a <vprintfmt+0x308>
	else if (lflag)
  801bf8:	85 d2                	test   %edx,%edx
  801bfa:	74 18                	je     801c14 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  801bfc:	8b 45 14             	mov    0x14(%ebp),%eax
  801bff:	8d 50 04             	lea    0x4(%eax),%edx
  801c02:	89 55 14             	mov    %edx,0x14(%ebp)
  801c05:	8b 00                	mov    (%eax),%eax
  801c07:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801c0a:	89 c1                	mov    %eax,%ecx
  801c0c:	c1 f9 1f             	sar    $0x1f,%ecx
  801c0f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801c12:	eb 16                	jmp    801c2a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  801c14:	8b 45 14             	mov    0x14(%ebp),%eax
  801c17:	8d 50 04             	lea    0x4(%eax),%edx
  801c1a:	89 55 14             	mov    %edx,0x14(%ebp)
  801c1d:	8b 00                	mov    (%eax),%eax
  801c1f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801c22:	89 c7                	mov    %eax,%edi
  801c24:	c1 ff 1f             	sar    $0x1f,%edi
  801c27:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801c2a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c2d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801c30:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801c35:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801c39:	79 7d                	jns    801cb8 <vprintfmt+0x396>
				putch('-', putdat);
  801c3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801c46:	ff d6                	call   *%esi
				num = -(long long) num;
  801c48:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c4b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801c4e:	f7 d8                	neg    %eax
  801c50:	83 d2 00             	adc    $0x0,%edx
  801c53:	f7 da                	neg    %edx
			}
			base = 10;
  801c55:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801c5a:	eb 5c                	jmp    801cb8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801c5c:	8d 45 14             	lea    0x14(%ebp),%eax
  801c5f:	e8 3f fc ff ff       	call   8018a3 <getuint>
			base = 10;
  801c64:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801c69:	eb 4d                	jmp    801cb8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801c6b:	8d 45 14             	lea    0x14(%ebp),%eax
  801c6e:	e8 30 fc ff ff       	call   8018a3 <getuint>
			base = 8;
  801c73:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801c78:	eb 3e                	jmp    801cb8 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  801c7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c7e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801c85:	ff d6                	call   *%esi
			putch('x', putdat);
  801c87:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c8b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801c92:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801c94:	8b 45 14             	mov    0x14(%ebp),%eax
  801c97:	8d 50 04             	lea    0x4(%eax),%edx
  801c9a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801c9d:	8b 00                	mov    (%eax),%eax
  801c9f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ca4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ca9:	eb 0d                	jmp    801cb8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801cab:	8d 45 14             	lea    0x14(%ebp),%eax
  801cae:	e8 f0 fb ff ff       	call   8018a3 <getuint>
			base = 16;
  801cb3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801cb8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  801cbc:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801cc0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801cc3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801cc7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ccb:	89 04 24             	mov    %eax,(%esp)
  801cce:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cd2:	89 da                	mov    %ebx,%edx
  801cd4:	89 f0                	mov    %esi,%eax
  801cd6:	e8 d5 fa ff ff       	call   8017b0 <printnum>
			break;
  801cdb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801cde:	e9 64 fc ff ff       	jmp    801947 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ce3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ce7:	89 0c 24             	mov    %ecx,(%esp)
  801cea:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cec:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801cef:	e9 53 fc ff ff       	jmp    801947 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801cf4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801cff:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801d01:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801d05:	0f 84 3c fc ff ff    	je     801947 <vprintfmt+0x25>
  801d0b:	83 ef 01             	sub    $0x1,%edi
  801d0e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801d12:	75 f7                	jne    801d0b <vprintfmt+0x3e9>
  801d14:	e9 2e fc ff ff       	jmp    801947 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  801d19:	83 c4 4c             	add    $0x4c,%esp
  801d1c:	5b                   	pop    %ebx
  801d1d:	5e                   	pop    %esi
  801d1e:	5f                   	pop    %edi
  801d1f:	5d                   	pop    %ebp
  801d20:	c3                   	ret    

00801d21 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	83 ec 28             	sub    $0x28,%esp
  801d27:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801d2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d30:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801d34:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801d37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801d3e:	85 d2                	test   %edx,%edx
  801d40:	7e 30                	jle    801d72 <vsnprintf+0x51>
  801d42:	85 c0                	test   %eax,%eax
  801d44:	74 2c                	je     801d72 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801d46:	8b 45 14             	mov    0x14(%ebp),%eax
  801d49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d4d:	8b 45 10             	mov    0x10(%ebp),%eax
  801d50:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d54:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801d57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d5b:	c7 04 24 dd 18 80 00 	movl   $0x8018dd,(%esp)
  801d62:	e8 bb fb ff ff       	call   801922 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801d67:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d6a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d70:	eb 05                	jmp    801d77 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801d72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801d77:	c9                   	leave  
  801d78:	c3                   	ret    

00801d79 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801d7f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801d82:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d86:	8b 45 10             	mov    0x10(%ebp),%eax
  801d89:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d94:	8b 45 08             	mov    0x8(%ebp),%eax
  801d97:	89 04 24             	mov    %eax,(%esp)
  801d9a:	e8 82 ff ff ff       	call   801d21 <vsnprintf>
	va_end(ap);

	return rc;
}
  801d9f:	c9                   	leave  
  801da0:	c3                   	ret    
  801da1:	66 90                	xchg   %ax,%ax
  801da3:	66 90                	xchg   %ax,%ax
  801da5:	66 90                	xchg   %ax,%ax
  801da7:	66 90                	xchg   %ax,%ax
  801da9:	66 90                	xchg   %ax,%ax
  801dab:	66 90                	xchg   %ax,%ax
  801dad:	66 90                	xchg   %ax,%ax
  801daf:	90                   	nop

00801db0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801db6:	80 3a 00             	cmpb   $0x0,(%edx)
  801db9:	74 10                	je     801dcb <strlen+0x1b>
  801dbb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801dc0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801dc3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801dc7:	75 f7                	jne    801dc0 <strlen+0x10>
  801dc9:	eb 05                	jmp    801dd0 <strlen+0x20>
  801dcb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    

00801dd2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	53                   	push   %ebx
  801dd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801dd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ddc:	85 c9                	test   %ecx,%ecx
  801dde:	74 1c                	je     801dfc <strnlen+0x2a>
  801de0:	80 3b 00             	cmpb   $0x0,(%ebx)
  801de3:	74 1e                	je     801e03 <strnlen+0x31>
  801de5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  801dea:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801dec:	39 ca                	cmp    %ecx,%edx
  801dee:	74 18                	je     801e08 <strnlen+0x36>
  801df0:	83 c2 01             	add    $0x1,%edx
  801df3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  801df8:	75 f0                	jne    801dea <strnlen+0x18>
  801dfa:	eb 0c                	jmp    801e08 <strnlen+0x36>
  801dfc:	b8 00 00 00 00       	mov    $0x0,%eax
  801e01:	eb 05                	jmp    801e08 <strnlen+0x36>
  801e03:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801e08:	5b                   	pop    %ebx
  801e09:	5d                   	pop    %ebp
  801e0a:	c3                   	ret    

00801e0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	53                   	push   %ebx
  801e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801e15:	89 c2                	mov    %eax,%edx
  801e17:	0f b6 19             	movzbl (%ecx),%ebx
  801e1a:	88 1a                	mov    %bl,(%edx)
  801e1c:	83 c2 01             	add    $0x1,%edx
  801e1f:	83 c1 01             	add    $0x1,%ecx
  801e22:	84 db                	test   %bl,%bl
  801e24:	75 f1                	jne    801e17 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801e26:	5b                   	pop    %ebx
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    

00801e29 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	53                   	push   %ebx
  801e2d:	83 ec 08             	sub    $0x8,%esp
  801e30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801e33:	89 1c 24             	mov    %ebx,(%esp)
  801e36:	e8 75 ff ff ff       	call   801db0 <strlen>
	strcpy(dst + len, src);
  801e3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e42:	01 d8                	add    %ebx,%eax
  801e44:	89 04 24             	mov    %eax,(%esp)
  801e47:	e8 bf ff ff ff       	call   801e0b <strcpy>
	return dst;
}
  801e4c:	89 d8                	mov    %ebx,%eax
  801e4e:	83 c4 08             	add    $0x8,%esp
  801e51:	5b                   	pop    %ebx
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	56                   	push   %esi
  801e58:	53                   	push   %ebx
  801e59:	8b 75 08             	mov    0x8(%ebp),%esi
  801e5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801e62:	85 db                	test   %ebx,%ebx
  801e64:	74 16                	je     801e7c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  801e66:	01 f3                	add    %esi,%ebx
  801e68:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  801e6a:	0f b6 02             	movzbl (%edx),%eax
  801e6d:	88 01                	mov    %al,(%ecx)
  801e6f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801e72:	80 3a 01             	cmpb   $0x1,(%edx)
  801e75:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801e78:	39 d9                	cmp    %ebx,%ecx
  801e7a:	75 ee                	jne    801e6a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801e7c:	89 f0                	mov    %esi,%eax
  801e7e:	5b                   	pop    %ebx
  801e7f:	5e                   	pop    %esi
  801e80:	5d                   	pop    %ebp
  801e81:	c3                   	ret    

00801e82 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	57                   	push   %edi
  801e86:	56                   	push   %esi
  801e87:	53                   	push   %ebx
  801e88:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e8e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e91:	89 f8                	mov    %edi,%eax
  801e93:	85 f6                	test   %esi,%esi
  801e95:	74 33                	je     801eca <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  801e97:	83 fe 01             	cmp    $0x1,%esi
  801e9a:	74 25                	je     801ec1 <strlcpy+0x3f>
  801e9c:	0f b6 0b             	movzbl (%ebx),%ecx
  801e9f:	84 c9                	test   %cl,%cl
  801ea1:	74 22                	je     801ec5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801ea3:	83 ee 02             	sub    $0x2,%esi
  801ea6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801eab:	88 08                	mov    %cl,(%eax)
  801ead:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801eb0:	39 f2                	cmp    %esi,%edx
  801eb2:	74 13                	je     801ec7 <strlcpy+0x45>
  801eb4:	83 c2 01             	add    $0x1,%edx
  801eb7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801ebb:	84 c9                	test   %cl,%cl
  801ebd:	75 ec                	jne    801eab <strlcpy+0x29>
  801ebf:	eb 06                	jmp    801ec7 <strlcpy+0x45>
  801ec1:	89 f8                	mov    %edi,%eax
  801ec3:	eb 02                	jmp    801ec7 <strlcpy+0x45>
  801ec5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801ec7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801eca:	29 f8                	sub    %edi,%eax
}
  801ecc:	5b                   	pop    %ebx
  801ecd:	5e                   	pop    %esi
  801ece:	5f                   	pop    %edi
  801ecf:	5d                   	pop    %ebp
  801ed0:	c3                   	ret    

00801ed1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801eda:	0f b6 01             	movzbl (%ecx),%eax
  801edd:	84 c0                	test   %al,%al
  801edf:	74 15                	je     801ef6 <strcmp+0x25>
  801ee1:	3a 02                	cmp    (%edx),%al
  801ee3:	75 11                	jne    801ef6 <strcmp+0x25>
		p++, q++;
  801ee5:	83 c1 01             	add    $0x1,%ecx
  801ee8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801eeb:	0f b6 01             	movzbl (%ecx),%eax
  801eee:	84 c0                	test   %al,%al
  801ef0:	74 04                	je     801ef6 <strcmp+0x25>
  801ef2:	3a 02                	cmp    (%edx),%al
  801ef4:	74 ef                	je     801ee5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ef6:	0f b6 c0             	movzbl %al,%eax
  801ef9:	0f b6 12             	movzbl (%edx),%edx
  801efc:	29 d0                	sub    %edx,%eax
}
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    

00801f00 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	56                   	push   %esi
  801f04:	53                   	push   %ebx
  801f05:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f08:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f0b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  801f0e:	85 f6                	test   %esi,%esi
  801f10:	74 29                	je     801f3b <strncmp+0x3b>
  801f12:	0f b6 03             	movzbl (%ebx),%eax
  801f15:	84 c0                	test   %al,%al
  801f17:	74 30                	je     801f49 <strncmp+0x49>
  801f19:	3a 02                	cmp    (%edx),%al
  801f1b:	75 2c                	jne    801f49 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  801f1d:	8d 43 01             	lea    0x1(%ebx),%eax
  801f20:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  801f22:	89 c3                	mov    %eax,%ebx
  801f24:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801f27:	39 f0                	cmp    %esi,%eax
  801f29:	74 17                	je     801f42 <strncmp+0x42>
  801f2b:	0f b6 08             	movzbl (%eax),%ecx
  801f2e:	84 c9                	test   %cl,%cl
  801f30:	74 17                	je     801f49 <strncmp+0x49>
  801f32:	83 c0 01             	add    $0x1,%eax
  801f35:	3a 0a                	cmp    (%edx),%cl
  801f37:	74 e9                	je     801f22 <strncmp+0x22>
  801f39:	eb 0e                	jmp    801f49 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801f3b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f40:	eb 0f                	jmp    801f51 <strncmp+0x51>
  801f42:	b8 00 00 00 00       	mov    $0x0,%eax
  801f47:	eb 08                	jmp    801f51 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801f49:	0f b6 03             	movzbl (%ebx),%eax
  801f4c:	0f b6 12             	movzbl (%edx),%edx
  801f4f:	29 d0                	sub    %edx,%eax
}
  801f51:	5b                   	pop    %ebx
  801f52:	5e                   	pop    %esi
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    

00801f55 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	53                   	push   %ebx
  801f59:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801f5f:	0f b6 18             	movzbl (%eax),%ebx
  801f62:	84 db                	test   %bl,%bl
  801f64:	74 1d                	je     801f83 <strchr+0x2e>
  801f66:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  801f68:	38 d3                	cmp    %dl,%bl
  801f6a:	75 06                	jne    801f72 <strchr+0x1d>
  801f6c:	eb 1a                	jmp    801f88 <strchr+0x33>
  801f6e:	38 ca                	cmp    %cl,%dl
  801f70:	74 16                	je     801f88 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801f72:	83 c0 01             	add    $0x1,%eax
  801f75:	0f b6 10             	movzbl (%eax),%edx
  801f78:	84 d2                	test   %dl,%dl
  801f7a:	75 f2                	jne    801f6e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  801f7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f81:	eb 05                	jmp    801f88 <strchr+0x33>
  801f83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f88:	5b                   	pop    %ebx
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    

00801f8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	53                   	push   %ebx
  801f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f92:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801f95:	0f b6 18             	movzbl (%eax),%ebx
  801f98:	84 db                	test   %bl,%bl
  801f9a:	74 16                	je     801fb2 <strfind+0x27>
  801f9c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  801f9e:	38 d3                	cmp    %dl,%bl
  801fa0:	75 06                	jne    801fa8 <strfind+0x1d>
  801fa2:	eb 0e                	jmp    801fb2 <strfind+0x27>
  801fa4:	38 ca                	cmp    %cl,%dl
  801fa6:	74 0a                	je     801fb2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801fa8:	83 c0 01             	add    $0x1,%eax
  801fab:	0f b6 10             	movzbl (%eax),%edx
  801fae:	84 d2                	test   %dl,%dl
  801fb0:	75 f2                	jne    801fa4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  801fb2:	5b                   	pop    %ebx
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    

00801fb5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	83 ec 0c             	sub    $0xc,%esp
  801fbb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801fbe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801fc1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801fc4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801fca:	85 c9                	test   %ecx,%ecx
  801fcc:	74 36                	je     802004 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801fce:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801fd4:	75 28                	jne    801ffe <memset+0x49>
  801fd6:	f6 c1 03             	test   $0x3,%cl
  801fd9:	75 23                	jne    801ffe <memset+0x49>
		c &= 0xFF;
  801fdb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801fdf:	89 d3                	mov    %edx,%ebx
  801fe1:	c1 e3 08             	shl    $0x8,%ebx
  801fe4:	89 d6                	mov    %edx,%esi
  801fe6:	c1 e6 18             	shl    $0x18,%esi
  801fe9:	89 d0                	mov    %edx,%eax
  801feb:	c1 e0 10             	shl    $0x10,%eax
  801fee:	09 f0                	or     %esi,%eax
  801ff0:	09 c2                	or     %eax,%edx
  801ff2:	89 d0                	mov    %edx,%eax
  801ff4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801ff6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801ff9:	fc                   	cld    
  801ffa:	f3 ab                	rep stos %eax,%es:(%edi)
  801ffc:	eb 06                	jmp    802004 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802001:	fc                   	cld    
  802002:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  802004:	89 f8                	mov    %edi,%eax
  802006:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802009:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80200c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80200f:	89 ec                	mov    %ebp,%esp
  802011:	5d                   	pop    %ebp
  802012:	c3                   	ret    

00802013 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	83 ec 08             	sub    $0x8,%esp
  802019:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80201c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80201f:	8b 45 08             	mov    0x8(%ebp),%eax
  802022:	8b 75 0c             	mov    0xc(%ebp),%esi
  802025:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802028:	39 c6                	cmp    %eax,%esi
  80202a:	73 36                	jae    802062 <memmove+0x4f>
  80202c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80202f:	39 d0                	cmp    %edx,%eax
  802031:	73 2f                	jae    802062 <memmove+0x4f>
		s += n;
		d += n;
  802033:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802036:	f6 c2 03             	test   $0x3,%dl
  802039:	75 1b                	jne    802056 <memmove+0x43>
  80203b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802041:	75 13                	jne    802056 <memmove+0x43>
  802043:	f6 c1 03             	test   $0x3,%cl
  802046:	75 0e                	jne    802056 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802048:	83 ef 04             	sub    $0x4,%edi
  80204b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80204e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  802051:	fd                   	std    
  802052:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802054:	eb 09                	jmp    80205f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  802056:	83 ef 01             	sub    $0x1,%edi
  802059:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80205c:	fd                   	std    
  80205d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80205f:	fc                   	cld    
  802060:	eb 20                	jmp    802082 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802062:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802068:	75 13                	jne    80207d <memmove+0x6a>
  80206a:	a8 03                	test   $0x3,%al
  80206c:	75 0f                	jne    80207d <memmove+0x6a>
  80206e:	f6 c1 03             	test   $0x3,%cl
  802071:	75 0a                	jne    80207d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  802073:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  802076:	89 c7                	mov    %eax,%edi
  802078:	fc                   	cld    
  802079:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80207b:	eb 05                	jmp    802082 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80207d:	89 c7                	mov    %eax,%edi
  80207f:	fc                   	cld    
  802080:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802082:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802085:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802088:	89 ec                	mov    %ebp,%esp
  80208a:	5d                   	pop    %ebp
  80208b:	c3                   	ret    

0080208c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  802092:	8b 45 10             	mov    0x10(%ebp),%eax
  802095:	89 44 24 08          	mov    %eax,0x8(%esp)
  802099:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a3:	89 04 24             	mov    %eax,(%esp)
  8020a6:	e8 68 ff ff ff       	call   802013 <memmove>
}
  8020ab:	c9                   	leave  
  8020ac:	c3                   	ret    

008020ad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8020ad:	55                   	push   %ebp
  8020ae:	89 e5                	mov    %esp,%ebp
  8020b0:	57                   	push   %edi
  8020b1:	56                   	push   %esi
  8020b2:	53                   	push   %ebx
  8020b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020b9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8020bc:	8d 78 ff             	lea    -0x1(%eax),%edi
  8020bf:	85 c0                	test   %eax,%eax
  8020c1:	74 36                	je     8020f9 <memcmp+0x4c>
		if (*s1 != *s2)
  8020c3:	0f b6 03             	movzbl (%ebx),%eax
  8020c6:	0f b6 0e             	movzbl (%esi),%ecx
  8020c9:	38 c8                	cmp    %cl,%al
  8020cb:	75 17                	jne    8020e4 <memcmp+0x37>
  8020cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8020d2:	eb 1a                	jmp    8020ee <memcmp+0x41>
  8020d4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  8020d9:	83 c2 01             	add    $0x1,%edx
  8020dc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8020e0:	38 c8                	cmp    %cl,%al
  8020e2:	74 0a                	je     8020ee <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  8020e4:	0f b6 c0             	movzbl %al,%eax
  8020e7:	0f b6 c9             	movzbl %cl,%ecx
  8020ea:	29 c8                	sub    %ecx,%eax
  8020ec:	eb 10                	jmp    8020fe <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8020ee:	39 fa                	cmp    %edi,%edx
  8020f0:	75 e2                	jne    8020d4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8020f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f7:	eb 05                	jmp    8020fe <memcmp+0x51>
  8020f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020fe:	5b                   	pop    %ebx
  8020ff:	5e                   	pop    %esi
  802100:	5f                   	pop    %edi
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    

00802103 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802103:	55                   	push   %ebp
  802104:	89 e5                	mov    %esp,%ebp
  802106:	53                   	push   %ebx
  802107:	8b 45 08             	mov    0x8(%ebp),%eax
  80210a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  80210d:	89 c2                	mov    %eax,%edx
  80210f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802112:	39 d0                	cmp    %edx,%eax
  802114:	73 13                	jae    802129 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  802116:	89 d9                	mov    %ebx,%ecx
  802118:	38 18                	cmp    %bl,(%eax)
  80211a:	75 06                	jne    802122 <memfind+0x1f>
  80211c:	eb 0b                	jmp    802129 <memfind+0x26>
  80211e:	38 08                	cmp    %cl,(%eax)
  802120:	74 07                	je     802129 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802122:	83 c0 01             	add    $0x1,%eax
  802125:	39 d0                	cmp    %edx,%eax
  802127:	75 f5                	jne    80211e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802129:	5b                   	pop    %ebx
  80212a:	5d                   	pop    %ebp
  80212b:	c3                   	ret    

0080212c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80212c:	55                   	push   %ebp
  80212d:	89 e5                	mov    %esp,%ebp
  80212f:	57                   	push   %edi
  802130:	56                   	push   %esi
  802131:	53                   	push   %ebx
  802132:	83 ec 04             	sub    $0x4,%esp
  802135:	8b 55 08             	mov    0x8(%ebp),%edx
  802138:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80213b:	0f b6 02             	movzbl (%edx),%eax
  80213e:	3c 09                	cmp    $0x9,%al
  802140:	74 04                	je     802146 <strtol+0x1a>
  802142:	3c 20                	cmp    $0x20,%al
  802144:	75 0e                	jne    802154 <strtol+0x28>
		s++;
  802146:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802149:	0f b6 02             	movzbl (%edx),%eax
  80214c:	3c 09                	cmp    $0x9,%al
  80214e:	74 f6                	je     802146 <strtol+0x1a>
  802150:	3c 20                	cmp    $0x20,%al
  802152:	74 f2                	je     802146 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  802154:	3c 2b                	cmp    $0x2b,%al
  802156:	75 0a                	jne    802162 <strtol+0x36>
		s++;
  802158:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80215b:	bf 00 00 00 00       	mov    $0x0,%edi
  802160:	eb 10                	jmp    802172 <strtol+0x46>
  802162:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802167:	3c 2d                	cmp    $0x2d,%al
  802169:	75 07                	jne    802172 <strtol+0x46>
		s++, neg = 1;
  80216b:	83 c2 01             	add    $0x1,%edx
  80216e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802172:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802178:	75 15                	jne    80218f <strtol+0x63>
  80217a:	80 3a 30             	cmpb   $0x30,(%edx)
  80217d:	75 10                	jne    80218f <strtol+0x63>
  80217f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802183:	75 0a                	jne    80218f <strtol+0x63>
		s += 2, base = 16;
  802185:	83 c2 02             	add    $0x2,%edx
  802188:	bb 10 00 00 00       	mov    $0x10,%ebx
  80218d:	eb 10                	jmp    80219f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  80218f:	85 db                	test   %ebx,%ebx
  802191:	75 0c                	jne    80219f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802193:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802195:	80 3a 30             	cmpb   $0x30,(%edx)
  802198:	75 05                	jne    80219f <strtol+0x73>
		s++, base = 8;
  80219a:	83 c2 01             	add    $0x1,%edx
  80219d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80219f:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8021a7:	0f b6 0a             	movzbl (%edx),%ecx
  8021aa:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8021ad:	89 f3                	mov    %esi,%ebx
  8021af:	80 fb 09             	cmp    $0x9,%bl
  8021b2:	77 08                	ja     8021bc <strtol+0x90>
			dig = *s - '0';
  8021b4:	0f be c9             	movsbl %cl,%ecx
  8021b7:	83 e9 30             	sub    $0x30,%ecx
  8021ba:	eb 22                	jmp    8021de <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  8021bc:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8021bf:	89 f3                	mov    %esi,%ebx
  8021c1:	80 fb 19             	cmp    $0x19,%bl
  8021c4:	77 08                	ja     8021ce <strtol+0xa2>
			dig = *s - 'a' + 10;
  8021c6:	0f be c9             	movsbl %cl,%ecx
  8021c9:	83 e9 57             	sub    $0x57,%ecx
  8021cc:	eb 10                	jmp    8021de <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  8021ce:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	80 fb 19             	cmp    $0x19,%bl
  8021d6:	77 16                	ja     8021ee <strtol+0xc2>
			dig = *s - 'A' + 10;
  8021d8:	0f be c9             	movsbl %cl,%ecx
  8021db:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8021de:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021e1:	7d 0f                	jge    8021f2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  8021e3:	83 c2 01             	add    $0x1,%edx
  8021e6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  8021ea:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8021ec:	eb b9                	jmp    8021a7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8021ee:	89 c1                	mov    %eax,%ecx
  8021f0:	eb 02                	jmp    8021f4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8021f2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8021f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8021f8:	74 05                	je     8021ff <strtol+0xd3>
		*endptr = (char *) s;
  8021fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8021fd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8021ff:	89 ca                	mov    %ecx,%edx
  802201:	f7 da                	neg    %edx
  802203:	85 ff                	test   %edi,%edi
  802205:	0f 45 c2             	cmovne %edx,%eax
}
  802208:	83 c4 04             	add    $0x4,%esp
  80220b:	5b                   	pop    %ebx
  80220c:	5e                   	pop    %esi
  80220d:	5f                   	pop    %edi
  80220e:	5d                   	pop    %ebp
  80220f:	c3                   	ret    

00802210 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	83 ec 0c             	sub    $0xc,%esp
  802216:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802219:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80221c:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  80221f:	b8 01 00 00 00       	mov    $0x1,%eax
  802224:	0f a2                	cpuid  
  802226:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802228:	b8 00 00 00 00       	mov    $0x0,%eax
  80222d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802230:	8b 55 08             	mov    0x8(%ebp),%edx
  802233:	89 c3                	mov    %eax,%ebx
  802235:	89 c7                	mov    %eax,%edi
  802237:	89 c6                	mov    %eax,%esi
  802239:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80223b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80223e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802241:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802244:	89 ec                	mov    %ebp,%esp
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    

00802248 <sys_cgetc>:

int
sys_cgetc(void)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	83 ec 0c             	sub    $0xc,%esp
  80224e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802251:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802254:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802257:	b8 01 00 00 00       	mov    $0x1,%eax
  80225c:	0f a2                	cpuid  
  80225e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802260:	ba 00 00 00 00       	mov    $0x0,%edx
  802265:	b8 01 00 00 00       	mov    $0x1,%eax
  80226a:	89 d1                	mov    %edx,%ecx
  80226c:	89 d3                	mov    %edx,%ebx
  80226e:	89 d7                	mov    %edx,%edi
  802270:	89 d6                	mov    %edx,%esi
  802272:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802274:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802277:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80227a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80227d:	89 ec                	mov    %ebp,%esp
  80227f:	5d                   	pop    %ebp
  802280:	c3                   	ret    

00802281 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802281:	55                   	push   %ebp
  802282:	89 e5                	mov    %esp,%ebp
  802284:	83 ec 38             	sub    $0x38,%esp
  802287:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80228a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80228d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802290:	b8 01 00 00 00       	mov    $0x1,%eax
  802295:	0f a2                	cpuid  
  802297:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802299:	b9 00 00 00 00       	mov    $0x0,%ecx
  80229e:	b8 03 00 00 00       	mov    $0x3,%eax
  8022a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8022a6:	89 cb                	mov    %ecx,%ebx
  8022a8:	89 cf                	mov    %ecx,%edi
  8022aa:	89 ce                	mov    %ecx,%esi
  8022ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8022ae:	85 c0                	test   %eax,%eax
  8022b0:	7e 28                	jle    8022da <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  8022b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8022b6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8022bd:	00 
  8022be:	c7 44 24 08 bf 3b 80 	movl   $0x803bbf,0x8(%esp)
  8022c5:	00 
  8022c6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8022cd:	00 
  8022ce:	c7 04 24 dc 3b 80 00 	movl   $0x803bdc,(%esp)
  8022d5:	e8 be f3 ff ff       	call   801698 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8022da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8022dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8022e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8022e3:	89 ec                	mov    %ebp,%esp
  8022e5:	5d                   	pop    %ebp
  8022e6:	c3                   	ret    

008022e7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8022e7:	55                   	push   %ebp
  8022e8:	89 e5                	mov    %esp,%ebp
  8022ea:	83 ec 0c             	sub    $0xc,%esp
  8022ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8022f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8022f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8022f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022fb:	0f a2                	cpuid  
  8022fd:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8022ff:	ba 00 00 00 00       	mov    $0x0,%edx
  802304:	b8 02 00 00 00       	mov    $0x2,%eax
  802309:	89 d1                	mov    %edx,%ecx
  80230b:	89 d3                	mov    %edx,%ebx
  80230d:	89 d7                	mov    %edx,%edi
  80230f:	89 d6                	mov    %edx,%esi
  802311:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802313:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802316:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802319:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80231c:	89 ec                	mov    %ebp,%esp
  80231e:	5d                   	pop    %ebp
  80231f:	c3                   	ret    

00802320 <sys_yield>:

void
sys_yield(void)
{
  802320:	55                   	push   %ebp
  802321:	89 e5                	mov    %esp,%ebp
  802323:	83 ec 0c             	sub    $0xc,%esp
  802326:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802329:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80232c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80232f:	b8 01 00 00 00       	mov    $0x1,%eax
  802334:	0f a2                	cpuid  
  802336:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802338:	ba 00 00 00 00       	mov    $0x0,%edx
  80233d:	b8 0b 00 00 00       	mov    $0xb,%eax
  802342:	89 d1                	mov    %edx,%ecx
  802344:	89 d3                	mov    %edx,%ebx
  802346:	89 d7                	mov    %edx,%edi
  802348:	89 d6                	mov    %edx,%esi
  80234a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80234c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80234f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802352:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802355:	89 ec                	mov    %ebp,%esp
  802357:	5d                   	pop    %ebp
  802358:	c3                   	ret    

00802359 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802359:	55                   	push   %ebp
  80235a:	89 e5                	mov    %esp,%ebp
  80235c:	83 ec 38             	sub    $0x38,%esp
  80235f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802362:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802365:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802368:	b8 01 00 00 00       	mov    $0x1,%eax
  80236d:	0f a2                	cpuid  
  80236f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802371:	be 00 00 00 00       	mov    $0x0,%esi
  802376:	b8 04 00 00 00       	mov    $0x4,%eax
  80237b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80237e:	8b 55 08             	mov    0x8(%ebp),%edx
  802381:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802384:	89 f7                	mov    %esi,%edi
  802386:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802388:	85 c0                	test   %eax,%eax
  80238a:	7e 28                	jle    8023b4 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80238c:	89 44 24 10          	mov    %eax,0x10(%esp)
  802390:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  802397:	00 
  802398:	c7 44 24 08 bf 3b 80 	movl   $0x803bbf,0x8(%esp)
  80239f:	00 
  8023a0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8023a7:	00 
  8023a8:	c7 04 24 dc 3b 80 00 	movl   $0x803bdc,(%esp)
  8023af:	e8 e4 f2 ff ff       	call   801698 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8023b4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8023b7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8023ba:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8023bd:	89 ec                	mov    %ebp,%esp
  8023bf:	5d                   	pop    %ebp
  8023c0:	c3                   	ret    

008023c1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8023c1:	55                   	push   %ebp
  8023c2:	89 e5                	mov    %esp,%ebp
  8023c4:	83 ec 38             	sub    $0x38,%esp
  8023c7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8023ca:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8023cd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8023d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8023d5:	0f a2                	cpuid  
  8023d7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8023de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8023e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8023ea:	8b 75 18             	mov    0x18(%ebp),%esi
  8023ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	7e 28                	jle    80241b <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8023f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023f7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8023fe:	00 
  8023ff:	c7 44 24 08 bf 3b 80 	movl   $0x803bbf,0x8(%esp)
  802406:	00 
  802407:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80240e:	00 
  80240f:	c7 04 24 dc 3b 80 00 	movl   $0x803bdc,(%esp)
  802416:	e8 7d f2 ff ff       	call   801698 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80241b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80241e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802421:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802424:	89 ec                	mov    %ebp,%esp
  802426:	5d                   	pop    %ebp
  802427:	c3                   	ret    

00802428 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802428:	55                   	push   %ebp
  802429:	89 e5                	mov    %esp,%ebp
  80242b:	83 ec 38             	sub    $0x38,%esp
  80242e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802431:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802434:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802437:	b8 01 00 00 00       	mov    $0x1,%eax
  80243c:	0f a2                	cpuid  
  80243e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802440:	bb 00 00 00 00       	mov    $0x0,%ebx
  802445:	b8 06 00 00 00       	mov    $0x6,%eax
  80244a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80244d:	8b 55 08             	mov    0x8(%ebp),%edx
  802450:	89 df                	mov    %ebx,%edi
  802452:	89 de                	mov    %ebx,%esi
  802454:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802456:	85 c0                	test   %eax,%eax
  802458:	7e 28                	jle    802482 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80245a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80245e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  802465:	00 
  802466:	c7 44 24 08 bf 3b 80 	movl   $0x803bbf,0x8(%esp)
  80246d:	00 
  80246e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  802475:	00 
  802476:	c7 04 24 dc 3b 80 00 	movl   $0x803bdc,(%esp)
  80247d:	e8 16 f2 ff ff       	call   801698 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802482:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802485:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802488:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80248b:	89 ec                	mov    %ebp,%esp
  80248d:	5d                   	pop    %ebp
  80248e:	c3                   	ret    

0080248f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80248f:	55                   	push   %ebp
  802490:	89 e5                	mov    %esp,%ebp
  802492:	83 ec 38             	sub    $0x38,%esp
  802495:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802498:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80249b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80249e:	b8 01 00 00 00       	mov    $0x1,%eax
  8024a3:	0f a2                	cpuid  
  8024a5:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8024b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8024b7:	89 df                	mov    %ebx,%edi
  8024b9:	89 de                	mov    %ebx,%esi
  8024bb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024bd:	85 c0                	test   %eax,%eax
  8024bf:	7e 28                	jle    8024e9 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8024c5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8024cc:	00 
  8024cd:	c7 44 24 08 bf 3b 80 	movl   $0x803bbf,0x8(%esp)
  8024d4:	00 
  8024d5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8024dc:	00 
  8024dd:	c7 04 24 dc 3b 80 00 	movl   $0x803bdc,(%esp)
  8024e4:	e8 af f1 ff ff       	call   801698 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8024e9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8024ec:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8024ef:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8024f2:	89 ec                	mov    %ebp,%esp
  8024f4:	5d                   	pop    %ebp
  8024f5:	c3                   	ret    

008024f6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8024f6:	55                   	push   %ebp
  8024f7:	89 e5                	mov    %esp,%ebp
  8024f9:	83 ec 38             	sub    $0x38,%esp
  8024fc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8024ff:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802502:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802505:	b8 01 00 00 00       	mov    $0x1,%eax
  80250a:	0f a2                	cpuid  
  80250c:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80250e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802513:	b8 09 00 00 00       	mov    $0x9,%eax
  802518:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80251b:	8b 55 08             	mov    0x8(%ebp),%edx
  80251e:	89 df                	mov    %ebx,%edi
  802520:	89 de                	mov    %ebx,%esi
  802522:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802524:	85 c0                	test   %eax,%eax
  802526:	7e 28                	jle    802550 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802528:	89 44 24 10          	mov    %eax,0x10(%esp)
  80252c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  802533:	00 
  802534:	c7 44 24 08 bf 3b 80 	movl   $0x803bbf,0x8(%esp)
  80253b:	00 
  80253c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  802543:	00 
  802544:	c7 04 24 dc 3b 80 00 	movl   $0x803bdc,(%esp)
  80254b:	e8 48 f1 ff ff       	call   801698 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802550:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802553:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802556:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802559:	89 ec                	mov    %ebp,%esp
  80255b:	5d                   	pop    %ebp
  80255c:	c3                   	ret    

0080255d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80255d:	55                   	push   %ebp
  80255e:	89 e5                	mov    %esp,%ebp
  802560:	83 ec 38             	sub    $0x38,%esp
  802563:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802566:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802569:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80256c:	b8 01 00 00 00       	mov    $0x1,%eax
  802571:	0f a2                	cpuid  
  802573:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802575:	bb 00 00 00 00       	mov    $0x0,%ebx
  80257a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80257f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802582:	8b 55 08             	mov    0x8(%ebp),%edx
  802585:	89 df                	mov    %ebx,%edi
  802587:	89 de                	mov    %ebx,%esi
  802589:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80258b:	85 c0                	test   %eax,%eax
  80258d:	7e 28                	jle    8025b7 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80258f:	89 44 24 10          	mov    %eax,0x10(%esp)
  802593:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80259a:	00 
  80259b:	c7 44 24 08 bf 3b 80 	movl   $0x803bbf,0x8(%esp)
  8025a2:	00 
  8025a3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8025aa:	00 
  8025ab:	c7 04 24 dc 3b 80 00 	movl   $0x803bdc,(%esp)
  8025b2:	e8 e1 f0 ff ff       	call   801698 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8025b7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8025ba:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8025bd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8025c0:	89 ec                	mov    %ebp,%esp
  8025c2:	5d                   	pop    %ebp
  8025c3:	c3                   	ret    

008025c4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8025c4:	55                   	push   %ebp
  8025c5:	89 e5                	mov    %esp,%ebp
  8025c7:	83 ec 0c             	sub    $0xc,%esp
  8025ca:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8025cd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8025d0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8025d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8025d8:	0f a2                	cpuid  
  8025da:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025dc:	be 00 00 00 00       	mov    $0x0,%esi
  8025e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8025e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025ef:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025f2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8025f4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8025f7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8025fa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8025fd:	89 ec                	mov    %ebp,%esp
  8025ff:	5d                   	pop    %ebp
  802600:	c3                   	ret    

00802601 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802601:	55                   	push   %ebp
  802602:	89 e5                	mov    %esp,%ebp
  802604:	83 ec 38             	sub    $0x38,%esp
  802607:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80260a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80260d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802610:	b8 01 00 00 00       	mov    $0x1,%eax
  802615:	0f a2                	cpuid  
  802617:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802619:	b9 00 00 00 00       	mov    $0x0,%ecx
  80261e:	b8 0d 00 00 00       	mov    $0xd,%eax
  802623:	8b 55 08             	mov    0x8(%ebp),%edx
  802626:	89 cb                	mov    %ecx,%ebx
  802628:	89 cf                	mov    %ecx,%edi
  80262a:	89 ce                	mov    %ecx,%esi
  80262c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80262e:	85 c0                	test   %eax,%eax
  802630:	7e 28                	jle    80265a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  802632:	89 44 24 10          	mov    %eax,0x10(%esp)
  802636:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80263d:	00 
  80263e:	c7 44 24 08 bf 3b 80 	movl   $0x803bbf,0x8(%esp)
  802645:	00 
  802646:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80264d:	00 
  80264e:	c7 04 24 dc 3b 80 00 	movl   $0x803bdc,(%esp)
  802655:	e8 3e f0 ff ff       	call   801698 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80265a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80265d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802660:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802663:	89 ec                	mov    %ebp,%esp
  802665:	5d                   	pop    %ebp
  802666:	c3                   	ret    
  802667:	90                   	nop

00802668 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802668:	55                   	push   %ebp
  802669:	89 e5                	mov    %esp,%ebp
  80266b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80266e:	83 3d 10 90 80 00 00 	cmpl   $0x0,0x809010
  802675:	75 54                	jne    8026cb <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  802677:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80267e:	00 
  80267f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802686:	ee 
  802687:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80268e:	e8 c6 fc ff ff       	call   802359 <sys_page_alloc>
  802693:	85 c0                	test   %eax,%eax
  802695:	74 20                	je     8026b7 <set_pgfault_handler+0x4f>
			panic("sys_page_alloc() failed in set_pgfault_handler()[%e]\n", r);
  802697:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80269b:	c7 44 24 08 ec 3b 80 	movl   $0x803bec,0x8(%esp)
  8026a2:	00 
  8026a3:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8026aa:	00 
  8026ab:	c7 04 24 22 3c 80 00 	movl   $0x803c22,(%esp)
  8026b2:	e8 e1 ef ff ff       	call   801698 <_panic>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8026b7:	c7 44 24 04 d8 26 80 	movl   $0x8026d8,0x4(%esp)
  8026be:	00 
  8026bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026c6:	e8 92 fe ff ff       	call   80255d <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ce:	a3 10 90 80 00       	mov    %eax,0x809010
}
  8026d3:	c9                   	leave  
  8026d4:	c3                   	ret    
  8026d5:	66 90                	xchg   %ax,%ax
  8026d7:	90                   	nop

008026d8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026d8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026d9:	a1 10 90 80 00       	mov    0x809010,%eax
	call *%eax
  8026de:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026e0:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// @yuhangj: get reserved place under old esp
	addl $0x08, %esp;
  8026e3:	83 c4 08             	add    $0x8,%esp

	movl 0x28(%esp), %eax;
  8026e6:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x04, %eax;
  8026ea:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x28(%esp);
  8026ed:	89 44 24 28          	mov    %eax,0x28(%esp)

    // @yuhangj: store old eip into the reserved place under old esp
	movl 0x20(%esp), %ebx;
  8026f1:	8b 5c 24 20          	mov    0x20(%esp),%ebx
	movl %ebx, (%eax);
  8026f5:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8026f7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp;
  8026f8:	83 c4 04             	add    $0x4,%esp
	popfl
  8026fb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8026fc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8026fd:	c3                   	ret    
  8026fe:	66 90                	xchg   %ax,%ax

00802700 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802700:	55                   	push   %ebp
  802701:	89 e5                	mov    %esp,%ebp
  802703:	56                   	push   %esi
  802704:	53                   	push   %ebx
  802705:	83 ec 10             	sub    $0x10,%esp
  802708:	8b 75 08             	mov    0x8(%ebp),%esi
  80270b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  80270e:	85 db                	test   %ebx,%ebx
  802710:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802715:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  802718:	89 1c 24             	mov    %ebx,(%esp)
  80271b:	e8 e1 fe ff ff       	call   802601 <sys_ipc_recv>
  802720:	85 c0                	test   %eax,%eax
  802722:	78 2d                	js     802751 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  802724:	85 f6                	test   %esi,%esi
  802726:	74 0a                	je     802732 <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  802728:	a1 0c 90 80 00       	mov    0x80900c,%eax
  80272d:	8b 40 74             	mov    0x74(%eax),%eax
  802730:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  802732:	85 db                	test   %ebx,%ebx
  802734:	74 13                	je     802749 <ipc_recv+0x49>
  802736:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80273a:	74 0d                	je     802749 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  80273c:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802741:	8b 40 78             	mov    0x78(%eax),%eax
  802744:	8b 55 10             	mov    0x10(%ebp),%edx
  802747:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  802749:	a1 0c 90 80 00       	mov    0x80900c,%eax
  80274e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802751:	83 c4 10             	add    $0x10,%esp
  802754:	5b                   	pop    %ebx
  802755:	5e                   	pop    %esi
  802756:	5d                   	pop    %ebp
  802757:	c3                   	ret    

00802758 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802758:	55                   	push   %ebp
  802759:	89 e5                	mov    %esp,%ebp
  80275b:	57                   	push   %edi
  80275c:	56                   	push   %esi
  80275d:	53                   	push   %ebx
  80275e:	83 ec 1c             	sub    $0x1c,%esp
  802761:	8b 7d 08             	mov    0x8(%ebp),%edi
  802764:	8b 75 0c             	mov    0xc(%ebp),%esi
  802767:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  80276a:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  80276c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802771:	0f 44 d8             	cmove  %eax,%ebx
  802774:	eb 2a                	jmp    8027a0 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  802776:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802779:	74 20                	je     80279b <ipc_send+0x43>
            panic("Send message error %e\n",r);
  80277b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80277f:	c7 44 24 08 30 3c 80 	movl   $0x803c30,0x8(%esp)
  802786:	00 
  802787:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80278e:	00 
  80278f:	c7 04 24 47 3c 80 00 	movl   $0x803c47,(%esp)
  802796:	e8 fd ee ff ff       	call   801698 <_panic>
		sys_yield();
  80279b:	e8 80 fb ff ff       	call   802320 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  8027a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8027a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027a7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027af:	89 3c 24             	mov    %edi,(%esp)
  8027b2:	e8 0d fe ff ff       	call   8025c4 <sys_ipc_try_send>
  8027b7:	85 c0                	test   %eax,%eax
  8027b9:	78 bb                	js     802776 <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  8027bb:	83 c4 1c             	add    $0x1c,%esp
  8027be:	5b                   	pop    %ebx
  8027bf:	5e                   	pop    %esi
  8027c0:	5f                   	pop    %edi
  8027c1:	5d                   	pop    %ebp
  8027c2:	c3                   	ret    

008027c3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027c3:	55                   	push   %ebp
  8027c4:	89 e5                	mov    %esp,%ebp
  8027c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8027c9:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8027ce:	39 c8                	cmp    %ecx,%eax
  8027d0:	74 17                	je     8027e9 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027d2:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8027d7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8027da:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027e0:	8b 52 50             	mov    0x50(%edx),%edx
  8027e3:	39 ca                	cmp    %ecx,%edx
  8027e5:	75 14                	jne    8027fb <ipc_find_env+0x38>
  8027e7:	eb 05                	jmp    8027ee <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027e9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8027ee:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027f1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8027f6:	8b 40 40             	mov    0x40(%eax),%eax
  8027f9:	eb 0e                	jmp    802809 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027fb:	83 c0 01             	add    $0x1,%eax
  8027fe:	3d 00 04 00 00       	cmp    $0x400,%eax
  802803:	75 d2                	jne    8027d7 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802805:	66 b8 00 00          	mov    $0x0,%ax
}
  802809:	5d                   	pop    %ebp
  80280a:	c3                   	ret    
  80280b:	66 90                	xchg   %ax,%ax
  80280d:	66 90                	xchg   %ax,%ax
  80280f:	90                   	nop

00802810 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802810:	55                   	push   %ebp
  802811:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802813:	8b 45 08             	mov    0x8(%ebp),%eax
  802816:	05 00 00 00 30       	add    $0x30000000,%eax
  80281b:	c1 e8 0c             	shr    $0xc,%eax
}
  80281e:	5d                   	pop    %ebp
  80281f:	c3                   	ret    

00802820 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802820:	55                   	push   %ebp
  802821:	89 e5                	mov    %esp,%ebp
  802823:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  802826:	8b 45 08             	mov    0x8(%ebp),%eax
  802829:	89 04 24             	mov    %eax,(%esp)
  80282c:	e8 df ff ff ff       	call   802810 <fd2num>
  802831:	c1 e0 0c             	shl    $0xc,%eax
  802834:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802839:	c9                   	leave  
  80283a:	c3                   	ret    

0080283b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80283b:	55                   	push   %ebp
  80283c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80283e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  802843:	a8 01                	test   $0x1,%al
  802845:	74 34                	je     80287b <fd_alloc+0x40>
  802847:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80284c:	a8 01                	test   $0x1,%al
  80284e:	74 32                	je     802882 <fd_alloc+0x47>
  802850:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  802855:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  802857:	89 c2                	mov    %eax,%edx
  802859:	c1 ea 16             	shr    $0x16,%edx
  80285c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802863:	f6 c2 01             	test   $0x1,%dl
  802866:	74 1f                	je     802887 <fd_alloc+0x4c>
  802868:	89 c2                	mov    %eax,%edx
  80286a:	c1 ea 0c             	shr    $0xc,%edx
  80286d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802874:	f6 c2 01             	test   $0x1,%dl
  802877:	75 1a                	jne    802893 <fd_alloc+0x58>
  802879:	eb 0c                	jmp    802887 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80287b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  802880:	eb 05                	jmp    802887 <fd_alloc+0x4c>
  802882:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  802887:	8b 45 08             	mov    0x8(%ebp),%eax
  80288a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80288c:	b8 00 00 00 00       	mov    $0x0,%eax
  802891:	eb 1a                	jmp    8028ad <fd_alloc+0x72>
  802893:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802898:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80289d:	75 b6                	jne    802855 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80289f:	8b 45 08             	mov    0x8(%ebp),%eax
  8028a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8028a8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8028ad:	5d                   	pop    %ebp
  8028ae:	c3                   	ret    

008028af <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8028af:	55                   	push   %ebp
  8028b0:	89 e5                	mov    %esp,%ebp
  8028b2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8028b5:	83 f8 1f             	cmp    $0x1f,%eax
  8028b8:	77 36                	ja     8028f0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8028ba:	c1 e0 0c             	shl    $0xc,%eax
  8028bd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8028c2:	89 c2                	mov    %eax,%edx
  8028c4:	c1 ea 16             	shr    $0x16,%edx
  8028c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028ce:	f6 c2 01             	test   $0x1,%dl
  8028d1:	74 24                	je     8028f7 <fd_lookup+0x48>
  8028d3:	89 c2                	mov    %eax,%edx
  8028d5:	c1 ea 0c             	shr    $0xc,%edx
  8028d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8028df:	f6 c2 01             	test   $0x1,%dl
  8028e2:	74 1a                	je     8028fe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8028e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028e7:	89 02                	mov    %eax,(%edx)
	return 0;
  8028e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8028ee:	eb 13                	jmp    802903 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8028f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8028f5:	eb 0c                	jmp    802903 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8028f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8028fc:	eb 05                	jmp    802903 <fd_lookup+0x54>
  8028fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802903:	5d                   	pop    %ebp
  802904:	c3                   	ret    

00802905 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802905:	55                   	push   %ebp
  802906:	89 e5                	mov    %esp,%ebp
  802908:	83 ec 18             	sub    $0x18,%esp
  80290b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80290e:	39 05 64 80 80 00    	cmp    %eax,0x808064
  802914:	75 10                	jne    802926 <dev_lookup+0x21>
			*dev = devtab[i];
  802916:	8b 45 0c             	mov    0xc(%ebp),%eax
  802919:	c7 00 64 80 80 00    	movl   $0x808064,(%eax)
			return 0;
  80291f:	b8 00 00 00 00       	mov    $0x0,%eax
  802924:	eb 2b                	jmp    802951 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802926:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  80292c:	8b 52 48             	mov    0x48(%edx),%edx
  80292f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802933:	89 54 24 04          	mov    %edx,0x4(%esp)
  802937:	c7 04 24 54 3c 80 00 	movl   $0x803c54,(%esp)
  80293e:	e8 50 ee ff ff       	call   801793 <cprintf>
	*dev = 0;
  802943:	8b 55 0c             	mov    0xc(%ebp),%edx
  802946:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80294c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802951:	c9                   	leave  
  802952:	c3                   	ret    

00802953 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802953:	55                   	push   %ebp
  802954:	89 e5                	mov    %esp,%ebp
  802956:	83 ec 38             	sub    $0x38,%esp
  802959:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80295c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80295f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802962:	8b 7d 08             	mov    0x8(%ebp),%edi
  802965:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802968:	89 3c 24             	mov    %edi,(%esp)
  80296b:	e8 a0 fe ff ff       	call   802810 <fd2num>
  802970:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  802973:	89 54 24 04          	mov    %edx,0x4(%esp)
  802977:	89 04 24             	mov    %eax,(%esp)
  80297a:	e8 30 ff ff ff       	call   8028af <fd_lookup>
  80297f:	89 c3                	mov    %eax,%ebx
  802981:	85 c0                	test   %eax,%eax
  802983:	78 05                	js     80298a <fd_close+0x37>
	    || fd != fd2)
  802985:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  802988:	74 0c                	je     802996 <fd_close+0x43>
		return (must_exist ? r : 0);
  80298a:	85 f6                	test   %esi,%esi
  80298c:	b8 00 00 00 00       	mov    $0x0,%eax
  802991:	0f 44 d8             	cmove  %eax,%ebx
  802994:	eb 3d                	jmp    8029d3 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802996:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802999:	89 44 24 04          	mov    %eax,0x4(%esp)
  80299d:	8b 07                	mov    (%edi),%eax
  80299f:	89 04 24             	mov    %eax,(%esp)
  8029a2:	e8 5e ff ff ff       	call   802905 <dev_lookup>
  8029a7:	89 c3                	mov    %eax,%ebx
  8029a9:	85 c0                	test   %eax,%eax
  8029ab:	78 16                	js     8029c3 <fd_close+0x70>
		if (dev->dev_close)
  8029ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8029b0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8029b3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8029b8:	85 c0                	test   %eax,%eax
  8029ba:	74 07                	je     8029c3 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  8029bc:	89 3c 24             	mov    %edi,(%esp)
  8029bf:	ff d0                	call   *%eax
  8029c1:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8029c3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8029c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029ce:	e8 55 fa ff ff       	call   802428 <sys_page_unmap>
	return r;
}
  8029d3:	89 d8                	mov    %ebx,%eax
  8029d5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8029d8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8029db:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8029de:	89 ec                	mov    %ebp,%esp
  8029e0:	5d                   	pop    %ebp
  8029e1:	c3                   	ret    

008029e2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8029e2:	55                   	push   %ebp
  8029e3:	89 e5                	mov    %esp,%ebp
  8029e5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8029e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8029f2:	89 04 24             	mov    %eax,(%esp)
  8029f5:	e8 b5 fe ff ff       	call   8028af <fd_lookup>
  8029fa:	85 c0                	test   %eax,%eax
  8029fc:	78 13                	js     802a11 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8029fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802a05:	00 
  802a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a09:	89 04 24             	mov    %eax,(%esp)
  802a0c:	e8 42 ff ff ff       	call   802953 <fd_close>
}
  802a11:	c9                   	leave  
  802a12:	c3                   	ret    

00802a13 <close_all>:

void
close_all(void)
{
  802a13:	55                   	push   %ebp
  802a14:	89 e5                	mov    %esp,%ebp
  802a16:	53                   	push   %ebx
  802a17:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802a1a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802a1f:	89 1c 24             	mov    %ebx,(%esp)
  802a22:	e8 bb ff ff ff       	call   8029e2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802a27:	83 c3 01             	add    $0x1,%ebx
  802a2a:	83 fb 20             	cmp    $0x20,%ebx
  802a2d:	75 f0                	jne    802a1f <close_all+0xc>
		close(i);
}
  802a2f:	83 c4 14             	add    $0x14,%esp
  802a32:	5b                   	pop    %ebx
  802a33:	5d                   	pop    %ebp
  802a34:	c3                   	ret    

00802a35 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802a35:	55                   	push   %ebp
  802a36:	89 e5                	mov    %esp,%ebp
  802a38:	83 ec 58             	sub    $0x58,%esp
  802a3b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802a3e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802a41:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802a44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802a47:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802a4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  802a51:	89 04 24             	mov    %eax,(%esp)
  802a54:	e8 56 fe ff ff       	call   8028af <fd_lookup>
  802a59:	85 c0                	test   %eax,%eax
  802a5b:	0f 88 e3 00 00 00    	js     802b44 <dup+0x10f>
		return r;
	close(newfdnum);
  802a61:	89 1c 24             	mov    %ebx,(%esp)
  802a64:	e8 79 ff ff ff       	call   8029e2 <close>

	newfd = INDEX2FD(newfdnum);
  802a69:	89 de                	mov    %ebx,%esi
  802a6b:	c1 e6 0c             	shl    $0xc,%esi
  802a6e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  802a74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a77:	89 04 24             	mov    %eax,(%esp)
  802a7a:	e8 a1 fd ff ff       	call   802820 <fd2data>
  802a7f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802a81:	89 34 24             	mov    %esi,(%esp)
  802a84:	e8 97 fd ff ff       	call   802820 <fd2data>
  802a89:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  802a8c:	89 f8                	mov    %edi,%eax
  802a8e:	c1 e8 16             	shr    $0x16,%eax
  802a91:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802a98:	a8 01                	test   $0x1,%al
  802a9a:	74 46                	je     802ae2 <dup+0xad>
  802a9c:	89 f8                	mov    %edi,%eax
  802a9e:	c1 e8 0c             	shr    $0xc,%eax
  802aa1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802aa8:	f6 c2 01             	test   $0x1,%dl
  802aab:	74 35                	je     802ae2 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802aad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802ab4:	25 07 0e 00 00       	and    $0xe07,%eax
  802ab9:	89 44 24 10          	mov    %eax,0x10(%esp)
  802abd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802ac0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ac4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802acb:	00 
  802acc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802ad0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ad7:	e8 e5 f8 ff ff       	call   8023c1 <sys_page_map>
  802adc:	89 c7                	mov    %eax,%edi
  802ade:	85 c0                	test   %eax,%eax
  802ae0:	78 3b                	js     802b1d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802ae2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ae5:	89 c2                	mov    %eax,%edx
  802ae7:	c1 ea 0c             	shr    $0xc,%edx
  802aea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802af1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802af7:	89 54 24 10          	mov    %edx,0x10(%esp)
  802afb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802aff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802b06:	00 
  802b07:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b12:	e8 aa f8 ff ff       	call   8023c1 <sys_page_map>
  802b17:	89 c7                	mov    %eax,%edi
  802b19:	85 c0                	test   %eax,%eax
  802b1b:	79 29                	jns    802b46 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802b1d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b28:	e8 fb f8 ff ff       	call   802428 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802b2d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802b30:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b3b:	e8 e8 f8 ff ff       	call   802428 <sys_page_unmap>
	return r;
  802b40:	89 fb                	mov    %edi,%ebx
  802b42:	eb 02                	jmp    802b46 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  802b44:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802b46:	89 d8                	mov    %ebx,%eax
  802b48:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802b4b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802b4e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802b51:	89 ec                	mov    %ebp,%esp
  802b53:	5d                   	pop    %ebp
  802b54:	c3                   	ret    

00802b55 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802b55:	55                   	push   %ebp
  802b56:	89 e5                	mov    %esp,%ebp
  802b58:	53                   	push   %ebx
  802b59:	83 ec 24             	sub    $0x24,%esp
  802b5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b62:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b66:	89 1c 24             	mov    %ebx,(%esp)
  802b69:	e8 41 fd ff ff       	call   8028af <fd_lookup>
  802b6e:	85 c0                	test   %eax,%eax
  802b70:	78 6d                	js     802bdf <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b75:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b7c:	8b 00                	mov    (%eax),%eax
  802b7e:	89 04 24             	mov    %eax,(%esp)
  802b81:	e8 7f fd ff ff       	call   802905 <dev_lookup>
  802b86:	85 c0                	test   %eax,%eax
  802b88:	78 55                	js     802bdf <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b8d:	8b 50 08             	mov    0x8(%eax),%edx
  802b90:	83 e2 03             	and    $0x3,%edx
  802b93:	83 fa 01             	cmp    $0x1,%edx
  802b96:	75 23                	jne    802bbb <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802b98:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802b9d:	8b 40 48             	mov    0x48(%eax),%eax
  802ba0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ba8:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  802baf:	e8 df eb ff ff       	call   801793 <cprintf>
		return -E_INVAL;
  802bb4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802bb9:	eb 24                	jmp    802bdf <read+0x8a>
	}
	if (!dev->dev_read)
  802bbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802bbe:	8b 52 08             	mov    0x8(%edx),%edx
  802bc1:	85 d2                	test   %edx,%edx
  802bc3:	74 15                	je     802bda <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802bc5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802bc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802bcf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802bd3:	89 04 24             	mov    %eax,(%esp)
  802bd6:	ff d2                	call   *%edx
  802bd8:	eb 05                	jmp    802bdf <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802bda:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  802bdf:	83 c4 24             	add    $0x24,%esp
  802be2:	5b                   	pop    %ebx
  802be3:	5d                   	pop    %ebp
  802be4:	c3                   	ret    

00802be5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802be5:	55                   	push   %ebp
  802be6:	89 e5                	mov    %esp,%ebp
  802be8:	57                   	push   %edi
  802be9:	56                   	push   %esi
  802bea:	53                   	push   %ebx
  802beb:	83 ec 1c             	sub    $0x1c,%esp
  802bee:	8b 7d 08             	mov    0x8(%ebp),%edi
  802bf1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802bf4:	85 f6                	test   %esi,%esi
  802bf6:	74 33                	je     802c2b <readn+0x46>
  802bf8:	b8 00 00 00 00       	mov    $0x0,%eax
  802bfd:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  802c02:	89 f2                	mov    %esi,%edx
  802c04:	29 c2                	sub    %eax,%edx
  802c06:	89 54 24 08          	mov    %edx,0x8(%esp)
  802c0a:	03 45 0c             	add    0xc(%ebp),%eax
  802c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c11:	89 3c 24             	mov    %edi,(%esp)
  802c14:	e8 3c ff ff ff       	call   802b55 <read>
		if (m < 0)
  802c19:	85 c0                	test   %eax,%eax
  802c1b:	78 17                	js     802c34 <readn+0x4f>
			return m;
		if (m == 0)
  802c1d:	85 c0                	test   %eax,%eax
  802c1f:	74 11                	je     802c32 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c21:	01 c3                	add    %eax,%ebx
  802c23:	89 d8                	mov    %ebx,%eax
  802c25:	39 f3                	cmp    %esi,%ebx
  802c27:	72 d9                	jb     802c02 <readn+0x1d>
  802c29:	eb 09                	jmp    802c34 <readn+0x4f>
  802c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  802c30:	eb 02                	jmp    802c34 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  802c32:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  802c34:	83 c4 1c             	add    $0x1c,%esp
  802c37:	5b                   	pop    %ebx
  802c38:	5e                   	pop    %esi
  802c39:	5f                   	pop    %edi
  802c3a:	5d                   	pop    %ebp
  802c3b:	c3                   	ret    

00802c3c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802c3c:	55                   	push   %ebp
  802c3d:	89 e5                	mov    %esp,%ebp
  802c3f:	53                   	push   %ebx
  802c40:	83 ec 24             	sub    $0x24,%esp
  802c43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c49:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c4d:	89 1c 24             	mov    %ebx,(%esp)
  802c50:	e8 5a fc ff ff       	call   8028af <fd_lookup>
  802c55:	85 c0                	test   %eax,%eax
  802c57:	78 68                	js     802cc1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c63:	8b 00                	mov    (%eax),%eax
  802c65:	89 04 24             	mov    %eax,(%esp)
  802c68:	e8 98 fc ff ff       	call   802905 <dev_lookup>
  802c6d:	85 c0                	test   %eax,%eax
  802c6f:	78 50                	js     802cc1 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c74:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802c78:	75 23                	jne    802c9d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802c7a:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802c7f:	8b 40 48             	mov    0x48(%eax),%eax
  802c82:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c86:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c8a:	c7 04 24 b4 3c 80 00 	movl   $0x803cb4,(%esp)
  802c91:	e8 fd ea ff ff       	call   801793 <cprintf>
		return -E_INVAL;
  802c96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802c9b:	eb 24                	jmp    802cc1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802c9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802ca0:	8b 52 0c             	mov    0xc(%edx),%edx
  802ca3:	85 d2                	test   %edx,%edx
  802ca5:	74 15                	je     802cbc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802ca7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802caa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802cb1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802cb5:	89 04 24             	mov    %eax,(%esp)
  802cb8:	ff d2                	call   *%edx
  802cba:	eb 05                	jmp    802cc1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802cbc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  802cc1:	83 c4 24             	add    $0x24,%esp
  802cc4:	5b                   	pop    %ebx
  802cc5:	5d                   	pop    %ebp
  802cc6:	c3                   	ret    

00802cc7 <seek>:

int
seek(int fdnum, off_t offset)
{
  802cc7:	55                   	push   %ebp
  802cc8:	89 e5                	mov    %esp,%ebp
  802cca:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802ccd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  802cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  802cd7:	89 04 24             	mov    %eax,(%esp)
  802cda:	e8 d0 fb ff ff       	call   8028af <fd_lookup>
  802cdf:	85 c0                	test   %eax,%eax
  802ce1:	78 0e                	js     802cf1 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  802ce3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802ce6:	8b 55 0c             	mov    0xc(%ebp),%edx
  802ce9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802cec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802cf1:	c9                   	leave  
  802cf2:	c3                   	ret    

00802cf3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802cf3:	55                   	push   %ebp
  802cf4:	89 e5                	mov    %esp,%ebp
  802cf6:	53                   	push   %ebx
  802cf7:	83 ec 24             	sub    $0x24,%esp
  802cfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802cfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d00:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d04:	89 1c 24             	mov    %ebx,(%esp)
  802d07:	e8 a3 fb ff ff       	call   8028af <fd_lookup>
  802d0c:	85 c0                	test   %eax,%eax
  802d0e:	78 61                	js     802d71 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d13:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d1a:	8b 00                	mov    (%eax),%eax
  802d1c:	89 04 24             	mov    %eax,(%esp)
  802d1f:	e8 e1 fb ff ff       	call   802905 <dev_lookup>
  802d24:	85 c0                	test   %eax,%eax
  802d26:	78 49                	js     802d71 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d2b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802d2f:	75 23                	jne    802d54 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802d31:	a1 0c 90 80 00       	mov    0x80900c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802d36:	8b 40 48             	mov    0x48(%eax),%eax
  802d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d41:	c7 04 24 74 3c 80 00 	movl   $0x803c74,(%esp)
  802d48:	e8 46 ea ff ff       	call   801793 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802d4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d52:	eb 1d                	jmp    802d71 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  802d54:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d57:	8b 52 18             	mov    0x18(%edx),%edx
  802d5a:	85 d2                	test   %edx,%edx
  802d5c:	74 0e                	je     802d6c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d61:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802d65:	89 04 24             	mov    %eax,(%esp)
  802d68:	ff d2                	call   *%edx
  802d6a:	eb 05                	jmp    802d71 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802d6c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  802d71:	83 c4 24             	add    $0x24,%esp
  802d74:	5b                   	pop    %ebx
  802d75:	5d                   	pop    %ebp
  802d76:	c3                   	ret    

00802d77 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802d77:	55                   	push   %ebp
  802d78:	89 e5                	mov    %esp,%ebp
  802d7a:	53                   	push   %ebx
  802d7b:	83 ec 24             	sub    $0x24,%esp
  802d7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d81:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d84:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d88:	8b 45 08             	mov    0x8(%ebp),%eax
  802d8b:	89 04 24             	mov    %eax,(%esp)
  802d8e:	e8 1c fb ff ff       	call   8028af <fd_lookup>
  802d93:	85 c0                	test   %eax,%eax
  802d95:	78 52                	js     802de9 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802da1:	8b 00                	mov    (%eax),%eax
  802da3:	89 04 24             	mov    %eax,(%esp)
  802da6:	e8 5a fb ff ff       	call   802905 <dev_lookup>
  802dab:	85 c0                	test   %eax,%eax
  802dad:	78 3a                	js     802de9 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  802daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802db2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802db6:	74 2c                	je     802de4 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802db8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802dbb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802dc2:	00 00 00 
	stat->st_isdir = 0;
  802dc5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802dcc:	00 00 00 
	stat->st_dev = dev;
  802dcf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802dd5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802dd9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802ddc:	89 14 24             	mov    %edx,(%esp)
  802ddf:	ff 50 14             	call   *0x14(%eax)
  802de2:	eb 05                	jmp    802de9 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802de4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802de9:	83 c4 24             	add    $0x24,%esp
  802dec:	5b                   	pop    %ebx
  802ded:	5d                   	pop    %ebp
  802dee:	c3                   	ret    

00802def <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802def:	55                   	push   %ebp
  802df0:	89 e5                	mov    %esp,%ebp
  802df2:	83 ec 18             	sub    $0x18,%esp
  802df5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802df8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802dfb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802e02:	00 
  802e03:	8b 45 08             	mov    0x8(%ebp),%eax
  802e06:	89 04 24             	mov    %eax,(%esp)
  802e09:	e8 84 01 00 00       	call   802f92 <open>
  802e0e:	89 c3                	mov    %eax,%ebx
  802e10:	85 c0                	test   %eax,%eax
  802e12:	78 1b                	js     802e2f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  802e14:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e17:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e1b:	89 1c 24             	mov    %ebx,(%esp)
  802e1e:	e8 54 ff ff ff       	call   802d77 <fstat>
  802e23:	89 c6                	mov    %eax,%esi
	close(fd);
  802e25:	89 1c 24             	mov    %ebx,(%esp)
  802e28:	e8 b5 fb ff ff       	call   8029e2 <close>
	return r;
  802e2d:	89 f3                	mov    %esi,%ebx
}
  802e2f:	89 d8                	mov    %ebx,%eax
  802e31:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802e34:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802e37:	89 ec                	mov    %ebp,%esp
  802e39:	5d                   	pop    %ebp
  802e3a:	c3                   	ret    
  802e3b:	90                   	nop

00802e3c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802e3c:	55                   	push   %ebp
  802e3d:	89 e5                	mov    %esp,%ebp
  802e3f:	83 ec 18             	sub    $0x18,%esp
  802e42:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802e45:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802e48:	89 c6                	mov    %eax,%esi
  802e4a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802e4c:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  802e53:	75 11                	jne    802e66 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802e55:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  802e5c:	e8 62 f9 ff ff       	call   8027c3 <ipc_find_env>
  802e61:	a3 00 90 80 00       	mov    %eax,0x809000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802e66:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802e6d:	00 
  802e6e:	c7 44 24 08 00 a0 80 	movl   $0x80a000,0x8(%esp)
  802e75:	00 
  802e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  802e7a:	a1 00 90 80 00       	mov    0x809000,%eax
  802e7f:	89 04 24             	mov    %eax,(%esp)
  802e82:	e8 d1 f8 ff ff       	call   802758 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802e87:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802e8e:	00 
  802e8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802e93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e9a:	e8 61 f8 ff ff       	call   802700 <ipc_recv>
}
  802e9f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802ea2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802ea5:	89 ec                	mov    %ebp,%esp
  802ea7:	5d                   	pop    %ebp
  802ea8:	c3                   	ret    

00802ea9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802ea9:	55                   	push   %ebp
  802eaa:	89 e5                	mov    %esp,%ebp
  802eac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  802eb2:	8b 40 0c             	mov    0xc(%eax),%eax
  802eb5:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.set_size.req_size = newsize;
  802eba:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ebd:	a3 04 a0 80 00       	mov    %eax,0x80a004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802ec2:	ba 00 00 00 00       	mov    $0x0,%edx
  802ec7:	b8 02 00 00 00       	mov    $0x2,%eax
  802ecc:	e8 6b ff ff ff       	call   802e3c <fsipc>
}
  802ed1:	c9                   	leave  
  802ed2:	c3                   	ret    

00802ed3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802ed3:	55                   	push   %ebp
  802ed4:	89 e5                	mov    %esp,%ebp
  802ed6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802ed9:	8b 45 08             	mov    0x8(%ebp),%eax
  802edc:	8b 40 0c             	mov    0xc(%eax),%eax
  802edf:	a3 00 a0 80 00       	mov    %eax,0x80a000
	return fsipc(FSREQ_FLUSH, NULL);
  802ee4:	ba 00 00 00 00       	mov    $0x0,%edx
  802ee9:	b8 06 00 00 00       	mov    $0x6,%eax
  802eee:	e8 49 ff ff ff       	call   802e3c <fsipc>
}
  802ef3:	c9                   	leave  
  802ef4:	c3                   	ret    

00802ef5 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802ef5:	55                   	push   %ebp
  802ef6:	89 e5                	mov    %esp,%ebp
  802ef8:	53                   	push   %ebx
  802ef9:	83 ec 14             	sub    $0x14,%esp
  802efc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802eff:	8b 45 08             	mov    0x8(%ebp),%eax
  802f02:	8b 40 0c             	mov    0xc(%eax),%eax
  802f05:	a3 00 a0 80 00       	mov    %eax,0x80a000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802f0a:	ba 00 00 00 00       	mov    $0x0,%edx
  802f0f:	b8 05 00 00 00       	mov    $0x5,%eax
  802f14:	e8 23 ff ff ff       	call   802e3c <fsipc>
  802f19:	85 c0                	test   %eax,%eax
  802f1b:	78 2b                	js     802f48 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802f1d:	c7 44 24 04 00 a0 80 	movl   $0x80a000,0x4(%esp)
  802f24:	00 
  802f25:	89 1c 24             	mov    %ebx,(%esp)
  802f28:	e8 de ee ff ff       	call   801e0b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802f2d:	a1 80 a0 80 00       	mov    0x80a080,%eax
  802f32:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802f38:	a1 84 a0 80 00       	mov    0x80a084,%eax
  802f3d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802f43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f48:	83 c4 14             	add    $0x14,%esp
  802f4b:	5b                   	pop    %ebx
  802f4c:	5d                   	pop    %ebp
  802f4d:	c3                   	ret    

00802f4e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802f4e:	55                   	push   %ebp
  802f4f:	89 e5                	mov    %esp,%ebp
  802f51:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  802f54:	c7 44 24 08 d1 3c 80 	movl   $0x803cd1,0x8(%esp)
  802f5b:	00 
  802f5c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  802f63:	00 
  802f64:	c7 04 24 ef 3c 80 00 	movl   $0x803cef,(%esp)
  802f6b:	e8 28 e7 ff ff       	call   801698 <_panic>

00802f70 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802f70:	55                   	push   %ebp
  802f71:	89 e5                	mov    %esp,%ebp
  802f73:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  802f76:	c7 44 24 08 fa 3c 80 	movl   $0x803cfa,0x8(%esp)
  802f7d:	00 
  802f7e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  802f85:	00 
  802f86:	c7 04 24 ef 3c 80 00 	movl   $0x803cef,(%esp)
  802f8d:	e8 06 e7 ff ff       	call   801698 <_panic>

00802f92 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802f92:	55                   	push   %ebp
  802f93:	89 e5                	mov    %esp,%ebp
  802f95:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  802f98:	c7 44 24 08 17 3d 80 	movl   $0x803d17,0x8(%esp)
  802f9f:	00 
  802fa0:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  802fa7:	00 
  802fa8:	c7 04 24 ef 3c 80 00 	movl   $0x803cef,(%esp)
  802faf:	e8 e4 e6 ff ff       	call   801698 <_panic>

00802fb4 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802fb4:	55                   	push   %ebp
  802fb5:	89 e5                	mov    %esp,%ebp
  802fb7:	53                   	push   %ebx
  802fb8:	83 ec 14             	sub    $0x14,%esp
  802fbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  802fbe:	89 1c 24             	mov    %ebx,(%esp)
  802fc1:	e8 ea ed ff ff       	call   801db0 <strlen>
  802fc6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802fcb:	7f 21                	jg     802fee <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802fcd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802fd1:	c7 04 24 00 a0 80 00 	movl   $0x80a000,(%esp)
  802fd8:	e8 2e ee ff ff       	call   801e0b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802fdd:	ba 00 00 00 00       	mov    $0x0,%edx
  802fe2:	b8 07 00 00 00       	mov    $0x7,%eax
  802fe7:	e8 50 fe ff ff       	call   802e3c <fsipc>
  802fec:	eb 05                	jmp    802ff3 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802fee:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  802ff3:	83 c4 14             	add    $0x14,%esp
  802ff6:	5b                   	pop    %ebx
  802ff7:	5d                   	pop    %ebp
  802ff8:	c3                   	ret    

00802ff9 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  802ff9:	55                   	push   %ebp
  802ffa:	89 e5                	mov    %esp,%ebp
  802ffc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802fff:	ba 00 00 00 00       	mov    $0x0,%edx
  803004:	b8 08 00 00 00       	mov    $0x8,%eax
  803009:	e8 2e fe ff ff       	call   802e3c <fsipc>
}
  80300e:	c9                   	leave  
  80300f:	c3                   	ret    

00803010 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803010:	55                   	push   %ebp
  803011:	89 e5                	mov    %esp,%ebp
  803013:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  803016:	89 d0                	mov    %edx,%eax
  803018:	c1 e8 16             	shr    $0x16,%eax
  80301b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803022:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  803027:	f6 c1 01             	test   $0x1,%cl
  80302a:	74 1d                	je     803049 <pageref+0x39>
		return 0;
	pte = vpt[PGNUM(v)];
  80302c:	c1 ea 0c             	shr    $0xc,%edx
  80302f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803036:	f6 c2 01             	test   $0x1,%dl
  803039:	74 0e                	je     803049 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80303b:	c1 ea 0c             	shr    $0xc,%edx
  80303e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803045:	ef 
  803046:	0f b7 c0             	movzwl %ax,%eax
}
  803049:	5d                   	pop    %ebp
  80304a:	c3                   	ret    
  80304b:	66 90                	xchg   %ax,%ax
  80304d:	66 90                	xchg   %ax,%ax
  80304f:	90                   	nop

00803050 <__udivdi3>:
  803050:	83 ec 1c             	sub    $0x1c,%esp
  803053:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  803057:	89 7c 24 14          	mov    %edi,0x14(%esp)
  80305b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80305f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  803063:	8b 7c 24 20          	mov    0x20(%esp),%edi
  803067:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  80306b:	85 c0                	test   %eax,%eax
  80306d:	89 74 24 10          	mov    %esi,0x10(%esp)
  803071:	89 7c 24 08          	mov    %edi,0x8(%esp)
  803075:	89 ea                	mov    %ebp,%edx
  803077:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80307b:	75 33                	jne    8030b0 <__udivdi3+0x60>
  80307d:	39 e9                	cmp    %ebp,%ecx
  80307f:	77 6f                	ja     8030f0 <__udivdi3+0xa0>
  803081:	85 c9                	test   %ecx,%ecx
  803083:	89 ce                	mov    %ecx,%esi
  803085:	75 0b                	jne    803092 <__udivdi3+0x42>
  803087:	b8 01 00 00 00       	mov    $0x1,%eax
  80308c:	31 d2                	xor    %edx,%edx
  80308e:	f7 f1                	div    %ecx
  803090:	89 c6                	mov    %eax,%esi
  803092:	31 d2                	xor    %edx,%edx
  803094:	89 e8                	mov    %ebp,%eax
  803096:	f7 f6                	div    %esi
  803098:	89 c5                	mov    %eax,%ebp
  80309a:	89 f8                	mov    %edi,%eax
  80309c:	f7 f6                	div    %esi
  80309e:	89 ea                	mov    %ebp,%edx
  8030a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8030a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8030a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8030ac:	83 c4 1c             	add    $0x1c,%esp
  8030af:	c3                   	ret    
  8030b0:	39 e8                	cmp    %ebp,%eax
  8030b2:	77 24                	ja     8030d8 <__udivdi3+0x88>
  8030b4:	0f bd c8             	bsr    %eax,%ecx
  8030b7:	83 f1 1f             	xor    $0x1f,%ecx
  8030ba:	89 0c 24             	mov    %ecx,(%esp)
  8030bd:	75 49                	jne    803108 <__udivdi3+0xb8>
  8030bf:	8b 74 24 08          	mov    0x8(%esp),%esi
  8030c3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  8030c7:	0f 86 ab 00 00 00    	jbe    803178 <__udivdi3+0x128>
  8030cd:	39 e8                	cmp    %ebp,%eax
  8030cf:	0f 82 a3 00 00 00    	jb     803178 <__udivdi3+0x128>
  8030d5:	8d 76 00             	lea    0x0(%esi),%esi
  8030d8:	31 d2                	xor    %edx,%edx
  8030da:	31 c0                	xor    %eax,%eax
  8030dc:	8b 74 24 10          	mov    0x10(%esp),%esi
  8030e0:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8030e4:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8030e8:	83 c4 1c             	add    $0x1c,%esp
  8030eb:	c3                   	ret    
  8030ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8030f0:	89 f8                	mov    %edi,%eax
  8030f2:	f7 f1                	div    %ecx
  8030f4:	31 d2                	xor    %edx,%edx
  8030f6:	8b 74 24 10          	mov    0x10(%esp),%esi
  8030fa:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8030fe:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  803102:	83 c4 1c             	add    $0x1c,%esp
  803105:	c3                   	ret    
  803106:	66 90                	xchg   %ax,%ax
  803108:	0f b6 0c 24          	movzbl (%esp),%ecx
  80310c:	89 c6                	mov    %eax,%esi
  80310e:	b8 20 00 00 00       	mov    $0x20,%eax
  803113:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  803117:	2b 04 24             	sub    (%esp),%eax
  80311a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80311e:	d3 e6                	shl    %cl,%esi
  803120:	89 c1                	mov    %eax,%ecx
  803122:	d3 ed                	shr    %cl,%ebp
  803124:	0f b6 0c 24          	movzbl (%esp),%ecx
  803128:	09 f5                	or     %esi,%ebp
  80312a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80312e:	d3 e6                	shl    %cl,%esi
  803130:	89 c1                	mov    %eax,%ecx
  803132:	89 74 24 04          	mov    %esi,0x4(%esp)
  803136:	89 d6                	mov    %edx,%esi
  803138:	d3 ee                	shr    %cl,%esi
  80313a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80313e:	d3 e2                	shl    %cl,%edx
  803140:	89 c1                	mov    %eax,%ecx
  803142:	d3 ef                	shr    %cl,%edi
  803144:	09 d7                	or     %edx,%edi
  803146:	89 f2                	mov    %esi,%edx
  803148:	89 f8                	mov    %edi,%eax
  80314a:	f7 f5                	div    %ebp
  80314c:	89 d6                	mov    %edx,%esi
  80314e:	89 c7                	mov    %eax,%edi
  803150:	f7 64 24 04          	mull   0x4(%esp)
  803154:	39 d6                	cmp    %edx,%esi
  803156:	72 30                	jb     803188 <__udivdi3+0x138>
  803158:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  80315c:	0f b6 0c 24          	movzbl (%esp),%ecx
  803160:	d3 e5                	shl    %cl,%ebp
  803162:	39 c5                	cmp    %eax,%ebp
  803164:	73 04                	jae    80316a <__udivdi3+0x11a>
  803166:	39 d6                	cmp    %edx,%esi
  803168:	74 1e                	je     803188 <__udivdi3+0x138>
  80316a:	89 f8                	mov    %edi,%eax
  80316c:	31 d2                	xor    %edx,%edx
  80316e:	e9 69 ff ff ff       	jmp    8030dc <__udivdi3+0x8c>
  803173:	90                   	nop
  803174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803178:	31 d2                	xor    %edx,%edx
  80317a:	b8 01 00 00 00       	mov    $0x1,%eax
  80317f:	e9 58 ff ff ff       	jmp    8030dc <__udivdi3+0x8c>
  803184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803188:	8d 47 ff             	lea    -0x1(%edi),%eax
  80318b:	31 d2                	xor    %edx,%edx
  80318d:	8b 74 24 10          	mov    0x10(%esp),%esi
  803191:	8b 7c 24 14          	mov    0x14(%esp),%edi
  803195:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  803199:	83 c4 1c             	add    $0x1c,%esp
  80319c:	c3                   	ret    
  80319d:	66 90                	xchg   %ax,%ax
  80319f:	90                   	nop

008031a0 <__umoddi3>:
  8031a0:	83 ec 2c             	sub    $0x2c,%esp
  8031a3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8031a7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8031ab:	89 74 24 20          	mov    %esi,0x20(%esp)
  8031af:	8b 74 24 38          	mov    0x38(%esp),%esi
  8031b3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  8031b7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  8031bb:	85 c0                	test   %eax,%eax
  8031bd:	89 c2                	mov    %eax,%edx
  8031bf:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  8031c3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8031c7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8031cb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8031cf:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8031d3:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8031d7:	75 1f                	jne    8031f8 <__umoddi3+0x58>
  8031d9:	39 fe                	cmp    %edi,%esi
  8031db:	76 63                	jbe    803240 <__umoddi3+0xa0>
  8031dd:	89 c8                	mov    %ecx,%eax
  8031df:	89 fa                	mov    %edi,%edx
  8031e1:	f7 f6                	div    %esi
  8031e3:	89 d0                	mov    %edx,%eax
  8031e5:	31 d2                	xor    %edx,%edx
  8031e7:	8b 74 24 20          	mov    0x20(%esp),%esi
  8031eb:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8031ef:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8031f3:	83 c4 2c             	add    $0x2c,%esp
  8031f6:	c3                   	ret    
  8031f7:	90                   	nop
  8031f8:	39 f8                	cmp    %edi,%eax
  8031fa:	77 64                	ja     803260 <__umoddi3+0xc0>
  8031fc:	0f bd e8             	bsr    %eax,%ebp
  8031ff:	83 f5 1f             	xor    $0x1f,%ebp
  803202:	75 74                	jne    803278 <__umoddi3+0xd8>
  803204:	8b 7c 24 14          	mov    0x14(%esp),%edi
  803208:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80320c:	0f 87 0e 01 00 00    	ja     803320 <__umoddi3+0x180>
  803212:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  803216:	29 f1                	sub    %esi,%ecx
  803218:	19 c7                	sbb    %eax,%edi
  80321a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80321e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  803222:	8b 44 24 14          	mov    0x14(%esp),%eax
  803226:	8b 54 24 18          	mov    0x18(%esp),%edx
  80322a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80322e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  803232:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  803236:	83 c4 2c             	add    $0x2c,%esp
  803239:	c3                   	ret    
  80323a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803240:	85 f6                	test   %esi,%esi
  803242:	89 f5                	mov    %esi,%ebp
  803244:	75 0b                	jne    803251 <__umoddi3+0xb1>
  803246:	b8 01 00 00 00       	mov    $0x1,%eax
  80324b:	31 d2                	xor    %edx,%edx
  80324d:	f7 f6                	div    %esi
  80324f:	89 c5                	mov    %eax,%ebp
  803251:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803255:	31 d2                	xor    %edx,%edx
  803257:	f7 f5                	div    %ebp
  803259:	89 c8                	mov    %ecx,%eax
  80325b:	f7 f5                	div    %ebp
  80325d:	eb 84                	jmp    8031e3 <__umoddi3+0x43>
  80325f:	90                   	nop
  803260:	89 c8                	mov    %ecx,%eax
  803262:	89 fa                	mov    %edi,%edx
  803264:	8b 74 24 20          	mov    0x20(%esp),%esi
  803268:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80326c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  803270:	83 c4 2c             	add    $0x2c,%esp
  803273:	c3                   	ret    
  803274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803278:	8b 44 24 10          	mov    0x10(%esp),%eax
  80327c:	be 20 00 00 00       	mov    $0x20,%esi
  803281:	89 e9                	mov    %ebp,%ecx
  803283:	29 ee                	sub    %ebp,%esi
  803285:	d3 e2                	shl    %cl,%edx
  803287:	89 f1                	mov    %esi,%ecx
  803289:	d3 e8                	shr    %cl,%eax
  80328b:	89 e9                	mov    %ebp,%ecx
  80328d:	09 d0                	or     %edx,%eax
  80328f:	89 fa                	mov    %edi,%edx
  803291:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803295:	8b 44 24 10          	mov    0x10(%esp),%eax
  803299:	d3 e0                	shl    %cl,%eax
  80329b:	89 f1                	mov    %esi,%ecx
  80329d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8032a1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8032a5:	d3 ea                	shr    %cl,%edx
  8032a7:	89 e9                	mov    %ebp,%ecx
  8032a9:	d3 e7                	shl    %cl,%edi
  8032ab:	89 f1                	mov    %esi,%ecx
  8032ad:	d3 e8                	shr    %cl,%eax
  8032af:	89 e9                	mov    %ebp,%ecx
  8032b1:	09 f8                	or     %edi,%eax
  8032b3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8032b7:	f7 74 24 0c          	divl   0xc(%esp)
  8032bb:	d3 e7                	shl    %cl,%edi
  8032bd:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8032c1:	89 d7                	mov    %edx,%edi
  8032c3:	f7 64 24 10          	mull   0x10(%esp)
  8032c7:	39 d7                	cmp    %edx,%edi
  8032c9:	89 c1                	mov    %eax,%ecx
  8032cb:	89 54 24 14          	mov    %edx,0x14(%esp)
  8032cf:	72 3b                	jb     80330c <__umoddi3+0x16c>
  8032d1:	39 44 24 18          	cmp    %eax,0x18(%esp)
  8032d5:	72 31                	jb     803308 <__umoddi3+0x168>
  8032d7:	8b 44 24 18          	mov    0x18(%esp),%eax
  8032db:	29 c8                	sub    %ecx,%eax
  8032dd:	19 d7                	sbb    %edx,%edi
  8032df:	89 e9                	mov    %ebp,%ecx
  8032e1:	89 fa                	mov    %edi,%edx
  8032e3:	d3 e8                	shr    %cl,%eax
  8032e5:	89 f1                	mov    %esi,%ecx
  8032e7:	d3 e2                	shl    %cl,%edx
  8032e9:	89 e9                	mov    %ebp,%ecx
  8032eb:	09 d0                	or     %edx,%eax
  8032ed:	89 fa                	mov    %edi,%edx
  8032ef:	d3 ea                	shr    %cl,%edx
  8032f1:	8b 74 24 20          	mov    0x20(%esp),%esi
  8032f5:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8032f9:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8032fd:	83 c4 2c             	add    $0x2c,%esp
  803300:	c3                   	ret    
  803301:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803308:	39 d7                	cmp    %edx,%edi
  80330a:	75 cb                	jne    8032d7 <__umoddi3+0x137>
  80330c:	8b 54 24 14          	mov    0x14(%esp),%edx
  803310:	89 c1                	mov    %eax,%ecx
  803312:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  803316:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80331a:	eb bb                	jmp    8032d7 <__umoddi3+0x137>
  80331c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803320:	3b 44 24 18          	cmp    0x18(%esp),%eax
  803324:	0f 82 e8 fe ff ff    	jb     803212 <__umoddi3+0x72>
  80332a:	e9 f3 fe ff ff       	jmp    803222 <__umoddi3+0x82>
