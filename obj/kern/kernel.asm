
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# physical addresses [0, 4MB).  This 4MB region will be suffice
	# until we set up our real page table in mem_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 f0 00 00 00       	call   f010012e <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 6e 1d f0 00 	cmpl   $0x0,0xf01d6e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 6e 1d f0    	mov    %esi,0xf01d6e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 d8 66 00 00       	call   f010673c <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 a0 6e 10 f0 	movl   $0xf0106ea0,(%esp)
f010007d:	e8 14 3f 00 00       	call   f0103f96 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 d5 3e 00 00       	call   f0103f63 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 e5 81 10 f0 	movl   $0xf01081e5,(%esp)
f0100095:	e8 fc 3e 00 00       	call   f0103f96 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 0e 09 00 00       	call   f01009b4 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000ae:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 0b 6f 10 f0 	movl   $0xf0106f0b,(%esp)
f01000d5:	e8 66 ff ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000da:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01000df:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000e2:	e8 55 66 00 00       	call   f010673c <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 17 6f 10 f0 	movl   $0xf0106f17,(%esp)
f01000f2:	e8 9f 3e 00 00       	call   f0103f96 <cprintf>

	lapic_init();
f01000f7:	e8 5b 66 00 00       	call   f0106757 <lapic_init>
	env_init_percpu();
f01000fc:	e8 a5 36 00 00       	call   f01037a6 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 aa 3e 00 00       	call   f0103fb0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 31 66 00 00       	call   f010673c <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 70 1d f0    	add    $0xf01d7020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011d:	c7 04 24 a0 23 12 f0 	movl   $0xf01223a0,(%esp)
f0100124:	e8 ac 68 00 00       	call   f01069d5 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100129:	e8 e6 4a 00 00       	call   f0104c14 <sched_yield>

f010012e <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	53                   	push   %ebx
f0100132:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100135:	b8 04 80 21 f0       	mov    $0xf0218004,%eax
f010013a:	2d 06 52 1d f0       	sub    $0xf01d5206,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 06 52 1d f0 	movl   $0xf01d5206,(%esp)
f0100152:	e8 3e 5f 00 00       	call   f0106095 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 7b 05 00 00       	call   f01006d7 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 2d 6f 10 f0 	movl   $0xf0106f2d,(%esp)
f010016b:	e8 26 3e 00 00       	call   f0103f96 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 4e 15 00 00       	call   f01016c3 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 56 36 00 00       	call   f01037d0 <env_init>
	trap_init();
f010017a:	e8 57 3f 00 00       	call   f01040d6 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	90                   	nop
f0100180:	e8 cf 62 00 00       	call   f0106454 <mp_init>
	lapic_init();
f0100185:	e8 cd 65 00 00       	call   f0106757 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010018a:	e8 34 3d 00 00       	call   f0103ec3 <pic_init>
f010018f:	c7 04 24 a0 23 12 f0 	movl   $0xf01223a0,(%esp)
f0100196:	e8 3a 68 00 00       	call   f01069d5 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010019b:	83 3d 88 6e 1d f0 07 	cmpl   $0x7,0xf01d6e88
f01001a2:	77 24                	ja     f01001c8 <i386_init+0x9a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001a4:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001ab:	00 
f01001ac:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f01001b3:	f0 
f01001b4:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
f01001bb:	00 
f01001bc:	c7 04 24 0b 6f 10 f0 	movl   $0xf0106f0b,(%esp)
f01001c3:	e8 78 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c8:	b8 6a 63 10 f0       	mov    $0xf010636a,%eax
f01001cd:	2d f0 62 10 f0       	sub    $0xf01062f0,%eax
f01001d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d6:	c7 44 24 04 f0 62 10 	movl   $0xf01062f0,0x4(%esp)
f01001dd:	f0 
f01001de:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001e5:	e8 09 5f 00 00       	call   f01060f3 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001ea:	6b 05 c4 73 1d f0 74 	imul   $0x74,0xf01d73c4,%eax
f01001f1:	05 20 70 1d f0       	add    $0xf01d7020,%eax
f01001f6:	3d 20 70 1d f0       	cmp    $0xf01d7020,%eax
f01001fb:	0f 86 c2 00 00 00    	jbe    f01002c3 <i386_init+0x195>
f0100201:	bb 20 70 1d f0       	mov    $0xf01d7020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100206:	e8 31 65 00 00       	call   f010673c <cpunum>
f010020b:	6b c0 74             	imul   $0x74,%eax,%eax
f010020e:	05 20 70 1d f0       	add    $0xf01d7020,%eax
f0100213:	39 c3                	cmp    %eax,%ebx
f0100215:	74 39                	je     f0100250 <i386_init+0x122>

static void boot_aps(void);


void
i386_init(void)
f0100217:	89 d8                	mov    %ebx,%eax
f0100219:	2d 20 70 1d f0       	sub    $0xf01d7020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010021e:	c1 f8 02             	sar    $0x2,%eax
f0100221:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100227:	c1 e0 0f             	shl    $0xf,%eax
f010022a:	8d 80 00 00 1e f0    	lea    -0xfe20000(%eax),%eax
f0100230:	a3 84 6e 1d f0       	mov    %eax,0xf01d6e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100235:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f010023c:	00 
f010023d:	0f b6 03             	movzbl (%ebx),%eax
f0100240:	89 04 24             	mov    %eax,(%esp)
f0100243:	e8 47 66 00 00       	call   f010688f <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100248:	8b 43 04             	mov    0x4(%ebx),%eax
f010024b:	83 f8 01             	cmp    $0x1,%eax
f010024e:	75 f8                	jne    f0100248 <i386_init+0x11a>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100250:	83 c3 74             	add    $0x74,%ebx
f0100253:	6b 05 c4 73 1d f0 74 	imul   $0x74,0xf01d73c4,%eax
f010025a:	05 20 70 1d f0       	add    $0xf01d7020,%eax
f010025f:	39 c3                	cmp    %eax,%ebx
f0100261:	72 a3                	jb     f0100206 <i386_init+0xd8>
f0100263:	eb 5e                	jmp    f01002c3 <i386_init+0x195>
	boot_aps();

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);
f0100265:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010026c:	00 
f010026d:	c7 44 24 04 1d 4c 00 	movl   $0x4c1d,0x4(%esp)
f0100274:	00 
f0100275:	c7 04 24 0f 02 16 f0 	movl   $0xf016020f,(%esp)
f010027c:	e8 2c 37 00 00       	call   f01039ad <env_create>
	// Starting non-boot CPUs
	boot_aps();

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
f0100281:	83 eb 01             	sub    $0x1,%ebx
f0100284:	75 df                	jne    f0100265 <i386_init+0x137>
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100286:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
f010028d:	00 
f010028e:	c7 44 24 04 82 53 01 	movl   $0x15382,0x4(%esp)
f0100295:	00 
f0100296:	c7 04 24 84 fe 1b f0 	movl   $0xf01bfe84,(%esp)
f010029d:	e8 0b 37 00 00       	call   f01039ad <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01002a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01002a9:	00 
f01002aa:	c7 44 24 04 63 4c 00 	movl   $0x4c63,0x4(%esp)
f01002b1:	00 
f01002b2:	c7 04 24 21 b2 1b f0 	movl   $0xf01bb221,(%esp)
f01002b9:	e8 ef 36 00 00       	call   f01039ad <env_create>
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);

#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01002be:	e8 51 49 00 00       	call   f0104c14 <sched_yield>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01002c3:	bb 08 00 00 00       	mov    $0x8,%ebx
f01002c8:	eb 9b                	jmp    f0100265 <i386_init+0x137>

f01002ca <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002ca:	55                   	push   %ebp
f01002cb:	89 e5                	mov    %esp,%ebp
f01002cd:	53                   	push   %ebx
f01002ce:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01002d1:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002d7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002db:	8b 45 08             	mov    0x8(%ebp),%eax
f01002de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002e2:	c7 04 24 48 6f 10 f0 	movl   $0xf0106f48,(%esp)
f01002e9:	e8 a8 3c 00 00       	call   f0103f96 <cprintf>
	vcprintf(fmt, ap);
f01002ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002f2:	8b 45 10             	mov    0x10(%ebp),%eax
f01002f5:	89 04 24             	mov    %eax,(%esp)
f01002f8:	e8 66 3c 00 00       	call   f0103f63 <vcprintf>
	cprintf("\n");
f01002fd:	c7 04 24 e5 81 10 f0 	movl   $0xf01081e5,(%esp)
f0100304:	e8 8d 3c 00 00       	call   f0103f96 <cprintf>
	va_end(ap);
}
f0100309:	83 c4 14             	add    $0x14,%esp
f010030c:	5b                   	pop    %ebx
f010030d:	5d                   	pop    %ebp
f010030e:	c3                   	ret    
f010030f:	90                   	nop

f0100310 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100310:	55                   	push   %ebp
f0100311:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100313:	ba 84 00 00 00       	mov    $0x84,%edx
f0100318:	ec                   	in     (%dx),%al
f0100319:	ec                   	in     (%dx),%al
f010031a:	ec                   	in     (%dx),%al
f010031b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010031c:	5d                   	pop    %ebp
f010031d:	c3                   	ret    

f010031e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010031e:	55                   	push   %ebp
f010031f:	89 e5                	mov    %esp,%ebp
f0100321:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100326:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100327:	a8 01                	test   $0x1,%al
f0100329:	74 08                	je     f0100333 <serial_proc_data+0x15>
f010032b:	b2 f8                	mov    $0xf8,%dl
f010032d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010032e:	0f b6 c0             	movzbl %al,%eax
f0100331:	eb 05                	jmp    f0100338 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100333:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100338:	5d                   	pop    %ebp
f0100339:	c3                   	ret    

f010033a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010033a:	55                   	push   %ebp
f010033b:	89 e5                	mov    %esp,%ebp
f010033d:	53                   	push   %ebx
f010033e:	83 ec 04             	sub    $0x4,%esp
f0100341:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100343:	eb 26                	jmp    f010036b <cons_intr+0x31>
		if (c == 0)
f0100345:	85 d2                	test   %edx,%edx
f0100347:	74 22                	je     f010036b <cons_intr+0x31>
			continue;
		cons.buf[cons.wpos++] = c;
f0100349:	a1 24 62 1d f0       	mov    0xf01d6224,%eax
f010034e:	88 90 20 60 1d f0    	mov    %dl,-0xfe29fe0(%eax)
f0100354:	8d 50 01             	lea    0x1(%eax),%edx
		if (cons.wpos == CONSBUFSIZE)
f0100357:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f010035d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100362:	0f 44 d0             	cmove  %eax,%edx
f0100365:	89 15 24 62 1d f0    	mov    %edx,0xf01d6224
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010036b:	ff d3                	call   *%ebx
f010036d:	89 c2                	mov    %eax,%edx
f010036f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100372:	75 d1                	jne    f0100345 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100374:	83 c4 04             	add    $0x4,%esp
f0100377:	5b                   	pop    %ebx
f0100378:	5d                   	pop    %ebp
f0100379:	c3                   	ret    

f010037a <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010037a:	55                   	push   %ebp
f010037b:	89 e5                	mov    %esp,%ebp
f010037d:	57                   	push   %edi
f010037e:	56                   	push   %esi
f010037f:	53                   	push   %ebx
f0100380:	83 ec 2c             	sub    $0x2c,%esp
f0100383:	89 c7                	mov    %eax,%edi
f0100385:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010038a:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f010038b:	a8 20                	test   $0x20,%al
f010038d:	75 1b                	jne    f01003aa <cons_putc+0x30>
f010038f:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100394:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100399:	e8 72 ff ff ff       	call   f0100310 <delay>
f010039e:	89 f2                	mov    %esi,%edx
f01003a0:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01003a1:	a8 20                	test   $0x20,%al
f01003a3:	75 05                	jne    f01003aa <cons_putc+0x30>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003a5:	83 eb 01             	sub    $0x1,%ebx
f01003a8:	75 ef                	jne    f0100399 <cons_putc+0x1f>
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f01003aa:	89 f8                	mov    %edi,%eax
f01003ac:	25 ff 00 00 00       	and    $0xff,%eax
f01003b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003b9:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003ba:	b2 79                	mov    $0x79,%dl
f01003bc:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003bd:	84 c0                	test   %al,%al
f01003bf:	78 1b                	js     f01003dc <cons_putc+0x62>
f01003c1:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01003c6:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f01003cb:	e8 40 ff ff ff       	call   f0100310 <delay>
f01003d0:	89 f2                	mov    %esi,%edx
f01003d2:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003d3:	84 c0                	test   %al,%al
f01003d5:	78 05                	js     f01003dc <cons_putc+0x62>
f01003d7:	83 eb 01             	sub    $0x1,%ebx
f01003da:	75 ef                	jne    f01003cb <cons_putc+0x51>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003dc:	ba 78 03 00 00       	mov    $0x378,%edx
f01003e1:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01003e5:	ee                   	out    %al,(%dx)
f01003e6:	b2 7a                	mov    $0x7a,%dl
f01003e8:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003ed:	ee                   	out    %al,(%dx)
f01003ee:	b8 08 00 00 00       	mov    $0x8,%eax
f01003f3:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003f4:	89 fa                	mov    %edi,%edx
f01003f6:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003fc:	89 f8                	mov    %edi,%eax
f01003fe:	80 cc 07             	or     $0x7,%ah
f0100401:	85 d2                	test   %edx,%edx
f0100403:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100406:	89 f8                	mov    %edi,%eax
f0100408:	25 ff 00 00 00       	and    $0xff,%eax
f010040d:	83 f8 09             	cmp    $0x9,%eax
f0100410:	74 77                	je     f0100489 <cons_putc+0x10f>
f0100412:	83 f8 09             	cmp    $0x9,%eax
f0100415:	7f 0b                	jg     f0100422 <cons_putc+0xa8>
f0100417:	83 f8 08             	cmp    $0x8,%eax
f010041a:	0f 85 9d 00 00 00    	jne    f01004bd <cons_putc+0x143>
f0100420:	eb 10                	jmp    f0100432 <cons_putc+0xb8>
f0100422:	83 f8 0a             	cmp    $0xa,%eax
f0100425:	74 3c                	je     f0100463 <cons_putc+0xe9>
f0100427:	83 f8 0d             	cmp    $0xd,%eax
f010042a:	0f 85 8d 00 00 00    	jne    f01004bd <cons_putc+0x143>
f0100430:	eb 39                	jmp    f010046b <cons_putc+0xf1>
	case '\b':
		if (crt_pos > 0) {
f0100432:	0f b7 05 34 62 1d f0 	movzwl 0xf01d6234,%eax
f0100439:	66 85 c0             	test   %ax,%ax
f010043c:	0f 84 e5 00 00 00    	je     f0100527 <cons_putc+0x1ad>
			crt_pos--;
f0100442:	83 e8 01             	sub    $0x1,%eax
f0100445:	66 a3 34 62 1d f0    	mov    %ax,0xf01d6234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010044b:	0f b7 c0             	movzwl %ax,%eax
f010044e:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f0100454:	83 cf 20             	or     $0x20,%edi
f0100457:	8b 15 30 62 1d f0    	mov    0xf01d6230,%edx
f010045d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100461:	eb 77                	jmp    f01004da <cons_putc+0x160>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100463:	66 83 05 34 62 1d f0 	addw   $0x50,0xf01d6234
f010046a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010046b:	0f b7 05 34 62 1d f0 	movzwl 0xf01d6234,%eax
f0100472:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100478:	c1 e8 16             	shr    $0x16,%eax
f010047b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010047e:	c1 e0 04             	shl    $0x4,%eax
f0100481:	66 a3 34 62 1d f0    	mov    %ax,0xf01d6234
f0100487:	eb 51                	jmp    f01004da <cons_putc+0x160>
		break;
	case '\t':
		cons_putc(' ');
f0100489:	b8 20 00 00 00       	mov    $0x20,%eax
f010048e:	e8 e7 fe ff ff       	call   f010037a <cons_putc>
		cons_putc(' ');
f0100493:	b8 20 00 00 00       	mov    $0x20,%eax
f0100498:	e8 dd fe ff ff       	call   f010037a <cons_putc>
		cons_putc(' ');
f010049d:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a2:	e8 d3 fe ff ff       	call   f010037a <cons_putc>
		cons_putc(' ');
f01004a7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ac:	e8 c9 fe ff ff       	call   f010037a <cons_putc>
		cons_putc(' ');
f01004b1:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b6:	e8 bf fe ff ff       	call   f010037a <cons_putc>
f01004bb:	eb 1d                	jmp    f01004da <cons_putc+0x160>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01004bd:	0f b7 05 34 62 1d f0 	movzwl 0xf01d6234,%eax
f01004c4:	0f b7 c8             	movzwl %ax,%ecx
f01004c7:	8b 15 30 62 1d f0    	mov    0xf01d6230,%edx
f01004cd:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01004d1:	83 c0 01             	add    $0x1,%eax
f01004d4:	66 a3 34 62 1d f0    	mov    %ax,0xf01d6234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01004da:	66 81 3d 34 62 1d f0 	cmpw   $0x7cf,0xf01d6234
f01004e1:	cf 07 
f01004e3:	76 42                	jbe    f0100527 <cons_putc+0x1ad>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004e5:	a1 30 62 1d f0       	mov    0xf01d6230,%eax
f01004ea:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004f1:	00 
f01004f2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004f8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004fc:	89 04 24             	mov    %eax,(%esp)
f01004ff:	e8 ef 5b 00 00       	call   f01060f3 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100504:	8b 15 30 62 1d f0    	mov    0xf01d6230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010050a:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010050f:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100515:	83 c0 01             	add    $0x1,%eax
f0100518:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010051d:	75 f0                	jne    f010050f <cons_putc+0x195>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010051f:	66 83 2d 34 62 1d f0 	subw   $0x50,0xf01d6234
f0100526:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100527:	8b 0d 2c 62 1d f0    	mov    0xf01d622c,%ecx
f010052d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100532:	89 ca                	mov    %ecx,%edx
f0100534:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100535:	0f b7 1d 34 62 1d f0 	movzwl 0xf01d6234,%ebx
f010053c:	8d 71 01             	lea    0x1(%ecx),%esi
f010053f:	89 d8                	mov    %ebx,%eax
f0100541:	66 c1 e8 08          	shr    $0x8,%ax
f0100545:	89 f2                	mov    %esi,%edx
f0100547:	ee                   	out    %al,(%dx)
f0100548:	b8 0f 00 00 00       	mov    $0xf,%eax
f010054d:	89 ca                	mov    %ecx,%edx
f010054f:	ee                   	out    %al,(%dx)
f0100550:	89 d8                	mov    %ebx,%eax
f0100552:	89 f2                	mov    %esi,%edx
f0100554:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100555:	83 c4 2c             	add    $0x2c,%esp
f0100558:	5b                   	pop    %ebx
f0100559:	5e                   	pop    %esi
f010055a:	5f                   	pop    %edi
f010055b:	5d                   	pop    %ebp
f010055c:	c3                   	ret    

f010055d <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010055d:	55                   	push   %ebp
f010055e:	89 e5                	mov    %esp,%ebp
f0100560:	53                   	push   %ebx
f0100561:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100564:	ba 64 00 00 00       	mov    $0x64,%edx
f0100569:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010056a:	a8 01                	test   $0x1,%al
f010056c:	0f 84 e5 00 00 00    	je     f0100657 <kbd_proc_data+0xfa>
f0100572:	b2 60                	mov    $0x60,%dl
f0100574:	ec                   	in     (%dx),%al
f0100575:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100577:	3c e0                	cmp    $0xe0,%al
f0100579:	75 11                	jne    f010058c <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f010057b:	83 0d 28 62 1d f0 40 	orl    $0x40,0xf01d6228
		return 0;
f0100582:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100587:	e9 d0 00 00 00       	jmp    f010065c <kbd_proc_data+0xff>
	} else if (data & 0x80) {
f010058c:	84 c0                	test   %al,%al
f010058e:	79 37                	jns    f01005c7 <kbd_proc_data+0x6a>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100590:	8b 0d 28 62 1d f0    	mov    0xf01d6228,%ecx
f0100596:	89 cb                	mov    %ecx,%ebx
f0100598:	83 e3 40             	and    $0x40,%ebx
f010059b:	83 e0 7f             	and    $0x7f,%eax
f010059e:	85 db                	test   %ebx,%ebx
f01005a0:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01005a3:	0f b6 d2             	movzbl %dl,%edx
f01005a6:	0f b6 82 a0 6f 10 f0 	movzbl -0xfef9060(%edx),%eax
f01005ad:	83 c8 40             	or     $0x40,%eax
f01005b0:	0f b6 c0             	movzbl %al,%eax
f01005b3:	f7 d0                	not    %eax
f01005b5:	21 c1                	and    %eax,%ecx
f01005b7:	89 0d 28 62 1d f0    	mov    %ecx,0xf01d6228
		return 0;
f01005bd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005c2:	e9 95 00 00 00       	jmp    f010065c <kbd_proc_data+0xff>
	} else if (shift & E0ESC) {
f01005c7:	8b 0d 28 62 1d f0    	mov    0xf01d6228,%ecx
f01005cd:	f6 c1 40             	test   $0x40,%cl
f01005d0:	74 0e                	je     f01005e0 <kbd_proc_data+0x83>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01005d2:	89 c2                	mov    %eax,%edx
f01005d4:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01005d7:	83 e1 bf             	and    $0xffffffbf,%ecx
f01005da:	89 0d 28 62 1d f0    	mov    %ecx,0xf01d6228
	}

	shift |= shiftcode[data];
f01005e0:	0f b6 d2             	movzbl %dl,%edx
f01005e3:	0f b6 82 a0 6f 10 f0 	movzbl -0xfef9060(%edx),%eax
f01005ea:	0b 05 28 62 1d f0    	or     0xf01d6228,%eax
	shift ^= togglecode[data];
f01005f0:	0f b6 8a a0 70 10 f0 	movzbl -0xfef8f60(%edx),%ecx
f01005f7:	31 c8                	xor    %ecx,%eax
f01005f9:	a3 28 62 1d f0       	mov    %eax,0xf01d6228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005fe:	89 c1                	mov    %eax,%ecx
f0100600:	83 e1 03             	and    $0x3,%ecx
f0100603:	8b 0c 8d a0 71 10 f0 	mov    -0xfef8e60(,%ecx,4),%ecx
f010060a:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010060e:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100611:	a8 08                	test   $0x8,%al
f0100613:	74 1b                	je     f0100630 <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f0100615:	89 da                	mov    %ebx,%edx
f0100617:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010061a:	83 f9 19             	cmp    $0x19,%ecx
f010061d:	77 05                	ja     f0100624 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f010061f:	83 eb 20             	sub    $0x20,%ebx
f0100622:	eb 0c                	jmp    f0100630 <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f0100624:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100627:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010062a:	83 fa 19             	cmp    $0x19,%edx
f010062d:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100630:	f7 d0                	not    %eax
f0100632:	a8 06                	test   $0x6,%al
f0100634:	75 26                	jne    f010065c <kbd_proc_data+0xff>
f0100636:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010063c:	75 1e                	jne    f010065c <kbd_proc_data+0xff>
		cprintf("Rebooting!\n");
f010063e:	c7 04 24 62 6f 10 f0 	movl   $0xf0106f62,(%esp)
f0100645:	e8 4c 39 00 00       	call   f0103f96 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010064a:	ba 92 00 00 00       	mov    $0x92,%edx
f010064f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100654:	ee                   	out    %al,(%dx)
f0100655:	eb 05                	jmp    f010065c <kbd_proc_data+0xff>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100657:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010065c:	89 d8                	mov    %ebx,%eax
f010065e:	83 c4 14             	add    $0x14,%esp
f0100661:	5b                   	pop    %ebx
f0100662:	5d                   	pop    %ebp
f0100663:	c3                   	ret    

f0100664 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100664:	83 3d 00 60 1d f0 00 	cmpl   $0x0,0xf01d6000
f010066b:	74 11                	je     f010067e <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010066d:	55                   	push   %ebp
f010066e:	89 e5                	mov    %esp,%ebp
f0100670:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100673:	b8 1e 03 10 f0       	mov    $0xf010031e,%eax
f0100678:	e8 bd fc ff ff       	call   f010033a <cons_intr>
}
f010067d:	c9                   	leave  
f010067e:	f3 c3                	repz ret 

f0100680 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100680:	55                   	push   %ebp
f0100681:	89 e5                	mov    %esp,%ebp
f0100683:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100686:	b8 5d 05 10 f0       	mov    $0xf010055d,%eax
f010068b:	e8 aa fc ff ff       	call   f010033a <cons_intr>
}
f0100690:	c9                   	leave  
f0100691:	c3                   	ret    

f0100692 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100692:	55                   	push   %ebp
f0100693:	89 e5                	mov    %esp,%ebp
f0100695:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100698:	e8 c7 ff ff ff       	call   f0100664 <serial_intr>
	kbd_intr();
f010069d:	e8 de ff ff ff       	call   f0100680 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01006a2:	8b 15 20 62 1d f0    	mov    0xf01d6220,%edx
f01006a8:	3b 15 24 62 1d f0    	cmp    0xf01d6224,%edx
f01006ae:	74 20                	je     f01006d0 <cons_getc+0x3e>
		c = cons.buf[cons.rpos++];
f01006b0:	0f b6 82 20 60 1d f0 	movzbl -0xfe29fe0(%edx),%eax
f01006b7:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f01006ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
f01006c0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006c5:	0f 44 d1             	cmove  %ecx,%edx
f01006c8:	89 15 20 62 1d f0    	mov    %edx,0xf01d6220
f01006ce:	eb 05                	jmp    f01006d5 <cons_getc+0x43>
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f01006d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01006d5:	c9                   	leave  
f01006d6:	c3                   	ret    

f01006d7 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006d7:	55                   	push   %ebp
f01006d8:	89 e5                	mov    %esp,%ebp
f01006da:	57                   	push   %edi
f01006db:	56                   	push   %esi
f01006dc:	53                   	push   %ebx
f01006dd:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006e0:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006e7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006ee:	5a a5 
	if (*cp != 0xA55A) {
f01006f0:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006f7:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006fb:	74 11                	je     f010070e <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006fd:	c7 05 2c 62 1d f0 b4 	movl   $0x3b4,0xf01d622c
f0100704:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100707:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f010070c:	eb 16                	jmp    f0100724 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010070e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100715:	c7 05 2c 62 1d f0 d4 	movl   $0x3d4,0xf01d622c
f010071c:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010071f:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f0100724:	8b 0d 2c 62 1d f0    	mov    0xf01d622c,%ecx
f010072a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010072f:	89 ca                	mov    %ecx,%edx
f0100731:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100732:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100735:	89 da                	mov    %ebx,%edx
f0100737:	ec                   	in     (%dx),%al
f0100738:	0f b6 f0             	movzbl %al,%esi
f010073b:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010073e:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100743:	89 ca                	mov    %ecx,%edx
f0100745:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100746:	89 da                	mov    %ebx,%edx
f0100748:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100749:	89 3d 30 62 1d f0    	mov    %edi,0xf01d6230
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010074f:	0f b6 d8             	movzbl %al,%ebx
f0100752:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100754:	66 89 35 34 62 1d f0 	mov    %si,0xf01d6234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f010075b:	e8 20 ff ff ff       	call   f0100680 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100760:	0f b7 05 88 23 12 f0 	movzwl 0xf0122388,%eax
f0100767:	25 fd ff 00 00       	and    $0xfffd,%eax
f010076c:	89 04 24             	mov    %eax,(%esp)
f010076f:	e8 e0 36 00 00       	call   f0103e54 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100774:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100779:	b8 00 00 00 00       	mov    $0x0,%eax
f010077e:	89 f2                	mov    %esi,%edx
f0100780:	ee                   	out    %al,(%dx)
f0100781:	b2 fb                	mov    $0xfb,%dl
f0100783:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100788:	ee                   	out    %al,(%dx)
f0100789:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010078e:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100793:	89 da                	mov    %ebx,%edx
f0100795:	ee                   	out    %al,(%dx)
f0100796:	b2 f9                	mov    $0xf9,%dl
f0100798:	b8 00 00 00 00       	mov    $0x0,%eax
f010079d:	ee                   	out    %al,(%dx)
f010079e:	b2 fb                	mov    $0xfb,%dl
f01007a0:	b8 03 00 00 00       	mov    $0x3,%eax
f01007a5:	ee                   	out    %al,(%dx)
f01007a6:	b2 fc                	mov    $0xfc,%dl
f01007a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ad:	ee                   	out    %al,(%dx)
f01007ae:	b2 f9                	mov    $0xf9,%dl
f01007b0:	b8 01 00 00 00       	mov    $0x1,%eax
f01007b5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007b6:	b2 fd                	mov    $0xfd,%dl
f01007b8:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01007b9:	3c ff                	cmp    $0xff,%al
f01007bb:	0f 95 c1             	setne  %cl
f01007be:	0f b6 c9             	movzbl %cl,%ecx
f01007c1:	89 0d 00 60 1d f0    	mov    %ecx,0xf01d6000
f01007c7:	89 f2                	mov    %esi,%edx
f01007c9:	ec                   	in     (%dx),%al
f01007ca:	89 da                	mov    %ebx,%edx
f01007cc:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007cd:	85 c9                	test   %ecx,%ecx
f01007cf:	75 0c                	jne    f01007dd <cons_init+0x106>
		cprintf("Serial port does not exist!\n");
f01007d1:	c7 04 24 6e 6f 10 f0 	movl   $0xf0106f6e,(%esp)
f01007d8:	e8 b9 37 00 00       	call   f0103f96 <cprintf>
}
f01007dd:	83 c4 1c             	add    $0x1c,%esp
f01007e0:	5b                   	pop    %ebx
f01007e1:	5e                   	pop    %esi
f01007e2:	5f                   	pop    %edi
f01007e3:	5d                   	pop    %ebp
f01007e4:	c3                   	ret    

f01007e5 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007e5:	55                   	push   %ebp
f01007e6:	89 e5                	mov    %esp,%ebp
f01007e8:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01007ee:	e8 87 fb ff ff       	call   f010037a <cons_putc>
}
f01007f3:	c9                   	leave  
f01007f4:	c3                   	ret    

f01007f5 <getchar>:

int
getchar(void)
{
f01007f5:	55                   	push   %ebp
f01007f6:	89 e5                	mov    %esp,%ebp
f01007f8:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007fb:	e8 92 fe ff ff       	call   f0100692 <cons_getc>
f0100800:	85 c0                	test   %eax,%eax
f0100802:	74 f7                	je     f01007fb <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100804:	c9                   	leave  
f0100805:	c3                   	ret    

f0100806 <iscons>:

int
iscons(int fdnum)
{
f0100806:	55                   	push   %ebp
f0100807:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100809:	b8 01 00 00 00       	mov    $0x1,%eax
f010080e:	5d                   	pop    %ebp
f010080f:	c3                   	ret    

f0100810 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100810:	55                   	push   %ebp
f0100811:	89 e5                	mov    %esp,%ebp
f0100813:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100816:	c7 04 24 b0 71 10 f0 	movl   $0xf01071b0,(%esp)
f010081d:	e8 74 37 00 00       	call   f0103f96 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100822:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100829:	00 
f010082a:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100831:	f0 
f0100832:	c7 04 24 8c 72 10 f0 	movl   $0xf010728c,(%esp)
f0100839:	e8 58 37 00 00       	call   f0103f96 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010083e:	c7 44 24 08 9f 6e 10 	movl   $0x106e9f,0x8(%esp)
f0100845:	00 
f0100846:	c7 44 24 04 9f 6e 10 	movl   $0xf0106e9f,0x4(%esp)
f010084d:	f0 
f010084e:	c7 04 24 b0 72 10 f0 	movl   $0xf01072b0,(%esp)
f0100855:	e8 3c 37 00 00       	call   f0103f96 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010085a:	c7 44 24 08 06 52 1d 	movl   $0x1d5206,0x8(%esp)
f0100861:	00 
f0100862:	c7 44 24 04 06 52 1d 	movl   $0xf01d5206,0x4(%esp)
f0100869:	f0 
f010086a:	c7 04 24 d4 72 10 f0 	movl   $0xf01072d4,(%esp)
f0100871:	e8 20 37 00 00       	call   f0103f96 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100876:	c7 44 24 08 04 80 21 	movl   $0x218004,0x8(%esp)
f010087d:	00 
f010087e:	c7 44 24 04 04 80 21 	movl   $0xf0218004,0x4(%esp)
f0100885:	f0 
f0100886:	c7 04 24 f8 72 10 f0 	movl   $0xf01072f8,(%esp)
f010088d:	e8 04 37 00 00       	call   f0103f96 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-entry+1023)/1024);
f0100892:	b8 03 84 21 f0       	mov    $0xf0218403,%eax
f0100897:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010089c:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008a2:	85 c0                	test   %eax,%eax
f01008a4:	0f 48 c2             	cmovs  %edx,%eax
f01008a7:	c1 f8 0a             	sar    $0xa,%eax
f01008aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ae:	c7 04 24 1c 73 10 f0 	movl   $0xf010731c,(%esp)
f01008b5:	e8 dc 36 00 00       	call   f0103f96 <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f01008ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01008bf:	c9                   	leave  
f01008c0:	c3                   	ret    

f01008c1 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01008c1:	55                   	push   %ebp
f01008c2:	89 e5                	mov    %esp,%ebp
f01008c4:	56                   	push   %esi
f01008c5:	53                   	push   %ebx
f01008c6:	83 ec 10             	sub    $0x10,%esp
f01008c9:	bb c4 73 10 f0       	mov    $0xf01073c4,%ebx
unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
f01008ce:	be e8 73 10 f0       	mov    $0xf01073e8,%esi
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008d3:	8b 03                	mov    (%ebx),%eax
f01008d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008d9:	8b 43 fc             	mov    -0x4(%ebx),%eax
f01008dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008e0:	c7 04 24 c9 71 10 f0 	movl   $0xf01071c9,(%esp)
f01008e7:	e8 aa 36 00 00       	call   f0103f96 <cprintf>
f01008ec:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008ef:	39 f3                	cmp    %esi,%ebx
f01008f1:	75 e0                	jne    f01008d3 <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01008f8:	83 c4 10             	add    $0x10,%esp
f01008fb:	5b                   	pop    %ebx
f01008fc:	5e                   	pop    %esi
f01008fd:	5d                   	pop    %ebp
f01008fe:	c3                   	ret    

f01008ff <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008ff:	55                   	push   %ebp
f0100900:	89 e5                	mov    %esp,%ebp
f0100902:	57                   	push   %edi
f0100903:	56                   	push   %esi
f0100904:	53                   	push   %ebx
f0100905:	83 ec 5c             	sub    $0x5c,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100908:	89 e8                	mov    %ebp,%eax
f010090a:	89 c6                	mov    %eax,%esi
	// Your code here.
	uint32_t ebp, eip, arg;
	struct Eipdebuginfo info;
	ebp = read_ebp();
	for ( ; ebp; ebp = *((uint32_t *)ebp)){
f010090c:	85 c0                	test   %eax,%eax
f010090e:	0f 84 93 00 00 00    	je     f01009a7 <mon_backtrace+0xa8>
		eip = *((uint32_t *)(ebp+4));
f0100914:	8b 46 04             	mov    0x4(%esi),%eax
f0100917:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		cprintf("ebp %x eip %x args", ebp, eip);
f010091a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010091e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100922:	c7 04 24 d2 71 10 f0 	movl   $0xf01071d2,(%esp)
f0100929:	e8 68 36 00 00       	call   f0103f96 <cprintf>
		uint32_t i = 0, *arg_ptr = (uint32_t *)(ebp + 8);
f010092e:	8d 5e 08             	lea    0x8(%esi),%ebx
		(end-entry+1023)/1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
f0100931:	8d 7e 1c             	lea    0x1c(%esi),%edi
	for ( ; ebp; ebp = *((uint32_t *)ebp)){
		eip = *((uint32_t *)(ebp+4));
		cprintf("ebp %x eip %x args", ebp, eip);
		uint32_t i = 0, *arg_ptr = (uint32_t *)(ebp + 8);
		for ( ; i < 5; i++)
			cprintf(" %08x", *(arg_ptr + i));
f0100934:	8b 03                	mov    (%ebx),%eax
f0100936:	89 44 24 04          	mov    %eax,0x4(%esp)
f010093a:	c7 04 24 e5 71 10 f0 	movl   $0xf01071e5,(%esp)
f0100941:	e8 50 36 00 00       	call   f0103f96 <cprintf>
f0100946:	83 c3 04             	add    $0x4,%ebx
	ebp = read_ebp();
	for ( ; ebp; ebp = *((uint32_t *)ebp)){
		eip = *((uint32_t *)(ebp+4));
		cprintf("ebp %x eip %x args", ebp, eip);
		uint32_t i = 0, *arg_ptr = (uint32_t *)(ebp + 8);
		for ( ; i < 5; i++)
f0100949:	39 fb                	cmp    %edi,%ebx
f010094b:	75 e7                	jne    f0100934 <mon_backtrace+0x35>
			cprintf(" %08x", *(arg_ptr + i));
		cprintf("\n");
f010094d:	c7 04 24 e5 81 10 f0 	movl   $0xf01081e5,(%esp)
f0100954:	e8 3d 36 00 00       	call   f0103f96 <cprintf>
		debuginfo_eip(eip, &info);
f0100959:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010095c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100960:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100963:	89 04 24             	mov    %eax,(%esp)
f0100966:	e8 db 4b 00 00       	call   f0105546 <debuginfo_eip>
		cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, 
f010096b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010096e:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100971:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100975:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100978:	89 44 24 10          	mov    %eax,0x10(%esp)
f010097c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010097f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100983:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100986:	89 44 24 08          	mov    %eax,0x8(%esp)
f010098a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010098d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100991:	c7 04 24 eb 71 10 f0 	movl   $0xf01071eb,(%esp)
f0100998:	e8 f9 35 00 00       	call   f0103f96 <cprintf>
{
	// Your code here.
	uint32_t ebp, eip, arg;
	struct Eipdebuginfo info;
	ebp = read_ebp();
	for ( ; ebp; ebp = *((uint32_t *)ebp)){
f010099d:	8b 36                	mov    (%esi),%esi
f010099f:	85 f6                	test   %esi,%esi
f01009a1:	0f 85 6d ff ff ff    	jne    f0100914 <mon_backtrace+0x15>
		cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, 
				info.eip_fn_namelen, info.eip_fn_name, 
				(eip - info.eip_fn_addr));
	}
	return 0;
}
f01009a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01009ac:	83 c4 5c             	add    $0x5c,%esp
f01009af:	5b                   	pop    %ebx
f01009b0:	5e                   	pop    %esi
f01009b1:	5f                   	pop    %edi
f01009b2:	5d                   	pop    %ebp
f01009b3:	c3                   	ret    

f01009b4 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009b4:	55                   	push   %ebp
f01009b5:	89 e5                	mov    %esp,%ebp
f01009b7:	57                   	push   %edi
f01009b8:	56                   	push   %esi
f01009b9:	53                   	push   %ebx
f01009ba:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009bd:	c7 04 24 48 73 10 f0 	movl   $0xf0107348,(%esp)
f01009c4:	e8 cd 35 00 00       	call   f0103f96 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009c9:	c7 04 24 6c 73 10 f0 	movl   $0xf010736c,(%esp)
f01009d0:	e8 c1 35 00 00       	call   f0103f96 <cprintf>

	if (tf != NULL)
f01009d5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009d9:	74 0b                	je     f01009e6 <monitor+0x32>
		print_trapframe(tf);
f01009db:	8b 45 08             	mov    0x8(%ebp),%eax
f01009de:	89 04 24             	mov    %eax,(%esp)
f01009e1:	e8 0c 3c 00 00       	call   f01045f2 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01009e6:	c7 04 24 fb 71 10 f0 	movl   $0xf01071fb,(%esp)
f01009ed:	e8 ce 53 00 00       	call   f0105dc0 <readline>
f01009f2:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009f4:	85 c0                	test   %eax,%eax
f01009f6:	74 ee                	je     f01009e6 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009f8:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009ff:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100a04:	eb 06                	jmp    f0100a0c <monitor+0x58>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a06:	c6 06 00             	movb   $0x0,(%esi)
f0100a09:	83 c6 01             	add    $0x1,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a0c:	0f b6 06             	movzbl (%esi),%eax
f0100a0f:	84 c0                	test   %al,%al
f0100a11:	74 6a                	je     f0100a7d <monitor+0xc9>
f0100a13:	0f be c0             	movsbl %al,%eax
f0100a16:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a1a:	c7 04 24 ff 71 10 f0 	movl   $0xf01071ff,(%esp)
f0100a21:	e8 0f 56 00 00       	call   f0106035 <strchr>
f0100a26:	85 c0                	test   %eax,%eax
f0100a28:	75 dc                	jne    f0100a06 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100a2a:	80 3e 00             	cmpb   $0x0,(%esi)
f0100a2d:	74 4e                	je     f0100a7d <monitor+0xc9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a2f:	83 fb 0f             	cmp    $0xf,%ebx
f0100a32:	75 16                	jne    f0100a4a <monitor+0x96>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a34:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a3b:	00 
f0100a3c:	c7 04 24 04 72 10 f0 	movl   $0xf0107204,(%esp)
f0100a43:	e8 4e 35 00 00       	call   f0103f96 <cprintf>
f0100a48:	eb 9c                	jmp    f01009e6 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100a4a:	89 74 9d a8          	mov    %esi,-0x58(%ebp,%ebx,4)
f0100a4e:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a51:	0f b6 06             	movzbl (%esi),%eax
f0100a54:	84 c0                	test   %al,%al
f0100a56:	75 0c                	jne    f0100a64 <monitor+0xb0>
f0100a58:	eb b2                	jmp    f0100a0c <monitor+0x58>
			buf++;
f0100a5a:	83 c6 01             	add    $0x1,%esi
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a5d:	0f b6 06             	movzbl (%esi),%eax
f0100a60:	84 c0                	test   %al,%al
f0100a62:	74 a8                	je     f0100a0c <monitor+0x58>
f0100a64:	0f be c0             	movsbl %al,%eax
f0100a67:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a6b:	c7 04 24 ff 71 10 f0 	movl   $0xf01071ff,(%esp)
f0100a72:	e8 be 55 00 00       	call   f0106035 <strchr>
f0100a77:	85 c0                	test   %eax,%eax
f0100a79:	74 df                	je     f0100a5a <monitor+0xa6>
f0100a7b:	eb 8f                	jmp    f0100a0c <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f0100a7d:	c7 44 9d a8 00 00 00 	movl   $0x0,-0x58(%ebp,%ebx,4)
f0100a84:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a85:	85 db                	test   %ebx,%ebx
f0100a87:	0f 84 59 ff ff ff    	je     f01009e6 <monitor+0x32>
f0100a8d:	bf c0 73 10 f0       	mov    $0xf01073c0,%edi
f0100a92:	be 00 00 00 00       	mov    $0x0,%esi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a97:	8b 07                	mov    (%edi),%eax
f0100a99:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a9d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100aa0:	89 04 24             	mov    %eax,(%esp)
f0100aa3:	e8 09 55 00 00       	call   f0105fb1 <strcmp>
f0100aa8:	85 c0                	test   %eax,%eax
f0100aaa:	75 24                	jne    f0100ad0 <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f0100aac:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100aaf:	8b 55 08             	mov    0x8(%ebp),%edx
f0100ab2:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100ab6:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ab9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100abd:	89 1c 24             	mov    %ebx,(%esp)
f0100ac0:	ff 14 85 c8 73 10 f0 	call   *-0xfef8c38(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ac7:	85 c0                	test   %eax,%eax
f0100ac9:	78 28                	js     f0100af3 <monitor+0x13f>
f0100acb:	e9 16 ff ff ff       	jmp    f01009e6 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100ad0:	83 c6 01             	add    $0x1,%esi
f0100ad3:	83 c7 0c             	add    $0xc,%edi
f0100ad6:	83 fe 03             	cmp    $0x3,%esi
f0100ad9:	75 bc                	jne    f0100a97 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100adb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ade:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ae2:	c7 04 24 21 72 10 f0 	movl   $0xf0107221,(%esp)
f0100ae9:	e8 a8 34 00 00       	call   f0103f96 <cprintf>
f0100aee:	e9 f3 fe ff ff       	jmp    f01009e6 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100af3:	83 c4 5c             	add    $0x5c,%esp
f0100af6:	5b                   	pop    %ebx
f0100af7:	5e                   	pop    %esi
f0100af8:	5f                   	pop    %edi
f0100af9:	5d                   	pop    %ebp
f0100afa:	c3                   	ret    

f0100afb <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100afb:	55                   	push   %ebp
f0100afc:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100afe:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100b01:	5d                   	pop    %ebp
f0100b02:	c3                   	ret    
f0100b03:	66 90                	xchg   %ax,%ax
f0100b05:	66 90                	xchg   %ax,%ax
f0100b07:	66 90                	xchg   %ax,%ax
f0100b09:	66 90                	xchg   %ax,%ax
f0100b0b:	66 90                	xchg   %ax,%ax
f0100b0d:	66 90                	xchg   %ax,%ax
f0100b0f:	90                   	nop

f0100b10 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b10:	55                   	push   %ebp
f0100b11:	89 e5                	mov    %esp,%ebp
f0100b13:	53                   	push   %ebx
f0100b14:	83 ec 14             	sub    $0x14,%esp
f0100b17:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b19:	83 3d 3c 62 1d f0 00 	cmpl   $0x0,0xf01d623c
f0100b20:	75 2b                	jne    f0100b4d <boot_alloc+0x3d>
		extern char end[];
		cprintf("\nend[] is VA [0x%x]: PA is [0x%x]\n", 
f0100b22:	c7 44 24 08 04 80 21 	movl   $0x218004,0x8(%esp)
f0100b29:	00 
f0100b2a:	c7 44 24 04 04 80 21 	movl   $0xf0218004,0x4(%esp)
f0100b31:	f0 
f0100b32:	c7 04 24 e4 73 10 f0 	movl   $0xf01073e4,(%esp)
f0100b39:	e8 58 34 00 00       	call   f0103f96 <cprintf>
			(int)end, (int)(end - KERNBASE));

		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b3e:	b8 03 90 21 f0       	mov    $0xf0219003,%eax
f0100b43:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b48:	a3 3c 62 1d f0       	mov    %eax,0xf01d623c
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	//  LAB 2: Your code here.
	
	amount_pages = n / PGSIZE;
f0100b4d:	89 da                	mov    %ebx,%edx
f0100b4f:	c1 ea 0c             	shr    $0xc,%edx
	
    if (n % PGSIZE)
f0100b52:	89 d8                	mov    %ebx,%eax
f0100b54:	25 ff 0f 00 00       	and    $0xfff,%eax
    {
        amount_pages += 1;
f0100b59:	83 f8 01             	cmp    $0x1,%eax
f0100b5c:	83 da ff             	sbb    $0xffffffff,%edx
        pmap_cprintf("\nNeed ROUNDUP");

    }
    pmap_cprintf("\nRequiring [%d: 0x%x] bytes: [%d] pages, total size[0x%x]\n", 
   	n, n, amount_pages, amount_pages*PGSIZE);
	result = nextfree;
f0100b5f:	a1 3c 62 1d f0       	mov    0xf01d623c,%eax
    if (0 != n){
f0100b64:	85 db                	test   %ebx,%ebx
f0100b66:	74 16                	je     f0100b7e <boot_alloc+0x6e>
        nextfree = ROUNDUP ((char *) ((uint32_t) nextfree + amount_pages * PGSIZE),
f0100b68:	c1 e2 0c             	shl    $0xc,%edx
f0100b6b:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100b72:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b78:	89 15 3c 62 1d f0    	mov    %edx,0xf01d623c
        pmap_cprintf("\nAllocated VA from [%p] to [%p]\n", result, nextfree);
    }
    pmap_cprintf("Function return VA [%p]\n", result);
    pmap_cprintf("\n======END of boot_alloc()======\n");
    return (void *) result;
}
f0100b7e:	83 c4 14             	add    $0x14,%esp
f0100b81:	5b                   	pop    %ebx
f0100b82:	5d                   	pop    %ebp
f0100b83:	c3                   	ret    

f0100b84 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b84:	89 d1                	mov    %edx,%ecx
f0100b86:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b89:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b8c:	a8 01                	test   $0x1,%al
f0100b8e:	74 5d                	je     f0100bed <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b95:	89 c1                	mov    %eax,%ecx
f0100b97:	c1 e9 0c             	shr    $0xc,%ecx
f0100b9a:	3b 0d 88 6e 1d f0    	cmp    0xf01d6e88,%ecx
f0100ba0:	72 26                	jb     f0100bc8 <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ba2:	55                   	push   %ebp
f0100ba3:	89 e5                	mov    %esp,%ebp
f0100ba5:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ba8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bac:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f0100bb3:	f0 
f0100bb4:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0100bbb:	00 
f0100bbc:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0100bc3:	e8 78 f4 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100bc8:	c1 ea 0c             	shr    $0xc,%edx
f0100bcb:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100bd1:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100bd8:	89 c2                	mov    %eax,%edx
f0100bda:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100bdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100be2:	85 d2                	test   %edx,%edx
f0100be4:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100be9:	0f 44 c2             	cmove  %edx,%eax
f0100bec:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100bed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100bf2:	c3                   	ret    

f0100bf3 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100bf3:	55                   	push   %ebp
f0100bf4:	89 e5                	mov    %esp,%ebp
f0100bf6:	83 ec 18             	sub    $0x18,%esp
f0100bf9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100bfc:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100bff:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100c01:	89 04 24             	mov    %eax,(%esp)
f0100c04:	e8 1f 32 00 00       	call   f0103e28 <mc146818_read>
f0100c09:	89 c6                	mov    %eax,%esi
f0100c0b:	83 c3 01             	add    $0x1,%ebx
f0100c0e:	89 1c 24             	mov    %ebx,(%esp)
f0100c11:	e8 12 32 00 00       	call   f0103e28 <mc146818_read>
f0100c16:	c1 e0 08             	shl    $0x8,%eax
f0100c19:	09 f0                	or     %esi,%eax
}
f0100c1b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100c1e:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100c21:	89 ec                	mov    %ebp,%esp
f0100c23:	5d                   	pop    %ebp
f0100c24:	c3                   	ret    

f0100c25 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100c25:	55                   	push   %ebp
f0100c26:	89 e5                	mov    %esp,%ebp
f0100c28:	57                   	push   %edi
f0100c29:	56                   	push   %esi
f0100c2a:	53                   	push   %ebx
f0100c2b:	83 ec 4c             	sub    $0x4c,%esp
f0100c2e:	89 45 c0             	mov    %eax,-0x40(%ebp)
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c31:	85 c0                	test   %eax,%eax
f0100c33:	0f 85 86 03 00 00    	jne    f0100fbf <check_page_free_list+0x39a>
f0100c39:	e9 97 03 00 00       	jmp    f0100fd5 <check_page_free_list+0x3b0>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100c3e:	c7 44 24 08 08 74 10 	movl   $0xf0107408,0x8(%esp)
f0100c45:	f0 
f0100c46:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0100c4d:	00 
f0100c4e:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0100c55:	e8 e6 f3 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0100c5a:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c5d:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c60:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c63:	89 55 e4             	mov    %edx,-0x1c(%ebp)
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f0100c66:	89 c2                	mov    %eax,%edx
f0100c68:	2b 15 90 6e 1d f0    	sub    0xf01d6e90,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c6e:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c74:	0f 95 c2             	setne  %dl
f0100c77:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c7a:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c7e:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c80:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c84:	8b 00                	mov    (%eax),%eax
f0100c86:	85 c0                	test   %eax,%eax
f0100c88:	75 dc                	jne    f0100c66 <check_page_free_list+0x41>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c8d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c93:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c96:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c99:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c9e:	a3 40 62 1d f0       	mov    %eax,0xf01d6240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ca3:	89 c3                	mov    %eax,%ebx
f0100ca5:	85 c0                	test   %eax,%eax
f0100ca7:	74 6c                	je     f0100d15 <check_page_free_list+0xf0>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ca9:	be 01 00 00 00       	mov    $0x1,%esi
f0100cae:	89 d8                	mov    %ebx,%eax
f0100cb0:	2b 05 90 6e 1d f0    	sub    0xf01d6e90,%eax
f0100cb6:	c1 f8 03             	sar    $0x3,%eax
f0100cb9:	c1 e0 0c             	shl    $0xc,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
f0100cbc:	89 c2                	mov    %eax,%edx
f0100cbe:	c1 ea 16             	shr    $0x16,%edx
f0100cc1:	39 f2                	cmp    %esi,%edx
f0100cc3:	73 4a                	jae    f0100d0f <check_page_free_list+0xea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cc5:	89 c2                	mov    %eax,%edx
f0100cc7:	c1 ea 0c             	shr    $0xc,%edx
f0100cca:	3b 15 88 6e 1d f0    	cmp    0xf01d6e88,%edx
f0100cd0:	72 20                	jb     f0100cf2 <check_page_free_list+0xcd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cd2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cd6:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f0100cdd:	f0 
f0100cde:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0100ce5:	00 
f0100ce6:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f0100ced:	e8 4e f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100cf2:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100cf9:	00 
f0100cfa:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100d01:	00 
	return (void *)(pa + KERNBASE);
f0100d02:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d07:	89 04 24             	mov    %eax,(%esp)
f0100d0a:	e8 86 53 00 00       	call   f0106095 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d0f:	8b 1b                	mov    (%ebx),%ebx
f0100d11:	85 db                	test   %ebx,%ebx
f0100d13:	75 99                	jne    f0100cae <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100d15:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d1a:	e8 f1 fd ff ff       	call   f0100b10 <boot_alloc>
f0100d1f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d22:	8b 15 40 62 1d f0    	mov    0xf01d6240,%edx
f0100d28:	85 d2                	test   %edx,%edx
f0100d2a:	0f 84 2e 02 00 00    	je     f0100f5e <check_page_free_list+0x339>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d30:	8b 3d 90 6e 1d f0    	mov    0xf01d6e90,%edi
f0100d36:	39 fa                	cmp    %edi,%edx
f0100d38:	72 51                	jb     f0100d8b <check_page_free_list+0x166>
		assert(pp < pages + npages);
f0100d3a:	a1 88 6e 1d f0       	mov    0xf01d6e88,%eax
f0100d3f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100d42:	8d 04 c7             	lea    (%edi,%eax,8),%eax
f0100d45:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100d48:	39 c2                	cmp    %eax,%edx
f0100d4a:	73 68                	jae    f0100db4 <check_page_free_list+0x18f>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d4c:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0100d4f:	89 d0                	mov    %edx,%eax
f0100d51:	29 f8                	sub    %edi,%eax
f0100d53:	a8 07                	test   $0x7,%al
f0100d55:	0f 85 86 00 00 00    	jne    f0100de1 <check_page_free_list+0x1bc>
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f0100d5b:	c1 f8 03             	sar    $0x3,%eax
f0100d5e:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d61:	85 c0                	test   %eax,%eax
f0100d63:	0f 84 a6 00 00 00    	je     f0100e0f <check_page_free_list+0x1ea>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d69:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d6e:	0f 84 c6 00 00 00    	je     f0100e3a <check_page_free_list+0x215>
static void
check_page_free_list(bool only_low_memory)
{
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d74:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d79:	be 00 00 00 00       	mov    $0x0,%esi
f0100d7e:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0100d81:	e9 d8 00 00 00       	jmp    f0100e5e <check_page_free_list+0x239>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d86:	3b 55 bc             	cmp    -0x44(%ebp),%edx
f0100d89:	73 24                	jae    f0100daf <check_page_free_list+0x18a>
f0100d8b:	c7 44 24 0c 1b 7f 10 	movl   $0xf0107f1b,0xc(%esp)
f0100d92:	f0 
f0100d93:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0100d9a:	f0 
f0100d9b:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0100da2:	00 
f0100da3:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0100daa:	e8 91 f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100daf:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100db2:	72 24                	jb     f0100dd8 <check_page_free_list+0x1b3>
f0100db4:	c7 44 24 0c 3c 7f 10 	movl   $0xf0107f3c,0xc(%esp)
f0100dbb:	f0 
f0100dbc:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0100dc3:	f0 
f0100dc4:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0100dcb:	00 
f0100dcc:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0100dd3:	e8 68 f2 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100dd8:	89 d0                	mov    %edx,%eax
f0100dda:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100ddd:	a8 07                	test   $0x7,%al
f0100ddf:	74 24                	je     f0100e05 <check_page_free_list+0x1e0>
f0100de1:	c7 44 24 0c 2c 74 10 	movl   $0xf010742c,0xc(%esp)
f0100de8:	f0 
f0100de9:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0100df0:	f0 
f0100df1:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0100df8:	00 
f0100df9:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0100e00:	e8 3b f2 ff ff       	call   f0100040 <_panic>
f0100e05:	c1 f8 03             	sar    $0x3,%eax
f0100e08:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100e0b:	85 c0                	test   %eax,%eax
f0100e0d:	75 24                	jne    f0100e33 <check_page_free_list+0x20e>
f0100e0f:	c7 44 24 0c 50 7f 10 	movl   $0xf0107f50,0xc(%esp)
f0100e16:	f0 
f0100e17:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0100e1e:	f0 
f0100e1f:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0100e26:	00 
f0100e27:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0100e2e:	e8 0d f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e33:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e38:	75 24                	jne    f0100e5e <check_page_free_list+0x239>
f0100e3a:	c7 44 24 0c 61 7f 10 	movl   $0xf0107f61,0xc(%esp)
f0100e41:	f0 
f0100e42:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0100e49:	f0 
f0100e4a:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0100e51:	00 
f0100e52:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0100e59:	e8 e2 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e5e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e63:	75 24                	jne    f0100e89 <check_page_free_list+0x264>
f0100e65:	c7 44 24 0c 60 74 10 	movl   $0xf0107460,0xc(%esp)
f0100e6c:	f0 
f0100e6d:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0100e74:	f0 
f0100e75:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0100e7c:	00 
f0100e7d:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0100e84:	e8 b7 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e89:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e8e:	75 24                	jne    f0100eb4 <check_page_free_list+0x28f>
f0100e90:	c7 44 24 0c 7a 7f 10 	movl   $0xf0107f7a,0xc(%esp)
f0100e97:	f0 
f0100e98:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0100e9f:	f0 
f0100ea0:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0100ea7:	00 
f0100ea8:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0100eaf:	e8 8c f1 ff ff       	call   f0100040 <_panic>
f0100eb4:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100eb6:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ebb:	0f 86 24 01 00 00    	jbe    f0100fe5 <check_page_free_list+0x3c0>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ec1:	89 c7                	mov    %eax,%edi
f0100ec3:	c1 ef 0c             	shr    $0xc,%edi
f0100ec6:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0100ec9:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0100ecc:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100ecf:	72 20                	jb     f0100ef1 <check_page_free_list+0x2cc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ed1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ed5:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f0100edc:	f0 
f0100edd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0100ee4:	00 
f0100ee5:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f0100eec:	e8 4f f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100ef1:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0100ef7:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0100efa:	0f 86 f5 00 00 00    	jbe    f0100ff5 <check_page_free_list+0x3d0>
f0100f00:	c7 44 24 0c 84 74 10 	movl   $0xf0107484,0xc(%esp)
f0100f07:	f0 
f0100f08:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0100f0f:	f0 
f0100f10:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0100f17:	00 
f0100f18:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0100f1f:	e8 1c f1 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f24:	c7 44 24 0c 94 7f 10 	movl   $0xf0107f94,0xc(%esp)
f0100f2b:	f0 
f0100f2c:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0100f33:	f0 
f0100f34:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0100f3b:	00 
f0100f3c:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0100f43:	e8 f8 f0 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100f48:	83 c6 01             	add    $0x1,%esi
f0100f4b:	eb 03                	jmp    f0100f50 <check_page_free_list+0x32b>
		else
			++nfree_extmem;
f0100f4d:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f50:	8b 12                	mov    (%edx),%edx
f0100f52:	85 d2                	test   %edx,%edx
f0100f54:	0f 85 2c fe ff ff    	jne    f0100d86 <check_page_free_list+0x161>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100f5a:	85 f6                	test   %esi,%esi
f0100f5c:	7f 24                	jg     f0100f82 <check_page_free_list+0x35d>
f0100f5e:	c7 44 24 0c b1 7f 10 	movl   $0xf0107fb1,0xc(%esp)
f0100f65:	f0 
f0100f66:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0100f6d:	f0 
f0100f6e:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0100f75:	00 
f0100f76:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0100f7d:	e8 be f0 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100f82:	85 db                	test   %ebx,%ebx
f0100f84:	7f 24                	jg     f0100faa <check_page_free_list+0x385>
f0100f86:	c7 44 24 0c c3 7f 10 	movl   $0xf0107fc3,0xc(%esp)
f0100f8d:	f0 
f0100f8e:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0100f95:	f0 
f0100f96:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0100f9d:	00 
f0100f9e:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0100fa5:	e8 96 f0 ff ff       	call   f0100040 <_panic>
	cprintf("check_page_free_list(%d) succeeded!!!!!\n", (int)only_low_memory);
f0100faa:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100fad:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fb1:	c7 04 24 cc 74 10 f0 	movl   $0xf01074cc,(%esp)
f0100fb8:	e8 d9 2f 00 00       	call   f0103f96 <cprintf>
f0100fbd:	eb 56                	jmp    f0101015 <check_page_free_list+0x3f0>
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100fbf:	a1 40 62 1d f0       	mov    0xf01d6240,%eax
f0100fc4:	85 c0                	test   %eax,%eax
f0100fc6:	0f 85 8e fc ff ff    	jne    f0100c5a <check_page_free_list+0x35>
f0100fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100fd0:	e9 69 fc ff ff       	jmp    f0100c3e <check_page_free_list+0x19>
f0100fd5:	83 3d 40 62 1d f0 00 	cmpl   $0x0,0xf01d6240
f0100fdc:	75 27                	jne    f0101005 <check_page_free_list+0x3e0>
f0100fde:	66 90                	xchg   %ax,%ax
f0100fe0:	e9 59 fc ff ff       	jmp    f0100c3e <check_page_free_list+0x19>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100fe5:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100fea:	0f 85 58 ff ff ff    	jne    f0100f48 <check_page_free_list+0x323>
f0100ff0:	e9 2f ff ff ff       	jmp    f0100f24 <check_page_free_list+0x2ff>
f0100ff5:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ffa:	0f 85 4d ff ff ff    	jne    f0100f4d <check_page_free_list+0x328>
f0101000:	e9 1f ff ff ff       	jmp    f0100f24 <check_page_free_list+0x2ff>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101005:	8b 1d 40 62 1d f0    	mov    0xf01d6240,%ebx
//
static void
check_page_free_list(bool only_low_memory)
{
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010100b:	be 00 04 00 00       	mov    $0x400,%esi
f0101010:	e9 99 fc ff ff       	jmp    f0100cae <check_page_free_list+0x89>
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
	cprintf("check_page_free_list(%d) succeeded!!!!!\n", (int)only_low_memory);
}
f0101015:	83 c4 4c             	add    $0x4c,%esp
f0101018:	5b                   	pop    %ebx
f0101019:	5e                   	pop    %esi
f010101a:	5f                   	pop    %edi
f010101b:	5d                   	pop    %ebp
f010101c:	c3                   	ret    

f010101d <set_page_used>:
// After this is done, NEVER use boot_alloc again.  ONLY use the page
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//

inline void set_page_used(struct Page *pi){
f010101d:	55                   	push   %ebp
f010101e:	89 e5                	mov    %esp,%ebp
f0101020:	8b 45 08             	mov    0x8(%ebp),%eax
	pi->pp_ref = 1;
f0101023:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pi->pp_link = 0;
f0101029:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f010102f:	5d                   	pop    %ebp
f0101030:	c3                   	ret    

f0101031 <set_page_free>:

/* @yuhangj
 * From high addr to lower one */
inline void set_page_free(struct Page *pi){
f0101031:	55                   	push   %ebp
f0101032:	89 e5                	mov    %esp,%ebp
f0101034:	8b 45 08             	mov    0x8(%ebp),%eax
	pi->pp_ref = 0;
f0101037:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	pi->pp_link = page_free_list;
f010103d:	8b 15 40 62 1d f0    	mov    0xf01d6240,%edx
f0101043:	89 10                	mov    %edx,(%eax)
	page_free_list = pi;
f0101045:	a3 40 62 1d f0       	mov    %eax,0xf01d6240
}
f010104a:	5d                   	pop    %ebp
f010104b:	c3                   	ret    

f010104c <page_init>:
void
page_init(void)
{
f010104c:	55                   	push   %ebp
f010104d:	89 e5                	mov    %esp,%ebp
f010104f:	57                   	push   %edi
f0101050:	56                   	push   %esi
f0101051:	53                   	push   %ebx
f0101052:	83 ec 3c             	sub    $0x3c,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	page_free_list = 0;
f0101055:	c7 05 40 62 1d f0 00 	movl   $0x0,0xf01d6240
f010105c:	00 00 00 
	size_t i;

	//int med = (int)ROUNDUP(((char*)pages)+(sizeof(struct Page)*npages)-0xf0000000, PGSIZE);
	//cprintf("\nmed = %d[0x%x]", med, med);
	int med = (int)ROUNDUP(((char*)envs)+(sizeof(struct Env)*NENV)-0xf0000000, PGSIZE);
f010105f:	a1 48 62 1d f0       	mov    0xf01d6248,%eax
f0101064:	05 ff ff 01 10       	add    $0x1001ffff,%eax
f0101069:	25 00 f0 ff ff       	and    $0xfffff000,%eax

	for (i = 0; i < npages; i++) {
f010106e:	83 3d 88 6e 1d f0 00 	cmpl   $0x0,0xf01d6e88
f0101075:	0f 84 5c 02 00 00    	je     f01012d7 <page_init+0x28b>
			
			if(i == IOPHYSMEM/PGSIZE)
				cprintf("\npages[%d][%p]->pages[%d][%p]: IO hole [IOPHYSMEM, EXTPHYSMEM)\n", 
					i, &pages[i], EXTPHYSMEM/PGSIZE-1, &pages[EXTPHYSMEM/PGSIZE-1]);
		}
		else if (i >= EXTPHYSMEM / PGSIZE && i < med / PGSIZE){
f010107b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101081:	85 c0                	test   %eax,%eax
f0101083:	0f 48 c2             	cmovs  %edx,%eax
f0101086:	c1 f8 0c             	sar    $0xc,%eax
f0101089:	89 c7                	mov    %eax,%edi
			set_page_used(&pages[i]);
			
			if(i == EXTPHYSMEM/PGSIZE)	
				cprintf("\npages[%d][%p]->pages[%d][%p]: Store some struct & arrays\n", 
f010108b:	83 e8 01             	sub    $0x1,%eax
f010108e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101095:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101098:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010109b:	be 00 00 00 00       	mov    $0x0,%esi

	//int med = (int)ROUNDUP(((char*)pages)+(sizeof(struct Page)*npages)-0xf0000000, PGSIZE);
	//cprintf("\nmed = %d[0x%x]", med, med);
	int med = (int)ROUNDUP(((char*)envs)+(sizeof(struct Env)*NENV)-0xf0000000, PGSIZE);

	for (i = 0; i < npages; i++) {
f01010a0:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i == 0){
f01010a5:	85 db                	test   %ebx,%ebx
f01010a7:	75 2b                	jne    f01010d4 <page_init+0x88>
			set_page_used(&pages[i]);
f01010a9:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//

inline void set_page_used(struct Page *pi){
	pi->pp_ref = 1;
f01010ae:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pi->pp_link = 0;
f01010b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	int med = (int)ROUNDUP(((char*)envs)+(sizeof(struct Env)*NENV)-0xf0000000, PGSIZE);

	for (i = 0; i < npages; i++) {
		if (i == 0){
			set_page_used(&pages[i]);
			cprintf("\npages[0][%p]:Real-mode IDT and BIOS area\n", &pages[0]);
f01010ba:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f01010bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010c3:	c7 04 24 f8 74 10 f0 	movl   $0xf01074f8,(%esp)
f01010ca:	e8 c7 2e 00 00       	call   f0103f96 <cprintf>
f01010cf:	e9 f1 01 00 00       	jmp    f01012c5 <page_init+0x279>
		}
		else if (i >= 1 && i < MPENTRY_PADDR / PGSIZE){
f01010d4:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01010d7:	83 f8 05             	cmp    $0x5,%eax
f01010da:	77 70                	ja     f010114c <page_init+0x100>
			set_page_free(&pages[i]);
f01010dc:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f01010e1:	01 f0                	add    %esi,%eax
}

/* @yuhangj
 * From high addr to lower one */
inline void set_page_free(struct Page *pi){
	pi->pp_ref = 0;
f01010e3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	pi->pp_link = page_free_list;
f01010e9:	8b 15 40 62 1d f0    	mov    0xf01d6240,%edx
f01010ef:	89 10                	mov    %edx,(%eax)
	page_free_list = pi;
f01010f1:	a3 40 62 1d f0       	mov    %eax,0xf01d6240
			cprintf("\npages[0][%p]:Real-mode IDT and BIOS area\n", &pages[0]);
		}
		else if (i >= 1 && i < MPENTRY_PADDR / PGSIZE){
			set_page_free(&pages[i]);

			if(i == 1)
f01010f6:	83 fb 01             	cmp    $0x1,%ebx
f01010f9:	75 24                	jne    f010111f <page_init+0xd3>
				cprintf("\nfree pages start at addr[%p]:pages[%d]\n", &pages[i], i);
f01010fb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101102:	00 
f0101103:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f0101108:	01 f0                	add    %esi,%eax
f010110a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010110e:	c7 04 24 24 75 10 f0 	movl   $0xf0107524,(%esp)
f0101115:	e8 7c 2e 00 00       	call   f0103f96 <cprintf>
f010111a:	e9 a6 01 00 00       	jmp    f01012c5 <page_init+0x279>
			if(i == MPENTRY_PADDR/PGSIZE -1)
f010111f:	83 fb 06             	cmp    $0x6,%ebx
f0101122:	0f 85 9d 01 00 00    	jne    f01012c5 <page_init+0x279>
				cprintf("free pages end at addr[%p]:pages[%d]\n", &pages[i], i);
f0101128:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
f010112f:	00 
f0101130:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f0101135:	01 f0                	add    %esi,%eax
f0101137:	89 44 24 04          	mov    %eax,0x4(%esp)
f010113b:	c7 04 24 50 75 10 f0 	movl   $0xf0107550,(%esp)
f0101142:	e8 4f 2e 00 00       	call   f0103f96 <cprintf>
f0101147:	e9 79 01 00 00       	jmp    f01012c5 <page_init+0x279>
		}
		else if (i >= MPENTRY_PADDR / PGSIZE && i < IOPHYSMEM / PGSIZE){
f010114c:	8d 43 f9             	lea    -0x7(%ebx),%eax
f010114f:	3d 98 00 00 00       	cmp    $0x98,%eax
f0101154:	77 52                	ja     f01011a8 <page_init+0x15c>
			set_page_used(&pages[i]);
f0101156:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f010115b:	01 f0                	add    %esi,%eax
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//

inline void set_page_used(struct Page *pi){
	pi->pp_ref = 1;
f010115d:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pi->pp_link = 0;
f0101163:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
				cprintf("free pages end at addr[%p]:pages[%d]\n", &pages[i], i);
		}
		else if (i >= MPENTRY_PADDR / PGSIZE && i < IOPHYSMEM / PGSIZE){
			set_page_used(&pages[i]);

			if (i == MPENTRY_PADDR / PGSIZE)
f0101169:	83 fb 07             	cmp    $0x7,%ebx
f010116c:	0f 85 53 01 00 00    	jne    f01012c5 <page_init+0x279>
				cprintf("\npages[%d][%p]->pages[%d][%p]: Remaped IO\n",
f0101172:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f0101177:	8d 90 f8 04 00 00    	lea    0x4f8(%eax),%edx
f010117d:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101181:	c7 44 24 0c 9f 00 00 	movl   $0x9f,0xc(%esp)
f0101188:	00 
f0101189:	01 f0                	add    %esi,%eax
f010118b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010118f:	c7 44 24 04 07 00 00 	movl   $0x7,0x4(%esp)
f0101196:	00 
f0101197:	c7 04 24 78 75 10 f0 	movl   $0xf0107578,(%esp)
f010119e:	e8 f3 2d 00 00       	call   f0103f96 <cprintf>
f01011a3:	e9 1d 01 00 00       	jmp    f01012c5 <page_init+0x279>
					i, &pages[i], IOPHYSMEM/PGSIZE-1, &pages[IOPHYSMEM/PGSIZE-1]);
		}	
		else if (i >= IOPHYSMEM / PGSIZE && i < EXTPHYSMEM / PGSIZE){
f01011a8:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f01011ae:	83 f8 5f             	cmp    $0x5f,%eax
f01011b1:	77 55                	ja     f0101208 <page_init+0x1bc>
			set_page_used(&pages[i]);
f01011b3:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f01011b8:	01 f0                	add    %esi,%eax
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//

inline void set_page_used(struct Page *pi){
	pi->pp_ref = 1;
f01011ba:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pi->pp_link = 0;
f01011c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
					i, &pages[i], IOPHYSMEM/PGSIZE-1, &pages[IOPHYSMEM/PGSIZE-1]);
		}	
		else if (i >= IOPHYSMEM / PGSIZE && i < EXTPHYSMEM / PGSIZE){
			set_page_used(&pages[i]);
			
			if(i == IOPHYSMEM/PGSIZE)
f01011c6:	81 fb a0 00 00 00    	cmp    $0xa0,%ebx
f01011cc:	0f 85 f3 00 00 00    	jne    f01012c5 <page_init+0x279>
				cprintf("\npages[%d][%p]->pages[%d][%p]: IO hole [IOPHYSMEM, EXTPHYSMEM)\n", 
f01011d2:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f01011d7:	8d 90 f8 07 00 00    	lea    0x7f8(%eax),%edx
f01011dd:	89 54 24 10          	mov    %edx,0x10(%esp)
f01011e1:	c7 44 24 0c ff 00 00 	movl   $0xff,0xc(%esp)
f01011e8:	00 
f01011e9:	01 f0                	add    %esi,%eax
f01011eb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011ef:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
f01011f6:	00 
f01011f7:	c7 04 24 a4 75 10 f0 	movl   $0xf01075a4,(%esp)
f01011fe:	e8 93 2d 00 00       	call   f0103f96 <cprintf>
f0101203:	e9 bd 00 00 00       	jmp    f01012c5 <page_init+0x279>
					i, &pages[i], EXTPHYSMEM/PGSIZE-1, &pages[EXTPHYSMEM/PGSIZE-1]);
		}
		else if (i >= EXTPHYSMEM / PGSIZE && i < med / PGSIZE){
f0101208:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f010120e:	76 54                	jbe    f0101264 <page_init+0x218>
f0101210:	39 df                	cmp    %ebx,%edi
f0101212:	76 50                	jbe    f0101264 <page_init+0x218>
			set_page_used(&pages[i]);
f0101214:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f0101219:	01 f0                	add    %esi,%eax
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//

inline void set_page_used(struct Page *pi){
	pi->pp_ref = 1;
f010121b:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pi->pp_link = 0;
f0101221:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
					i, &pages[i], EXTPHYSMEM/PGSIZE-1, &pages[EXTPHYSMEM/PGSIZE-1]);
		}
		else if (i >= EXTPHYSMEM / PGSIZE && i < med / PGSIZE){
			set_page_used(&pages[i]);
			
			if(i == EXTPHYSMEM/PGSIZE)	
f0101227:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
f010122d:	0f 85 92 00 00 00    	jne    f01012c5 <page_init+0x279>
				cprintf("\npages[%d][%p]->pages[%d][%p]: Store some struct & arrays\n", 
f0101233:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f0101238:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010123b:	01 c2                	add    %eax,%edx
f010123d:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101241:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101244:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101248:	01 f0                	add    %esi,%eax
f010124a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010124e:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
f0101255:	00 
f0101256:	c7 04 24 e4 75 10 f0 	movl   $0xf01075e4,(%esp)
f010125d:	e8 34 2d 00 00       	call   f0103f96 <cprintf>
f0101262:	eb 61                	jmp    f01012c5 <page_init+0x279>
					i, &pages[i], med/PGSIZE-1, &pages[med/PGSIZE-1]);
		}
		else{
			set_page_free(&pages[i]);
f0101264:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f0101269:	01 f0                	add    %esi,%eax
}

/* @yuhangj
 * From high addr to lower one */
inline void set_page_free(struct Page *pi){
	pi->pp_ref = 0;
f010126b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	pi->pp_link = page_free_list;
f0101271:	8b 15 40 62 1d f0    	mov    0xf01d6240,%edx
f0101277:	89 10                	mov    %edx,(%eax)
	page_free_list = pi;
f0101279:	a3 40 62 1d f0       	mov    %eax,0xf01d6240
					i, &pages[i], med/PGSIZE-1, &pages[med/PGSIZE-1]);
		}
		else{
			set_page_free(&pages[i]);

			if(i == med/PGSIZE)
f010127e:	39 df                	cmp    %ebx,%edi
f0101280:	75 1b                	jne    f010129d <page_init+0x251>
				cprintf("\nfree pages start at pages[%d][%p]",i, &pages[i]);
f0101282:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f0101287:	01 f0                	add    %esi,%eax
f0101289:	89 44 24 08          	mov    %eax,0x8(%esp)
f010128d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101291:	c7 04 24 20 76 10 f0 	movl   $0xf0107620,(%esp)
f0101298:	e8 f9 2c 00 00       	call   f0103f96 <cprintf>
			if(i == npages-1)
f010129d:	a1 88 6e 1d f0       	mov    0xf01d6e88,%eax
f01012a2:	83 e8 01             	sub    $0x1,%eax
f01012a5:	39 d8                	cmp    %ebx,%eax
f01012a7:	75 1c                	jne    f01012c5 <page_init+0x279>
				cprintf("\nfree pages end at pages[%d][%p]\n",i, &pages[i]);
f01012a9:	8b 15 90 6e 1d f0    	mov    0xf01d6e90,%edx
f01012af:	01 f2                	add    %esi,%edx
f01012b1:	89 54 24 08          	mov    %edx,0x8(%esp)
f01012b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012b9:	c7 04 24 44 76 10 f0 	movl   $0xf0107644,(%esp)
f01012c0:	e8 d1 2c 00 00       	call   f0103f96 <cprintf>

	//int med = (int)ROUNDUP(((char*)pages)+(sizeof(struct Page)*npages)-0xf0000000, PGSIZE);
	//cprintf("\nmed = %d[0x%x]", med, med);
	int med = (int)ROUNDUP(((char*)envs)+(sizeof(struct Env)*NENV)-0xf0000000, PGSIZE);

	for (i = 0; i < npages; i++) {
f01012c5:	83 c3 01             	add    $0x1,%ebx
f01012c8:	83 c6 08             	add    $0x8,%esi
f01012cb:	39 1d 88 6e 1d f0    	cmp    %ebx,0xf01d6e88
f01012d1:	0f 87 ce fd ff ff    	ja     f01010a5 <page_init+0x59>
				cprintf("\nfree pages start at pages[%d][%p]",i, &pages[i]);
			if(i == npages-1)
				cprintf("\nfree pages end at pages[%d][%p]\n",i, &pages[i]);
		} 
	}
	cprintf("\nThe last free page [%p]\n", page_free_list);
f01012d7:	a1 40 62 1d f0       	mov    0xf01d6240,%eax
f01012dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012e0:	c7 04 24 d4 7f 10 f0 	movl   $0xf0107fd4,(%esp)
f01012e7:	e8 aa 2c 00 00       	call   f0103f96 <cprintf>
	// for(page_free_list, k; page_free_list->pp_link != 0;k++, page_free_list= page_free_list->pp_link)
	// {
	// 	//if((int)page_free_list == 0xf011b000)
	// 		cprintf("k=[%d], find",k);
	// }
}
f01012ec:	83 c4 3c             	add    $0x3c,%esp
f01012ef:	5b                   	pop    %ebx
f01012f0:	5e                   	pop    %esi
f01012f1:	5f                   	pop    %edi
f01012f2:	5d                   	pop    %ebp
f01012f3:	c3                   	ret    

f01012f4 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f01012f4:	55                   	push   %ebp
f01012f5:	89 e5                	mov    %esp,%ebp
f01012f7:	53                   	push   %ebx
f01012f8:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	pmap_cprintf("\nALLOC_ZERO[0x%x], alloc_flags[0x%x]\n", ALLOC_ZERO, alloc_flags);

	//cprintf("\n# == == In function page_alloc() == == #\n");
	if (page_free_list == NULL){
f01012fb:	8b 1d 40 62 1d f0    	mov    0xf01d6240,%ebx
f0101301:	85 db                	test   %ebx,%ebx
f0101303:	74 66                	je     f010136b <page_alloc+0x77>
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f0101305:	89 d8                	mov    %ebx,%eax
f0101307:	2b 05 90 6e 1d f0    	sub    0xf01d6e90,%eax
f010130d:	c1 f8 03             	sar    $0x3,%eax
f0101310:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101313:	89 c2                	mov    %eax,%edx
f0101315:	c1 ea 0c             	shr    $0xc,%edx
f0101318:	3b 15 88 6e 1d f0    	cmp    0xf01d6e88,%edx
f010131e:	72 20                	jb     f0101340 <page_alloc+0x4c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101320:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101324:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f010132b:	f0 
f010132c:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0101333:	00 
f0101334:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f010133b:	e8 00 ed ff ff       	call   f0100040 <_panic>
	
	//cprintf("\nfree pages:[%p] p(KVA)[%p]", page_free_list, p);
	//cprintf("\nfreelist(page addr):[%p], next[%p], KVA[]\n", 
	//	free, page_free_list->pp_link);
	
	page_free_list = page_free_list->pp_link;
f0101340:	8b 13                	mov    (%ebx),%edx
f0101342:	89 15 40 62 1d f0    	mov    %edx,0xf01d6240
	if (alloc_flags & ALLOC_ZERO){
f0101348:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010134c:	74 1d                	je     f010136b <page_alloc+0x77>
		pmap_cprintf("$$$$$$PAGE allocated at kva [%p]\n", p);
		//for (i = 0 ; i < PGSIZE; i++)
		//	p[i] = '\0';
		memset(p,0,PGSIZE);
f010134e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101355:	00 
f0101356:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010135d:	00 
	return (void *)(pa + KERNBASE);
f010135e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101363:	89 04 24             	mov    %eax,(%esp)
f0101366:	e8 2a 4d 00 00       	call   f0106095 <memset>
	}
	return free;
}
f010136b:	89 d8                	mov    %ebx,%eax
f010136d:	83 c4 14             	add    $0x14,%esp
f0101370:	5b                   	pop    %ebx
f0101371:	5d                   	pop    %ebp
f0101372:	c3                   	ret    

f0101373 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0101373:	55                   	push   %ebp
f0101374:	89 e5                	mov    %esp,%ebp
f0101376:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	
	//cprintf("\n# == == page_free() == == #\n");
	pp->pp_link = page_free_list;
f0101379:	8b 15 40 62 1d f0    	mov    0xf01d6240,%edx
f010137f:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101381:	a3 40 62 1d f0       	mov    %eax,0xf01d6240
	//cprintf("\npage_free_list is [%p]\n", page_free_list);
	//cprintf("\n# == == end of function page_alloc() == == #\n");
}
f0101386:	5d                   	pop    %ebp
f0101387:	c3                   	ret    

f0101388 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0101388:	55                   	push   %ebp
f0101389:	89 e5                	mov    %esp,%ebp
f010138b:	83 ec 04             	sub    $0x4,%esp
f010138e:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101391:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0101395:	83 ea 01             	sub    $0x1,%edx
f0101398:	66 89 50 04          	mov    %dx,0x4(%eax)
f010139c:	66 85 d2             	test   %dx,%dx
f010139f:	75 08                	jne    f01013a9 <page_decref+0x21>
		page_free(pp);
f01013a1:	89 04 24             	mov    %eax,(%esp)
f01013a4:	e8 ca ff ff ff       	call   f0101373 <page_free>
}
f01013a9:	c9                   	leave  
f01013aa:	c3                   	ret    

f01013ab <pgdir_walk>:
// To construct a linear address la from PDX(la), PTX(la), and PGOFF(la),
// use PGADDR(PDX(la), PTX(la), PGOFF(la)).

pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01013ab:	55                   	push   %ebp
f01013ac:	89 e5                	mov    %esp,%ebp
f01013ae:	56                   	push   %esi
f01013af:	53                   	push   %ebx
f01013b0:	83 ec 10             	sub    $0x10,%esp
f01013b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	// @yuhangj
	// pt is the kva of Page Table Adddress. 
	// pte_pa = PADDR(&pt[ptx]) is the offeset PTE from PageTable(PA)
	// &pt[ptx] is the kva of PTE in the PageTable//存放pte的地址

	uint32_t pdx = PDX(va), ptx = PTX(va);
f01013b6:	89 c3                	mov    %eax,%ebx
f01013b8:	c1 eb 0c             	shr    $0xc,%ebx
f01013bb:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01013c1:	c1 e8 16             	shr    $0x16,%eax
	pde_t *pt = 0;

	 // cprintf("\npgdir:[%p]; VA:[%p]; pdx:[%d:0x%x]; ptx:[%d:0x%x]\n", 
	 //   	pgdir, va, pdx, pdx, ptx, ptx);

	if (pgdir[pdx] & PTE_P){
f01013c4:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
f01013cb:	03 75 08             	add    0x8(%ebp),%esi
f01013ce:	8b 06                	mov    (%esi),%eax
f01013d0:	a8 01                	test   $0x1,%al
f01013d2:	74 3b                	je     f010140f <pgdir_walk+0x64>
		
		 // cprintf("pgdir[pdx:%d]At[%p] contains [0x%x], PT is [0x%x]\n",
		 //   	pdx, &pgdir[pdx],pgdir[pdx],PTE_ADDR(pgdir[pdx]));
		
		pt = KADDR(PTE_ADDR(pgdir[pdx]));
f01013d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013d9:	89 c2                	mov    %eax,%edx
f01013db:	c1 ea 0c             	shr    $0xc,%edx
f01013de:	3b 15 88 6e 1d f0    	cmp    0xf01d6e88,%edx
f01013e4:	72 20                	jb     f0101406 <pgdir_walk+0x5b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013ea:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f01013f1:	f0 
f01013f2:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
f01013f9:	00 
f01013fa:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101401:	e8 3a ec ff ff       	call   f0100040 <_panic>
		
		 // cprintf("PTE_P & Return\nPT PA[%p] VA[%p], PT offset ptx[0x%x:%d]\n", 
		 //  	PTE_ADDR(pgdir[pdx]), pt, ptx, ptx);
		 // cprintf("PADDR(pt) [%p]\n", PADDR(&pt[ptx]));

		return &pt[ptx];
f0101406:	8d 84 98 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,4),%eax
f010140d:	eb 7d                	jmp    f010148c <pgdir_walk+0xe1>
	}
	if (!create)
f010140f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101413:	74 6b                	je     f0101480 <pgdir_walk+0xd5>
		return NULL;

	struct Page *page = page_alloc(ALLOC_ZERO);
f0101415:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010141c:	e8 d3 fe ff ff       	call   f01012f4 <page_alloc>
	if (!page){
f0101421:	85 c0                	test   %eax,%eax
f0101423:	74 62                	je     f0101487 <pgdir_walk+0xdc>
		pmap_cprintf("page_alloc() fail\n");
		return NULL;
	}
	page->pp_ref = 1;
f0101425:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f010142b:	89 c2                	mov    %eax,%edx
f010142d:	2b 15 90 6e 1d f0    	sub    0xf01d6e90,%edx
f0101433:	c1 fa 03             	sar    $0x3,%edx
f0101436:	c1 e2 0c             	shl    $0xc,%edx
	pgdir[pdx] = page2pa(page) | PTE_P | PTE_U |PTE_W;
f0101439:	83 ca 07             	or     $0x7,%edx
f010143c:	89 16                	mov    %edx,(%esi)
f010143e:	2b 05 90 6e 1d f0    	sub    0xf01d6e90,%eax
f0101444:	c1 f8 03             	sar    $0x3,%eax
f0101447:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010144a:	89 c2                	mov    %eax,%edx
f010144c:	c1 ea 0c             	shr    $0xc,%edx
f010144f:	3b 15 88 6e 1d f0    	cmp    0xf01d6e88,%edx
f0101455:	72 20                	jb     f0101477 <pgdir_walk+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101457:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010145b:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f0101462:	f0 
f0101463:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f010146a:	00 
f010146b:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f0101472:	e8 c9 eb ff ff       	call   f0100040 <_panic>
	pt = page2kva(page);
	
	//cprintf("return addr &pt[%d]: [%p]\n",ptx, &pt[ptx]);

	return &pt[ptx];
f0101477:	8d 84 98 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,4),%eax
f010147e:	eb 0c                	jmp    f010148c <pgdir_walk+0xe1>
		 // cprintf("PADDR(pt) [%p]\n", PADDR(&pt[ptx]));

		return &pt[ptx];
	}
	if (!create)
		return NULL;
f0101480:	b8 00 00 00 00       	mov    $0x0,%eax
f0101485:	eb 05                	jmp    f010148c <pgdir_walk+0xe1>

	struct Page *page = page_alloc(ALLOC_ZERO);
	if (!page){
		pmap_cprintf("page_alloc() fail\n");
		return NULL;
f0101487:	b8 00 00 00 00       	mov    $0x0,%eax
	pt = page2kva(page);
	
	//cprintf("return addr &pt[%d]: [%p]\n",ptx, &pt[ptx]);

	return &pt[ptx];
}
f010148c:	83 c4 10             	add    $0x10,%esp
f010148f:	5b                   	pop    %ebx
f0101490:	5e                   	pop    %esi
f0101491:	5d                   	pop    %ebp
f0101492:	c3                   	ret    

f0101493 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101493:	55                   	push   %ebp
f0101494:	89 e5                	mov    %esp,%ebp
f0101496:	57                   	push   %edi
f0101497:	56                   	push   %esi
f0101498:	53                   	push   %ebx
f0101499:	83 ec 2c             	sub    $0x2c,%esp
f010149c:	89 c6                	mov    %eax,%esi
f010149e:	89 d3                	mov    %edx,%ebx
f01014a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01014a3:	8b 7d 08             	mov    0x8(%ebp),%edi
	//Fill this function in

	cprintf("VA: [0x%x]; PA: [0x%x]\n", va, pa);
f01014a6:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01014aa:	89 54 24 04          	mov    %edx,0x4(%esp)
f01014ae:	c7 04 24 ee 7f 10 f0 	movl   $0xf0107fee,(%esp)
f01014b5:	e8 dc 2a 00 00       	call   f0103f96 <cprintf>
	va &= ~0xfff;
f01014ba:	89 d8                	mov    %ebx,%eax
f01014bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	pa &= ~0xfff;
f01014c1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi

	//注意判断条件：KERNBASE + 1G 会溢出uint32_t！
	for ( ; size != 0; va += PGSIZE, pa += PGSIZE, size -= PGSIZE){
f01014c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01014cb:	74 70                	je     f010153d <boot_map_region+0xaa>
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	//Fill this function in

	cprintf("VA: [0x%x]; PA: [0x%x]\n", va, pa);
	va &= ~0xfff;
f01014cd:	89 c3                	mov    %eax,%ebx
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01014cf:	29 c7                	sub    %eax,%edi
f01014d1:	89 7d dc             	mov    %edi,-0x24(%ebp)
	for ( ; size != 0; va += PGSIZE, pa += PGSIZE, size -= PGSIZE){
		pde_t *ptep;
		ptep = pgdir_walk(pgdir, (void *)va, 1);
		//cprintf("In boot_map_region(), ptep[%p], pa[%p]\n", ptep, pa);
		assert(ptep);
		*ptep = pa | perm | PTE_P;
f01014d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014d7:	83 c8 01             	or     $0x1,%eax
f01014da:	89 45 e0             	mov    %eax,-0x20(%ebp)
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01014dd:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01014e0:	01 df                	add    %ebx,%edi
	pa &= ~0xfff;

	//注意判断条件：KERNBASE + 1G 会溢出uint32_t！
	for ( ; size != 0; va += PGSIZE, pa += PGSIZE, size -= PGSIZE){
		pde_t *ptep;
		ptep = pgdir_walk(pgdir, (void *)va, 1);
f01014e2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01014e9:	00 
f01014ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01014ee:	89 34 24             	mov    %esi,(%esp)
f01014f1:	e8 b5 fe ff ff       	call   f01013ab <pgdir_walk>
		//cprintf("In boot_map_region(), ptep[%p], pa[%p]\n", ptep, pa);
		assert(ptep);
f01014f6:	85 c0                	test   %eax,%eax
f01014f8:	75 24                	jne    f010151e <boot_map_region+0x8b>
f01014fa:	c7 44 24 0c 06 80 10 	movl   $0xf0108006,0xc(%esp)
f0101501:	f0 
f0101502:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101509:	f0 
f010150a:	c7 44 24 04 84 02 00 	movl   $0x284,0x4(%esp)
f0101511:	00 
f0101512:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101519:	e8 22 eb ff ff       	call   f0100040 <_panic>
		*ptep = pa | perm | PTE_P;
f010151e:	0b 7d e0             	or     -0x20(%ebp),%edi
f0101521:	89 38                	mov    %edi,(%eax)
		//cprintf("PA[%p], ptep[%p]; *ptep[0x%x]\n", pa, ptep, *ptep);
		//可能通过boot_map_region改变权限, 所以pgdir表项需要做相应调整
		pgdir[PDX(va)] |= perm | PTE_P;
f0101523:	89 d8                	mov    %ebx,%eax
f0101525:	c1 e8 16             	shr    $0x16,%eax
f0101528:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010152b:	09 14 86             	or     %edx,(%esi,%eax,4)
	cprintf("VA: [0x%x]; PA: [0x%x]\n", va, pa);
	va &= ~0xfff;
	pa &= ~0xfff;

	//注意判断条件：KERNBASE + 1G 会溢出uint32_t！
	for ( ; size != 0; va += PGSIZE, pa += PGSIZE, size -= PGSIZE){
f010152e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101534:	81 6d e4 00 10 00 00 	subl   $0x1000,-0x1c(%ebp)
f010153b:	75 a0                	jne    f01014dd <boot_map_region+0x4a>
		*ptep = pa | perm | PTE_P;
		//cprintf("PA[%p], ptep[%p]; *ptep[0x%x]\n", pa, ptep, *ptep);
		//可能通过boot_map_region改变权限, 所以pgdir表项需要做相应调整
		pgdir[PDX(va)] |= perm | PTE_P;
	}
}
f010153d:	83 c4 2c             	add    $0x2c,%esp
f0101540:	5b                   	pop    %ebx
f0101541:	5e                   	pop    %esi
f0101542:	5f                   	pop    %edi
f0101543:	5d                   	pop    %ebp
f0101544:	c3                   	ret    

f0101545 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.

struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101545:	55                   	push   %ebp
f0101546:	89 e5                	mov    %esp,%ebp
f0101548:	53                   	push   %ebx
f0101549:	83 ec 14             	sub    $0x14,%esp
f010154c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	// pgdir_walk只负责返回page table entry, 至于检查PTE_P, present位的职责，
	// 应该交给page_lookup. (所以pgdir_walk里面的确应该将PTE_P置位为0)
	pde_t *ptep = pgdir_walk(pgdir, va, 0);
f010154f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101556:	00 
f0101557:	8b 45 0c             	mov    0xc(%ebp),%eax
f010155a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010155e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101561:	89 04 24             	mov    %eax,(%esp)
f0101564:	e8 42 fe ff ff       	call   f01013ab <pgdir_walk>
	if (!ptep)
f0101569:	85 c0                	test   %eax,%eax
f010156b:	74 3e                	je     f01015ab <page_lookup+0x66>
		return NULL;
	if (pte_store)
f010156d:	85 db                	test   %ebx,%ebx
f010156f:	74 02                	je     f0101573 <page_lookup+0x2e>
		*pte_store = ptep;
f0101571:	89 03                	mov    %eax,(%ebx)
	if (*ptep & PTE_P)//只有当PTE_P置位时，才返回Page *
f0101573:	8b 00                	mov    (%eax),%eax
f0101575:	a8 01                	test   $0x1,%al
f0101577:	74 39                	je     f01015b2 <page_lookup+0x6d>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101579:	c1 e8 0c             	shr    $0xc,%eax
f010157c:	3b 05 88 6e 1d f0    	cmp    0xf01d6e88,%eax
f0101582:	72 1c                	jb     f01015a0 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f0101584:	c7 44 24 08 68 76 10 	movl   $0xf0107668,0x8(%esp)
f010158b:	f0 
f010158c:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101593:	00 
f0101594:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f010159b:	e8 a0 ea ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01015a0:	8b 15 90 6e 1d f0    	mov    0xf01d6e90,%edx
f01015a6:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		return pa2page(PTE_ADDR(*ptep));
f01015a9:	eb 0c                	jmp    f01015b7 <page_lookup+0x72>
	// Fill this function in
	// pgdir_walk只负责返回page table entry, 至于检查PTE_P, present位的职责，
	// 应该交给page_lookup. (所以pgdir_walk里面的确应该将PTE_P置位为0)
	pde_t *ptep = pgdir_walk(pgdir, va, 0);
	if (!ptep)
		return NULL;
f01015ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01015b0:	eb 05                	jmp    f01015b7 <page_lookup+0x72>
	if (pte_store)
		*pte_store = ptep;
	if (*ptep & PTE_P)//只有当PTE_P置位时，才返回Page *
		return pa2page(PTE_ADDR(*ptep));
	return NULL;
f01015b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015b7:	83 c4 14             	add    $0x14,%esp
f01015ba:	5b                   	pop    %ebx
f01015bb:	5d                   	pop    %ebp
f01015bc:	c3                   	ret    

f01015bd <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01015bd:	55                   	push   %ebp
f01015be:	89 e5                	mov    %esp,%ebp
f01015c0:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01015c3:	e8 74 51 00 00       	call   f010673c <cpunum>
f01015c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01015cb:	83 b8 28 70 1d f0 00 	cmpl   $0x0,-0xfe28fd8(%eax)
f01015d2:	74 16                	je     f01015ea <tlb_invalidate+0x2d>
f01015d4:	e8 63 51 00 00       	call   f010673c <cpunum>
f01015d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01015dc:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f01015e2:	8b 55 08             	mov    0x8(%ebp),%edx
f01015e5:	39 50 60             	cmp    %edx,0x60(%eax)
f01015e8:	75 06                	jne    f01015f0 <tlb_invalidate+0x33>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01015ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015ed:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01015f0:	c9                   	leave  
f01015f1:	c3                   	ret    

f01015f2 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01015f2:	55                   	push   %ebp
f01015f3:	89 e5                	mov    %esp,%ebp
f01015f5:	83 ec 28             	sub    $0x28,%esp
f01015f8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01015fb:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01015fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101601:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in

	struct Page *page = NULL;
	pte_t *ptep = NULL;
f0101604:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	if ((page = page_lookup(pgdir, va, &ptep)) != NULL){
f010160b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010160e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101612:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101616:	89 1c 24             	mov    %ebx,(%esp)
f0101619:	e8 27 ff ff ff       	call   f0101545 <page_lookup>
f010161e:	85 c0                	test   %eax,%eax
f0101620:	74 1d                	je     f010163f <page_remove+0x4d>
		page_decref(page);
f0101622:	89 04 24             	mov    %eax,(%esp)
f0101625:	e8 5e fd ff ff       	call   f0101388 <page_decref>
		*ptep = *ptep & (0xfff & ~PTE_P);
f010162a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010162d:	81 20 fe 0f 00 00    	andl   $0xffe,(%eax)
		tlb_invalidate(pgdir, va);
f0101633:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101637:	89 1c 24             	mov    %ebx,(%esp)
f010163a:	e8 7e ff ff ff       	call   f01015bd <tlb_invalidate>
	}
}
f010163f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101642:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101645:	89 ec                	mov    %ebp,%esp
f0101647:	5d                   	pop    %ebp
f0101648:	c3                   	ret    

f0101649 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f0101649:	55                   	push   %ebp
f010164a:	89 e5                	mov    %esp,%ebp
f010164c:	83 ec 28             	sub    $0x28,%esp
f010164f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101652:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101655:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101658:	8b 75 0c             	mov    0xc(%ebp),%esi
f010165b:	8b 7d 10             	mov    0x10(%ebp),%edi
	//Fill this function in
	//cprintf("in page_insert\n");
	pte_t *ptep = pgdir_walk(pgdir, va, 1);
f010165e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101665:	00 
f0101666:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010166a:	8b 45 08             	mov    0x8(%ebp),%eax
f010166d:	89 04 24             	mov    %eax,(%esp)
f0101670:	e8 36 fd ff ff       	call   f01013ab <pgdir_walk>
f0101675:	89 c3                	mov    %eax,%ebx
	if (!ptep){
f0101677:	85 c0                	test   %eax,%eax
f0101679:	74 36                	je     f01016b1 <page_insert+0x68>

	//这儿非常trick!
	//如果va, pp和以前的调用的page_insert相同，且pp->pp_ref++写在page_remove()
	//下面的话, page_remove()就会把pp放到page_free_list上了
	//所以必须先ref++,再检测page_remove()
	pp->pp_ref++;
f010167b:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if (*ptep & PTE_P){
f0101680:	f6 00 01             	testb  $0x1,(%eax)
f0101683:	74 0f                	je     f0101694 <page_insert+0x4b>
		pmap_cprintf("NEED page_remove()\n");
		page_remove(pgdir, va);
f0101685:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101689:	8b 45 08             	mov    0x8(%ebp),%eax
f010168c:	89 04 24             	mov    %eax,(%esp)
f010168f:	e8 5e ff ff ff       	call   f01015f2 <page_remove>
	}
	*ptep = page2pa(pp) | perm | PTE_P;
f0101694:	8b 45 14             	mov    0x14(%ebp),%eax
f0101697:	83 c8 01             	or     $0x1,%eax
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f010169a:	2b 35 90 6e 1d f0    	sub    0xf01d6e90,%esi
f01016a0:	c1 fe 03             	sar    $0x3,%esi
f01016a3:	c1 e6 0c             	shl    $0xc,%esi
f01016a6:	09 c6                	or     %eax,%esi
f01016a8:	89 33                	mov    %esi,(%ebx)
	//pgdir[PDX(va)] |= *ptep & 0xfff;
	pmap_cprintf("ptep[%p]; env_pgdir[%p]; va[%p]; PDX(va)[%d]; pgdir[PDX(va)][%p]", 
		ptep, pgdir, va, PDX(va), pgdir[PDX(va)]);
	//tlb_invalidate(pgdir, va);
	//cprintf("end of page_insert\n");
	return 0;
f01016aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01016af:	eb 05                	jmp    f01016b6 <page_insert+0x6d>
	//Fill this function in
	//cprintf("in page_insert\n");
	pte_t *ptep = pgdir_walk(pgdir, va, 1);
	if (!ptep){
		pmap_cprintf(" No ptep\n");
		return -E_NO_MEM;
f01016b1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pmap_cprintf("ptep[%p]; env_pgdir[%p]; va[%p]; PDX(va)[%d]; pgdir[PDX(va)][%p]", 
		ptep, pgdir, va, PDX(va), pgdir[PDX(va)]);
	//tlb_invalidate(pgdir, va);
	//cprintf("end of page_insert\n");
	return 0;
}
f01016b6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01016b9:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01016bc:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01016bf:	89 ec                	mov    %ebp,%esp
f01016c1:	5d                   	pop    %ebp
f01016c2:	c3                   	ret    

f01016c3 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01016c3:	55                   	push   %ebp
f01016c4:	89 e5                	mov    %esp,%ebp
f01016c6:	57                   	push   %edi
f01016c7:	56                   	push   %esi
f01016c8:	53                   	push   %ebx
f01016c9:	83 ec 4c             	sub    $0x4c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01016cc:	b8 15 00 00 00       	mov    $0x15,%eax
f01016d1:	e8 1d f5 ff ff       	call   f0100bf3 <nvram_read>
f01016d6:	c1 e0 0a             	shl    $0xa,%eax
f01016d9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01016df:	85 c0                	test   %eax,%eax
f01016e1:	0f 48 c2             	cmovs  %edx,%eax
f01016e4:	c1 f8 0c             	sar    $0xc,%eax
f01016e7:	a3 38 62 1d f0       	mov    %eax,0xf01d6238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01016ec:	b8 17 00 00 00       	mov    $0x17,%eax
f01016f1:	e8 fd f4 ff ff       	call   f0100bf3 <nvram_read>
f01016f6:	c1 e0 0a             	shl    $0xa,%eax
f01016f9:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01016ff:	85 c0                	test   %eax,%eax
f0101701:	0f 49 d8             	cmovns %eax,%ebx
f0101704:	c1 fb 0c             	sar    $0xc,%ebx

	cprintf("\nnpages_basemem is [%d]KB: [%d]pages\n", 
		npages_basemem*PGSIZE/1024, npages_basemem);
f0101707:	a1 38 62 1d f0       	mov    0xf01d6238,%eax
	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;

	cprintf("\nnpages_basemem is [%d]KB: [%d]pages\n", 
f010170c:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages_basemem*PGSIZE/1024, npages_basemem);
f0101710:	c1 e0 0c             	shl    $0xc,%eax
	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;

	cprintf("\nnpages_basemem is [%d]KB: [%d]pages\n", 
f0101713:	c1 e8 0a             	shr    $0xa,%eax
f0101716:	89 44 24 04          	mov    %eax,0x4(%esp)
f010171a:	c7 04 24 88 76 10 f0 	movl   $0xf0107688,(%esp)
f0101721:	e8 70 28 00 00       	call   f0103f96 <cprintf>
		npages_basemem*PGSIZE/1024, npages_basemem);
	cprintf("npages_extmem is [%d]KB: [%d]pages\n",
		npages_extmem*PGSIZE/1024, npages_extmem);
f0101726:	89 df                	mov    %ebx,%edi
f0101728:	c1 e7 0c             	shl    $0xc,%edi
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;

	cprintf("\nnpages_basemem is [%d]KB: [%d]pages\n", 
		npages_basemem*PGSIZE/1024, npages_basemem);
	cprintf("npages_extmem is [%d]KB: [%d]pages\n",
f010172b:	89 fe                	mov    %edi,%esi
f010172d:	c1 ee 0a             	shr    $0xa,%esi
f0101730:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101734:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101738:	c7 04 24 b0 76 10 f0 	movl   $0xf01076b0,(%esp)
f010173f:	e8 52 28 00 00       	call   f0103f96 <cprintf>
		npages_extmem*PGSIZE/1024, npages_extmem);

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101744:	85 db                	test   %ebx,%ebx
f0101746:	74 0e                	je     f0101756 <mem_init+0x93>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101748:	81 c3 00 01 00 00    	add    $0x100,%ebx
f010174e:	89 1d 88 6e 1d f0    	mov    %ebx,0xf01d6e88
f0101754:	eb 0a                	jmp    f0101760 <mem_init+0x9d>
	else
		npages = npages_basemem;
f0101756:	a1 38 62 1d f0       	mov    0xf01d6238,%eax
f010175b:	a3 88 6e 1d f0       	mov    %eax,0xf01d6e88
	cprintf("npages(total pages of PM) is [%d]\n", npages);
f0101760:	a1 88 6e 1d f0       	mov    0xf01d6e88,%eax
f0101765:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101769:	c7 04 24 d4 76 10 f0 	movl   $0xf01076d4,(%esp)
f0101770:	e8 21 28 00 00       	call   f0103f96 <cprintf>
	cprintf("\nPhysical memory: %uK:[%uMB] available", npages*PGSIZE/1024,
		npages * PGSIZE / (1024*1024));
f0101775:	a1 88 6e 1d f0       	mov    0xf01d6e88,%eax
f010177a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;
	cprintf("npages(total pages of PM) is [%d]\n", npages);
	cprintf("\nPhysical memory: %uK:[%uMB] available", npages*PGSIZE/1024,
f010177d:	89 c2                	mov    %eax,%edx
f010177f:	c1 ea 14             	shr    $0x14,%edx
f0101782:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101786:	c1 e8 0a             	shr    $0xa,%eax
f0101789:	89 44 24 04          	mov    %eax,0x4(%esp)
f010178d:	c7 04 24 f8 76 10 f0 	movl   $0xf01076f8,(%esp)
f0101794:	e8 fd 27 00 00       	call   f0103f96 <cprintf>
		npages * PGSIZE / (1024*1024));
	cprintf("\nbase = %uK[0x%x], extended = %uK[0x%x]\n",
		npages_basemem * PGSIZE / 1024,
f0101799:	a1 38 62 1d f0       	mov    0xf01d6238,%eax
f010179e:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;
	cprintf("npages(total pages of PM) is [%d]\n", npages);
	cprintf("\nPhysical memory: %uK:[%uMB] available", npages*PGSIZE/1024,
		npages * PGSIZE / (1024*1024));
	cprintf("\nbase = %uK[0x%x], extended = %uK[0x%x]\n",
f01017a1:	89 7c 24 10          	mov    %edi,0x10(%esp)
f01017a5:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01017a9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017ad:	c1 e8 0a             	shr    $0xa,%eax
f01017b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017b4:	c7 04 24 20 77 10 f0 	movl   $0xf0107720,(%esp)
f01017bb:	e8 d6 27 00 00       	call   f0103f96 <cprintf>
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	// 
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01017c0:	b8 00 10 00 00       	mov    $0x1000,%eax
f01017c5:	e8 46 f3 ff ff       	call   f0100b10 <boot_alloc>
f01017ca:	a3 8c 6e 1d f0       	mov    %eax,0xf01d6e8c
	memset(kern_pgdir, 0, PGSIZE);
f01017cf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01017d6:	00 
f01017d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01017de:	00 
f01017df:	89 04 24             	mov    %eax,(%esp)
f01017e2:	e8 ae 48 00 00       	call   f0106095 <memset>

	cprintf("\nInitialize page directory at VA[kern_pgdir: %p]\n", kern_pgdir);
f01017e7:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f01017ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017f0:	c7 04 24 4c 77 10 f0 	movl   $0xf010774c,(%esp)
f01017f7:	e8 9a 27 00 00       	call   f0103f96 <cprintf>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01017fc:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101801:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101806:	77 20                	ja     f0101828 <mem_init+0x165>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101808:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010180c:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0101813:	f0 
f0101814:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
f010181b:	00 
f010181c:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101823:	e8 18 e8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101828:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010182e:	83 ca 05             	or     $0x5,%edx
f0101831:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	
	cprintf("\nUVPT = [0x%x];\nPDX(UVPT) = [%d: 0x%x];\nkern_pgdir[PDX(UVPY)]=[0x%x] with perm = [%p]\n",
f0101837:	c7 44 24 14 05 00 00 	movl   $0x5,0x14(%esp)
f010183e:	00 
f010183f:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101843:	c7 44 24 0c bd 03 00 	movl   $0x3bd,0xc(%esp)
f010184a:	00 
f010184b:	c7 44 24 08 bd 03 00 	movl   $0x3bd,0x8(%esp)
f0101852:	00 
f0101853:	c7 44 24 04 00 00 40 	movl   $0xef400000,0x4(%esp)
f010185a:	ef 
f010185b:	c7 04 24 80 77 10 f0 	movl   $0xf0107780,(%esp)
f0101862:	e8 2f 27 00 00       	call   f0103f96 <cprintf>
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:

	/* 16639 pages of the whole physical memory mapped to page array in virtual 
	 * memory which store these info */
	pages = (struct Page *) boot_alloc(sizeof(struct Page) * npages);
f0101867:	a1 88 6e 1d f0       	mov    0xf01d6e88,%eax
f010186c:	c1 e0 03             	shl    $0x3,%eax
f010186f:	e8 9c f2 ff ff       	call   f0100b10 <boot_alloc>
f0101874:	a3 90 6e 1d f0       	mov    %eax,0xf01d6e90

	cprintf("\nsizeof(struct Page): [%d]; npages: [%d]\n", sizeof(struct Page), npages);
f0101879:	a1 88 6e 1d f0       	mov    0xf01d6e88,%eax
f010187e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101882:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
f0101889:	00 
f010188a:	c7 04 24 d8 77 10 f0 	movl   $0xf01077d8,(%esp)
f0101891:	e8 00 27 00 00       	call   f0103f96 <cprintf>
	cprintf("Pages allocated at address: [0x%x]\n", pages);
f0101896:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f010189b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010189f:	c7 04 24 04 78 10 f0 	movl   $0xf0107804,(%esp)
f01018a6:	e8 eb 26 00 00       	call   f0103f96 <cprintf>
	
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f01018ab:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01018b0:	e8 5b f2 ff ff       	call   f0100b10 <boot_alloc>
f01018b5:	a3 48 62 1d f0       	mov    %eax,0xf01d6248
	
	cprintf("\nsizeof(struct ENV): [%d]; NENV: [%d]\n", sizeof(struct Env), NENV);
f01018ba:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
f01018c1:	00 
f01018c2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
f01018c9:	00 
f01018ca:	c7 04 24 28 78 10 f0 	movl   $0xf0107828,(%esp)
f01018d1:	e8 c0 26 00 00       	call   f0103f96 <cprintf>
	cprintf("envs allocated at address: [0x%x]\n", envs);
f01018d6:	a1 48 62 1d f0       	mov    0xf01d6248,%eax
f01018db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018df:	c7 04 24 50 78 10 f0 	movl   $0xf0107850,(%esp)
f01018e6:	e8 ab 26 00 00       	call   f0103f96 <cprintf>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01018eb:	e8 5c f7 ff ff       	call   f010104c <page_init>

	check_page_free_list(1);
f01018f0:	b8 01 00 00 00       	mov    $0x1,%eax
f01018f5:	e8 2b f3 ff ff       	call   f0100c25 <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f01018fa:	83 3d 90 6e 1d f0 00 	cmpl   $0x0,0xf01d6e90
f0101901:	75 1c                	jne    f010191f <mem_init+0x25c>
		panic("'pages' is a null pointer!");
f0101903:	c7 44 24 08 0b 80 10 	movl   $0xf010800b,0x8(%esp)
f010190a:	f0 
f010190b:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0101912:	00 
f0101913:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f010191a:	e8 21 e7 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	//cprintf("\npage_free_list[%p] in check_page_alloc\n",page_free_list);
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010191f:	a1 40 62 1d f0       	mov    0xf01d6240,%eax
f0101924:	85 c0                	test   %eax,%eax
f0101926:	74 10                	je     f0101938 <mem_init+0x275>
f0101928:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f010192d:	83 c3 01             	add    $0x1,%ebx
	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	//cprintf("\npage_free_list[%p] in check_page_alloc\n",page_free_list);
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101930:	8b 00                	mov    (%eax),%eax
f0101932:	85 c0                	test   %eax,%eax
f0101934:	75 f7                	jne    f010192d <mem_init+0x26a>
f0101936:	eb 05                	jmp    f010193d <mem_init+0x27a>
f0101938:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010193d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101944:	e8 ab f9 ff ff       	call   f01012f4 <page_alloc>
f0101949:	89 c7                	mov    %eax,%edi
f010194b:	85 c0                	test   %eax,%eax
f010194d:	75 24                	jne    f0101973 <mem_init+0x2b0>
f010194f:	c7 44 24 0c 26 80 10 	movl   $0xf0108026,0xc(%esp)
f0101956:	f0 
f0101957:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f010195e:	f0 
f010195f:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0101966:	00 
f0101967:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f010196e:	e8 cd e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101973:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010197a:	e8 75 f9 ff ff       	call   f01012f4 <page_alloc>
f010197f:	89 c6                	mov    %eax,%esi
f0101981:	85 c0                	test   %eax,%eax
f0101983:	75 24                	jne    f01019a9 <mem_init+0x2e6>
f0101985:	c7 44 24 0c 3c 80 10 	movl   $0xf010803c,0xc(%esp)
f010198c:	f0 
f010198d:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101994:	f0 
f0101995:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f010199c:	00 
f010199d:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01019a4:	e8 97 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01019a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019b0:	e8 3f f9 ff ff       	call   f01012f4 <page_alloc>
f01019b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019b8:	85 c0                	test   %eax,%eax
f01019ba:	75 24                	jne    f01019e0 <mem_init+0x31d>
f01019bc:	c7 44 24 0c 52 80 10 	movl   $0xf0108052,0xc(%esp)
f01019c3:	f0 
f01019c4:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01019cb:	f0 
f01019cc:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f01019d3:	00 
f01019d4:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01019db:	e8 60 e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019e0:	39 f7                	cmp    %esi,%edi
f01019e2:	75 24                	jne    f0101a08 <mem_init+0x345>
f01019e4:	c7 44 24 0c 68 80 10 	movl   $0xf0108068,0xc(%esp)
f01019eb:	f0 
f01019ec:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01019f3:	f0 
f01019f4:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f01019fb:	00 
f01019fc:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101a03:	e8 38 e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a08:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101a0b:	74 05                	je     f0101a12 <mem_init+0x34f>
f0101a0d:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101a10:	75 24                	jne    f0101a36 <mem_init+0x373>
f0101a12:	c7 44 24 0c 74 78 10 	movl   $0xf0107874,0xc(%esp)
f0101a19:	f0 
f0101a1a:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101a21:	f0 
f0101a22:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f0101a29:	00 
f0101a2a:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101a31:	e8 0a e6 ff ff       	call   f0100040 <_panic>
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f0101a36:	8b 15 90 6e 1d f0    	mov    0xf01d6e90,%edx

	assert(page2pa(pp0) < npages*PGSIZE);
f0101a3c:	a1 88 6e 1d f0       	mov    0xf01d6e88,%eax
f0101a41:	c1 e0 0c             	shl    $0xc,%eax
f0101a44:	89 f9                	mov    %edi,%ecx
f0101a46:	29 d1                	sub    %edx,%ecx
f0101a48:	c1 f9 03             	sar    $0x3,%ecx
f0101a4b:	c1 e1 0c             	shl    $0xc,%ecx
f0101a4e:	39 c1                	cmp    %eax,%ecx
f0101a50:	72 24                	jb     f0101a76 <mem_init+0x3b3>
f0101a52:	c7 44 24 0c 7a 80 10 	movl   $0xf010807a,0xc(%esp)
f0101a59:	f0 
f0101a5a:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101a61:	f0 
f0101a62:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0101a69:	00 
f0101a6a:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101a71:	e8 ca e5 ff ff       	call   f0100040 <_panic>
f0101a76:	89 f1                	mov    %esi,%ecx
f0101a78:	29 d1                	sub    %edx,%ecx
f0101a7a:	c1 f9 03             	sar    $0x3,%ecx
f0101a7d:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101a80:	39 c8                	cmp    %ecx,%eax
f0101a82:	77 24                	ja     f0101aa8 <mem_init+0x3e5>
f0101a84:	c7 44 24 0c 97 80 10 	movl   $0xf0108097,0xc(%esp)
f0101a8b:	f0 
f0101a8c:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101a93:	f0 
f0101a94:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101a9b:	00 
f0101a9c:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101aa3:	e8 98 e5 ff ff       	call   f0100040 <_panic>
f0101aa8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101aab:	29 d1                	sub    %edx,%ecx
f0101aad:	89 ca                	mov    %ecx,%edx
f0101aaf:	c1 fa 03             	sar    $0x3,%edx
f0101ab2:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101ab5:	39 d0                	cmp    %edx,%eax
f0101ab7:	77 24                	ja     f0101add <mem_init+0x41a>
f0101ab9:	c7 44 24 0c b4 80 10 	movl   $0xf01080b4,0xc(%esp)
f0101ac0:	f0 
f0101ac1:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101ac8:	f0 
f0101ac9:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101ad0:	00 
f0101ad1:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101ad8:	e8 63 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101add:	a1 40 62 1d f0       	mov    0xf01d6240,%eax
f0101ae2:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101ae5:	c7 05 40 62 1d f0 00 	movl   $0x0,0xf01d6240
f0101aec:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101aef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101af6:	e8 f9 f7 ff ff       	call   f01012f4 <page_alloc>
f0101afb:	85 c0                	test   %eax,%eax
f0101afd:	74 24                	je     f0101b23 <mem_init+0x460>
f0101aff:	c7 44 24 0c d1 80 10 	movl   $0xf01080d1,0xc(%esp)
f0101b06:	f0 
f0101b07:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101b0e:	f0 
f0101b0f:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0101b16:	00 
f0101b17:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101b1e:	e8 1d e5 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101b23:	89 3c 24             	mov    %edi,(%esp)
f0101b26:	e8 48 f8 ff ff       	call   f0101373 <page_free>
	page_free(pp1);
f0101b2b:	89 34 24             	mov    %esi,(%esp)
f0101b2e:	e8 40 f8 ff ff       	call   f0101373 <page_free>
	page_free(pp2);
f0101b33:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b36:	89 04 24             	mov    %eax,(%esp)
f0101b39:	e8 35 f8 ff ff       	call   f0101373 <page_free>
	pp0 = pp1 = pp2 = 0;

	assert((pp0 = page_alloc(0)));
f0101b3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b45:	e8 aa f7 ff ff       	call   f01012f4 <page_alloc>
f0101b4a:	89 c6                	mov    %eax,%esi
f0101b4c:	85 c0                	test   %eax,%eax
f0101b4e:	75 24                	jne    f0101b74 <mem_init+0x4b1>
f0101b50:	c7 44 24 0c 26 80 10 	movl   $0xf0108026,0xc(%esp)
f0101b57:	f0 
f0101b58:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101b5f:	f0 
f0101b60:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101b67:	00 
f0101b68:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101b6f:	e8 cc e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b7b:	e8 74 f7 ff ff       	call   f01012f4 <page_alloc>
f0101b80:	89 c7                	mov    %eax,%edi
f0101b82:	85 c0                	test   %eax,%eax
f0101b84:	75 24                	jne    f0101baa <mem_init+0x4e7>
f0101b86:	c7 44 24 0c 3c 80 10 	movl   $0xf010803c,0xc(%esp)
f0101b8d:	f0 
f0101b8e:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101b95:	f0 
f0101b96:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0101b9d:	00 
f0101b9e:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101ba5:	e8 96 e4 ff ff       	call   f0100040 <_panic>

	assert((pp2 = page_alloc(0)));
f0101baa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bb1:	e8 3e f7 ff ff       	call   f01012f4 <page_alloc>
f0101bb6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101bb9:	85 c0                	test   %eax,%eax
f0101bbb:	75 24                	jne    f0101be1 <mem_init+0x51e>
f0101bbd:	c7 44 24 0c 52 80 10 	movl   $0xf0108052,0xc(%esp)
f0101bc4:	f0 
f0101bc5:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101bcc:	f0 
f0101bcd:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0101bd4:	00 
f0101bd5:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101bdc:	e8 5f e4 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101be1:	39 fe                	cmp    %edi,%esi
f0101be3:	75 24                	jne    f0101c09 <mem_init+0x546>
f0101be5:	c7 44 24 0c 68 80 10 	movl   $0xf0108068,0xc(%esp)
f0101bec:	f0 
f0101bed:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101bf4:	f0 
f0101bf5:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0101bfc:	00 
f0101bfd:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101c04:	e8 37 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c09:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101c0c:	74 05                	je     f0101c13 <mem_init+0x550>
f0101c0e:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101c11:	75 24                	jne    f0101c37 <mem_init+0x574>
f0101c13:	c7 44 24 0c 74 78 10 	movl   $0xf0107874,0xc(%esp)
f0101c1a:	f0 
f0101c1b:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101c22:	f0 
f0101c23:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0101c2a:	00 
f0101c2b:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101c32:	e8 09 e4 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101c37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c3e:	e8 b1 f6 ff ff       	call   f01012f4 <page_alloc>
f0101c43:	85 c0                	test   %eax,%eax
f0101c45:	74 24                	je     f0101c6b <mem_init+0x5a8>
f0101c47:	c7 44 24 0c d1 80 10 	movl   $0xf01080d1,0xc(%esp)
f0101c4e:	f0 
f0101c4f:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101c56:	f0 
f0101c57:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0101c5e:	00 
f0101c5f:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101c66:	e8 d5 e3 ff ff       	call   f0100040 <_panic>
f0101c6b:	89 f0                	mov    %esi,%eax
f0101c6d:	2b 05 90 6e 1d f0    	sub    0xf01d6e90,%eax
f0101c73:	c1 f8 03             	sar    $0x3,%eax
f0101c76:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c79:	89 c2                	mov    %eax,%edx
f0101c7b:	c1 ea 0c             	shr    $0xc,%edx
f0101c7e:	3b 15 88 6e 1d f0    	cmp    0xf01d6e88,%edx
f0101c84:	72 20                	jb     f0101ca6 <mem_init+0x5e3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c86:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c8a:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f0101c91:	f0 
f0101c92:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0101c99:	00 
f0101c9a:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f0101ca1:	e8 9a e3 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101ca6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101cad:	00 
f0101cae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101cb5:	00 
	return (void *)(pa + KERNBASE);
f0101cb6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cbb:	89 04 24             	mov    %eax,(%esp)
f0101cbe:	e8 d2 43 00 00       	call   f0106095 <memset>
	page_free(pp0);
f0101cc3:	89 34 24             	mov    %esi,(%esp)
f0101cc6:	e8 a8 f6 ff ff       	call   f0101373 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101ccb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101cd2:	e8 1d f6 ff ff       	call   f01012f4 <page_alloc>
f0101cd7:	85 c0                	test   %eax,%eax
f0101cd9:	75 24                	jne    f0101cff <mem_init+0x63c>
f0101cdb:	c7 44 24 0c e0 80 10 	movl   $0xf01080e0,0xc(%esp)
f0101ce2:	f0 
f0101ce3:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101cea:	f0 
f0101ceb:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101cf2:	00 
f0101cf3:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101cfa:	e8 41 e3 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101cff:	39 c6                	cmp    %eax,%esi
f0101d01:	74 24                	je     f0101d27 <mem_init+0x664>
f0101d03:	c7 44 24 0c fe 80 10 	movl   $0xf01080fe,0xc(%esp)
f0101d0a:	f0 
f0101d0b:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101d12:	f0 
f0101d13:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101d1a:	00 
f0101d1b:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101d22:	e8 19 e3 ff ff       	call   f0100040 <_panic>
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f0101d27:	89 f2                	mov    %esi,%edx
f0101d29:	2b 15 90 6e 1d f0    	sub    0xf01d6e90,%edx
f0101d2f:	c1 fa 03             	sar    $0x3,%edx
f0101d32:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d35:	89 d0                	mov    %edx,%eax
f0101d37:	c1 e8 0c             	shr    $0xc,%eax
f0101d3a:	3b 05 88 6e 1d f0    	cmp    0xf01d6e88,%eax
f0101d40:	72 20                	jb     f0101d62 <mem_init+0x69f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d42:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101d46:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f0101d4d:	f0 
f0101d4e:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0101d55:	00 
f0101d56:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f0101d5d:	e8 de e2 ff ff       	call   f0100040 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101d62:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101d69:	75 11                	jne    f0101d7c <mem_init+0x6b9>
f0101d6b:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101d71:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101d77:	80 38 00             	cmpb   $0x0,(%eax)
f0101d7a:	74 24                	je     f0101da0 <mem_init+0x6dd>
f0101d7c:	c7 44 24 0c 0e 81 10 	movl   $0xf010810e,0xc(%esp)
f0101d83:	f0 
f0101d84:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101d8b:	f0 
f0101d8c:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0101d93:	00 
f0101d94:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101d9b:	e8 a0 e2 ff ff       	call   f0100040 <_panic>
f0101da0:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101da3:	39 d0                	cmp    %edx,%eax
f0101da5:	75 d0                	jne    f0101d77 <mem_init+0x6b4>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101da7:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101daa:	89 15 40 62 1d f0    	mov    %edx,0xf01d6240

	// free the pages we took
	page_free(pp0);
f0101db0:	89 34 24             	mov    %esi,(%esp)
f0101db3:	e8 bb f5 ff ff       	call   f0101373 <page_free>
	page_free(pp1);
f0101db8:	89 3c 24             	mov    %edi,(%esp)
f0101dbb:	e8 b3 f5 ff ff       	call   f0101373 <page_free>
	page_free(pp2);
f0101dc0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dc3:	89 04 24             	mov    %eax,(%esp)
f0101dc6:	e8 a8 f5 ff ff       	call   f0101373 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101dcb:	a1 40 62 1d f0       	mov    0xf01d6240,%eax
f0101dd0:	85 c0                	test   %eax,%eax
f0101dd2:	74 09                	je     f0101ddd <mem_init+0x71a>
		--nfree;
f0101dd4:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101dd7:	8b 00                	mov    (%eax),%eax
f0101dd9:	85 c0                	test   %eax,%eax
f0101ddb:	75 f7                	jne    f0101dd4 <mem_init+0x711>
		--nfree;
	assert(nfree == 0);
f0101ddd:	85 db                	test   %ebx,%ebx
f0101ddf:	74 24                	je     f0101e05 <mem_init+0x742>
f0101de1:	c7 44 24 0c 18 81 10 	movl   $0xf0108118,0xc(%esp)
f0101de8:	f0 
f0101de9:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101df0:	f0 
f0101df1:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0101df8:	00 
f0101df9:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101e00:	e8 3b e2 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101e05:	c7 04 24 94 78 10 f0 	movl   $0xf0107894,(%esp)
f0101e0c:	e8 85 21 00 00       	call   f0103f96 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101e11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e18:	e8 d7 f4 ff ff       	call   f01012f4 <page_alloc>
f0101e1d:	89 c3                	mov    %eax,%ebx
f0101e1f:	85 c0                	test   %eax,%eax
f0101e21:	75 24                	jne    f0101e47 <mem_init+0x784>
f0101e23:	c7 44 24 0c 26 80 10 	movl   $0xf0108026,0xc(%esp)
f0101e2a:	f0 
f0101e2b:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101e32:	f0 
f0101e33:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f0101e3a:	00 
f0101e3b:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101e42:	e8 f9 e1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101e47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e4e:	e8 a1 f4 ff ff       	call   f01012f4 <page_alloc>
f0101e53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101e56:	85 c0                	test   %eax,%eax
f0101e58:	75 24                	jne    f0101e7e <mem_init+0x7bb>
f0101e5a:	c7 44 24 0c 3c 80 10 	movl   $0xf010803c,0xc(%esp)
f0101e61:	f0 
f0101e62:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101e69:	f0 
f0101e6a:	c7 44 24 04 4e 04 00 	movl   $0x44e,0x4(%esp)
f0101e71:	00 
f0101e72:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101e79:	e8 c2 e1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101e7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e85:	e8 6a f4 ff ff       	call   f01012f4 <page_alloc>
f0101e8a:	89 c6                	mov    %eax,%esi
f0101e8c:	85 c0                	test   %eax,%eax
f0101e8e:	75 24                	jne    f0101eb4 <mem_init+0x7f1>
f0101e90:	c7 44 24 0c 52 80 10 	movl   $0xf0108052,0xc(%esp)
f0101e97:	f0 
f0101e98:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101e9f:	f0 
f0101ea0:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0101ea7:	00 
f0101ea8:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101eaf:	e8 8c e1 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101eb4:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0101eb7:	75 24                	jne    f0101edd <mem_init+0x81a>
f0101eb9:	c7 44 24 0c 68 80 10 	movl   $0xf0108068,0xc(%esp)
f0101ec0:	f0 
f0101ec1:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101ec8:	f0 
f0101ec9:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f0101ed0:	00 
f0101ed1:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101ed8:	e8 63 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101edd:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101ee0:	74 04                	je     f0101ee6 <mem_init+0x823>
f0101ee2:	39 c3                	cmp    %eax,%ebx
f0101ee4:	75 24                	jne    f0101f0a <mem_init+0x847>
f0101ee6:	c7 44 24 0c 74 78 10 	movl   $0xf0107874,0xc(%esp)
f0101eed:	f0 
f0101eee:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101ef5:	f0 
f0101ef6:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f0101efd:	00 
f0101efe:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101f05:	e8 36 e1 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101f0a:	8b 3d 40 62 1d f0    	mov    0xf01d6240,%edi
f0101f10:	89 7d c8             	mov    %edi,-0x38(%ebp)
	page_free_list = 0;
f0101f13:	c7 05 40 62 1d f0 00 	movl   $0x0,0xf01d6240
f0101f1a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101f1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f24:	e8 cb f3 ff ff       	call   f01012f4 <page_alloc>
f0101f29:	85 c0                	test   %eax,%eax
f0101f2b:	74 24                	je     f0101f51 <mem_init+0x88e>
f0101f2d:	c7 44 24 0c d1 80 10 	movl   $0xf01080d1,0xc(%esp)
f0101f34:	f0 
f0101f35:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101f3c:	f0 
f0101f3d:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f0101f44:	00 
f0101f45:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101f4c:	e8 ef e0 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101f51:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101f54:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101f58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101f5f:	00 
f0101f60:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0101f65:	89 04 24             	mov    %eax,(%esp)
f0101f68:	e8 d8 f5 ff ff       	call   f0101545 <page_lookup>
f0101f6d:	85 c0                	test   %eax,%eax
f0101f6f:	74 24                	je     f0101f95 <mem_init+0x8d2>
f0101f71:	c7 44 24 0c b4 78 10 	movl   $0xf01078b4,0xc(%esp)
f0101f78:	f0 
f0101f79:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101f80:	f0 
f0101f81:	c7 44 24 04 5d 04 00 	movl   $0x45d,0x4(%esp)
f0101f88:	00 
f0101f89:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101f90:	e8 ab e0 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101f95:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f9c:	00 
f0101f9d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fa4:	00 
f0101fa5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fa8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101fac:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0101fb1:	89 04 24             	mov    %eax,(%esp)
f0101fb4:	e8 90 f6 ff ff       	call   f0101649 <page_insert>
f0101fb9:	85 c0                	test   %eax,%eax
f0101fbb:	78 24                	js     f0101fe1 <mem_init+0x91e>
f0101fbd:	c7 44 24 0c ec 78 10 	movl   $0xf01078ec,0xc(%esp)
f0101fc4:	f0 
f0101fc5:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0101fcc:	f0 
f0101fcd:	c7 44 24 04 60 04 00 	movl   $0x460,0x4(%esp)
f0101fd4:	00 
f0101fd5:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0101fdc:	e8 5f e0 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101fe1:	89 1c 24             	mov    %ebx,(%esp)
f0101fe4:	e8 8a f3 ff ff       	call   f0101373 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101fe9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ff0:	00 
f0101ff1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ff8:	00 
f0101ff9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ffc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102000:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102005:	89 04 24             	mov    %eax,(%esp)
f0102008:	e8 3c f6 ff ff       	call   f0101649 <page_insert>
f010200d:	85 c0                	test   %eax,%eax
f010200f:	74 24                	je     f0102035 <mem_init+0x972>
f0102011:	c7 44 24 0c 1c 79 10 	movl   $0xf010791c,0xc(%esp)
f0102018:	f0 
f0102019:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102020:	f0 
f0102021:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f0102028:	00 
f0102029:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102030:	e8 0b e0 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102035:	8b 3d 8c 6e 1d f0    	mov    0xf01d6e8c,%edi
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f010203b:	8b 15 90 6e 1d f0    	mov    0xf01d6e90,%edx
f0102041:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102044:	8b 17                	mov    (%edi),%edx
f0102046:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010204c:	89 d8                	mov    %ebx,%eax
f010204e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0102051:	c1 f8 03             	sar    $0x3,%eax
f0102054:	c1 e0 0c             	shl    $0xc,%eax
f0102057:	39 c2                	cmp    %eax,%edx
f0102059:	74 24                	je     f010207f <mem_init+0x9bc>
f010205b:	c7 44 24 0c 4c 79 10 	movl   $0xf010794c,0xc(%esp)
f0102062:	f0 
f0102063:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f010206a:	f0 
f010206b:	c7 44 24 04 65 04 00 	movl   $0x465,0x4(%esp)
f0102072:	00 
f0102073:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f010207a:	e8 c1 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010207f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102084:	89 f8                	mov    %edi,%eax
f0102086:	e8 f9 ea ff ff       	call   f0100b84 <check_va2pa>
f010208b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010208e:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0102091:	c1 fa 03             	sar    $0x3,%edx
f0102094:	c1 e2 0c             	shl    $0xc,%edx
f0102097:	39 d0                	cmp    %edx,%eax
f0102099:	74 24                	je     f01020bf <mem_init+0x9fc>
f010209b:	c7 44 24 0c 74 79 10 	movl   $0xf0107974,0xc(%esp)
f01020a2:	f0 
f01020a3:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01020aa:	f0 
f01020ab:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f01020b2:	00 
f01020b3:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01020ba:	e8 81 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01020bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020c2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01020c7:	74 24                	je     f01020ed <mem_init+0xa2a>
f01020c9:	c7 44 24 0c 23 81 10 	movl   $0xf0108123,0xc(%esp)
f01020d0:	f0 
f01020d1:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01020d8:	f0 
f01020d9:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f01020e0:	00 
f01020e1:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01020e8:	e8 53 df ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01020ed:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020f2:	74 24                	je     f0102118 <mem_init+0xa55>
f01020f4:	c7 44 24 0c 34 81 10 	movl   $0xf0108134,0xc(%esp)
f01020fb:	f0 
f01020fc:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102103:	f0 
f0102104:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f010210b:	00 
f010210c:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102113:	e8 28 df ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102118:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010211f:	00 
f0102120:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102127:	00 
f0102128:	89 74 24 04          	mov    %esi,0x4(%esp)
f010212c:	89 3c 24             	mov    %edi,(%esp)
f010212f:	e8 15 f5 ff ff       	call   f0101649 <page_insert>
f0102134:	85 c0                	test   %eax,%eax
f0102136:	74 24                	je     f010215c <mem_init+0xa99>
f0102138:	c7 44 24 0c a4 79 10 	movl   $0xf01079a4,0xc(%esp)
f010213f:	f0 
f0102140:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102147:	f0 
f0102148:	c7 44 24 04 6b 04 00 	movl   $0x46b,0x4(%esp)
f010214f:	00 
f0102150:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102157:	e8 e4 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010215c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102161:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102166:	e8 19 ea ff ff       	call   f0100b84 <check_va2pa>
f010216b:	89 f2                	mov    %esi,%edx
f010216d:	2b 15 90 6e 1d f0    	sub    0xf01d6e90,%edx
f0102173:	c1 fa 03             	sar    $0x3,%edx
f0102176:	c1 e2 0c             	shl    $0xc,%edx
f0102179:	39 d0                	cmp    %edx,%eax
f010217b:	74 24                	je     f01021a1 <mem_init+0xade>
f010217d:	c7 44 24 0c e0 79 10 	movl   $0xf01079e0,0xc(%esp)
f0102184:	f0 
f0102185:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f010218c:	f0 
f010218d:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f0102194:	00 
f0102195:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f010219c:	e8 9f de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01021a1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01021a6:	74 24                	je     f01021cc <mem_init+0xb09>
f01021a8:	c7 44 24 0c 45 81 10 	movl   $0xf0108145,0xc(%esp)
f01021af:	f0 
f01021b0:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01021b7:	f0 
f01021b8:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f01021bf:	00 
f01021c0:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01021c7:	e8 74 de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01021cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021d3:	e8 1c f1 ff ff       	call   f01012f4 <page_alloc>
f01021d8:	85 c0                	test   %eax,%eax
f01021da:	74 24                	je     f0102200 <mem_init+0xb3d>
f01021dc:	c7 44 24 0c d1 80 10 	movl   $0xf01080d1,0xc(%esp)
f01021e3:	f0 
f01021e4:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01021eb:	f0 
f01021ec:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f01021f3:	00 
f01021f4:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01021fb:	e8 40 de ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102200:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102207:	00 
f0102208:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010220f:	00 
f0102210:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102214:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102219:	89 04 24             	mov    %eax,(%esp)
f010221c:	e8 28 f4 ff ff       	call   f0101649 <page_insert>
f0102221:	85 c0                	test   %eax,%eax
f0102223:	74 24                	je     f0102249 <mem_init+0xb86>
f0102225:	c7 44 24 0c a4 79 10 	movl   $0xf01079a4,0xc(%esp)
f010222c:	f0 
f010222d:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102234:	f0 
f0102235:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f010223c:	00 
f010223d:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102244:	e8 f7 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102249:	ba 00 10 00 00       	mov    $0x1000,%edx
f010224e:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102253:	e8 2c e9 ff ff       	call   f0100b84 <check_va2pa>
f0102258:	89 f2                	mov    %esi,%edx
f010225a:	2b 15 90 6e 1d f0    	sub    0xf01d6e90,%edx
f0102260:	c1 fa 03             	sar    $0x3,%edx
f0102263:	c1 e2 0c             	shl    $0xc,%edx
f0102266:	39 d0                	cmp    %edx,%eax
f0102268:	74 24                	je     f010228e <mem_init+0xbcb>
f010226a:	c7 44 24 0c e0 79 10 	movl   $0xf01079e0,0xc(%esp)
f0102271:	f0 
f0102272:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102279:	f0 
f010227a:	c7 44 24 04 74 04 00 	movl   $0x474,0x4(%esp)
f0102281:	00 
f0102282:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102289:	e8 b2 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010228e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102293:	74 24                	je     f01022b9 <mem_init+0xbf6>
f0102295:	c7 44 24 0c 45 81 10 	movl   $0xf0108145,0xc(%esp)
f010229c:	f0 
f010229d:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01022a4:	f0 
f01022a5:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f01022ac:	00 
f01022ad:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01022b4:	e8 87 dd ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01022b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022c0:	e8 2f f0 ff ff       	call   f01012f4 <page_alloc>
f01022c5:	85 c0                	test   %eax,%eax
f01022c7:	74 24                	je     f01022ed <mem_init+0xc2a>
f01022c9:	c7 44 24 0c d1 80 10 	movl   $0xf01080d1,0xc(%esp)
f01022d0:	f0 
f01022d1:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01022d8:	f0 
f01022d9:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f01022e0:	00 
f01022e1:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01022e8:	e8 53 dd ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01022ed:	8b 15 8c 6e 1d f0    	mov    0xf01d6e8c,%edx
f01022f3:	8b 02                	mov    (%edx),%eax
f01022f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022fa:	89 c1                	mov    %eax,%ecx
f01022fc:	c1 e9 0c             	shr    $0xc,%ecx
f01022ff:	3b 0d 88 6e 1d f0    	cmp    0xf01d6e88,%ecx
f0102305:	72 20                	jb     f0102327 <mem_init+0xc64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102307:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010230b:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f0102312:	f0 
f0102313:	c7 44 24 04 7c 04 00 	movl   $0x47c,0x4(%esp)
f010231a:	00 
f010231b:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102322:	e8 19 dd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102327:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010232c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010232f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102336:	00 
f0102337:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010233e:	00 
f010233f:	89 14 24             	mov    %edx,(%esp)
f0102342:	e8 64 f0 ff ff       	call   f01013ab <pgdir_walk>
f0102347:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010234a:	83 c2 04             	add    $0x4,%edx
f010234d:	39 d0                	cmp    %edx,%eax
f010234f:	74 24                	je     f0102375 <mem_init+0xcb2>
f0102351:	c7 44 24 0c 10 7a 10 	movl   $0xf0107a10,0xc(%esp)
f0102358:	f0 
f0102359:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102360:	f0 
f0102361:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f0102368:	00 
f0102369:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102370:	e8 cb dc ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102375:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010237c:	00 
f010237d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102384:	00 
f0102385:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102389:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f010238e:	89 04 24             	mov    %eax,(%esp)
f0102391:	e8 b3 f2 ff ff       	call   f0101649 <page_insert>
f0102396:	85 c0                	test   %eax,%eax
f0102398:	74 24                	je     f01023be <mem_init+0xcfb>
f010239a:	c7 44 24 0c 50 7a 10 	movl   $0xf0107a50,0xc(%esp)
f01023a1:	f0 
f01023a2:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01023a9:	f0 
f01023aa:	c7 44 24 04 80 04 00 	movl   $0x480,0x4(%esp)
f01023b1:	00 
f01023b2:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01023b9:	e8 82 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023be:	8b 3d 8c 6e 1d f0    	mov    0xf01d6e8c,%edi
f01023c4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023c9:	89 f8                	mov    %edi,%eax
f01023cb:	e8 b4 e7 ff ff       	call   f0100b84 <check_va2pa>
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f01023d0:	89 f2                	mov    %esi,%edx
f01023d2:	2b 15 90 6e 1d f0    	sub    0xf01d6e90,%edx
f01023d8:	c1 fa 03             	sar    $0x3,%edx
f01023db:	c1 e2 0c             	shl    $0xc,%edx
f01023de:	39 d0                	cmp    %edx,%eax
f01023e0:	74 24                	je     f0102406 <mem_init+0xd43>
f01023e2:	c7 44 24 0c e0 79 10 	movl   $0xf01079e0,0xc(%esp)
f01023e9:	f0 
f01023ea:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01023f1:	f0 
f01023f2:	c7 44 24 04 81 04 00 	movl   $0x481,0x4(%esp)
f01023f9:	00 
f01023fa:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102401:	e8 3a dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102406:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010240b:	74 24                	je     f0102431 <mem_init+0xd6e>
f010240d:	c7 44 24 0c 45 81 10 	movl   $0xf0108145,0xc(%esp)
f0102414:	f0 
f0102415:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f010241c:	f0 
f010241d:	c7 44 24 04 82 04 00 	movl   $0x482,0x4(%esp)
f0102424:	00 
f0102425:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f010242c:	e8 0f dc ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102431:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102438:	00 
f0102439:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102440:	00 
f0102441:	89 3c 24             	mov    %edi,(%esp)
f0102444:	e8 62 ef ff ff       	call   f01013ab <pgdir_walk>
f0102449:	f6 00 04             	testb  $0x4,(%eax)
f010244c:	75 24                	jne    f0102472 <mem_init+0xdaf>
f010244e:	c7 44 24 0c 90 7a 10 	movl   $0xf0107a90,0xc(%esp)
f0102455:	f0 
f0102456:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f010245d:	f0 
f010245e:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f0102465:	00 
f0102466:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f010246d:	e8 ce db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102472:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102477:	f6 00 04             	testb  $0x4,(%eax)
f010247a:	75 24                	jne    f01024a0 <mem_init+0xddd>
f010247c:	c7 44 24 0c 56 81 10 	movl   $0xf0108156,0xc(%esp)
f0102483:	f0 
f0102484:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f010248b:	f0 
f010248c:	c7 44 24 04 84 04 00 	movl   $0x484,0x4(%esp)
f0102493:	00 
f0102494:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f010249b:	e8 a0 db ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01024a0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01024a7:	00 
f01024a8:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01024af:	00 
f01024b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01024b4:	89 04 24             	mov    %eax,(%esp)
f01024b7:	e8 8d f1 ff ff       	call   f0101649 <page_insert>
f01024bc:	85 c0                	test   %eax,%eax
f01024be:	78 24                	js     f01024e4 <mem_init+0xe21>
f01024c0:	c7 44 24 0c c4 7a 10 	movl   $0xf0107ac4,0xc(%esp)
f01024c7:	f0 
f01024c8:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01024cf:	f0 
f01024d0:	c7 44 24 04 87 04 00 	movl   $0x487,0x4(%esp)
f01024d7:	00 
f01024d8:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01024df:	e8 5c db ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01024e4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01024eb:	00 
f01024ec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024f3:	00 
f01024f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01024fb:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102500:	89 04 24             	mov    %eax,(%esp)
f0102503:	e8 41 f1 ff ff       	call   f0101649 <page_insert>
f0102508:	85 c0                	test   %eax,%eax
f010250a:	74 24                	je     f0102530 <mem_init+0xe6d>
f010250c:	c7 44 24 0c fc 7a 10 	movl   $0xf0107afc,0xc(%esp)
f0102513:	f0 
f0102514:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f010251b:	f0 
f010251c:	c7 44 24 04 8a 04 00 	movl   $0x48a,0x4(%esp)
f0102523:	00 
f0102524:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f010252b:	e8 10 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102530:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102537:	00 
f0102538:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010253f:	00 
f0102540:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102545:	89 04 24             	mov    %eax,(%esp)
f0102548:	e8 5e ee ff ff       	call   f01013ab <pgdir_walk>
f010254d:	f6 00 04             	testb  $0x4,(%eax)
f0102550:	74 24                	je     f0102576 <mem_init+0xeb3>
f0102552:	c7 44 24 0c 38 7b 10 	movl   $0xf0107b38,0xc(%esp)
f0102559:	f0 
f010255a:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102561:	f0 
f0102562:	c7 44 24 04 8b 04 00 	movl   $0x48b,0x4(%esp)
f0102569:	00 
f010256a:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102571:	e8 ca da ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102576:	8b 3d 8c 6e 1d f0    	mov    0xf01d6e8c,%edi
f010257c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102581:	89 f8                	mov    %edi,%eax
f0102583:	e8 fc e5 ff ff       	call   f0100b84 <check_va2pa>
f0102588:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010258b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010258e:	2b 05 90 6e 1d f0    	sub    0xf01d6e90,%eax
f0102594:	c1 f8 03             	sar    $0x3,%eax
f0102597:	c1 e0 0c             	shl    $0xc,%eax
f010259a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010259d:	74 24                	je     f01025c3 <mem_init+0xf00>
f010259f:	c7 44 24 0c 70 7b 10 	movl   $0xf0107b70,0xc(%esp)
f01025a6:	f0 
f01025a7:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01025ae:	f0 
f01025af:	c7 44 24 04 8e 04 00 	movl   $0x48e,0x4(%esp)
f01025b6:	00 
f01025b7:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01025be:	e8 7d da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025c3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025c8:	89 f8                	mov    %edi,%eax
f01025ca:	e8 b5 e5 ff ff       	call   f0100b84 <check_va2pa>
f01025cf:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01025d2:	74 24                	je     f01025f8 <mem_init+0xf35>
f01025d4:	c7 44 24 0c 9c 7b 10 	movl   $0xf0107b9c,0xc(%esp)
f01025db:	f0 
f01025dc:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01025e3:	f0 
f01025e4:	c7 44 24 04 8f 04 00 	movl   $0x48f,0x4(%esp)
f01025eb:	00 
f01025ec:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01025f3:	e8 48 da ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01025f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025fb:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0102600:	74 24                	je     f0102626 <mem_init+0xf63>
f0102602:	c7 44 24 0c 6c 81 10 	movl   $0xf010816c,0xc(%esp)
f0102609:	f0 
f010260a:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102611:	f0 
f0102612:	c7 44 24 04 91 04 00 	movl   $0x491,0x4(%esp)
f0102619:	00 
f010261a:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102621:	e8 1a da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102626:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010262b:	74 24                	je     f0102651 <mem_init+0xf8e>
f010262d:	c7 44 24 0c 7d 81 10 	movl   $0xf010817d,0xc(%esp)
f0102634:	f0 
f0102635:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f010263c:	f0 
f010263d:	c7 44 24 04 92 04 00 	movl   $0x492,0x4(%esp)
f0102644:	00 
f0102645:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f010264c:	e8 ef d9 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102651:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102658:	e8 97 ec ff ff       	call   f01012f4 <page_alloc>
f010265d:	85 c0                	test   %eax,%eax
f010265f:	74 04                	je     f0102665 <mem_init+0xfa2>
f0102661:	39 c6                	cmp    %eax,%esi
f0102663:	74 24                	je     f0102689 <mem_init+0xfc6>
f0102665:	c7 44 24 0c cc 7b 10 	movl   $0xf0107bcc,0xc(%esp)
f010266c:	f0 
f010266d:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102674:	f0 
f0102675:	c7 44 24 04 95 04 00 	movl   $0x495,0x4(%esp)
f010267c:	00 
f010267d:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102684:	e8 b7 d9 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102689:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102690:	00 
f0102691:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102696:	89 04 24             	mov    %eax,(%esp)
f0102699:	e8 54 ef ff ff       	call   f01015f2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010269e:	8b 3d 8c 6e 1d f0    	mov    0xf01d6e8c,%edi
f01026a4:	ba 00 00 00 00       	mov    $0x0,%edx
f01026a9:	89 f8                	mov    %edi,%eax
f01026ab:	e8 d4 e4 ff ff       	call   f0100b84 <check_va2pa>
f01026b0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026b3:	74 24                	je     f01026d9 <mem_init+0x1016>
f01026b5:	c7 44 24 0c f0 7b 10 	movl   $0xf0107bf0,0xc(%esp)
f01026bc:	f0 
f01026bd:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01026c4:	f0 
f01026c5:	c7 44 24 04 99 04 00 	movl   $0x499,0x4(%esp)
f01026cc:	00 
f01026cd:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01026d4:	e8 67 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026d9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01026de:	89 f8                	mov    %edi,%eax
f01026e0:	e8 9f e4 ff ff       	call   f0100b84 <check_va2pa>
f01026e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01026e8:	2b 15 90 6e 1d f0    	sub    0xf01d6e90,%edx
f01026ee:	c1 fa 03             	sar    $0x3,%edx
f01026f1:	c1 e2 0c             	shl    $0xc,%edx
f01026f4:	39 d0                	cmp    %edx,%eax
f01026f6:	74 24                	je     f010271c <mem_init+0x1059>
f01026f8:	c7 44 24 0c 9c 7b 10 	movl   $0xf0107b9c,0xc(%esp)
f01026ff:	f0 
f0102700:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102707:	f0 
f0102708:	c7 44 24 04 9a 04 00 	movl   $0x49a,0x4(%esp)
f010270f:	00 
f0102710:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102717:	e8 24 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010271c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010271f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102724:	74 24                	je     f010274a <mem_init+0x1087>
f0102726:	c7 44 24 0c 23 81 10 	movl   $0xf0108123,0xc(%esp)
f010272d:	f0 
f010272e:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102735:	f0 
f0102736:	c7 44 24 04 9b 04 00 	movl   $0x49b,0x4(%esp)
f010273d:	00 
f010273e:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102745:	e8 f6 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010274a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010274f:	74 24                	je     f0102775 <mem_init+0x10b2>
f0102751:	c7 44 24 0c 7d 81 10 	movl   $0xf010817d,0xc(%esp)
f0102758:	f0 
f0102759:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102760:	f0 
f0102761:	c7 44 24 04 9c 04 00 	movl   $0x49c,0x4(%esp)
f0102768:	00 
f0102769:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102770:	e8 cb d8 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102775:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010277c:	00 
f010277d:	89 3c 24             	mov    %edi,(%esp)
f0102780:	e8 6d ee ff ff       	call   f01015f2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102785:	8b 3d 8c 6e 1d f0    	mov    0xf01d6e8c,%edi
f010278b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102790:	89 f8                	mov    %edi,%eax
f0102792:	e8 ed e3 ff ff       	call   f0100b84 <check_va2pa>
f0102797:	83 f8 ff             	cmp    $0xffffffff,%eax
f010279a:	74 24                	je     f01027c0 <mem_init+0x10fd>
f010279c:	c7 44 24 0c f0 7b 10 	movl   $0xf0107bf0,0xc(%esp)
f01027a3:	f0 
f01027a4:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01027ab:	f0 
f01027ac:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f01027b3:	00 
f01027b4:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01027bb:	e8 80 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01027c0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01027c5:	89 f8                	mov    %edi,%eax
f01027c7:	e8 b8 e3 ff ff       	call   f0100b84 <check_va2pa>
f01027cc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01027cf:	74 24                	je     f01027f5 <mem_init+0x1132>
f01027d1:	c7 44 24 0c 14 7c 10 	movl   $0xf0107c14,0xc(%esp)
f01027d8:	f0 
f01027d9:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01027e0:	f0 
f01027e1:	c7 44 24 04 a1 04 00 	movl   $0x4a1,0x4(%esp)
f01027e8:	00 
f01027e9:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01027f0:	e8 4b d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01027f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027f8:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01027fd:	74 24                	je     f0102823 <mem_init+0x1160>
f01027ff:	c7 44 24 0c 8e 81 10 	movl   $0xf010818e,0xc(%esp)
f0102806:	f0 
f0102807:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f010280e:	f0 
f010280f:	c7 44 24 04 a2 04 00 	movl   $0x4a2,0x4(%esp)
f0102816:	00 
f0102817:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f010281e:	e8 1d d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102823:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102828:	74 24                	je     f010284e <mem_init+0x118b>
f010282a:	c7 44 24 0c 7d 81 10 	movl   $0xf010817d,0xc(%esp)
f0102831:	f0 
f0102832:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102839:	f0 
f010283a:	c7 44 24 04 a3 04 00 	movl   $0x4a3,0x4(%esp)
f0102841:	00 
f0102842:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102849:	e8 f2 d7 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010284e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102855:	e8 9a ea ff ff       	call   f01012f4 <page_alloc>
f010285a:	85 c0                	test   %eax,%eax
f010285c:	74 05                	je     f0102863 <mem_init+0x11a0>
f010285e:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102861:	74 24                	je     f0102887 <mem_init+0x11c4>
f0102863:	c7 44 24 0c 3c 7c 10 	movl   $0xf0107c3c,0xc(%esp)
f010286a:	f0 
f010286b:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102872:	f0 
f0102873:	c7 44 24 04 a6 04 00 	movl   $0x4a6,0x4(%esp)
f010287a:	00 
f010287b:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102882:	e8 b9 d7 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102887:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010288e:	e8 61 ea ff ff       	call   f01012f4 <page_alloc>
f0102893:	85 c0                	test   %eax,%eax
f0102895:	74 24                	je     f01028bb <mem_init+0x11f8>
f0102897:	c7 44 24 0c d1 80 10 	movl   $0xf01080d1,0xc(%esp)
f010289e:	f0 
f010289f:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01028a6:	f0 
f01028a7:	c7 44 24 04 a9 04 00 	movl   $0x4a9,0x4(%esp)
f01028ae:	00 
f01028af:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01028b6:	e8 85 d7 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01028bb:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f01028c0:	8b 08                	mov    (%eax),%ecx
f01028c2:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01028c8:	89 da                	mov    %ebx,%edx
f01028ca:	2b 15 90 6e 1d f0    	sub    0xf01d6e90,%edx
f01028d0:	c1 fa 03             	sar    $0x3,%edx
f01028d3:	c1 e2 0c             	shl    $0xc,%edx
f01028d6:	39 d1                	cmp    %edx,%ecx
f01028d8:	74 24                	je     f01028fe <mem_init+0x123b>
f01028da:	c7 44 24 0c 4c 79 10 	movl   $0xf010794c,0xc(%esp)
f01028e1:	f0 
f01028e2:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01028e9:	f0 
f01028ea:	c7 44 24 04 ac 04 00 	movl   $0x4ac,0x4(%esp)
f01028f1:	00 
f01028f2:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01028f9:	e8 42 d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01028fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102904:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102909:	74 24                	je     f010292f <mem_init+0x126c>
f010290b:	c7 44 24 0c 34 81 10 	movl   $0xf0108134,0xc(%esp)
f0102912:	f0 
f0102913:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f010291a:	f0 
f010291b:	c7 44 24 04 ae 04 00 	movl   $0x4ae,0x4(%esp)
f0102922:	00 
f0102923:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f010292a:	e8 11 d7 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010292f:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102935:	89 1c 24             	mov    %ebx,(%esp)
f0102938:	e8 36 ea ff ff       	call   f0101373 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010293d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102944:	00 
f0102945:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010294c:	00 
f010294d:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102952:	89 04 24             	mov    %eax,(%esp)
f0102955:	e8 51 ea ff ff       	call   f01013ab <pgdir_walk>
f010295a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010295d:	8b 15 8c 6e 1d f0    	mov    0xf01d6e8c,%edx
f0102963:	8b 4a 04             	mov    0x4(%edx),%ecx
f0102966:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010296c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010296f:	8b 0d 88 6e 1d f0    	mov    0xf01d6e88,%ecx
f0102975:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102978:	c1 ef 0c             	shr    $0xc,%edi
f010297b:	39 cf                	cmp    %ecx,%edi
f010297d:	72 23                	jb     f01029a2 <mem_init+0x12df>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010297f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102982:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102986:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f010298d:	f0 
f010298e:	c7 44 24 04 b5 04 00 	movl   $0x4b5,0x4(%esp)
f0102995:	00 
f0102996:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f010299d:	e8 9e d6 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01029a2:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01029a5:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f01029ab:	39 f8                	cmp    %edi,%eax
f01029ad:	74 24                	je     f01029d3 <mem_init+0x1310>
f01029af:	c7 44 24 0c 9f 81 10 	movl   $0xf010819f,0xc(%esp)
f01029b6:	f0 
f01029b7:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01029be:	f0 
f01029bf:	c7 44 24 04 b6 04 00 	movl   $0x4b6,0x4(%esp)
f01029c6:	00 
f01029c7:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01029ce:	e8 6d d6 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01029d3:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f01029da:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f01029e0:	89 d8                	mov    %ebx,%eax
f01029e2:	2b 05 90 6e 1d f0    	sub    0xf01d6e90,%eax
f01029e8:	c1 f8 03             	sar    $0x3,%eax
f01029eb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029ee:	89 c2                	mov    %eax,%edx
f01029f0:	c1 ea 0c             	shr    $0xc,%edx
f01029f3:	39 d1                	cmp    %edx,%ecx
f01029f5:	77 20                	ja     f0102a17 <mem_init+0x1354>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029fb:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f0102a02:	f0 
f0102a03:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102a0a:	00 
f0102a0b:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f0102a12:	e8 29 d6 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102a17:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a1e:	00 
f0102a1f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102a26:	00 
	return (void *)(pa + KERNBASE);
f0102a27:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a2c:	89 04 24             	mov    %eax,(%esp)
f0102a2f:	e8 61 36 00 00       	call   f0106095 <memset>
	page_free(pp0);
f0102a34:	89 1c 24             	mov    %ebx,(%esp)
f0102a37:	e8 37 e9 ff ff       	call   f0101373 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102a3c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102a43:	00 
f0102a44:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102a4b:	00 
f0102a4c:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102a51:	89 04 24             	mov    %eax,(%esp)
f0102a54:	e8 52 e9 ff ff       	call   f01013ab <pgdir_walk>
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f0102a59:	89 da                	mov    %ebx,%edx
f0102a5b:	2b 15 90 6e 1d f0    	sub    0xf01d6e90,%edx
f0102a61:	c1 fa 03             	sar    $0x3,%edx
f0102a64:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a67:	89 d0                	mov    %edx,%eax
f0102a69:	c1 e8 0c             	shr    $0xc,%eax
f0102a6c:	3b 05 88 6e 1d f0    	cmp    0xf01d6e88,%eax
f0102a72:	72 20                	jb     f0102a94 <mem_init+0x13d1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a74:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102a78:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f0102a7f:	f0 
f0102a80:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102a87:	00 
f0102a88:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f0102a8f:	e8 ac d5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102a94:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102a9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102a9d:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102aa4:	75 11                	jne    f0102ab7 <mem_init+0x13f4>
f0102aa6:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102aac:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102ab2:	f6 00 01             	testb  $0x1,(%eax)
f0102ab5:	74 24                	je     f0102adb <mem_init+0x1418>
f0102ab7:	c7 44 24 0c b7 81 10 	movl   $0xf01081b7,0xc(%esp)
f0102abe:	f0 
f0102abf:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102ac6:	f0 
f0102ac7:	c7 44 24 04 c0 04 00 	movl   $0x4c0,0x4(%esp)
f0102ace:	00 
f0102acf:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102ad6:	e8 65 d5 ff ff       	call   f0100040 <_panic>
f0102adb:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102ade:	39 d0                	cmp    %edx,%eax
f0102ae0:	75 d0                	jne    f0102ab2 <mem_init+0x13ef>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102ae2:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102ae7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102aed:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// give free list back
	page_free_list = fl;
f0102af3:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102af6:	89 3d 40 62 1d f0    	mov    %edi,0xf01d6240

	// free the pages we took
	page_free(pp0);
f0102afc:	89 1c 24             	mov    %ebx,(%esp)
f0102aff:	e8 6f e8 ff ff       	call   f0101373 <page_free>
	page_free(pp1);
f0102b04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b07:	89 04 24             	mov    %eax,(%esp)
f0102b0a:	e8 64 e8 ff ff       	call   f0101373 <page_free>
	page_free(pp2);
f0102b0f:	89 34 24             	mov    %esi,(%esp)
f0102b12:	e8 5c e8 ff ff       	call   f0101373 <page_free>

	cprintf("check_page() succeeded!\n");
f0102b17:	c7 04 24 ce 81 10 f0 	movl   $0xf01081ce,(%esp)
f0102b1e:	e8 73 14 00 00       	call   f0103f96 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	cprintf("\nmap 'pages' at linear address UPAGES[0x%x]\n", UPAGES);
f0102b23:	c7 44 24 04 00 00 00 	movl   $0xef000000,0x4(%esp)
f0102b2a:	ef 
f0102b2b:	c7 04 24 60 7c 10 f0 	movl   $0xf0107c60,(%esp)
f0102b32:	e8 5f 14 00 00       	call   f0103f96 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages * sizeof(struct Page), PGSIZE),
f0102b37:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b3c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b41:	77 20                	ja     f0102b63 <mem_init+0x14a0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b43:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b47:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0102b4e:	f0 
f0102b4f:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
f0102b56:	00 
f0102b57:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102b5e:	e8 dd d4 ff ff       	call   f0100040 <_panic>
f0102b63:	8b 15 88 6e 1d f0    	mov    0xf01d6e88,%edx
f0102b69:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102b70:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102b76:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102b7d:	00 
	return (physaddr_t)kva - KERNBASE;
f0102b7e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b83:	89 04 24             	mov    %eax,(%esp)
f0102b86:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102b8b:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102b90:	e8 fe e8 ff ff       	call   f0101493 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	cprintf("\nmap 'envs' at linear address UENVS[0x%x]\n", UENVS);
f0102b95:	c7 44 24 04 00 00 c0 	movl   $0xeec00000,0x4(%esp)
f0102b9c:	ee 
f0102b9d:	c7 04 24 90 7c 10 f0 	movl   $0xf0107c90,(%esp)
f0102ba4:	e8 ed 13 00 00       	call   f0103f96 <cprintf>
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE),
f0102ba9:	a1 48 62 1d f0       	mov    0xf01d6248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bb3:	77 20                	ja     f0102bd5 <mem_init+0x1512>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bb5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bb9:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0102bc0:	f0 
f0102bc1:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
f0102bc8:	00 
f0102bc9:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102bd0:	e8 6b d4 ff ff       	call   f0100040 <_panic>
f0102bd5:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102bdc:	00 
	return (physaddr_t)kva - KERNBASE;
f0102bdd:	05 00 00 00 10       	add    $0x10000000,%eax
f0102be2:	89 04 24             	mov    %eax,(%esp)
f0102be5:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102bea:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102bef:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102bf4:	e8 9a e8 ff ff       	call   f0101493 <boot_map_region>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	cprintf("\nmap 'bootstack' at KSTKSIZE PA[0x%x]\n", KSTKSIZE);
f0102bf9:	c7 44 24 04 00 80 00 	movl   $0x8000,0x4(%esp)
f0102c00:	00 
f0102c01:	c7 04 24 bc 7c 10 f0 	movl   $0xf0107cbc,(%esp)
f0102c08:	e8 89 13 00 00       	call   f0103f96 <cprintf>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c0d:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0102c12:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c17:	77 20                	ja     f0102c39 <mem_init+0x1576>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c19:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c1d:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0102c24:	f0 
f0102c25:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
f0102c2c:	00 
f0102c2d:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102c34:	e8 07 d4 ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, 
f0102c39:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c40:	00 
f0102c41:	c7 04 24 00 80 11 00 	movl   $0x118000,(%esp)
f0102c48:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102c4d:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0102c52:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102c57:	e8 37 e8 ff ff       	call   f0101493 <boot_map_region>
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	
	// uint64_t kern_map_length = 0x100000000 - (uint64_t) KERNBASE;
	// boot_map_region(kern_pgdir, KERNBASE, (uint32_t) kern_map_length, 0, PTE_W|PTE_P);
	cprintf("\nMap all of physical memory at KERNBASE\n");
f0102c5c:	c7 04 24 e4 7c 10 f0 	movl   $0xf0107ce4,(%esp)
f0102c63:	e8 2e 13 00 00       	call   f0103f96 <cprintf>
	boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W|PTE_P);
f0102c68:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c6f:	00 
f0102c70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c77:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102c7c:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102c81:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102c86:	e8 08 e8 ff ff       	call   f0101493 <boot_map_region>
static void
mem_init_mp(void)
{
	// Create a direct mapping at the top of virtual address space starting
	// at IOMEMBASE for accessing the LAPIC unit using memory-mapped I/O.
	boot_map_region(kern_pgdir, IOMEMBASE, -IOMEMBASE, IOMEM_PADDR, PTE_W);
f0102c8b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102c92:	00 
f0102c93:	c7 04 24 00 00 00 fe 	movl   $0xfe000000,(%esp)
f0102c9a:	b9 00 00 00 02       	mov    $0x2000000,%ecx
f0102c9f:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
f0102ca4:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102ca9:	e8 e5 e7 ff ff       	call   f0101493 <boot_map_region>
	//             it will fault rather than overwrite another CPU's stack.
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	size_t i = 0;
f0102cae:	bb 00 00 00 00       	mov    $0x0,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102cb3:	89 df                	mov    %ebx,%edi
f0102cb5:	f7 df                	neg    %edi
f0102cb7:	c1 e7 10             	shl    $0x10,%edi
f0102cba:	81 ef 00 80 40 10    	sub    $0x10408000,%edi
	uint32_t kstacktop_i;
	for(; i< NCPU; i++){
		kstacktop_i = KSTACKTOP - (i + 1) * (KSTKSIZE + KSTKGAP) + KSTKGAP;

#ifdef DEBUG
		cprintf("\ni[%d]: kstacktop_i[%p],", i, kstacktop_i);
f0102cc0:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0102cc4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102cc8:	c7 04 24 e7 81 10 f0 	movl   $0xf01081e7,(%esp)
f0102ccf:	e8 c2 12 00 00       	call   f0103f96 <cprintf>
		cprintf("percpu_kstacks[%d]:[%p]\n",i ,percpu_kstacks[i]);
f0102cd4:	89 de                	mov    %ebx,%esi
f0102cd6:	c1 e6 0f             	shl    $0xf,%esi
f0102cd9:	81 c6 00 80 1d f0    	add    $0xf01d8000,%esi
f0102cdf:	89 74 24 08          	mov    %esi,0x8(%esp)
f0102ce3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102ce7:	c7 04 24 00 82 10 f0 	movl   $0xf0108200,(%esp)
f0102cee:	e8 a3 12 00 00       	call   f0103f96 <cprintf>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cf3:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102cf9:	77 20                	ja     f0102d1b <mem_init+0x1658>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cfb:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102cff:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0102d06:	f0 
f0102d07:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
f0102d0e:	00 
f0102d0f:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102d16:	e8 25 d3 ff ff       	call   f0100040 <_panic>
#endif

		boot_map_region(kern_pgdir, kstacktop_i, KSTKSIZE, 
f0102d1b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d22:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d23:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0102d29:	89 34 24             	mov    %esi,(%esp)
f0102d2c:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d31:	89 fa                	mov    %edi,%edx
f0102d33:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0102d38:	e8 56 e7 ff ff       	call   f0101493 <boot_map_region>
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	size_t i = 0;
	uint32_t kstacktop_i;
	for(; i< NCPU; i++){
f0102d3d:	83 c3 01             	add    $0x1,%ebx
f0102d40:	83 fb 08             	cmp    $0x8,%ebx
f0102d43:	0f 85 6a ff ff ff    	jne    f0102cb3 <mem_init+0x15f0>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d49:	8b 3d 8c 6e 1d f0    	mov    0xf01d6e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0102d4f:	8b 15 88 6e 1d f0    	mov    0xf01d6e88,%edx
f0102d55:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102d58:	8d 04 d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%eax
	for (i = 0; i < n; i += PGSIZE)
f0102d5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d64:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102d67:	75 30                	jne    f0102d99 <mem_init+0x16d6>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102d69:	8b 1d 48 62 1d f0    	mov    0xf01d6248,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d6f:	89 de                	mov    %ebx,%esi
f0102d71:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102d76:	89 f8                	mov    %edi,%eax
f0102d78:	e8 07 de ff ff       	call   f0100b84 <check_va2pa>
f0102d7d:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d83:	0f 86 94 00 00 00    	jbe    f0102e1d <mem_init+0x175a>
f0102d89:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d8e:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0102d94:	e9 a4 00 00 00       	jmp    f0102e3d <mem_init+0x177a>
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102d99:	8b 1d 90 6e 1d f0    	mov    0xf01d6e90,%ebx
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102d9f:	8d b3 00 00 00 10    	lea    0x10000000(%ebx),%esi
f0102da5:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102daa:	89 f8                	mov    %edi,%eax
f0102dac:	e8 d3 dd ff ff       	call   f0100b84 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102db1:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102db7:	77 20                	ja     f0102dd9 <mem_init+0x1716>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102db9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102dbd:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0102dc4:	f0 
f0102dc5:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0102dcc:	00 
f0102dcd:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102dd4:	e8 67 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102dd9:	ba 00 00 00 00       	mov    $0x0,%edx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102dde:	8d 0c 32             	lea    (%edx,%esi,1),%ecx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102de1:	39 c1                	cmp    %eax,%ecx
f0102de3:	74 24                	je     f0102e09 <mem_init+0x1746>
f0102de5:	c7 44 24 0c 10 7d 10 	movl   $0xf0107d10,0xc(%esp)
f0102dec:	f0 
f0102ded:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102df4:	f0 
f0102df5:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0102dfc:	00 
f0102dfd:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102e04:	e8 37 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e09:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
f0102e0f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102e12:	0f 87 ef 06 00 00    	ja     f0103507 <mem_init+0x1e44>
f0102e18:	e9 4c ff ff ff       	jmp    f0102d69 <mem_init+0x16a6>
f0102e1d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102e21:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0102e28:	f0 
f0102e29:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0102e30:	00 
f0102e31:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102e38:	e8 03 d2 ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e3d:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e40:	39 d0                	cmp    %edx,%eax
f0102e42:	74 24                	je     f0102e68 <mem_init+0x17a5>
f0102e44:	c7 44 24 0c 44 7d 10 	movl   $0xf0107d44,0xc(%esp)
f0102e4b:	f0 
f0102e4c:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102e53:	f0 
f0102e54:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0102e5b:	00 
f0102e5c:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102e63:	e8 d8 d1 ff ff       	call   f0100040 <_panic>
f0102e68:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e6e:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102e74:	0f 85 7f 06 00 00    	jne    f01034f9 <mem_init+0x1e36>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e7a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102e7d:	c1 e6 0c             	shl    $0xc,%esi
f0102e80:	85 f6                	test   %esi,%esi
f0102e82:	74 4b                	je     f0102ecf <mem_init+0x180c>
f0102e84:	bb 00 00 00 00       	mov    $0x0,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e89:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e8f:	89 f8                	mov    %edi,%eax
f0102e91:	e8 ee dc ff ff       	call   f0100b84 <check_va2pa>
f0102e96:	39 c3                	cmp    %eax,%ebx
f0102e98:	74 24                	je     f0102ebe <mem_init+0x17fb>
f0102e9a:	c7 44 24 0c 78 7d 10 	movl   $0xf0107d78,0xc(%esp)
f0102ea1:	f0 
f0102ea2:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102ea9:	f0 
f0102eaa:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0102eb1:	00 
f0102eb2:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102eb9:	e8 82 d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ebe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ec4:	39 f3                	cmp    %esi,%ebx
f0102ec6:	72 c1                	jb     f0102e89 <mem_init+0x17c6>
f0102ec8:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
f0102ecd:	eb 05                	jmp    f0102ed4 <mem_init+0x1811>
f0102ecf:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
f0102ed4:	89 da                	mov    %ebx,%edx
f0102ed6:	89 f8                	mov    %edi,%eax
f0102ed8:	e8 a7 dc ff ff       	call   f0100b84 <check_va2pa>
f0102edd:	39 c3                	cmp    %eax,%ebx
f0102edf:	74 24                	je     f0102f05 <mem_init+0x1842>
f0102ee1:	c7 44 24 0c 19 82 10 	movl   $0xf0108219,0xc(%esp)
f0102ee8:	f0 
f0102ee9:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102ef0:	f0 
f0102ef1:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f0102ef8:	00 
f0102ef9:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102f00:	e8 3b d1 ff ff       	call   f0100040 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0102f05:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f0b:	81 fb 00 f0 ff ff    	cmp    $0xfffff000,%ebx
f0102f11:	75 c1                	jne    f0102ed4 <mem_init+0x1811>
f0102f13:	be 00 00 bf ef       	mov    $0xefbf0000,%esi
f0102f18:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0102f1f:	89 7d d4             	mov    %edi,-0x2c(%ebp)

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f22:	bb 00 00 00 00       	mov    $0x0,%ebx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f27:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102f2a:	c1 e7 0f             	shl    $0xf,%edi
f0102f2d:	81 c7 00 80 1d f0    	add    $0xf01d8000,%edi
	return (physaddr_t)kva - KERNBASE;
f0102f33:	8d 8f 00 00 00 10    	lea    0x10000000(%edi),%ecx
f0102f39:	89 4d d0             	mov    %ecx,-0x30(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102f3c:	8d 94 1e 00 80 00 00 	lea    0x8000(%esi,%ebx,1),%edx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f46:	e8 39 dc ff ff       	call   f0100b84 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f4b:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102f51:	77 20                	ja     f0102f73 <mem_init+0x18b0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f53:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102f57:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0102f5e:	f0 
f0102f5f:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f0102f66:	00 
f0102f67:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102f6e:	e8 cd d0 ff ff       	call   f0100040 <_panic>
f0102f73:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102f76:	01 da                	add    %ebx,%edx
f0102f78:	39 d0                	cmp    %edx,%eax
f0102f7a:	74 24                	je     f0102fa0 <mem_init+0x18dd>
f0102f7c:	c7 44 24 0c a0 7d 10 	movl   $0xf0107da0,0xc(%esp)
f0102f83:	f0 
f0102f84:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102f8b:	f0 
f0102f8c:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f0102f93:	00 
f0102f94:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102f9b:	e8 a0 d0 ff ff       	call   f0100040 <_panic>

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102fa0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102fa6:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102fac:	75 8e                	jne    f0102f3c <mem_init+0x1879>
f0102fae:	66 bb 00 00          	mov    $0x0,%bx
f0102fb2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102fb5:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102fb8:	89 f8                	mov    %edi,%eax
f0102fba:	e8 c5 db ff ff       	call   f0100b84 <check_va2pa>
f0102fbf:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102fc2:	74 24                	je     f0102fe8 <mem_init+0x1925>
f0102fc4:	c7 44 24 0c e8 7d 10 	movl   $0xf0107de8,0xc(%esp)
f0102fcb:	f0 
f0102fcc:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0102fd3:	f0 
f0102fd4:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f0102fdb:	00 
f0102fdc:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0102fe3:	e8 58 d0 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102fe8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102fee:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102ff4:	75 bf                	jne    f0102fb5 <mem_init+0x18f2>
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102ff6:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0102ffa:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0103000:	83 7d cc 08          	cmpl   $0x8,-0x34(%ebp)
f0103004:	0f 85 18 ff ff ff    	jne    f0102f22 <mem_init+0x185f>
f010300a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010300d:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103012:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103018:	83 fa 03             	cmp    $0x3,%edx
f010301b:	77 2e                	ja     f010304b <mem_init+0x1988>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010301d:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0103021:	0f 85 aa 00 00 00    	jne    f01030d1 <mem_init+0x1a0e>
f0103027:	c7 44 24 0c 34 82 10 	movl   $0xf0108234,0xc(%esp)
f010302e:	f0 
f010302f:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0103036:	f0 
f0103037:	c7 44 24 04 1e 04 00 	movl   $0x41e,0x4(%esp)
f010303e:	00 
f010303f:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0103046:	e8 f5 cf ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010304b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103050:	76 55                	jbe    f01030a7 <mem_init+0x19e4>
				assert(pgdir[i] & PTE_P);
f0103052:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103055:	f6 c2 01             	test   $0x1,%dl
f0103058:	75 24                	jne    f010307e <mem_init+0x19bb>
f010305a:	c7 44 24 0c 34 82 10 	movl   $0xf0108234,0xc(%esp)
f0103061:	f0 
f0103062:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0103069:	f0 
f010306a:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0103071:	00 
f0103072:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0103079:	e8 c2 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010307e:	f6 c2 02             	test   $0x2,%dl
f0103081:	75 4e                	jne    f01030d1 <mem_init+0x1a0e>
f0103083:	c7 44 24 0c 45 82 10 	movl   $0xf0108245,0xc(%esp)
f010308a:	f0 
f010308b:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0103092:	f0 
f0103093:	c7 44 24 04 23 04 00 	movl   $0x423,0x4(%esp)
f010309a:	00 
f010309b:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01030a2:	e8 99 cf ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01030a7:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01030ab:	74 24                	je     f01030d1 <mem_init+0x1a0e>
f01030ad:	c7 44 24 0c 56 82 10 	movl   $0xf0108256,0xc(%esp)
f01030b4:	f0 
f01030b5:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01030bc:	f0 
f01030bd:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f01030c4:	00 
f01030c5:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01030cc:	e8 6f cf ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01030d1:	83 c0 01             	add    $0x1,%eax
f01030d4:	3d 00 04 00 00       	cmp    $0x400,%eax
f01030d9:	0f 85 33 ff ff ff    	jne    f0103012 <mem_init+0x194f>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01030df:	c7 04 24 0c 7e 10 f0 	movl   $0xf0107e0c,(%esp)
f01030e6:	e8 ab 0e 00 00       	call   f0103f96 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01030eb:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030f0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030f5:	77 20                	ja     f0103117 <mem_init+0x1a54>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030fb:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0103102:	f0 
f0103103:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
f010310a:	00 
f010310b:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0103112:	e8 29 cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103117:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010311c:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010311f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103124:	e8 fc da ff ff       	call   f0100c25 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103129:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f010312c:	83 e0 f3             	and    $0xfffffff3,%eax
f010312f:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103134:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103137:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010313e:	e8 b1 e1 ff ff       	call   f01012f4 <page_alloc>
f0103143:	89 c3                	mov    %eax,%ebx
f0103145:	85 c0                	test   %eax,%eax
f0103147:	75 24                	jne    f010316d <mem_init+0x1aaa>
f0103149:	c7 44 24 0c 26 80 10 	movl   $0xf0108026,0xc(%esp)
f0103150:	f0 
f0103151:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0103158:	f0 
f0103159:	c7 44 24 04 db 04 00 	movl   $0x4db,0x4(%esp)
f0103160:	00 
f0103161:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0103168:	e8 d3 ce ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010316d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103174:	e8 7b e1 ff ff       	call   f01012f4 <page_alloc>
f0103179:	89 c7                	mov    %eax,%edi
f010317b:	85 c0                	test   %eax,%eax
f010317d:	75 24                	jne    f01031a3 <mem_init+0x1ae0>
f010317f:	c7 44 24 0c 3c 80 10 	movl   $0xf010803c,0xc(%esp)
f0103186:	f0 
f0103187:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f010318e:	f0 
f010318f:	c7 44 24 04 dc 04 00 	movl   $0x4dc,0x4(%esp)
f0103196:	00 
f0103197:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f010319e:	e8 9d ce ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01031a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031aa:	e8 45 e1 ff ff       	call   f01012f4 <page_alloc>
f01031af:	89 c6                	mov    %eax,%esi
f01031b1:	85 c0                	test   %eax,%eax
f01031b3:	75 24                	jne    f01031d9 <mem_init+0x1b16>
f01031b5:	c7 44 24 0c 52 80 10 	movl   $0xf0108052,0xc(%esp)
f01031bc:	f0 
f01031bd:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01031c4:	f0 
f01031c5:	c7 44 24 04 dd 04 00 	movl   $0x4dd,0x4(%esp)
f01031cc:	00 
f01031cd:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01031d4:	e8 67 ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01031d9:	89 1c 24             	mov    %ebx,(%esp)
f01031dc:	e8 92 e1 ff ff       	call   f0101373 <page_free>
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f01031e1:	89 f8                	mov    %edi,%eax
f01031e3:	2b 05 90 6e 1d f0    	sub    0xf01d6e90,%eax
f01031e9:	c1 f8 03             	sar    $0x3,%eax
f01031ec:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031ef:	89 c2                	mov    %eax,%edx
f01031f1:	c1 ea 0c             	shr    $0xc,%edx
f01031f4:	3b 15 88 6e 1d f0    	cmp    0xf01d6e88,%edx
f01031fa:	72 20                	jb     f010321c <mem_init+0x1b59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103200:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f0103207:	f0 
f0103208:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f010320f:	00 
f0103210:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f0103217:	e8 24 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010321c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103223:	00 
f0103224:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010322b:	00 
	return (void *)(pa + KERNBASE);
f010322c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103231:	89 04 24             	mov    %eax,(%esp)
f0103234:	e8 5c 2e 00 00       	call   f0106095 <memset>
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f0103239:	89 f0                	mov    %esi,%eax
f010323b:	2b 05 90 6e 1d f0    	sub    0xf01d6e90,%eax
f0103241:	c1 f8 03             	sar    $0x3,%eax
f0103244:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103247:	89 c2                	mov    %eax,%edx
f0103249:	c1 ea 0c             	shr    $0xc,%edx
f010324c:	3b 15 88 6e 1d f0    	cmp    0xf01d6e88,%edx
f0103252:	72 20                	jb     f0103274 <mem_init+0x1bb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103254:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103258:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f010325f:	f0 
f0103260:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0103267:	00 
f0103268:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f010326f:	e8 cc cd ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103274:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010327b:	00 
f010327c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103283:	00 
	return (void *)(pa + KERNBASE);
f0103284:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103289:	89 04 24             	mov    %eax,(%esp)
f010328c:	e8 04 2e 00 00       	call   f0106095 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103291:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103298:	00 
f0103299:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032a0:	00 
f01032a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01032a5:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f01032aa:	89 04 24             	mov    %eax,(%esp)
f01032ad:	e8 97 e3 ff ff       	call   f0101649 <page_insert>
	assert(pp1->pp_ref == 1);
f01032b2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01032b7:	74 24                	je     f01032dd <mem_init+0x1c1a>
f01032b9:	c7 44 24 0c 23 81 10 	movl   $0xf0108123,0xc(%esp)
f01032c0:	f0 
f01032c1:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01032c8:	f0 
f01032c9:	c7 44 24 04 e2 04 00 	movl   $0x4e2,0x4(%esp)
f01032d0:	00 
f01032d1:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01032d8:	e8 63 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01032dd:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01032e4:	01 01 01 
f01032e7:	74 24                	je     f010330d <mem_init+0x1c4a>
f01032e9:	c7 44 24 0c 2c 7e 10 	movl   $0xf0107e2c,0xc(%esp)
f01032f0:	f0 
f01032f1:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01032f8:	f0 
f01032f9:	c7 44 24 04 e3 04 00 	movl   $0x4e3,0x4(%esp)
f0103300:	00 
f0103301:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0103308:	e8 33 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010330d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103314:	00 
f0103315:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010331c:	00 
f010331d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103321:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0103326:	89 04 24             	mov    %eax,(%esp)
f0103329:	e8 1b e3 ff ff       	call   f0101649 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010332e:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103335:	02 02 02 
f0103338:	74 24                	je     f010335e <mem_init+0x1c9b>
f010333a:	c7 44 24 0c 50 7e 10 	movl   $0xf0107e50,0xc(%esp)
f0103341:	f0 
f0103342:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0103349:	f0 
f010334a:	c7 44 24 04 e5 04 00 	movl   $0x4e5,0x4(%esp)
f0103351:	00 
f0103352:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0103359:	e8 e2 cc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010335e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103363:	74 24                	je     f0103389 <mem_init+0x1cc6>
f0103365:	c7 44 24 0c 45 81 10 	movl   $0xf0108145,0xc(%esp)
f010336c:	f0 
f010336d:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0103374:	f0 
f0103375:	c7 44 24 04 e6 04 00 	movl   $0x4e6,0x4(%esp)
f010337c:	00 
f010337d:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0103384:	e8 b7 cc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103389:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010338e:	74 24                	je     f01033b4 <mem_init+0x1cf1>
f0103390:	c7 44 24 0c 8e 81 10 	movl   $0xf010818e,0xc(%esp)
f0103397:	f0 
f0103398:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f010339f:	f0 
f01033a0:	c7 44 24 04 e7 04 00 	movl   $0x4e7,0x4(%esp)
f01033a7:	00 
f01033a8:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01033af:	e8 8c cc ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01033b4:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01033bb:	03 03 03 
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f01033be:	89 f0                	mov    %esi,%eax
f01033c0:	2b 05 90 6e 1d f0    	sub    0xf01d6e90,%eax
f01033c6:	c1 f8 03             	sar    $0x3,%eax
f01033c9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033cc:	89 c2                	mov    %eax,%edx
f01033ce:	c1 ea 0c             	shr    $0xc,%edx
f01033d1:	3b 15 88 6e 1d f0    	cmp    0xf01d6e88,%edx
f01033d7:	72 20                	jb     f01033f9 <mem_init+0x1d36>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033dd:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f01033e4:	f0 
f01033e5:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01033ec:	00 
f01033ed:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f01033f4:	e8 47 cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01033f9:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103400:	03 03 03 
f0103403:	74 24                	je     f0103429 <mem_init+0x1d66>
f0103405:	c7 44 24 0c 74 7e 10 	movl   $0xf0107e74,0xc(%esp)
f010340c:	f0 
f010340d:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0103414:	f0 
f0103415:	c7 44 24 04 e9 04 00 	movl   $0x4e9,0x4(%esp)
f010341c:	00 
f010341d:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0103424:	e8 17 cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103429:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103430:	00 
f0103431:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f0103436:	89 04 24             	mov    %eax,(%esp)
f0103439:	e8 b4 e1 ff ff       	call   f01015f2 <page_remove>
	assert(pp2->pp_ref == 0);
f010343e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103443:	74 24                	je     f0103469 <mem_init+0x1da6>
f0103445:	c7 44 24 0c 7d 81 10 	movl   $0xf010817d,0xc(%esp)
f010344c:	f0 
f010344d:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0103454:	f0 
f0103455:	c7 44 24 04 eb 04 00 	movl   $0x4eb,0x4(%esp)
f010345c:	00 
f010345d:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f0103464:	e8 d7 cb ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103469:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
f010346e:	8b 08                	mov    (%eax),%ecx
f0103470:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f0103476:	89 da                	mov    %ebx,%edx
f0103478:	2b 15 90 6e 1d f0    	sub    0xf01d6e90,%edx
f010347e:	c1 fa 03             	sar    $0x3,%edx
f0103481:	c1 e2 0c             	shl    $0xc,%edx
f0103484:	39 d1                	cmp    %edx,%ecx
f0103486:	74 24                	je     f01034ac <mem_init+0x1de9>
f0103488:	c7 44 24 0c 4c 79 10 	movl   $0xf010794c,0xc(%esp)
f010348f:	f0 
f0103490:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0103497:	f0 
f0103498:	c7 44 24 04 ee 04 00 	movl   $0x4ee,0x4(%esp)
f010349f:	00 
f01034a0:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01034a7:	e8 94 cb ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01034ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01034b2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01034b7:	74 24                	je     f01034dd <mem_init+0x1e1a>
f01034b9:	c7 44 24 0c 34 81 10 	movl   $0xf0108134,0xc(%esp)
f01034c0:	f0 
f01034c1:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01034c8:	f0 
f01034c9:	c7 44 24 04 f0 04 00 	movl   $0x4f0,0x4(%esp)
f01034d0:	00 
f01034d1:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01034d8:	e8 63 cb ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01034dd:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01034e3:	89 1c 24             	mov    %ebx,(%esp)
f01034e6:	e8 88 de ff ff       	call   f0101373 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01034eb:	c7 04 24 a0 7e 10 f0 	movl   $0xf0107ea0,(%esp)
f01034f2:	e8 9f 0a 00 00       	call   f0103f96 <cprintf>
f01034f7:	eb 22                	jmp    f010351b <mem_init+0x1e58>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01034f9:	89 da                	mov    %ebx,%edx
f01034fb:	89 f8                	mov    %edi,%eax
f01034fd:	e8 82 d6 ff ff       	call   f0100b84 <check_va2pa>
f0103502:	e9 36 f9 ff ff       	jmp    f0102e3d <mem_init+0x177a>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103507:	81 ea 00 f0 ff 10    	sub    $0x10fff000,%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010350d:	89 f8                	mov    %edi,%eax
f010350f:	e8 70 d6 ff ff       	call   f0100b84 <check_va2pa>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103514:	89 da                	mov    %ebx,%edx
f0103516:	e9 c3 f8 ff ff       	jmp    f0102dde <mem_init+0x171b>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010351b:	83 c4 4c             	add    $0x4c,%esp
f010351e:	5b                   	pop    %ebx
f010351f:	5e                   	pop    %esi
f0103520:	5f                   	pop    %edi
f0103521:	5d                   	pop    %ebp
f0103522:	c3                   	ret    

f0103523 <user_mem_check>:
//
#define ADDRMAX(a, b) ((uint32_t)a < (uint32_t)b)?(uint32_t)b:(uint32_t)a

int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103523:	55                   	push   %ebp
f0103524:	89 e5                	mov    %esp,%ebp
f0103526:	57                   	push   %edi
f0103527:	56                   	push   %esi
f0103528:	53                   	push   %ebx
f0103529:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 3: Your code here.
	uint32_t begin = ROUNDDOWN((uint32_t)va, PGSIZE);
f010352c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010352f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	uint32_t end = ROUNDUP((uint32_t)va + len, PGSIZE);
f0103534:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103537:	03 55 10             	add    0x10(%ebp),%edx
f010353a:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0103540:	89 d7                	mov    %edx,%edi
f0103542:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	pde_t *pagedir = env->env_pgdir;
f0103548:	8b 55 08             	mov    0x8(%ebp),%edx
f010354b:	8b 5a 60             	mov    0x60(%edx),%ebx
	perm |= PTE_P;
f010354e:	8b 75 14             	mov    0x14(%ebp),%esi
f0103551:	83 ce 01             	or     $0x1,%esi

	for (; begin < end; begin += PGSIZE){
f0103554:	39 f8                	cmp    %edi,%eax
f0103556:	0f 83 df 00 00 00    	jae    f010363b <user_mem_check+0x118>
		/* @yuhangj 
		 * Va is below ULIM*/
		if(begin >= ULIM){
f010355c:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103561:	77 1c                	ja     f010357f <user_mem_check+0x5c>
			/* Point to the first erroneous virtual addr */
			user_mem_check_addr = ADDRMAX(va, begin);
			return -E_FAULT;
		}
		pde_t pde = pagedir[PDX(begin)];
f0103563:	89 c2                	mov    %eax,%edx
f0103565:	c1 ea 16             	shr    $0x16,%edx
f0103568:	8b 14 93             	mov    (%ebx,%edx,4),%edx

		/* @yuhangj
		 * check the corresponding PDE has the right/given perm */
		if ((pde & perm) != perm){
f010356b:	89 75 e0             	mov    %esi,-0x20(%ebp)
f010356e:	89 d1                	mov    %edx,%ecx
f0103570:	21 f1                	and    %esi,%ecx
f0103572:	39 ce                	cmp    %ecx,%esi
f0103574:	74 45                	je     f01035bb <user_mem_check+0x98>
f0103576:	eb 2d                	jmp    f01035a5 <user_mem_check+0x82>
	perm |= PTE_P;

	for (; begin < end; begin += PGSIZE){
		/* @yuhangj 
		 * Va is below ULIM*/
		if(begin >= ULIM){
f0103578:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010357d:	76 16                	jbe    f0103595 <user_mem_check+0x72>
			/* Point to the first erroneous virtual addr */
			user_mem_check_addr = ADDRMAX(va, begin);
f010357f:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0103582:	0f 42 45 0c          	cmovb  0xc(%ebp),%eax
f0103586:	a3 44 62 1d f0       	mov    %eax,0xf01d6244
			return -E_FAULT;
f010358b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103590:	e9 ab 00 00 00       	jmp    f0103640 <user_mem_check+0x11d>
		}
		pde_t pde = pagedir[PDX(begin)];
f0103595:	89 c2                	mov    %eax,%edx
f0103597:	c1 ea 16             	shr    $0x16,%edx
f010359a:	8b 14 93             	mov    (%ebx,%edx,4),%edx

		/* @yuhangj
		 * check the corresponding PDE has the right/given perm */
		if ((pde & perm) != perm){
f010359d:	89 d6                	mov    %edx,%esi
f010359f:	21 ce                	and    %ecx,%esi
f01035a1:	39 ce                	cmp    %ecx,%esi
f01035a3:	74 22                	je     f01035c7 <user_mem_check+0xa4>
			user_mem_check_addr = ADDRMAX(va, begin);
f01035a5:	3b 45 0c             	cmp    0xc(%ebp),%eax
f01035a8:	0f 42 45 0c          	cmovb  0xc(%ebp),%eax
f01035ac:	a3 44 62 1d f0       	mov    %eax,0xf01d6244
			return -E_FAULT;
f01035b1:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01035b6:	e9 85 00 00 00       	jmp    f0103640 <user_mem_check+0x11d>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035bb:	8b 0d 88 6e 1d f0    	mov    0xf01d6e88,%ecx
f01035c1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01035c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
		}
		/* @yuhangj 
		 * if this is not a 4MB page
		 * check the corresponding PTE ha the right/given perm */
		if(!(pde & PTE_PS))
f01035c7:	f6 c2 80             	test   $0x80,%dl
f01035ca:	75 5b                	jne    f0103627 <user_mem_check+0x104>
		{
			pte_t pte = ((pte_t*)KADDR(PTE_ADDR(pde)))[PTX(begin)];
f01035cc:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01035d2:	89 d6                	mov    %edx,%esi
f01035d4:	c1 ee 0c             	shr    $0xc,%esi
f01035d7:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01035da:	72 20                	jb     f01035fc <user_mem_check+0xd9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01035dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01035e0:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f01035e7:	f0 
f01035e8:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f01035ef:	00 
f01035f0:	c7 04 24 01 7f 10 f0 	movl   $0xf0107f01,(%esp)
f01035f7:	e8 44 ca ff ff       	call   f0100040 <_panic>
f01035fc:	89 c6                	mov    %eax,%esi
f01035fe:	c1 ee 0c             	shr    $0xc,%esi
f0103601:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
			if((pte & perm) != perm){
f0103607:	8b 94 b2 00 00 00 f0 	mov    -0x10000000(%edx,%esi,4),%edx
f010360e:	21 ca                	and    %ecx,%edx
f0103610:	39 ca                	cmp    %ecx,%edx
f0103612:	74 13                	je     f0103627 <user_mem_check+0x104>
				user_mem_check_addr = ADDRMAX(va,begin);
f0103614:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0103617:	0f 42 45 0c          	cmovb  0xc(%ebp),%eax
f010361b:	a3 44 62 1d f0       	mov    %eax,0xf01d6244
				return -E_FAULT;
f0103620:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103625:	eb 19                	jmp    f0103640 <user_mem_check+0x11d>
	uint32_t begin = ROUNDDOWN((uint32_t)va, PGSIZE);
	uint32_t end = ROUNDUP((uint32_t)va + len, PGSIZE);
	pde_t *pagedir = env->env_pgdir;
	perm |= PTE_P;

	for (; begin < end; begin += PGSIZE){
f0103627:	05 00 10 00 00       	add    $0x1000,%eax
f010362c:	39 c7                	cmp    %eax,%edi
f010362e:	0f 87 44 ff ff ff    	ja     f0103578 <user_mem_check+0x55>
				user_mem_check_addr = ADDRMAX(va,begin);
				return -E_FAULT;
			}
		}
	}
	return 0;
f0103634:	b8 00 00 00 00       	mov    $0x0,%eax
f0103639:	eb 05                	jmp    f0103640 <user_mem_check+0x11d>
f010363b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103640:	83 c4 2c             	add    $0x2c,%esp
f0103643:	5b                   	pop    %ebx
f0103644:	5e                   	pop    %esi
f0103645:	5f                   	pop    %edi
f0103646:	5d                   	pop    %ebp
f0103647:	c3                   	ret    

f0103648 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103648:	55                   	push   %ebp
f0103649:	89 e5                	mov    %esp,%ebp
f010364b:	53                   	push   %ebx
f010364c:	83 ec 14             	sub    $0x14,%esp
f010364f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103652:	8b 45 14             	mov    0x14(%ebp),%eax
f0103655:	83 c8 04             	or     $0x4,%eax
f0103658:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010365c:	8b 45 10             	mov    0x10(%ebp),%eax
f010365f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103663:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103666:	89 44 24 04          	mov    %eax,0x4(%esp)
f010366a:	89 1c 24             	mov    %ebx,(%esp)
f010366d:	e8 b1 fe ff ff       	call   f0103523 <user_mem_check>
f0103672:	85 c0                	test   %eax,%eax
f0103674:	79 24                	jns    f010369a <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103676:	a1 44 62 1d f0       	mov    0xf01d6244,%eax
f010367b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010367f:	8b 43 48             	mov    0x48(%ebx),%eax
f0103682:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103686:	c7 04 24 cc 7e 10 f0 	movl   $0xf0107ecc,(%esp)
f010368d:	e8 04 09 00 00       	call   f0103f96 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103692:	89 1c 24             	mov    %ebx,(%esp)
f0103695:	e8 1e 06 00 00       	call   f0103cb8 <env_destroy>
	}
}
f010369a:	83 c4 14             	add    $0x14,%esp
f010369d:	5b                   	pop    %ebx
f010369e:	5d                   	pop    %ebp
f010369f:	c3                   	ret    

f01036a0 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01036a0:	55                   	push   %ebp
f01036a1:	89 e5                	mov    %esp,%ebp
f01036a3:	57                   	push   %edi
f01036a4:	56                   	push   %esi
f01036a5:	53                   	push   %ebx
f01036a6:	83 ec 1c             	sub    $0x1c,%esp
f01036a9:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uint32_t begin = ROUNDDOWN((uint32_t)va, PGSIZE);
f01036ab:	89 d3                	mov    %edx,%ebx
f01036ad:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t i, end = ROUNDUP((uint32_t)(va + len), PGSIZE);
f01036b3:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f01036ba:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	//int i;
	struct Page* pg;
	env_cprintf("\nva[%p]; begin[0x%x]; end[0x%x]; len[%d: 0x%x]; PGSIZE[0x%x]\n",
	 va, begin, end, len, len, PGSIZE);

	for (i = begin; i < end; i= i+PGSIZE){
f01036c0:	39 f3                	cmp    %esi,%ebx
f01036c2:	73 31                	jae    f01036f5 <region_alloc+0x55>

		env_cprintf("\ni[0x%x]: begin[%p], end[%p]\n", i, begin, end);

		pg = page_alloc(!ALLOC_ZERO);
f01036c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01036cb:	e8 24 dc ff ff       	call   f01012f4 <page_alloc>

		env_cprintf("Allocate page[addr:%p] in pages array for env\n", pg);
		
		page_insert(e->env_pgdir, pg,(void*)i, PTE_U|PTE_W|PTE_P);
f01036d0:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01036d7:	00 
f01036d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01036dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036e0:	8b 47 60             	mov    0x60(%edi),%eax
f01036e3:	89 04 24             	mov    %eax,(%esp)
f01036e6:	e8 5e df ff ff       	call   f0101649 <page_insert>
	//int i;
	struct Page* pg;
	env_cprintf("\nva[%p]; begin[0x%x]; end[0x%x]; len[%d: 0x%x]; PGSIZE[0x%x]\n",
	 va, begin, end, len, len, PGSIZE);

	for (i = begin; i < end; i= i+PGSIZE){
f01036eb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01036f1:	39 de                	cmp    %ebx,%esi
f01036f3:	77 cf                	ja     f01036c4 <region_alloc+0x24>
		
		page_insert(e->env_pgdir, pg,(void*)i, PTE_U|PTE_W|PTE_P);
		env_cprintf("page_insert is OK!\n");
	}
	env_cprintf("\n#####END of function region_alloc()#####\n");
}
f01036f5:	83 c4 1c             	add    $0x1c,%esp
f01036f8:	5b                   	pop    %ebx
f01036f9:	5e                   	pop    %esi
f01036fa:	5f                   	pop    %edi
f01036fb:	5d                   	pop    %ebp
f01036fc:	c3                   	ret    

f01036fd <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01036fd:	55                   	push   %ebp
f01036fe:	89 e5                	mov    %esp,%ebp
f0103700:	83 ec 08             	sub    $0x8,%esp
f0103703:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0103706:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0103709:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010370c:	85 c0                	test   %eax,%eax
f010370e:	75 1a                	jne    f010372a <envid2env+0x2d>
		*env_store = curenv;
f0103710:	e8 27 30 00 00       	call   f010673c <cpunum>
f0103715:	6b c0 74             	imul   $0x74,%eax,%eax
f0103718:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f010371e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103721:	89 02                	mov    %eax,(%edx)
		return 0;
f0103723:	b8 00 00 00 00       	mov    $0x0,%eax
f0103728:	eb 72                	jmp    f010379c <envid2env+0x9f>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010372a:	89 c3                	mov    %eax,%ebx
f010372c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103732:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103735:	03 1d 48 62 1d f0    	add    0xf01d6248,%ebx
	//env_cprintf("Get the addr of env[%d]:[%p]",ENVX(envid), e);
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010373b:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010373f:	74 05                	je     f0103746 <envid2env+0x49>
f0103741:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103744:	74 10                	je     f0103756 <envid2env+0x59>
		*env_store = 0;
f0103746:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103749:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010374f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103754:	eb 46                	jmp    f010379c <envid2env+0x9f>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103756:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010375a:	74 36                	je     f0103792 <envid2env+0x95>
f010375c:	e8 db 2f 00 00       	call   f010673c <cpunum>
f0103761:	6b c0 74             	imul   $0x74,%eax,%eax
f0103764:	39 98 28 70 1d f0    	cmp    %ebx,-0xfe28fd8(%eax)
f010376a:	74 26                	je     f0103792 <envid2env+0x95>
f010376c:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010376f:	e8 c8 2f 00 00       	call   f010673c <cpunum>
f0103774:	6b c0 74             	imul   $0x74,%eax,%eax
f0103777:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f010377d:	3b 70 48             	cmp    0x48(%eax),%esi
f0103780:	74 10                	je     f0103792 <envid2env+0x95>
		*env_store = 0;
f0103782:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103785:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		return -E_BAD_ENV;
f010378b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103790:	eb 0a                	jmp    f010379c <envid2env+0x9f>
	}

	*env_store = e;
f0103792:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103795:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103797:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010379c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010379f:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01037a2:	89 ec                	mov    %ebp,%esp
f01037a4:	5d                   	pop    %ebp
f01037a5:	c3                   	ret    

f01037a6 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01037a6:	55                   	push   %ebp
f01037a7:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01037a9:	b8 00 23 12 f0       	mov    $0xf0122300,%eax
f01037ae:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01037b1:	b8 23 00 00 00       	mov    $0x23,%eax
f01037b6:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01037b8:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01037ba:	b0 10                	mov    $0x10,%al
f01037bc:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01037be:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01037c0:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01037c2:	ea c9 37 10 f0 08 00 	ljmp   $0x8,$0xf01037c9
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01037c9:	b0 00                	mov    $0x0,%al
f01037cb:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01037ce:	5d                   	pop    %ebp
f01037cf:	c3                   	ret    

f01037d0 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01037d0:	55                   	push   %ebp
f01037d1:	89 e5                	mov    %esp,%ebp
f01037d3:	56                   	push   %esi
f01037d4:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	//memset(envs, 0x00, sizeof(struct Env) * NENV);
	for (i = NENV - 1; i >= 0; i--){
		envs[i].env_status = ENV_FREE;
f01037d5:	8b 35 48 62 1d f0    	mov    0xf01d6248,%esi
f01037db:	8b 0d 4c 62 1d f0    	mov    0xf01d624c,%ecx
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f01037e1:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01037e7:	ba 00 04 00 00       	mov    $0x400,%edx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	//memset(envs, 0x00, sizeof(struct Env) * NENV);
	for (i = NENV - 1; i >= 0; i--){
		envs[i].env_status = ENV_FREE;
f01037ec:	89 c3                	mov    %eax,%ebx
f01037ee:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f01037f5:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01037fc:	89 48 44             	mov    %ecx,0x44(%eax)
f01037ff:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0103802:	89 d9                	mov    %ebx,%ecx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	//memset(envs, 0x00, sizeof(struct Env) * NENV);
	for (i = NENV - 1; i >= 0; i--){
f0103804:	83 ea 01             	sub    $0x1,%edx
f0103807:	75 e3                	jne    f01037ec <env_init+0x1c>
f0103809:	89 35 4c 62 1d f0    	mov    %esi,0xf01d624c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
		//cprintf("Insert envs[%d] into env_free_list:[%p]\n", i,env_free_list);
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f010380f:	e8 92 ff ff ff       	call   f01037a6 <env_init_percpu>
}
f0103814:	5b                   	pop    %ebx
f0103815:	5e                   	pop    %esi
f0103816:	5d                   	pop    %ebp
f0103817:	c3                   	ret    

f0103818 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103818:	55                   	push   %ebp
f0103819:	89 e5                	mov    %esp,%ebp
f010381b:	53                   	push   %ebx
f010381c:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010381f:	8b 1d 4c 62 1d f0    	mov    0xf01d624c,%ebx
f0103825:	85 db                	test   %ebx,%ebx
f0103827:	0f 84 6e 01 00 00    	je     f010399b <env_alloc+0x183>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010382d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103834:	e8 bb da ff ff       	call   f01012f4 <page_alloc>
f0103839:	85 c0                	test   %eax,%eax
f010383b:	0f 84 61 01 00 00    	je     f01039a2 <env_alloc+0x18a>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0103841:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
page2pa(struct Page *pp)
{
	//cprintf("\npage addr:[%p]; pages head_addr:[%p]; transfered PA:[]\n", 
	//	 pp, pages);
	
	return (pp - pages) << PGSHIFT;
f0103846:	2b 05 90 6e 1d f0    	sub    0xf01d6e90,%eax
f010384c:	c1 f8 03             	sar    $0x3,%eax
f010384f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103852:	89 c2                	mov    %eax,%edx
f0103854:	c1 ea 0c             	shr    $0xc,%edx
f0103857:	3b 15 88 6e 1d f0    	cmp    0xf01d6e88,%edx
f010385d:	72 20                	jb     f010387f <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010385f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103863:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f010386a:	f0 
f010386b:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0103872:	00 
f0103873:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f010387a:	e8 c1 c7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010387f:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir =(pde_t*) page2kva(p);
f0103884:	89 43 60             	mov    %eax,0x60(%ebx)
	env_cprintf("Page addr[%p] pages[%d]\n", 
		p, ((int)p - (int)pages)/sizeof(struct Page*));
	env_cprintf("Allocates the e->env_pgdir at kva [%p]\n", e->env_pgdir);
	env_cprintf("kern_pgdir addr is [%p]\n", kern_pgdir);

	memmove(e->env_pgdir, kern_pgdir, PGSIZE);
f0103887:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010388e:	00 
f010388f:	8b 15 8c 6e 1d f0    	mov    0xf01d6e8c,%edx
f0103895:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103899:	89 04 24             	mov    %eax,(%esp)
f010389c:	e8 52 28 00 00       	call   f01060f3 <memmove>
	memset(e->env_pgdir, 0, sizeof(pde_t)*PDX(UTOP));
f01038a1:	c7 44 24 08 ec 0e 00 	movl   $0xeec,0x8(%esp)
f01038a8:	00 
f01038a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01038b0:	00 
f01038b1:	8b 43 60             	mov    0x60(%ebx),%eax
f01038b4:	89 04 24             	mov    %eax,(%esp)
f01038b7:	e8 d9 27 00 00       	call   f0106095 <memset>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01038bc:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038bf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038c4:	77 20                	ja     f01038e6 <env_alloc+0xce>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038ca:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f01038d1:	f0 
f01038d2:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f01038d9:	00 
f01038da:	c7 04 24 84 82 10 f0 	movl   $0xf0108284,(%esp)
f01038e1:	e8 5a c7 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01038e6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01038ec:	83 ca 05             	or     $0x5,%edx
f01038ef:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	/* @yuhangj: if true,return -E_NO_FREE_ENV < 0*/
	if ((r = env_setup_vm(e)) < 0) 
		return r;

	// Generate an env_id for this environment. 1 << 12
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01038f5:	8b 43 48             	mov    0x48(%ebx),%eax
f01038f8:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01038fd:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103902:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103907:	0f 4e c2             	cmovle %edx,%eax

	env_cprintf("generation [%d]\n", generation);
	e->env_id = generation | (e - envs);
f010390a:	89 da                	mov    %ebx,%edx
f010390c:	2b 15 48 62 1d f0    	sub    0xf01d6248,%edx
f0103912:	c1 fa 02             	sar    $0x2,%edx
f0103915:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010391b:	09 d0                	or     %edx,%eax
f010391d:	89 43 48             	mov    %eax,0x48(%ebx)
	env_cprintf("e->env_id[%d]; parent_id[%d]\n", e->env_id, parent_id);

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103920:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103923:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103926:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010392d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103934:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010393b:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103942:	00 
f0103943:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010394a:	00 
f010394b:	89 1c 24             	mov    %ebx,(%esp)
f010394e:	e8 42 27 00 00       	call   f0106095 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103953:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103959:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010395f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103965:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010396c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103972:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103979:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103980:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103987:	8b 43 44             	mov    0x44(%ebx),%eax
f010398a:	a3 4c 62 1d f0       	mov    %eax,0xf01d624c
	*newenv_store = e;
f010398f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103992:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103994:	b8 00 00 00 00       	mov    $0x0,%eax
f0103999:	eb 0c                	jmp    f01039a7 <env_alloc+0x18f>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010399b:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01039a0:	eb 05                	jmp    f01039a7 <env_alloc+0x18f>
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01039a2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01039a7:	83 c4 14             	add    $0x14,%esp
f01039aa:	5b                   	pop    %ebx
f01039ab:	5d                   	pop    %ebp
f01039ac:	c3                   	ret    

f01039ad <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f01039ad:	55                   	push   %ebp
f01039ae:	89 e5                	mov    %esp,%ebp
f01039b0:	57                   	push   %edi
f01039b1:	56                   	push   %esi
f01039b2:	53                   	push   %ebx
f01039b3:	83 ec 3c             	sub    $0x3c,%esp
f01039b6:	8b 7d 08             	mov    0x8(%ebp),%edi
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	struct Env* penv;
	
	//cprintf("\ncreate an new env with TYPE[%d]\n", type);
	env_alloc(&penv, 0);
f01039b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01039c0:	00 
f01039c1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01039c4:	89 04 24             	mov    %eax,(%esp)
f01039c7:	e8 4c fe ff ff       	call   f0103818 <env_alloc>

	load_icode(penv,binary, size);
f01039cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	env_cprintf("\n          In function load_icode()\n");
	env_cprintf("Binary/elfhd addr[%p]; Env(e) addr[%p]; Size[%p]\n", 
		binary, e, size);

	if(elfhd->e_magic != ELF_MAGIC)
f01039d2:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01039d8:	74 0c                	je     f01039e6 <env_create+0x39>
		cprintf("load_icode(): invalid elf file\n");
f01039da:	c7 04 24 64 82 10 f0 	movl   $0xf0108264,(%esp)
f01039e1:	e8 b0 05 00 00       	call   f0103f96 <cprintf>
	struct Proghdr *ph, *eph;

	/* @yuhangj
	 * (uint8_t*) is very important!!!!!!!!!!! 
	 * Or you cannot find the true addr of ph*/
	ph = (struct Proghdr*)((uint8_t *)elfhd + elfhd->e_phoff);
f01039e6:	89 fb                	mov    %edi,%ebx
f01039e8:	03 5f 1c             	add    0x1c(%edi),%ebx

	env_cprintf("ph [%p];\n", ph);
	env_cprintf("\nPADDR(e->env_pgdir)[%p]\n", PADDR(e->env_pgdir));
	env_cprintf("elfhd[%p]; e_phnum[%d]; e_entry[%p]; e_phoff[%d]\n", 
		elfhd,elfhd->e_phnum,elfhd->e_entry,elfhd->e_phoff);
	lcr3(PADDR(e->env_pgdir));
f01039eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01039ee:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039f1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039f6:	77 20                	ja     f0103a18 <env_create+0x6b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039fc:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0103a03:	f0 
f0103a04:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
f0103a0b:	00 
f0103a0c:	c7 04 24 84 82 10 f0 	movl   $0xf0108284,(%esp)
f0103a13:	e8 28 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a18:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103a1d:	0f 22 d8             	mov    %eax,%cr3

	for(i = 0; i < elfhd->e_phnum; i++,ph++){
f0103a20:	66 83 7f 2c 00       	cmpw   $0x0,0x2c(%edi)
f0103a25:	74 5b                	je     f0103a82 <env_create+0xd5>
f0103a27:	be 00 00 00 00       	mov    $0x0,%esi
		
		if(ph->p_type == ELF_PROG_LOAD){
f0103a2c:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103a2f:	75 43                	jne    f0103a74 <env_create+0xc7>
			env_cprintf("[num=%d]:ph[%p]; p_type[%d]\n", i, ph, ph->p_type);
			env_cprintf("p_pa[%p]; p_va[%p]; p_memsz[%d]; p_filesz[%d]\n", 
				ph->p_pa, ph->p_va, ph->p_memsz, ph->p_filesz);
			
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f0103a31:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103a34:	8b 53 08             	mov    0x8(%ebx),%edx
f0103a37:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a3a:	e8 61 fc ff ff       	call   f01036a0 <region_alloc>
			env_cprintf("region_alloc() succeed!\n");

			memset((void*)ph->p_va, 0, ph->p_memsz);
f0103a3f:	8b 43 14             	mov    0x14(%ebx),%eax
f0103a42:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a4d:	00 
f0103a4e:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a51:	89 04 24             	mov    %eax,(%esp)
f0103a54:	e8 3c 26 00 00       	call   f0106095 <memset>
			env_cprintf("memset() at ph->p_va[%p] with size[0x%x] succeed!\n", 
				ph->p_va, ph->p_memsz);
			
			memmove((void*)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0103a59:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a5c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a60:	89 f8                	mov    %edi,%eax
f0103a62:	03 43 04             	add    0x4(%ebx),%eax
f0103a65:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a69:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a6c:	89 04 24             	mov    %eax,(%esp)
f0103a6f:	e8 7f 26 00 00       	call   f01060f3 <memmove>
	env_cprintf("\nPADDR(e->env_pgdir)[%p]\n", PADDR(e->env_pgdir));
	env_cprintf("elfhd[%p]; e_phnum[%d]; e_entry[%p]; e_phoff[%d]\n", 
		elfhd,elfhd->e_phnum,elfhd->e_entry,elfhd->e_phoff);
	lcr3(PADDR(e->env_pgdir));

	for(i = 0; i < elfhd->e_phnum; i++,ph++){
f0103a74:	83 c6 01             	add    $0x1,%esi
f0103a77:	83 c3 20             	add    $0x20,%ebx
f0103a7a:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
f0103a7e:	39 c6                	cmp    %eax,%esi
f0103a80:	7c aa                	jl     f0103a2c <env_create+0x7f>
				ph->p_va, ph->p_filesz);


		}
	}
	lcr3(PADDR(kern_pgdir));
f0103a82:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a87:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a8c:	77 20                	ja     f0103aae <env_create+0x101>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a92:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0103a99:	f0 
f0103a9a:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0103aa1:	00 
f0103aa2:	c7 04 24 84 82 10 f0 	movl   $0xf0108284,(%esp)
f0103aa9:	e8 92 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103aae:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ab3:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = elfhd->e_entry;
f0103ab6:	8b 47 18             	mov    0x18(%edi),%eax
f0103ab9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103abc:	89 42 30             	mov    %eax,0x30(%edx)
	env_cprintf("e tf_eip[%p]\n", e->env_tf.tf_eip);

	//
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE); 
f0103abf:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103ac4:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103ac9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103acc:	e8 cf fb ff ff       	call   f01036a0 <region_alloc>
	//cprintf("\ncreate an new env with TYPE[%d]\n", type);
	env_alloc(&penv, 0);

	load_icode(penv,binary, size);
	
	penv->env_type = type;
f0103ad1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ad4:	8b 55 10             	mov    0x10(%ebp),%edx
f0103ad7:	89 50 50             	mov    %edx,0x50(%eax)
	penv->env_parent_id = 0;
f0103ada:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
}
f0103ae1:	83 c4 3c             	add    $0x3c,%esp
f0103ae4:	5b                   	pop    %ebx
f0103ae5:	5e                   	pop    %esi
f0103ae6:	5f                   	pop    %edi
f0103ae7:	5d                   	pop    %ebp
f0103ae8:	c3                   	ret    

f0103ae9 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103ae9:	55                   	push   %ebp
f0103aea:	89 e5                	mov    %esp,%ebp
f0103aec:	57                   	push   %edi
f0103aed:	56                   	push   %esi
f0103aee:	53                   	push   %ebx
f0103aef:	83 ec 2c             	sub    $0x2c,%esp
f0103af2:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103af5:	e8 42 2c 00 00       	call   f010673c <cpunum>
f0103afa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103afd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103b04:	39 b8 28 70 1d f0    	cmp    %edi,-0xfe28fd8(%eax)
f0103b0a:	75 3b                	jne    f0103b47 <env_free+0x5e>
		lcr3(PADDR(kern_pgdir));
f0103b0c:	a1 8c 6e 1d f0       	mov    0xf01d6e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b11:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b16:	77 20                	ja     f0103b38 <env_free+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b18:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b1c:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0103b23:	f0 
f0103b24:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
f0103b2b:	00 
f0103b2c:	c7 04 24 84 82 10 f0 	movl   $0xf0108284,(%esp)
f0103b33:	e8 08 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b38:	05 00 00 00 10       	add    $0x10000000,%eax
f0103b3d:	0f 22 d8             	mov    %eax,%cr3
f0103b40:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
f0103b47:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b4a:	c1 e0 02             	shl    $0x2,%eax
f0103b4d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b50:	8b 47 60             	mov    0x60(%edi),%eax
f0103b53:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b56:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103b59:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b5f:	0f 84 b7 00 00 00    	je     f0103c1c <env_free+0x133>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b65:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b6b:	89 f0                	mov    %esi,%eax
f0103b6d:	c1 e8 0c             	shr    $0xc,%eax
f0103b70:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b73:	3b 05 88 6e 1d f0    	cmp    0xf01d6e88,%eax
f0103b79:	72 20                	jb     f0103b9b <env_free+0xb2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b7b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b7f:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f0103b86:	f0 
f0103b87:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
f0103b8e:	00 
f0103b8f:	c7 04 24 84 82 10 f0 	movl   $0xf0108284,(%esp)
f0103b96:	e8 a5 c4 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b9b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b9e:	c1 e2 16             	shl    $0x16,%edx
f0103ba1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103ba4:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103ba9:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103bb0:	01 
f0103bb1:	74 17                	je     f0103bca <env_free+0xe1>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103bb3:	89 d8                	mov    %ebx,%eax
f0103bb5:	c1 e0 0c             	shl    $0xc,%eax
f0103bb8:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103bbb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bbf:	8b 47 60             	mov    0x60(%edi),%eax
f0103bc2:	89 04 24             	mov    %eax,(%esp)
f0103bc5:	e8 28 da ff ff       	call   f01015f2 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103bca:	83 c3 01             	add    $0x1,%ebx
f0103bcd:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103bd3:	75 d4                	jne    f0103ba9 <env_free+0xc0>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103bd5:	8b 47 60             	mov    0x60(%edi),%eax
f0103bd8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103bdb:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103be2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103be5:	3b 05 88 6e 1d f0    	cmp    0xf01d6e88,%eax
f0103beb:	72 1c                	jb     f0103c09 <env_free+0x120>
		panic("pa2page called with invalid pa");
f0103bed:	c7 44 24 08 68 76 10 	movl   $0xf0107668,0x8(%esp)
f0103bf4:	f0 
f0103bf5:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0103bfc:	00 
f0103bfd:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f0103c04:	e8 37 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c09:	a1 90 6e 1d f0       	mov    0xf01d6e90,%eax
f0103c0e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103c11:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103c14:	89 04 24             	mov    %eax,(%esp)
f0103c17:	e8 6c d7 ff ff       	call   f0101388 <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103c1c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103c20:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103c27:	0f 85 1a ff ff ff    	jne    f0103b47 <env_free+0x5e>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103c2d:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c30:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c35:	77 20                	ja     f0103c57 <env_free+0x16e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c37:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c3b:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0103c42:	f0 
f0103c43:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
f0103c4a:	00 
f0103c4b:	c7 04 24 84 82 10 f0 	movl   $0xf0108284,(%esp)
f0103c52:	e8 e9 c3 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103c57:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c5e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c63:	c1 e8 0c             	shr    $0xc,%eax
f0103c66:	3b 05 88 6e 1d f0    	cmp    0xf01d6e88,%eax
f0103c6c:	72 1c                	jb     f0103c8a <env_free+0x1a1>
		panic("pa2page called with invalid pa");
f0103c6e:	c7 44 24 08 68 76 10 	movl   $0xf0107668,0x8(%esp)
f0103c75:	f0 
f0103c76:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0103c7d:	00 
f0103c7e:	c7 04 24 0d 7f 10 f0 	movl   $0xf0107f0d,(%esp)
f0103c85:	e8 b6 c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c8a:	8b 15 90 6e 1d f0    	mov    0xf01d6e90,%edx
f0103c90:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103c93:	89 04 24             	mov    %eax,(%esp)
f0103c96:	e8 ed d6 ff ff       	call   f0101388 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c9b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103ca2:	a1 4c 62 1d f0       	mov    0xf01d624c,%eax
f0103ca7:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103caa:	89 3d 4c 62 1d f0    	mov    %edi,0xf01d624c
}
f0103cb0:	83 c4 2c             	add    $0x2c,%esp
f0103cb3:	5b                   	pop    %ebx
f0103cb4:	5e                   	pop    %esi
f0103cb5:	5f                   	pop    %edi
f0103cb6:	5d                   	pop    %ebp
f0103cb7:	c3                   	ret    

f0103cb8 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103cb8:	55                   	push   %ebp
f0103cb9:	89 e5                	mov    %esp,%ebp
f0103cbb:	53                   	push   %ebx
f0103cbc:	83 ec 14             	sub    $0x14,%esp
f0103cbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103cc2:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103cc6:	75 19                	jne    f0103ce1 <env_destroy+0x29>
f0103cc8:	e8 6f 2a 00 00       	call   f010673c <cpunum>
f0103ccd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cd0:	39 98 28 70 1d f0    	cmp    %ebx,-0xfe28fd8(%eax)
f0103cd6:	74 09                	je     f0103ce1 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103cd8:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103cdf:	eb 2f                	jmp    f0103d10 <env_destroy+0x58>
	}

	env_free(e);
f0103ce1:	89 1c 24             	mov    %ebx,(%esp)
f0103ce4:	e8 00 fe ff ff       	call   f0103ae9 <env_free>

	if (curenv == e) {
f0103ce9:	e8 4e 2a 00 00       	call   f010673c <cpunum>
f0103cee:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cf1:	39 98 28 70 1d f0    	cmp    %ebx,-0xfe28fd8(%eax)
f0103cf7:	75 17                	jne    f0103d10 <env_destroy+0x58>
		curenv = NULL;
f0103cf9:	e8 3e 2a 00 00       	call   f010673c <cpunum>
f0103cfe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d01:	c7 80 28 70 1d f0 00 	movl   $0x0,-0xfe28fd8(%eax)
f0103d08:	00 00 00 
		sched_yield();
f0103d0b:	e8 04 0f 00 00       	call   f0104c14 <sched_yield>
	}
}
f0103d10:	83 c4 14             	add    $0x14,%esp
f0103d13:	5b                   	pop    %ebx
f0103d14:	5d                   	pop    %ebp
f0103d15:	c3                   	ret    

f0103d16 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103d16:	55                   	push   %ebp
f0103d17:	89 e5                	mov    %esp,%ebp
f0103d19:	53                   	push   %ebx
f0103d1a:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103d1d:	e8 1a 2a 00 00       	call   f010673c <cpunum>
f0103d22:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d25:	8b 98 28 70 1d f0    	mov    -0xfe28fd8(%eax),%ebx
f0103d2b:	e8 0c 2a 00 00       	call   f010673c <cpunum>
f0103d30:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103d33:	8b 65 08             	mov    0x8(%ebp),%esp
f0103d36:	61                   	popa   
f0103d37:	07                   	pop    %es
f0103d38:	1f                   	pop    %ds
f0103d39:	83 c4 08             	add    $0x8,%esp
f0103d3c:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103d3d:	c7 44 24 08 8f 82 10 	movl   $0xf010828f,0x8(%esp)
f0103d44:	f0 
f0103d45:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
f0103d4c:	00 
f0103d4d:	c7 04 24 84 82 10 f0 	movl   $0xf0108284,(%esp)
f0103d54:	e8 e7 c2 ff ff       	call   f0100040 <_panic>

f0103d59 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d59:	55                   	push   %ebp
f0103d5a:	89 e5                	mov    %esp,%ebp
f0103d5c:	53                   	push   %ebx
f0103d5d:	83 ec 14             	sub    $0x14,%esp
f0103d60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103d63:	e8 d4 29 00 00       	call   f010673c <cpunum>
f0103d68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d6b:	83 b8 28 70 1d f0 00 	cmpl   $0x0,-0xfe28fd8(%eax)
f0103d72:	74 29                	je     f0103d9d <env_run+0x44>
f0103d74:	e8 c3 29 00 00       	call   f010673c <cpunum>
f0103d79:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d7c:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0103d82:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d86:	75 15                	jne    f0103d9d <env_run+0x44>
        curenv->env_status = ENV_RUNNABLE;
f0103d88:	e8 af 29 00 00       	call   f010673c <cpunum>
f0103d8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d90:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0103d96:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

    //cprintf("\nIn function env_run\n");
    curenv = e;
f0103d9d:	e8 9a 29 00 00       	call   f010673c <cpunum>
f0103da2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103da5:	89 98 28 70 1d f0    	mov    %ebx,-0xfe28fd8(%eax)
    curenv->env_status = ENV_RUNNING;
f0103dab:	e8 8c 29 00 00       	call   f010673c <cpunum>
f0103db0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db3:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0103db9:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f0103dc0:	e8 77 29 00 00       	call   f010673c <cpunum>
f0103dc5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dc8:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0103dce:	83 40 58 01          	addl   $0x1,0x58(%eax)

    lcr3(PADDR(curenv->env_pgdir));
f0103dd2:	e8 65 29 00 00       	call   f010673c <cpunum>
f0103dd7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dda:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0103de0:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103de3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103de8:	77 20                	ja     f0103e0a <env_run+0xb1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103dea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103dee:	c7 44 24 08 c4 6e 10 	movl   $0xf0106ec4,0x8(%esp)
f0103df5:	f0 
f0103df6:	c7 44 24 04 62 02 00 	movl   $0x262,0x4(%esp)
f0103dfd:	00 
f0103dfe:	c7 04 24 84 82 10 f0 	movl   $0xf0108284,(%esp)
f0103e05:	e8 36 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103e0a:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e0f:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103e12:	c7 04 24 a0 23 12 f0 	movl   $0xf01223a0,(%esp)
f0103e19:	e8 87 2c 00 00       	call   f0106aa5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103e1e:	f3 90                	pause  
    unlock_kernel();
    env_pop_tf(&e->env_tf);
f0103e20:	89 1c 24             	mov    %ebx,(%esp)
f0103e23:	e8 ee fe ff ff       	call   f0103d16 <env_pop_tf>

f0103e28 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e28:	55                   	push   %ebp
f0103e29:	89 e5                	mov    %esp,%ebp
void
mc146818_write(unsigned reg, unsigned datum)
{
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e2b:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e2f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e34:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e35:	b2 71                	mov    $0x71,%dl
f0103e37:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e38:	0f b6 c0             	movzbl %al,%eax
}
f0103e3b:	5d                   	pop    %ebp
f0103e3c:	c3                   	ret    

f0103e3d <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e3d:	55                   	push   %ebp
f0103e3e:	89 e5                	mov    %esp,%ebp
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e40:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e44:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e49:	ee                   	out    %al,(%dx)
f0103e4a:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
f0103e4e:	b2 71                	mov    $0x71,%dl
f0103e50:	ee                   	out    %al,(%dx)
f0103e51:	5d                   	pop    %ebp
f0103e52:	c3                   	ret    
f0103e53:	90                   	nop

f0103e54 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e54:	55                   	push   %ebp
f0103e55:	89 e5                	mov    %esp,%ebp
f0103e57:	56                   	push   %esi
f0103e58:	53                   	push   %ebx
f0103e59:	83 ec 10             	sub    $0x10,%esp
f0103e5c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103e5f:	66 a3 88 23 12 f0    	mov    %ax,0xf0122388
	if (!didinit)
f0103e65:	83 3d 50 62 1d f0 00 	cmpl   $0x0,0xf01d6250
f0103e6c:	74 4e                	je     f0103ebc <irq_setmask_8259A+0x68>
f0103e6e:	89 c6                	mov    %eax,%esi
f0103e70:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e75:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e76:	66 c1 e8 08          	shr    $0x8,%ax
f0103e7a:	b2 a1                	mov    $0xa1,%dl
f0103e7c:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e7d:	c7 04 24 9b 82 10 f0 	movl   $0xf010829b,(%esp)
f0103e84:	e8 0d 01 00 00       	call   f0103f96 <cprintf>
	for (i = 0; i < 16; i++)
f0103e89:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e8e:	0f b7 f6             	movzwl %si,%esi
f0103e91:	f7 d6                	not    %esi
f0103e93:	0f a3 de             	bt     %ebx,%esi
f0103e96:	73 10                	jae    f0103ea8 <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0103e98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e9c:	c7 04 24 af 88 10 f0 	movl   $0xf01088af,(%esp)
f0103ea3:	e8 ee 00 00 00       	call   f0103f96 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103ea8:	83 c3 01             	add    $0x1,%ebx
f0103eab:	83 fb 10             	cmp    $0x10,%ebx
f0103eae:	75 e3                	jne    f0103e93 <irq_setmask_8259A+0x3f>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103eb0:	c7 04 24 e5 81 10 f0 	movl   $0xf01081e5,(%esp)
f0103eb7:	e8 da 00 00 00       	call   f0103f96 <cprintf>
}
f0103ebc:	83 c4 10             	add    $0x10,%esp
f0103ebf:	5b                   	pop    %ebx
f0103ec0:	5e                   	pop    %esi
f0103ec1:	5d                   	pop    %ebp
f0103ec2:	c3                   	ret    

f0103ec3 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103ec3:	c7 05 50 62 1d f0 01 	movl   $0x1,0xf01d6250
f0103eca:	00 00 00 
f0103ecd:	ba 21 00 00 00       	mov    $0x21,%edx
f0103ed2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ed7:	ee                   	out    %al,(%dx)
f0103ed8:	b2 a1                	mov    $0xa1,%dl
f0103eda:	ee                   	out    %al,(%dx)
f0103edb:	b2 20                	mov    $0x20,%dl
f0103edd:	b8 11 00 00 00       	mov    $0x11,%eax
f0103ee2:	ee                   	out    %al,(%dx)
f0103ee3:	b2 21                	mov    $0x21,%dl
f0103ee5:	b8 20 00 00 00       	mov    $0x20,%eax
f0103eea:	ee                   	out    %al,(%dx)
f0103eeb:	b8 04 00 00 00       	mov    $0x4,%eax
f0103ef0:	ee                   	out    %al,(%dx)
f0103ef1:	b8 03 00 00 00       	mov    $0x3,%eax
f0103ef6:	ee                   	out    %al,(%dx)
f0103ef7:	b2 a0                	mov    $0xa0,%dl
f0103ef9:	b8 11 00 00 00       	mov    $0x11,%eax
f0103efe:	ee                   	out    %al,(%dx)
f0103eff:	b2 a1                	mov    $0xa1,%dl
f0103f01:	b8 28 00 00 00       	mov    $0x28,%eax
f0103f06:	ee                   	out    %al,(%dx)
f0103f07:	b8 02 00 00 00       	mov    $0x2,%eax
f0103f0c:	ee                   	out    %al,(%dx)
f0103f0d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f12:	ee                   	out    %al,(%dx)
f0103f13:	b2 20                	mov    $0x20,%dl
f0103f15:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f1a:	ee                   	out    %al,(%dx)
f0103f1b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f20:	ee                   	out    %al,(%dx)
f0103f21:	b2 a0                	mov    $0xa0,%dl
f0103f23:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f28:	ee                   	out    %al,(%dx)
f0103f29:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f2e:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103f2f:	0f b7 05 88 23 12 f0 	movzwl 0xf0122388,%eax
f0103f36:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f3a:	74 12                	je     f0103f4e <pic_init+0x8b>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103f3c:	55                   	push   %ebp
f0103f3d:	89 e5                	mov    %esp,%ebp
f0103f3f:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103f42:	0f b7 c0             	movzwl %ax,%eax
f0103f45:	89 04 24             	mov    %eax,(%esp)
f0103f48:	e8 07 ff ff ff       	call   f0103e54 <irq_setmask_8259A>
}
f0103f4d:	c9                   	leave  
f0103f4e:	f3 c3                	repz ret 

f0103f50 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f50:	55                   	push   %ebp
f0103f51:	89 e5                	mov    %esp,%ebp
f0103f53:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103f56:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f59:	89 04 24             	mov    %eax,(%esp)
f0103f5c:	e8 84 c8 ff ff       	call   f01007e5 <cputchar>
	*cnt++;
}
f0103f61:	c9                   	leave  
f0103f62:	c3                   	ret    

f0103f63 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f63:	55                   	push   %ebp
f0103f64:	89 e5                	mov    %esp,%ebp
f0103f66:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f70:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f73:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f77:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f7a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f81:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f85:	c7 04 24 50 3f 10 f0 	movl   $0xf0103f50,(%esp)
f0103f8c:	e8 a1 19 00 00       	call   f0105932 <vprintfmt>
	return cnt;
}
f0103f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f94:	c9                   	leave  
f0103f95:	c3                   	ret    

f0103f96 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f96:	55                   	push   %ebp
f0103f97:	89 e5                	mov    %esp,%ebp
f0103f99:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f9c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f9f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fa3:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fa6:	89 04 24             	mov    %eax,(%esp)
f0103fa9:	e8 b5 ff ff ff       	call   f0103f63 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103fae:	c9                   	leave  
f0103faf:	c3                   	ret    

f0103fb0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103fb0:	55                   	push   %ebp
f0103fb1:	89 e5                	mov    %esp,%ebp
f0103fb3:	57                   	push   %edi
f0103fb4:	56                   	push   %esi
f0103fb5:	53                   	push   %ebx
f0103fb6:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	uint8_t cpuid;
	cpuid = thiscpu -> cpu_id;
f0103fb9:	e8 7e 27 00 00       	call   f010673c <cpunum>
f0103fbe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc1:	0f b6 98 20 70 1d f0 	movzbl -0xfe28fe0(%eax),%ebx
	thiscpu -> cpu_ts = thiscpu -> cpu_ts;
f0103fc8:	e8 6f 27 00 00       	call   f010673c <cpunum>
f0103fcd:	89 c7                	mov    %eax,%edi
f0103fcf:	e8 68 27 00 00       	call   f010673c <cpunum>
f0103fd4:	6b ff 74             	imul   $0x74,%edi,%edi
f0103fd7:	6b f0 74             	imul   $0x74,%eax,%esi
f0103fda:	81 c7 2c 70 1d f0    	add    $0xf01d702c,%edi
f0103fe0:	81 c6 2c 70 1d f0    	add    $0xf01d702c,%esi
f0103fe6:	b9 1a 00 00 00       	mov    $0x1a,%ecx
f0103feb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	thiscpu -> cpu_ts.ts_esp0 = KSTACKTOP - cpuid * (KSTKSIZE + KSTKGAP);
f0103fed:	e8 4a 27 00 00       	call   f010673c <cpunum>
f0103ff2:	0f b6 f3             	movzbl %bl,%esi
f0103ff5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff8:	89 f2                	mov    %esi,%edx
f0103ffa:	f7 da                	neg    %edx
f0103ffc:	c1 e2 10             	shl    $0x10,%edx
f0103fff:	81 ea 00 00 40 10    	sub    $0x10400000,%edx
f0104005:	89 90 30 70 1d f0    	mov    %edx,-0xfe28fd0(%eax)
	thiscpu -> cpu_ts.ts_ss0 =  GD_KD;
f010400b:	e8 2c 27 00 00       	call   f010673c <cpunum>
f0104010:	6b c0 74             	imul   $0x74,%eax,%eax
f0104013:	66 c7 80 34 70 1d f0 	movw   $0x10,-0xfe28fcc(%eax)
f010401a:	10 00 

	cprintf("thiscpu id[%d]; stack[%p]; ss[0x%x]\n", 
		cpuid, thiscpu->cpu_ts.ts_esp0, thiscpu->cpu_ts.ts_ss0);
f010401c:	e8 1b 27 00 00       	call   f010673c <cpunum>
f0104021:	6b c0 74             	imul   $0x74,%eax,%eax
	cpuid = thiscpu -> cpu_id;
	thiscpu -> cpu_ts = thiscpu -> cpu_ts;
	thiscpu -> cpu_ts.ts_esp0 = KSTACKTOP - cpuid * (KSTKSIZE + KSTKGAP);
	thiscpu -> cpu_ts.ts_ss0 =  GD_KD;

	cprintf("thiscpu id[%d]; stack[%p]; ss[0x%x]\n", 
f0104024:	0f b7 b8 34 70 1d f0 	movzwl -0xfe28fcc(%eax),%edi
		cpuid, thiscpu->cpu_ts.ts_esp0, thiscpu->cpu_ts.ts_ss0);
f010402b:	e8 0c 27 00 00       	call   f010673c <cpunum>
	cpuid = thiscpu -> cpu_id;
	thiscpu -> cpu_ts = thiscpu -> cpu_ts;
	thiscpu -> cpu_ts.ts_esp0 = KSTACKTOP - cpuid * (KSTKSIZE + KSTKGAP);
	thiscpu -> cpu_ts.ts_ss0 =  GD_KD;

	cprintf("thiscpu id[%d]; stack[%p]; ss[0x%x]\n", 
f0104030:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104034:	6b c0 74             	imul   $0x74,%eax,%eax
f0104037:	8b 80 30 70 1d f0    	mov    -0xfe28fd0(%eax),%eax
f010403d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104041:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104045:	c7 04 24 b0 82 10 f0 	movl   $0xf01082b0,(%esp)
f010404c:	e8 45 ff ff ff       	call   f0103f96 <cprintf>
		cpuid, thiscpu->cpu_ts.ts_esp0, thiscpu->cpu_ts.ts_ss0);

	// @yuhangj
	// Initialize the TSS slot of the gdt
	gdt[(GD_TSS0 >> 3) + cpuid] = SEG16(STS_T32A, (uint32_t)(&thiscpu -> cpu_ts),
f0104051:	83 c6 05             	add    $0x5,%esi
f0104054:	e8 e3 26 00 00       	call   f010673c <cpunum>
f0104059:	89 c7                	mov    %eax,%edi
f010405b:	e8 dc 26 00 00       	call   f010673c <cpunum>
f0104060:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104063:	e8 d4 26 00 00       	call   f010673c <cpunum>
f0104068:	66 c7 04 f5 20 23 12 	movw   $0x68,-0xfeddce0(,%esi,8)
f010406f:	f0 68 00 
f0104072:	6b ff 74             	imul   $0x74,%edi,%edi
f0104075:	81 c7 2c 70 1d f0    	add    $0xf01d702c,%edi
f010407b:	66 89 3c f5 22 23 12 	mov    %di,-0xfeddcde(,%esi,8)
f0104082:	f0 
f0104083:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0104087:	81 c2 2c 70 1d f0    	add    $0xf01d702c,%edx
f010408d:	c1 ea 10             	shr    $0x10,%edx
f0104090:	88 14 f5 24 23 12 f0 	mov    %dl,-0xfeddcdc(,%esi,8)
f0104097:	c6 04 f5 26 23 12 f0 	movb   $0x40,-0xfeddcda(,%esi,8)
f010409e:	40 
f010409f:	6b c0 74             	imul   $0x74,%eax,%eax
f01040a2:	05 2c 70 1d f0       	add    $0xf01d702c,%eax
f01040a7:	c1 e8 18             	shr    $0x18,%eax
f01040aa:	88 04 f5 27 23 12 f0 	mov    %al,-0xfeddcd9(,%esi,8)
		sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3) + cpuid].sd_s = 0;
f01040b1:	c6 04 f5 25 23 12 f0 	movb   $0x89,-0xfeddcdb(,%esi,8)
f01040b8:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpuid << 3));
f01040b9:	0f b6 db             	movzbl %bl,%ebx
f01040bc:	8d 1c dd 28 00 00 00 	lea    0x28(,%ebx,8),%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01040c3:	0f 00 db             	ltr    %bx
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01040c6:	b8 8c 23 12 f0       	mov    $0xf012238c,%eax
f01040cb:	0f 01 18             	lidtl  (%eax)
	// // bottom three bits are special; we leave them 0)
	// ltr(GD_TSS0);

	// // Load the IDT
	// lidt(&idt_pd);
}
f01040ce:	83 c4 2c             	add    $0x2c,%esp
f01040d1:	5b                   	pop    %ebx
f01040d2:	5e                   	pop    %esi
f01040d3:	5f                   	pop    %edi
f01040d4:	5d                   	pop    %ebp
f01040d5:	c3                   	ret    

f01040d6 <trap_init>:
}


void
trap_init(void)
{
f01040d6:	55                   	push   %ebp
f01040d7:	89 e5                	mov    %esp,%ebp
f01040d9:	56                   	push   %esi
f01040da:	53                   	push   %ebx
	extern void IRQ_spurious();
	extern void IRQ_ide();
	extern void IRQ_error();

	/* SETGATE(Gatedesc, istrap[1/0], sel, off, dpl) -- inc/mmu.h*/
	SETGATE(idt[T_DIVIDE] ,0, GD_KT, Divide_error, 0);
f01040db:	b8 54 4b 10 f0       	mov    $0xf0104b54,%eax
f01040e0:	66 a3 60 62 1d f0    	mov    %ax,0xf01d6260
f01040e6:	66 c7 05 62 62 1d f0 	movw   $0x8,0xf01d6262
f01040ed:	08 00 
f01040ef:	c6 05 64 62 1d f0 00 	movb   $0x0,0xf01d6264
f01040f6:	c6 05 65 62 1d f0 8e 	movb   $0x8e,0xf01d6265
f01040fd:	c1 e8 10             	shr    $0x10,%eax
f0104100:	66 a3 66 62 1d f0    	mov    %ax,0xf01d6266
	SETGATE(idt[T_DEBUG] ,0, GD_KT, Debug, 0);
f0104106:	b8 5e 4b 10 f0       	mov    $0xf0104b5e,%eax
f010410b:	66 a3 68 62 1d f0    	mov    %ax,0xf01d6268
f0104111:	66 c7 05 6a 62 1d f0 	movw   $0x8,0xf01d626a
f0104118:	08 00 
f010411a:	c6 05 6c 62 1d f0 00 	movb   $0x0,0xf01d626c
f0104121:	c6 05 6d 62 1d f0 8e 	movb   $0x8e,0xf01d626d
f0104128:	c1 e8 10             	shr    $0x10,%eax
f010412b:	66 a3 6e 62 1d f0    	mov    %ax,0xf01d626e
	SETGATE(idt[T_NMI] ,0, GD_KT, Non_Maskable_Interrupt, 0);
f0104131:	b8 68 4b 10 f0       	mov    $0xf0104b68,%eax
f0104136:	66 a3 70 62 1d f0    	mov    %ax,0xf01d6270
f010413c:	66 c7 05 72 62 1d f0 	movw   $0x8,0xf01d6272
f0104143:	08 00 
f0104145:	c6 05 74 62 1d f0 00 	movb   $0x0,0xf01d6274
f010414c:	c6 05 75 62 1d f0 8e 	movb   $0x8e,0xf01d6275
f0104153:	c1 e8 10             	shr    $0x10,%eax
f0104156:	66 a3 76 62 1d f0    	mov    %ax,0xf01d6276
	SETGATE(idt[T_BRKPT] ,0, GD_KT, Breakpoint, 3);
f010415c:	b8 72 4b 10 f0       	mov    $0xf0104b72,%eax
f0104161:	66 a3 78 62 1d f0    	mov    %ax,0xf01d6278
f0104167:	66 c7 05 7a 62 1d f0 	movw   $0x8,0xf01d627a
f010416e:	08 00 
f0104170:	c6 05 7c 62 1d f0 00 	movb   $0x0,0xf01d627c
f0104177:	c6 05 7d 62 1d f0 ee 	movb   $0xee,0xf01d627d
f010417e:	c1 e8 10             	shr    $0x10,%eax
f0104181:	66 a3 7e 62 1d f0    	mov    %ax,0xf01d627e
	SETGATE(idt[T_OFLOW] ,0, GD_KT, Overflow, 0);
f0104187:	b8 7c 4b 10 f0       	mov    $0xf0104b7c,%eax
f010418c:	66 a3 80 62 1d f0    	mov    %ax,0xf01d6280
f0104192:	66 c7 05 82 62 1d f0 	movw   $0x8,0xf01d6282
f0104199:	08 00 
f010419b:	c6 05 84 62 1d f0 00 	movb   $0x0,0xf01d6284
f01041a2:	c6 05 85 62 1d f0 8e 	movb   $0x8e,0xf01d6285
f01041a9:	c1 e8 10             	shr    $0x10,%eax
f01041ac:	66 a3 86 62 1d f0    	mov    %ax,0xf01d6286
	SETGATE(idt[T_BOUND] ,0, GD_KT, BOUND_Range_Exceeded, 0);
f01041b2:	b8 82 4b 10 f0       	mov    $0xf0104b82,%eax
f01041b7:	66 a3 88 62 1d f0    	mov    %ax,0xf01d6288
f01041bd:	66 c7 05 8a 62 1d f0 	movw   $0x8,0xf01d628a
f01041c4:	08 00 
f01041c6:	c6 05 8c 62 1d f0 00 	movb   $0x0,0xf01d628c
f01041cd:	c6 05 8d 62 1d f0 8e 	movb   $0x8e,0xf01d628d
f01041d4:	c1 e8 10             	shr    $0x10,%eax
f01041d7:	66 a3 8e 62 1d f0    	mov    %ax,0xf01d628e
	SETGATE(idt[T_ILLOP] ,0, GD_KT, Invalid_Opcode, 0);
f01041dd:	b8 88 4b 10 f0       	mov    $0xf0104b88,%eax
f01041e2:	66 a3 90 62 1d f0    	mov    %ax,0xf01d6290
f01041e8:	66 c7 05 92 62 1d f0 	movw   $0x8,0xf01d6292
f01041ef:	08 00 
f01041f1:	c6 05 94 62 1d f0 00 	movb   $0x0,0xf01d6294
f01041f8:	c6 05 95 62 1d f0 8e 	movb   $0x8e,0xf01d6295
f01041ff:	c1 e8 10             	shr    $0x10,%eax
f0104202:	66 a3 96 62 1d f0    	mov    %ax,0xf01d6296
	SETGATE(idt[T_DEVICE] ,0, GD_KT, Device_Not_Available, 0);
f0104208:	b8 8e 4b 10 f0       	mov    $0xf0104b8e,%eax
f010420d:	66 a3 98 62 1d f0    	mov    %ax,0xf01d6298
f0104213:	66 c7 05 9a 62 1d f0 	movw   $0x8,0xf01d629a
f010421a:	08 00 
f010421c:	c6 05 9c 62 1d f0 00 	movb   $0x0,0xf01d629c
f0104223:	c6 05 9d 62 1d f0 8e 	movb   $0x8e,0xf01d629d
f010422a:	c1 e8 10             	shr    $0x10,%eax
f010422d:	66 a3 9e 62 1d f0    	mov    %ax,0xf01d629e
	SETGATE(idt[T_DBLFLT] ,0, GD_KT, Double_Fault, 0);
f0104233:	b8 94 4b 10 f0       	mov    $0xf0104b94,%eax
f0104238:	66 a3 a0 62 1d f0    	mov    %ax,0xf01d62a0
f010423e:	66 c7 05 a2 62 1d f0 	movw   $0x8,0xf01d62a2
f0104245:	08 00 
f0104247:	c6 05 a4 62 1d f0 00 	movb   $0x0,0xf01d62a4
f010424e:	c6 05 a5 62 1d f0 8e 	movb   $0x8e,0xf01d62a5
f0104255:	c1 e8 10             	shr    $0x10,%eax
f0104258:	66 a3 a6 62 1d f0    	mov    %ax,0xf01d62a6
	SETGATE(idt[T_TSS] ,0, GD_KT, Invalid_TSS, 0);
f010425e:	b8 98 4b 10 f0       	mov    $0xf0104b98,%eax
f0104263:	66 a3 b0 62 1d f0    	mov    %ax,0xf01d62b0
f0104269:	66 c7 05 b2 62 1d f0 	movw   $0x8,0xf01d62b2
f0104270:	08 00 
f0104272:	c6 05 b4 62 1d f0 00 	movb   $0x0,0xf01d62b4
f0104279:	c6 05 b5 62 1d f0 8e 	movb   $0x8e,0xf01d62b5
f0104280:	c1 e8 10             	shr    $0x10,%eax
f0104283:	66 a3 b6 62 1d f0    	mov    %ax,0xf01d62b6
	SETGATE(idt[T_SEGNP] ,0, GD_KT, Segment_Not_Present, 0);
f0104289:	b8 9c 4b 10 f0       	mov    $0xf0104b9c,%eax
f010428e:	66 a3 b8 62 1d f0    	mov    %ax,0xf01d62b8
f0104294:	66 c7 05 ba 62 1d f0 	movw   $0x8,0xf01d62ba
f010429b:	08 00 
f010429d:	c6 05 bc 62 1d f0 00 	movb   $0x0,0xf01d62bc
f01042a4:	c6 05 bd 62 1d f0 8e 	movb   $0x8e,0xf01d62bd
f01042ab:	c1 e8 10             	shr    $0x10,%eax
f01042ae:	66 a3 be 62 1d f0    	mov    %ax,0xf01d62be
	SETGATE(idt[T_STACK] ,0, GD_KT, Stack_Fault, 0);
f01042b4:	b8 a0 4b 10 f0       	mov    $0xf0104ba0,%eax
f01042b9:	66 a3 c0 62 1d f0    	mov    %ax,0xf01d62c0
f01042bf:	66 c7 05 c2 62 1d f0 	movw   $0x8,0xf01d62c2
f01042c6:	08 00 
f01042c8:	c6 05 c4 62 1d f0 00 	movb   $0x0,0xf01d62c4
f01042cf:	c6 05 c5 62 1d f0 8e 	movb   $0x8e,0xf01d62c5
f01042d6:	c1 e8 10             	shr    $0x10,%eax
f01042d9:	66 a3 c6 62 1d f0    	mov    %ax,0xf01d62c6
	SETGATE(idt[T_GPFLT] ,0, GD_KT, General_Protection, 0);
f01042df:	b8 a4 4b 10 f0       	mov    $0xf0104ba4,%eax
f01042e4:	66 a3 c8 62 1d f0    	mov    %ax,0xf01d62c8
f01042ea:	66 c7 05 ca 62 1d f0 	movw   $0x8,0xf01d62ca
f01042f1:	08 00 
f01042f3:	c6 05 cc 62 1d f0 00 	movb   $0x0,0xf01d62cc
f01042fa:	c6 05 cd 62 1d f0 8e 	movb   $0x8e,0xf01d62cd
f0104301:	c1 e8 10             	shr    $0x10,%eax
f0104304:	66 a3 ce 62 1d f0    	mov    %ax,0xf01d62ce
	SETGATE(idt[T_PGFLT] ,0, GD_KT, Page_Fault, 0);
f010430a:	b8 a8 4b 10 f0       	mov    $0xf0104ba8,%eax
f010430f:	66 a3 d0 62 1d f0    	mov    %ax,0xf01d62d0
f0104315:	66 c7 05 d2 62 1d f0 	movw   $0x8,0xf01d62d2
f010431c:	08 00 
f010431e:	c6 05 d4 62 1d f0 00 	movb   $0x0,0xf01d62d4
f0104325:	c6 05 d5 62 1d f0 8e 	movb   $0x8e,0xf01d62d5
f010432c:	c1 e8 10             	shr    $0x10,%eax
f010432f:	66 a3 d6 62 1d f0    	mov    %ax,0xf01d62d6
	SETGATE(idt[T_FPERR] ,0, GD_KT, x87_FPU_Floating_Point_Error, 0);
f0104335:	b8 ac 4b 10 f0       	mov    $0xf0104bac,%eax
f010433a:	66 a3 e0 62 1d f0    	mov    %ax,0xf01d62e0
f0104340:	66 c7 05 e2 62 1d f0 	movw   $0x8,0xf01d62e2
f0104347:	08 00 
f0104349:	c6 05 e4 62 1d f0 00 	movb   $0x0,0xf01d62e4
f0104350:	c6 05 e5 62 1d f0 8e 	movb   $0x8e,0xf01d62e5
f0104357:	c1 e8 10             	shr    $0x10,%eax
f010435a:	66 a3 e6 62 1d f0    	mov    %ax,0xf01d62e6
	SETGATE(idt[T_ALIGN] ,0, GD_KT, Alignment_Check, 0);
f0104360:	b8 b2 4b 10 f0       	mov    $0xf0104bb2,%eax
f0104365:	66 a3 e8 62 1d f0    	mov    %ax,0xf01d62e8
f010436b:	66 c7 05 ea 62 1d f0 	movw   $0x8,0xf01d62ea
f0104372:	08 00 
f0104374:	c6 05 ec 62 1d f0 00 	movb   $0x0,0xf01d62ec
f010437b:	c6 05 ed 62 1d f0 8e 	movb   $0x8e,0xf01d62ed
f0104382:	c1 e8 10             	shr    $0x10,%eax
f0104385:	66 a3 ee 62 1d f0    	mov    %ax,0xf01d62ee
	SETGATE(idt[T_MCHK] ,0, GD_KT, Machine_Check, 0);
f010438b:	b8 b8 4b 10 f0       	mov    $0xf0104bb8,%eax
f0104390:	66 a3 f0 62 1d f0    	mov    %ax,0xf01d62f0
f0104396:	66 c7 05 f2 62 1d f0 	movw   $0x8,0xf01d62f2
f010439d:	08 00 
f010439f:	c6 05 f4 62 1d f0 00 	movb   $0x0,0xf01d62f4
f01043a6:	c6 05 f5 62 1d f0 8e 	movb   $0x8e,0xf01d62f5
f01043ad:	c1 e8 10             	shr    $0x10,%eax
f01043b0:	66 a3 f6 62 1d f0    	mov    %ax,0xf01d62f6
	SETGATE(idt[T_SIMDERR] ,0, GD_KT, SIMD_Floating_Point_Exception, 0);
f01043b6:	b8 be 4b 10 f0       	mov    $0xf0104bbe,%eax
f01043bb:	66 a3 f8 62 1d f0    	mov    %ax,0xf01d62f8
f01043c1:	66 c7 05 fa 62 1d f0 	movw   $0x8,0xf01d62fa
f01043c8:	08 00 
f01043ca:	c6 05 fc 62 1d f0 00 	movb   $0x0,0xf01d62fc
f01043d1:	c6 05 fd 62 1d f0 8e 	movb   $0x8e,0xf01d62fd
f01043d8:	c1 e8 10             	shr    $0x10,%eax
f01043db:	66 a3 fe 62 1d f0    	mov    %ax,0xf01d62fe

	SETGATE(idt[T_SYSCALL], 0 , GD_KT, System_call, 3);
f01043e1:	b8 c4 4b 10 f0       	mov    $0xf0104bc4,%eax
f01043e6:	66 a3 e0 63 1d f0    	mov    %ax,0xf01d63e0
f01043ec:	66 c7 05 e2 63 1d f0 	movw   $0x8,0xf01d63e2
f01043f3:	08 00 
f01043f5:	c6 05 e4 63 1d f0 00 	movb   $0x0,0xf01d63e4
f01043fc:	c6 05 e5 63 1d f0 ee 	movb   $0xee,0xf01d63e5
f0104403:	c1 e8 10             	shr    $0x10,%eax
f0104406:	66 a3 e6 63 1d f0    	mov    %ax,0xf01d63e6

	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, IRQ_timer, 0);
f010440c:	b8 ca 4b 10 f0       	mov    $0xf0104bca,%eax
f0104411:	66 a3 60 63 1d f0    	mov    %ax,0xf01d6360
f0104417:	66 c7 05 62 63 1d f0 	movw   $0x8,0xf01d6362
f010441e:	08 00 
f0104420:	c6 05 64 63 1d f0 00 	movb   $0x0,0xf01d6364
f0104427:	c6 05 65 63 1d f0 8e 	movb   $0x8e,0xf01d6365
f010442e:	c1 e8 10             	shr    $0x10,%eax
f0104431:	66 a3 66 63 1d f0    	mov    %ax,0xf01d6366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, IRQ_kbd, 0);
f0104437:	b8 d0 4b 10 f0       	mov    $0xf0104bd0,%eax
f010443c:	66 a3 68 63 1d f0    	mov    %ax,0xf01d6368
f0104442:	66 c7 05 6a 63 1d f0 	movw   $0x8,0xf01d636a
f0104449:	08 00 
f010444b:	c6 05 6c 63 1d f0 00 	movb   $0x0,0xf01d636c
f0104452:	c6 05 6d 63 1d f0 8e 	movb   $0x8e,0xf01d636d
f0104459:	c1 e8 10             	shr    $0x10,%eax
f010445c:	66 a3 6e 63 1d f0    	mov    %ax,0xf01d636e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, IRQ_serial, 0);
f0104462:	b8 d6 4b 10 f0       	mov    $0xf0104bd6,%eax
f0104467:	66 a3 80 63 1d f0    	mov    %ax,0xf01d6380
f010446d:	66 c7 05 82 63 1d f0 	movw   $0x8,0xf01d6382
f0104474:	08 00 
f0104476:	c6 05 84 63 1d f0 00 	movb   $0x0,0xf01d6384
f010447d:	c6 05 85 63 1d f0 8e 	movb   $0x8e,0xf01d6385
f0104484:	c1 e8 10             	shr    $0x10,%eax
f0104487:	66 a3 86 63 1d f0    	mov    %ax,0xf01d6386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, IRQ_spurious, 0);
f010448d:	b8 dc 4b 10 f0       	mov    $0xf0104bdc,%eax
f0104492:	66 a3 98 63 1d f0    	mov    %ax,0xf01d6398
f0104498:	66 c7 05 9a 63 1d f0 	movw   $0x8,0xf01d639a
f010449f:	08 00 
f01044a1:	c6 05 9c 63 1d f0 00 	movb   $0x0,0xf01d639c
f01044a8:	c6 05 9d 63 1d f0 8e 	movb   $0x8e,0xf01d639d
f01044af:	c1 e8 10             	shr    $0x10,%eax
f01044b2:	66 a3 9e 63 1d f0    	mov    %ax,0xf01d639e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, IRQ_ide, 0);
f01044b8:	b8 e2 4b 10 f0       	mov    $0xf0104be2,%eax
f01044bd:	66 a3 d0 63 1d f0    	mov    %ax,0xf01d63d0
f01044c3:	66 c7 05 d2 63 1d f0 	movw   $0x8,0xf01d63d2
f01044ca:	08 00 
f01044cc:	c6 05 d4 63 1d f0 00 	movb   $0x0,0xf01d63d4
f01044d3:	c6 05 d5 63 1d f0 8e 	movb   $0x8e,0xf01d63d5
f01044da:	c1 e8 10             	shr    $0x10,%eax
f01044dd:	66 a3 d6 63 1d f0    	mov    %ax,0xf01d63d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, IRQ_error, 0);
f01044e3:	b8 e8 4b 10 f0       	mov    $0xf0104be8,%eax
f01044e8:	66 a3 f8 63 1d f0    	mov    %ax,0xf01d63f8
f01044ee:	66 c7 05 fa 63 1d f0 	movw   $0x8,0xf01d63fa
f01044f5:	08 00 
f01044f7:	c6 05 fc 63 1d f0 00 	movb   $0x0,0xf01d63fc
f01044fe:	c6 05 fd 63 1d f0 8e 	movb   $0x8e,0xf01d63fd
f0104505:	c1 e8 10             	shr    $0x10,%eax
f0104508:	66 a3 fe 63 1d f0    	mov    %ax,0xf01d63fe
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
f010450e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104513:	0f a2                	cpuid  
f0104515:	89 d6                	mov    %edx,%esi
	// Per-CPU setup 
	if (get_cpu_features() & CPUID_FLAG_SEP)
f0104517:	f7 c6 00 08 00 00    	test   $0x800,%esi
f010451d:	74 23                	je     f0104542 <trap_init+0x46c>
	{
		wrmsr(SYSENTER_CS, GD_KT, 0);
f010451f:	ba 00 00 00 00       	mov    $0x0,%edx
f0104524:	b8 08 00 00 00       	mov    $0x8,%eax
f0104529:	b9 74 01 00 00       	mov    $0x174,%ecx
f010452e:	0f 30                	wrmsr  
		wrmsr(SYSENTER_ESP, KSTACKTOP, 0);
f0104530:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f0104535:	b1 75                	mov    $0x75,%cl
f0104537:	0f 30                	wrmsr  
		wrmsr(SYSENTER_EIP, sysenter_handler, 0);
f0104539:	b8 ee 4b 10 f0       	mov    $0xf0104bee,%eax
f010453e:	b1 76                	mov    $0x76,%cl
f0104540:	0f 30                	wrmsr  
	}


	// Per-CPU setup 
	trap_init_percpu();
f0104542:	e8 69 fa ff ff       	call   f0103fb0 <trap_init_percpu>
}
f0104547:	5b                   	pop    %ebx
f0104548:	5e                   	pop    %esi
f0104549:	5d                   	pop    %ebp
f010454a:	c3                   	ret    

f010454b <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010454b:	55                   	push   %ebp
f010454c:	89 e5                	mov    %esp,%ebp
f010454e:	53                   	push   %ebx
f010454f:	83 ec 14             	sub    $0x14,%esp
f0104552:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104555:	8b 03                	mov    (%ebx),%eax
f0104557:	89 44 24 04          	mov    %eax,0x4(%esp)
f010455b:	c7 04 24 fb 82 10 f0 	movl   $0xf01082fb,(%esp)
f0104562:	e8 2f fa ff ff       	call   f0103f96 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104567:	8b 43 04             	mov    0x4(%ebx),%eax
f010456a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010456e:	c7 04 24 0a 83 10 f0 	movl   $0xf010830a,(%esp)
f0104575:	e8 1c fa ff ff       	call   f0103f96 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010457a:	8b 43 08             	mov    0x8(%ebx),%eax
f010457d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104581:	c7 04 24 19 83 10 f0 	movl   $0xf0108319,(%esp)
f0104588:	e8 09 fa ff ff       	call   f0103f96 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010458d:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104590:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104594:	c7 04 24 28 83 10 f0 	movl   $0xf0108328,(%esp)
f010459b:	e8 f6 f9 ff ff       	call   f0103f96 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01045a0:	8b 43 10             	mov    0x10(%ebx),%eax
f01045a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045a7:	c7 04 24 37 83 10 f0 	movl   $0xf0108337,(%esp)
f01045ae:	e8 e3 f9 ff ff       	call   f0103f96 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01045b3:	8b 43 14             	mov    0x14(%ebx),%eax
f01045b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ba:	c7 04 24 46 83 10 f0 	movl   $0xf0108346,(%esp)
f01045c1:	e8 d0 f9 ff ff       	call   f0103f96 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01045c6:	8b 43 18             	mov    0x18(%ebx),%eax
f01045c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045cd:	c7 04 24 55 83 10 f0 	movl   $0xf0108355,(%esp)
f01045d4:	e8 bd f9 ff ff       	call   f0103f96 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01045d9:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01045dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045e0:	c7 04 24 64 83 10 f0 	movl   $0xf0108364,(%esp)
f01045e7:	e8 aa f9 ff ff       	call   f0103f96 <cprintf>
}
f01045ec:	83 c4 14             	add    $0x14,%esp
f01045ef:	5b                   	pop    %ebx
f01045f0:	5d                   	pop    %ebp
f01045f1:	c3                   	ret    

f01045f2 <print_trapframe>:
	// lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01045f2:	55                   	push   %ebp
f01045f3:	89 e5                	mov    %esp,%ebp
f01045f5:	56                   	push   %esi
f01045f6:	53                   	push   %ebx
f01045f7:	83 ec 10             	sub    $0x10,%esp
f01045fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01045fd:	e8 3a 21 00 00       	call   f010673c <cpunum>
f0104602:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104606:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010460a:	c7 04 24 c8 83 10 f0 	movl   $0xf01083c8,(%esp)
f0104611:	e8 80 f9 ff ff       	call   f0103f96 <cprintf>
	print_regs(&tf->tf_regs);
f0104616:	89 1c 24             	mov    %ebx,(%esp)
f0104619:	e8 2d ff ff ff       	call   f010454b <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010461e:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104622:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104626:	c7 04 24 e6 83 10 f0 	movl   $0xf01083e6,(%esp)
f010462d:	e8 64 f9 ff ff       	call   f0103f96 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104632:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104636:	89 44 24 04          	mov    %eax,0x4(%esp)
f010463a:	c7 04 24 f9 83 10 f0 	movl   $0xf01083f9,(%esp)
f0104641:	e8 50 f9 ff ff       	call   f0103f96 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104646:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104649:	83 f8 13             	cmp    $0x13,%eax
f010464c:	77 09                	ja     f0104657 <print_trapframe+0x65>
		return excnames[trapno];
f010464e:	8b 14 85 60 86 10 f0 	mov    -0xfef79a0(,%eax,4),%edx
f0104655:	eb 1f                	jmp    f0104676 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f0104657:	83 f8 30             	cmp    $0x30,%eax
f010465a:	74 15                	je     f0104671 <print_trapframe+0x7f>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010465c:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f010465f:	83 fa 0f             	cmp    $0xf,%edx
f0104662:	ba 7f 83 10 f0       	mov    $0xf010837f,%edx
f0104667:	b9 92 83 10 f0       	mov    $0xf0108392,%ecx
f010466c:	0f 47 d1             	cmova  %ecx,%edx
f010466f:	eb 05                	jmp    f0104676 <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0104671:	ba 73 83 10 f0       	mov    $0xf0108373,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104676:	89 54 24 08          	mov    %edx,0x8(%esp)
f010467a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010467e:	c7 04 24 0c 84 10 f0 	movl   $0xf010840c,(%esp)
f0104685:	e8 0c f9 ff ff       	call   f0103f96 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010468a:	3b 1d 60 6a 1d f0    	cmp    0xf01d6a60,%ebx
f0104690:	75 19                	jne    f01046ab <print_trapframe+0xb9>
f0104692:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104696:	75 13                	jne    f01046ab <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104698:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010469b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010469f:	c7 04 24 1e 84 10 f0 	movl   $0xf010841e,(%esp)
f01046a6:	e8 eb f8 ff ff       	call   f0103f96 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01046ab:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01046ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046b2:	c7 04 24 2d 84 10 f0 	movl   $0xf010842d,(%esp)
f01046b9:	e8 d8 f8 ff ff       	call   f0103f96 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01046be:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01046c2:	75 51                	jne    f0104715 <print_trapframe+0x123>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01046c4:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01046c7:	89 c2                	mov    %eax,%edx
f01046c9:	83 e2 01             	and    $0x1,%edx
f01046cc:	ba a1 83 10 f0       	mov    $0xf01083a1,%edx
f01046d1:	b9 ac 83 10 f0       	mov    $0xf01083ac,%ecx
f01046d6:	0f 45 ca             	cmovne %edx,%ecx
f01046d9:	89 c2                	mov    %eax,%edx
f01046db:	83 e2 02             	and    $0x2,%edx
f01046de:	ba b8 83 10 f0       	mov    $0xf01083b8,%edx
f01046e3:	be be 83 10 f0       	mov    $0xf01083be,%esi
f01046e8:	0f 44 d6             	cmove  %esi,%edx
f01046eb:	83 e0 04             	and    $0x4,%eax
f01046ee:	b8 c3 83 10 f0       	mov    $0xf01083c3,%eax
f01046f3:	be 16 85 10 f0       	mov    $0xf0108516,%esi
f01046f8:	0f 44 c6             	cmove  %esi,%eax
f01046fb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01046ff:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104703:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104707:	c7 04 24 3b 84 10 f0 	movl   $0xf010843b,(%esp)
f010470e:	e8 83 f8 ff ff       	call   f0103f96 <cprintf>
f0104713:	eb 0c                	jmp    f0104721 <print_trapframe+0x12f>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104715:	c7 04 24 e5 81 10 f0 	movl   $0xf01081e5,(%esp)
f010471c:	e8 75 f8 ff ff       	call   f0103f96 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104721:	8b 43 30             	mov    0x30(%ebx),%eax
f0104724:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104728:	c7 04 24 4a 84 10 f0 	movl   $0xf010844a,(%esp)
f010472f:	e8 62 f8 ff ff       	call   f0103f96 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104734:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104738:	89 44 24 04          	mov    %eax,0x4(%esp)
f010473c:	c7 04 24 59 84 10 f0 	movl   $0xf0108459,(%esp)
f0104743:	e8 4e f8 ff ff       	call   f0103f96 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104748:	8b 43 38             	mov    0x38(%ebx),%eax
f010474b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010474f:	c7 04 24 6c 84 10 f0 	movl   $0xf010846c,(%esp)
f0104756:	e8 3b f8 ff ff       	call   f0103f96 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010475b:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010475f:	74 27                	je     f0104788 <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104761:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104764:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104768:	c7 04 24 7b 84 10 f0 	movl   $0xf010847b,(%esp)
f010476f:	e8 22 f8 ff ff       	call   f0103f96 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104774:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104778:	89 44 24 04          	mov    %eax,0x4(%esp)
f010477c:	c7 04 24 8a 84 10 f0 	movl   $0xf010848a,(%esp)
f0104783:	e8 0e f8 ff ff       	call   f0103f96 <cprintf>
	}
}
f0104788:	83 c4 10             	add    $0x10,%esp
f010478b:	5b                   	pop    %ebx
f010478c:	5e                   	pop    %esi
f010478d:	5d                   	pop    %ebp
f010478e:	c3                   	ret    

f010478f <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010478f:	55                   	push   %ebp
f0104790:	89 e5                	mov    %esp,%ebp
f0104792:	83 ec 48             	sub    $0x48,%esp
f0104795:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104798:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010479b:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010479e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01047a1:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if(!(tf->tf_cs & 3)){
f01047a4:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01047a8:	75 27                	jne    f01047d1 <page_fault_handler+0x42>
		panic("kernel fault va %08x ip %08x\n", fault_va, tf->tf_eip);
f01047aa:	8b 43 30             	mov    0x30(%ebx),%eax
f01047ad:	89 44 24 10          	mov    %eax,0x10(%esp)
f01047b1:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01047b5:	c7 44 24 08 9d 84 10 	movl   $0xf010849d,0x8(%esp)
f01047bc:	f0 
f01047bd:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
f01047c4:	00 
f01047c5:	c7 04 24 bb 84 10 f0 	movl   $0xf01084bb,(%esp)
f01047cc:	e8 6f b8 ff ff       	call   f0100040 <_panic>
	// 	uint32_t utf_eflags;
	// 	/* the trap-time stack to return to */
	// 	uintptr_t utf_esp;
	// } __attribute__((packed));

	if(curenv->env_pgfault_upcall){
f01047d1:	e8 66 1f 00 00       	call   f010673c <cpunum>
f01047d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01047d9:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f01047df:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01047e3:	0f 84 04 01 00 00    	je     f01048ed <page_fault_handler+0x15e>
		uintptr_t esp;
		struct UTrapframe *user_trap;
		esp = tf->tf_esp;
f01047e9:	8b 43 3c             	mov    0x3c(%ebx),%eax
		if(esp < UXSTACKTOP && esp > UXSTACKTOP - PGSIZE)
f01047ec:	8d 90 ff 0f 40 11    	lea    0x11400fff(%eax),%edx
			esp -= 4;
f01047f2:	83 e8 04             	sub    $0x4,%eax
f01047f5:	81 fa fe 0f 00 00    	cmp    $0xffe,%edx
f01047fb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0104800:	89 d7                	mov    %edx,%edi
f0104802:	0f 46 f8             	cmovbe %eax,%edi
		else 
			esp = UXSTACKTOP;
		user_trap = (struct UTrapframe*)(esp - sizeof(struct UTrapframe));
f0104805:	8d 47 cc             	lea    -0x34(%edi),%eax
f0104808:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		user_mem_assert(curenv, (void*)user_trap, sizeof(struct UTrapframe), PTE_U|PTE_W);
f010480b:	e8 2c 1f 00 00       	call   f010673c <cpunum>
f0104810:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0104817:	00 
f0104818:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f010481f:	00 
f0104820:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104823:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104827:	6b c0 74             	imul   $0x74,%eax,%eax
f010482a:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0104830:	89 04 24             	mov    %eax,(%esp)
f0104833:	e8 10 ee ff ff       	call   f0103648 <user_mem_assert>
	
		user_trap->utf_fault_va = fault_va;
f0104838:	89 77 cc             	mov    %esi,-0x34(%edi)
		user_trap->utf_err = tf->tf_err;
f010483b:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010483e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104841:	89 42 04             	mov    %eax,0x4(%edx)
		user_trap->utf_regs = tf->tf_regs;
f0104844:	83 ef 2c             	sub    $0x2c,%edi
f0104847:	89 de                	mov    %ebx,%esi
f0104849:	b8 20 00 00 00       	mov    $0x20,%eax
f010484e:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104854:	74 03                	je     f0104859 <page_fault_handler+0xca>
f0104856:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104857:	b0 1f                	mov    $0x1f,%al
f0104859:	f7 c7 02 00 00 00    	test   $0x2,%edi
f010485f:	74 05                	je     f0104866 <page_fault_handler+0xd7>
f0104861:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104863:	83 e8 02             	sub    $0x2,%eax
f0104866:	89 c1                	mov    %eax,%ecx
f0104868:	c1 e9 02             	shr    $0x2,%ecx
f010486b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010486d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104872:	a8 02                	test   $0x2,%al
f0104874:	74 0b                	je     f0104881 <page_fault_handler+0xf2>
f0104876:	0f b7 16             	movzwl (%esi),%edx
f0104879:	66 89 17             	mov    %dx,(%edi)
f010487c:	ba 02 00 00 00       	mov    $0x2,%edx
f0104881:	a8 01                	test   $0x1,%al
f0104883:	74 07                	je     f010488c <page_fault_handler+0xfd>
f0104885:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f0104889:	88 04 17             	mov    %al,(%edi,%edx,1)
		user_trap->utf_eip = tf->tf_eip;
f010488c:	8b 43 30             	mov    0x30(%ebx),%eax
f010488f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104892:	89 42 28             	mov    %eax,0x28(%edx)
		user_trap->utf_eflags = tf->tf_eflags;
f0104895:	8b 43 38             	mov    0x38(%ebx),%eax
f0104898:	89 42 2c             	mov    %eax,0x2c(%edx)
		user_trap->utf_esp = tf->tf_esp;
f010489b:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010489e:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f01048a1:	e8 96 1e 00 00       	call   f010673c <cpunum>
f01048a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01048a9:	8b 98 28 70 1d f0    	mov    -0xfe28fd8(%eax),%ebx
f01048af:	e8 88 1e 00 00       	call   f010673c <cpunum>
f01048b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01048b7:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f01048bd:	8b 40 64             	mov    0x64(%eax),%eax
f01048c0:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (uint32_t)user_trap;
f01048c3:	e8 74 1e 00 00       	call   f010673c <cpunum>
f01048c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01048cb:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f01048d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048d4:	89 50 3c             	mov    %edx,0x3c(%eax)

		env_run(curenv);
f01048d7:	e8 60 1e 00 00       	call   f010673c <cpunum>
f01048dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01048df:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f01048e5:	89 04 24             	mov    %eax,(%esp)
f01048e8:	e8 6c f4 ff ff       	call   f0103d59 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01048ed:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01048f0:	e8 47 1e 00 00       	call   f010673c <cpunum>

		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01048f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01048f9:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f01048fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104900:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax

		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104906:	8b 40 48             	mov    0x48(%eax),%eax
f0104909:	89 44 24 04          	mov    %eax,0x4(%esp)
f010490d:	c7 04 24 d8 82 10 f0 	movl   $0xf01082d8,(%esp)
f0104914:	e8 7d f6 ff ff       	call   f0103f96 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104919:	89 1c 24             	mov    %ebx,(%esp)
f010491c:	e8 d1 fc ff ff       	call   f01045f2 <print_trapframe>
	env_destroy(curenv);
f0104921:	e8 16 1e 00 00       	call   f010673c <cpunum>
f0104926:	6b c0 74             	imul   $0x74,%eax,%eax
f0104929:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f010492f:	89 04 24             	mov    %eax,(%esp)
f0104932:	e8 81 f3 ff ff       	call   f0103cb8 <env_destroy>
}
f0104937:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010493a:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010493d:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104940:	89 ec                	mov    %ebp,%esp
f0104942:	5d                   	pop    %ebp
f0104943:	c3                   	ret    

f0104944 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104944:	55                   	push   %ebp
f0104945:	89 e5                	mov    %esp,%ebp
f0104947:	57                   	push   %edi
f0104948:	56                   	push   %esi
f0104949:	83 ec 20             	sub    $0x20,%esp
f010494c:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010494f:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104950:	83 3d 80 6e 1d f0 00 	cmpl   $0x0,0xf01d6e80
f0104957:	74 01                	je     f010495a <trap+0x16>
		asm volatile("hlt");
f0104959:	f4                   	hlt    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010495a:	9c                   	pushf  
f010495b:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010495c:	f6 c4 02             	test   $0x2,%ah
f010495f:	74 24                	je     f0104985 <trap+0x41>
f0104961:	c7 44 24 0c c7 84 10 	movl   $0xf01084c7,0xc(%esp)
f0104968:	f0 
f0104969:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f0104970:	f0 
f0104971:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f0104978:	00 
f0104979:	c7 04 24 bb 84 10 f0 	movl   $0xf01084bb,(%esp)
f0104980:	e8 bb b6 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104985:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104989:	83 e0 03             	and    $0x3,%eax
f010498c:	66 83 f8 03          	cmp    $0x3,%ax
f0104990:	0f 85 a7 00 00 00    	jne    f0104a3d <trap+0xf9>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104996:	c7 04 24 a0 23 12 f0 	movl   $0xf01223a0,(%esp)
f010499d:	e8 33 20 00 00       	call   f01069d5 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f01049a2:	e8 95 1d 00 00       	call   f010673c <cpunum>
f01049a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01049aa:	83 b8 28 70 1d f0 00 	cmpl   $0x0,-0xfe28fd8(%eax)
f01049b1:	75 24                	jne    f01049d7 <trap+0x93>
f01049b3:	c7 44 24 0c e0 84 10 	movl   $0xf01084e0,0xc(%esp)
f01049ba:	f0 
f01049bb:	c7 44 24 08 27 7f 10 	movl   $0xf0107f27,0x8(%esp)
f01049c2:	f0 
f01049c3:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
f01049ca:	00 
f01049cb:	c7 04 24 bb 84 10 f0 	movl   $0xf01084bb,(%esp)
f01049d2:	e8 69 b6 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01049d7:	e8 60 1d 00 00       	call   f010673c <cpunum>
f01049dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01049df:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f01049e5:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01049e9:	75 2d                	jne    f0104a18 <trap+0xd4>
			env_free(curenv);
f01049eb:	e8 4c 1d 00 00       	call   f010673c <cpunum>
f01049f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f3:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f01049f9:	89 04 24             	mov    %eax,(%esp)
f01049fc:	e8 e8 f0 ff ff       	call   f0103ae9 <env_free>
			curenv = NULL;
f0104a01:	e8 36 1d 00 00       	call   f010673c <cpunum>
f0104a06:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a09:	c7 80 28 70 1d f0 00 	movl   $0x0,-0xfe28fd8(%eax)
f0104a10:	00 00 00 
			sched_yield();
f0104a13:	e8 fc 01 00 00       	call   f0104c14 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104a18:	e8 1f 1d 00 00       	call   f010673c <cpunum>
f0104a1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a20:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0104a26:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104a2b:	89 c7                	mov    %eax,%edi
f0104a2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104a2f:	e8 08 1d 00 00       	call   f010673c <cpunum>
f0104a34:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a37:	8b b0 28 70 1d f0    	mov    -0xfe28fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104a3d:	89 35 60 6a 1d f0    	mov    %esi,0xf01d6a60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT){
f0104a43:	8b 46 28             	mov    0x28(%esi),%eax
f0104a46:	83 f8 0e             	cmp    $0xe,%eax
f0104a49:	75 0d                	jne    f0104a58 <trap+0x114>
		page_fault_handler(tf);
f0104a4b:	89 34 24             	mov    %esi,(%esp)
f0104a4e:	e8 3c fd ff ff       	call   f010478f <page_fault_handler>
f0104a53:	e9 b9 00 00 00       	jmp    f0104b11 <trap+0x1cd>
		return;
	}else if(tf->tf_trapno == T_BRKPT || tf -> tf_trapno == T_DEBUG ){
f0104a58:	89 c2                	mov    %eax,%edx
f0104a5a:	83 e2 fd             	and    $0xfffffffd,%edx
f0104a5d:	83 fa 01             	cmp    $0x1,%edx
f0104a60:	75 0d                	jne    f0104a6f <trap+0x12b>
		monitor(tf);
f0104a62:	89 34 24             	mov    %esi,(%esp)
f0104a65:	e8 4a bf ff ff       	call   f01009b4 <monitor>
f0104a6a:	e9 a2 00 00 00       	jmp    f0104b11 <trap+0x1cd>
		page_fault_handler(tf);
		return;
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	}else if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
f0104a6f:	83 f8 20             	cmp    $0x20,%eax
f0104a72:	75 0a                	jne    f0104a7e <trap+0x13a>
		lapic_eoi();
f0104a74:	e8 f8 1d 00 00       	call   f0106871 <lapic_eoi>
		sched_yield();
f0104a79:	e8 96 01 00 00       	call   f0104c14 <sched_yield>
		return;
	}
	
	if(tf->tf_trapno == T_SYSCALL){
f0104a7e:	83 f8 30             	cmp    $0x30,%eax
f0104a81:	75 32                	jne    f0104ab5 <trap+0x171>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, 
f0104a83:	8b 46 04             	mov    0x4(%esi),%eax
f0104a86:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104a8a:	8b 06                	mov    (%esi),%eax
f0104a8c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104a90:	8b 46 10             	mov    0x10(%esi),%eax
f0104a93:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a97:	8b 46 18             	mov    0x18(%esi),%eax
f0104a9a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a9e:	8b 46 14             	mov    0x14(%esi),%eax
f0104aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104aa5:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104aa8:	89 04 24             	mov    %eax,(%esp)
f0104aab:	e8 a1 02 00 00       	call   f0104d51 <syscall>
f0104ab0:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104ab3:	eb 5c                	jmp    f0104b11 <trap+0x1cd>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104ab5:	83 f8 27             	cmp    $0x27,%eax
f0104ab8:	75 16                	jne    f0104ad0 <trap+0x18c>
		cprintf("Spurious interrupt on irq 7\n");
f0104aba:	c7 04 24 e7 84 10 f0 	movl   $0xf01084e7,(%esp)
f0104ac1:	e8 d0 f4 ff ff       	call   f0103f96 <cprintf>
		print_trapframe(tf);
f0104ac6:	89 34 24             	mov    %esi,(%esp)
f0104ac9:	e8 24 fb ff ff       	call   f01045f2 <print_trapframe>
f0104ace:	eb 41                	jmp    f0104b11 <trap+0x1cd>
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	// @yuhangj added in line 319 in this file

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104ad0:	89 34 24             	mov    %esi,(%esp)
f0104ad3:	e8 1a fb ff ff       	call   f01045f2 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104ad8:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104add:	75 1c                	jne    f0104afb <trap+0x1b7>
		panic("unhandled trap in kernel");
f0104adf:	c7 44 24 08 04 85 10 	movl   $0xf0108504,0x8(%esp)
f0104ae6:	f0 
f0104ae7:	c7 44 24 04 5b 01 00 	movl   $0x15b,0x4(%esp)
f0104aee:	00 
f0104aef:	c7 04 24 bb 84 10 f0 	movl   $0xf01084bb,(%esp)
f0104af6:	e8 45 b5 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104afb:	e8 3c 1c 00 00       	call   f010673c <cpunum>
f0104b00:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b03:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0104b09:	89 04 24             	mov    %eax,(%esp)
f0104b0c:	e8 a7 f1 ff ff       	call   f0103cb8 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104b11:	e8 26 1c 00 00       	call   f010673c <cpunum>
f0104b16:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b19:	83 b8 28 70 1d f0 00 	cmpl   $0x0,-0xfe28fd8(%eax)
f0104b20:	74 2a                	je     f0104b4c <trap+0x208>
f0104b22:	e8 15 1c 00 00       	call   f010673c <cpunum>
f0104b27:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b2a:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0104b30:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104b34:	75 16                	jne    f0104b4c <trap+0x208>
		env_run(curenv);
f0104b36:	e8 01 1c 00 00       	call   f010673c <cpunum>
f0104b3b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b3e:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0104b44:	89 04 24             	mov    %eax,(%esp)
f0104b47:	e8 0d f2 ff ff       	call   f0103d59 <env_run>
	else
		sched_yield();
f0104b4c:	e8 c3 00 00 00       	call   f0104c14 <sched_yield>
f0104b51:	66 90                	xchg   %ax,%ax
f0104b53:	90                   	nop

f0104b54 <Divide_error>:
# TRAPHANDLER_NOEC(trap29,29)
# TRAPHANDLER_NOEC(trap30,30)
# TRAPHANDLER_NOEC(trap31,31)

# TRAPHANDLER_NOEC(trap_sysc,T_SYSCALL)
TRAPHANDLER_NOEC(Divide_error, T_DIVIDE);
f0104b54:	6a 00                	push   $0x0
f0104b56:	6a 00                	push   $0x0
f0104b58:	e9 a3 00 00 00       	jmp    f0104c00 <_alltraps>
f0104b5d:	90                   	nop

f0104b5e <Debug>:
TRAPHANDLER_NOEC(Debug, T_DEBUG);
f0104b5e:	6a 00                	push   $0x0
f0104b60:	6a 01                	push   $0x1
f0104b62:	e9 99 00 00 00       	jmp    f0104c00 <_alltraps>
f0104b67:	90                   	nop

f0104b68 <Non_Maskable_Interrupt>:
TRAPHANDLER_NOEC(Non_Maskable_Interrupt, T_NMI);
f0104b68:	6a 00                	push   $0x0
f0104b6a:	6a 02                	push   $0x2
f0104b6c:	e9 8f 00 00 00       	jmp    f0104c00 <_alltraps>
f0104b71:	90                   	nop

f0104b72 <Breakpoint>:
TRAPHANDLER_NOEC(Breakpoint, T_BRKPT);
f0104b72:	6a 00                	push   $0x0
f0104b74:	6a 03                	push   $0x3
f0104b76:	e9 85 00 00 00       	jmp    f0104c00 <_alltraps>
f0104b7b:	90                   	nop

f0104b7c <Overflow>:
TRAPHANDLER_NOEC(Overflow, T_OFLOW);
f0104b7c:	6a 00                	push   $0x0
f0104b7e:	6a 04                	push   $0x4
f0104b80:	eb 7e                	jmp    f0104c00 <_alltraps>

f0104b82 <BOUND_Range_Exceeded>:
TRAPHANDLER_NOEC(BOUND_Range_Exceeded, T_BOUND);
f0104b82:	6a 00                	push   $0x0
f0104b84:	6a 05                	push   $0x5
f0104b86:	eb 78                	jmp    f0104c00 <_alltraps>

f0104b88 <Invalid_Opcode>:
TRAPHANDLER_NOEC(Invalid_Opcode, T_ILLOP);
f0104b88:	6a 00                	push   $0x0
f0104b8a:	6a 06                	push   $0x6
f0104b8c:	eb 72                	jmp    f0104c00 <_alltraps>

f0104b8e <Device_Not_Available>:
TRAPHANDLER_NOEC(Device_Not_Available, T_DEVICE);
f0104b8e:	6a 00                	push   $0x0
f0104b90:	6a 07                	push   $0x7
f0104b92:	eb 6c                	jmp    f0104c00 <_alltraps>

f0104b94 <Double_Fault>:
TRAPHANDLER(Double_Fault, T_DBLFLT);
f0104b94:	6a 08                	push   $0x8
f0104b96:	eb 68                	jmp    f0104c00 <_alltraps>

f0104b98 <Invalid_TSS>:
TRAPHANDLER(Invalid_TSS, T_TSS);
f0104b98:	6a 0a                	push   $0xa
f0104b9a:	eb 64                	jmp    f0104c00 <_alltraps>

f0104b9c <Segment_Not_Present>:
TRAPHANDLER(Segment_Not_Present, T_SEGNP);
f0104b9c:	6a 0b                	push   $0xb
f0104b9e:	eb 60                	jmp    f0104c00 <_alltraps>

f0104ba0 <Stack_Fault>:
TRAPHANDLER(Stack_Fault, T_STACK);
f0104ba0:	6a 0c                	push   $0xc
f0104ba2:	eb 5c                	jmp    f0104c00 <_alltraps>

f0104ba4 <General_Protection>:
TRAPHANDLER(General_Protection, T_GPFLT);
f0104ba4:	6a 0d                	push   $0xd
f0104ba6:	eb 58                	jmp    f0104c00 <_alltraps>

f0104ba8 <Page_Fault>:
TRAPHANDLER(Page_Fault, T_PGFLT);
f0104ba8:	6a 0e                	push   $0xe
f0104baa:	eb 54                	jmp    f0104c00 <_alltraps>

f0104bac <x87_FPU_Floating_Point_Error>:
TRAPHANDLER_NOEC(x87_FPU_Floating_Point_Error, T_FPERR);
f0104bac:	6a 00                	push   $0x0
f0104bae:	6a 10                	push   $0x10
f0104bb0:	eb 4e                	jmp    f0104c00 <_alltraps>

f0104bb2 <Alignment_Check>:
TRAPHANDLER_NOEC(Alignment_Check, T_ALIGN);
f0104bb2:	6a 00                	push   $0x0
f0104bb4:	6a 11                	push   $0x11
f0104bb6:	eb 48                	jmp    f0104c00 <_alltraps>

f0104bb8 <Machine_Check>:
TRAPHANDLER_NOEC(Machine_Check, T_MCHK);
f0104bb8:	6a 00                	push   $0x0
f0104bba:	6a 12                	push   $0x12
f0104bbc:	eb 42                	jmp    f0104c00 <_alltraps>

f0104bbe <SIMD_Floating_Point_Exception>:
TRAPHANDLER_NOEC(SIMD_Floating_Point_Exception, T_SIMDERR);
f0104bbe:	6a 00                	push   $0x0
f0104bc0:	6a 13                	push   $0x13
f0104bc2:	eb 3c                	jmp    f0104c00 <_alltraps>

f0104bc4 <System_call>:

TRAPHANDLER_NOEC(System_call,T_SYSCALL);
f0104bc4:	6a 00                	push   $0x0
f0104bc6:	6a 30                	push   $0x30
f0104bc8:	eb 36                	jmp    f0104c00 <_alltraps>

f0104bca <IRQ_timer>:

TRAPHANDLER_NOEC(IRQ_timer,IRQ_OFFSET+IRQ_TIMER);
f0104bca:	6a 00                	push   $0x0
f0104bcc:	6a 20                	push   $0x20
f0104bce:	eb 30                	jmp    f0104c00 <_alltraps>

f0104bd0 <IRQ_kbd>:
TRAPHANDLER_NOEC(IRQ_kbd,IRQ_OFFSET+IRQ_KBD);
f0104bd0:	6a 00                	push   $0x0
f0104bd2:	6a 21                	push   $0x21
f0104bd4:	eb 2a                	jmp    f0104c00 <_alltraps>

f0104bd6 <IRQ_serial>:
TRAPHANDLER_NOEC(IRQ_serial,IRQ_OFFSET+IRQ_SERIAL);
f0104bd6:	6a 00                	push   $0x0
f0104bd8:	6a 24                	push   $0x24
f0104bda:	eb 24                	jmp    f0104c00 <_alltraps>

f0104bdc <IRQ_spurious>:
TRAPHANDLER_NOEC(IRQ_spurious,IRQ_OFFSET+IRQ_SPURIOUS);
f0104bdc:	6a 00                	push   $0x0
f0104bde:	6a 27                	push   $0x27
f0104be0:	eb 1e                	jmp    f0104c00 <_alltraps>

f0104be2 <IRQ_ide>:
TRAPHANDLER_NOEC(IRQ_ide,IRQ_OFFSET+IRQ_IDE);
f0104be2:	6a 00                	push   $0x0
f0104be4:	6a 2e                	push   $0x2e
f0104be6:	eb 18                	jmp    f0104c00 <_alltraps>

f0104be8 <IRQ_error>:
TRAPHANDLER_NOEC(IRQ_error,IRQ_OFFSET+IRQ_ERROR);
f0104be8:	6a 00                	push   $0x0
f0104bea:	6a 33                	push   $0x33
f0104bec:	eb 12                	jmp    f0104c00 <_alltraps>

f0104bee <sysenter_handler>:
	in the correct locations and call sysexit.
*/
.globl sysenter_handler
sysenter_handler:

pushl $0
f0104bee:	6a 00                	push   $0x0
pushl %edi
f0104bf0:	57                   	push   %edi
pushl %ebx
f0104bf1:	53                   	push   %ebx
pushl %ecx
f0104bf2:	51                   	push   %ecx
pushl %edx
f0104bf3:	52                   	push   %edx
pushl %eax
f0104bf4:	50                   	push   %eax
call syscall
f0104bf5:	e8 57 01 00 00       	call   f0104d51 <syscall>

/* 
	Get our stack pointer in ecx
	and our return addr in edx
*/
movl %ebp, %ecx
f0104bfa:	89 e9                	mov    %ebp,%ecx
movl %esi, %edx
f0104bfc:	89 f2                	mov    %esi,%edx

sysexit
f0104bfe:	0f 35                	sysexit 

f0104c00 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
f0104c00:	1e                   	push   %ds
	pushl %es
f0104c01:	06                   	push   %es
	pushal
f0104c02:	60                   	pusha  
	movl $GD_KD, %eax
f0104c03:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104c08:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104c0a:	8e c0                	mov    %eax,%es
	pushl %esp
f0104c0c:	54                   	push   %esp
	call trap
f0104c0d:	e8 32 fd ff ff       	call   f0104944 <trap>
f0104c12:	66 90                	xchg   %ax,%ax

f0104c14 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104c14:	55                   	push   %ebp
f0104c15:	89 e5                	mov    %esp,%ebp
f0104c17:	53                   	push   %ebx
f0104c18:	83 ec 14             	sub    $0x14,%esp

	// LAB 4: Your code here.
	struct Env *e;
	//int cur_id;

	e = curenv;
f0104c1b:	e8 1c 1b 00 00       	call   f010673c <cpunum>
f0104c20:	6b c0 74             	imul   $0x74,%eax,%eax
    if(e == NULL)
f0104c23:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
        e = envs;
f0104c29:	85 c0                	test   %eax,%eax
f0104c2b:	0f 44 05 48 62 1d f0 	cmove  0xf01d6248,%eax

    for(i = 0; i < NENV ; i++, e++){
        if(e >= envs + NENV)
f0104c32:	8b 1d 48 62 1d f0    	mov    0xf01d6248,%ebx
f0104c38:	8d 8b 00 f0 01 00    	lea    0x1f000(%ebx),%ecx
f0104c3e:	ba 00 04 00 00       	mov    $0x400,%edx
            e = envs;
f0104c43:	39 c1                	cmp    %eax,%ecx
f0104c45:	0f 46 c3             	cmovbe %ebx,%eax
        if(e->env_status == ENV_RUNNABLE && e->env_type != ENV_TYPE_IDLE)
f0104c48:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104c4c:	75 0e                	jne    f0104c5c <sched_yield+0x48>
f0104c4e:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f0104c52:	74 08                	je     f0104c5c <sched_yield+0x48>
            env_run(e);
f0104c54:	89 04 24             	mov    %eax,(%esp)
f0104c57:	e8 fd f0 ff ff       	call   f0103d59 <env_run>

	e = curenv;
    if(e == NULL)
        e = envs;

    for(i = 0; i < NENV ; i++, e++){
f0104c5c:	83 c0 7c             	add    $0x7c,%eax
f0104c5f:	83 ea 01             	sub    $0x1,%edx
f0104c62:	75 df                	jne    f0104c43 <sched_yield+0x2f>
#include <kern/monitor.h>


// Choose a user environment to run and run it.
void
sched_yield(void)
f0104c64:	8d 43 50             	lea    0x50(%ebx),%eax
f0104c67:	ba 00 00 00 00       	mov    $0x0,%edx
	
	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f0104c6c:	83 38 01             	cmpl   $0x1,(%eax)
f0104c6f:	74 0b                	je     f0104c7c <sched_yield+0x68>
		    (envs[i].env_status == ENV_RUNNABLE ||
f0104c71:	8b 48 04             	mov    0x4(%eax),%ecx
f0104c74:	83 e9 02             	sub    $0x2,%ecx
	
	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f0104c77:	83 f9 01             	cmp    $0x1,%ecx
f0104c7a:	76 10                	jbe    f0104c8c <sched_yield+0x78>
    }
	
	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104c7c:	83 c2 01             	add    $0x1,%edx
f0104c7f:	83 c0 7c             	add    $0x7c,%eax
f0104c82:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0104c88:	75 e2                	jne    f0104c6c <sched_yield+0x58>
f0104c8a:	eb 08                	jmp    f0104c94 <sched_yield+0x80>
		if (envs[i].env_type != ENV_TYPE_IDLE &&
		    (envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0104c8c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0104c92:	75 1a                	jne    f0104cae <sched_yield+0x9a>
		cprintf("No more runnable environments!\n");
f0104c94:	c7 04 24 b0 86 10 f0 	movl   $0xf01086b0,(%esp)
f0104c9b:	e8 f6 f2 ff ff       	call   f0103f96 <cprintf>
		while (1)
			monitor(NULL);
f0104ca0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104ca7:	e8 08 bd ff ff       	call   f01009b4 <monitor>
f0104cac:	eb f2                	jmp    f0104ca0 <sched_yield+0x8c>
	}

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
f0104cae:	e8 89 1a 00 00       	call   f010673c <cpunum>
f0104cb3:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104cb6:	01 c3                	add    %eax,%ebx
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
f0104cb8:	8b 43 54             	mov    0x54(%ebx),%eax
f0104cbb:	83 e8 02             	sub    $0x2,%eax
f0104cbe:	83 f8 01             	cmp    $0x1,%eax
f0104cc1:	76 25                	jbe    f0104ce8 <sched_yield+0xd4>
		panic("CPU %d: No idle environment!", cpunum());
f0104cc3:	e8 74 1a 00 00       	call   f010673c <cpunum>
f0104cc8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104ccc:	c7 44 24 08 d0 86 10 	movl   $0xf01086d0,0x8(%esp)
f0104cd3:	f0 
f0104cd4:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
f0104cdb:	00 
f0104cdc:	c7 04 24 ed 86 10 f0 	movl   $0xf01086ed,(%esp)
f0104ce3:	e8 58 b3 ff ff       	call   f0100040 <_panic>
	env_run(idle);
f0104ce8:	89 1c 24             	mov    %ebx,(%esp)
f0104ceb:	e8 69 f0 ff ff       	call   f0103d59 <env_run>

f0104cf0 <sys_page_unmap>:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
f0104cf0:	55                   	push   %ebp
f0104cf1:	89 e5                	mov    %esp,%ebp
f0104cf3:	53                   	push   %ebx
f0104cf4:	83 ec 24             	sub    $0x24,%esp
f0104cf7:	89 d3                	mov    %edx,%ebx
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env* e;
	void *alignment_va = ROUNDDOWN(va, PGSIZE);
f0104cf9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx

	if((size_t) va >= UTOP || va != alignment_va){
f0104cff:	39 d3                	cmp    %edx,%ebx
f0104d01:	75 3c                	jne    f0104d3f <sys_page_unmap+0x4f>
f0104d03:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104d09:	77 34                	ja     f0104d3f <sys_page_unmap+0x4f>
	// know why 
	//	cprintf("Over bound UTOP in sys_page_map->va[%p][align:%p]\n", 
	//		va, alignment_va);
		return -E_INVAL;
	}
	if(envid2env(envid, &e, 1))
f0104d0b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d12:	00 
f0104d13:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104d16:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104d1a:	89 04 24             	mov    %eax,(%esp)
f0104d1d:	e8 db e9 ff ff       	call   f01036fd <envid2env>
f0104d22:	85 c0                	test   %eax,%eax
f0104d24:	75 20                	jne    f0104d46 <sys_page_unmap+0x56>
		return -E_BAD_ENV;
	page_remove(e->env_pgdir, va);
f0104d26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104d2d:	8b 40 60             	mov    0x60(%eax),%eax
f0104d30:	89 04 24             	mov    %eax,(%esp)
f0104d33:	e8 ba c8 ff ff       	call   f01015f2 <page_remove>
	return 0;
f0104d38:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d3d:	eb 0c                	jmp    f0104d4b <sys_page_unmap+0x5b>
	// @yuhangj 
	// with the next two lines, the last gradetest failed but i dont 
	// know why 
	//	cprintf("Over bound UTOP in sys_page_map->va[%p][align:%p]\n", 
	//		va, alignment_va);
		return -E_INVAL;
f0104d3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d44:	eb 05                	jmp    f0104d4b <sys_page_unmap+0x5b>
	}
	if(envid2env(envid, &e, 1))
		return -E_BAD_ENV;
f0104d46:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
	page_remove(e->env_pgdir, va);
	return 0;
	//panic("sys_page_unmap not implemented");
}
f0104d4b:	83 c4 24             	add    $0x24,%esp
f0104d4e:	5b                   	pop    %ebx
f0104d4f:	5d                   	pop    %ebp
f0104d50:	c3                   	ret    

f0104d51 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104d51:	55                   	push   %ebp
f0104d52:	89 e5                	mov    %esp,%ebp
f0104d54:	53                   	push   %ebx
f0104d55:	83 ec 24             	sub    $0x24,%esp
f0104d58:	8b 45 08             	mov    0x8(%ebp),%eax
// 	SYS_yield,
// 	SYS_ipc_try_send,
// 	SYS_ipc_recv,
// 	NSYSCALLS
//  };
	switch(syscallno)
f0104d5b:	83 f8 0d             	cmp    $0xd,%eax
f0104d5e:	0f 87 9a 06 00 00    	ja     f01053fe <syscall+0x6ad>
f0104d64:	ff 24 85 50 88 10 f0 	jmp    *-0xfef77b0(,%eax,4)
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104d6b:	e8 22 b9 ff ff       	call   f0100692 <cons_getc>
// 	NSYSCALLS
//  };
	switch(syscallno)
	{
		case SYS_cgetc:
			return sys_cgetc();
f0104d70:	e9 95 06 00 00       	jmp    f010540a <syscall+0x6b9>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104d75:	e8 c2 19 00 00       	call   f010673c <cpunum>
f0104d7a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104d81:	00 
f0104d82:	8b 55 10             	mov    0x10(%ebp),%edx
f0104d85:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104d89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104d8c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104d90:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d93:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0104d99:	89 04 24             	mov    %eax,(%esp)
f0104d9c:	e8 a7 e8 ff ff       	call   f0103648 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104da1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104da4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104da8:	8b 55 10             	mov    0x10(%ebp),%edx
f0104dab:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104daf:	c7 04 24 fa 86 10 f0 	movl   $0xf01086fa,(%esp)
f0104db6:	e8 db f1 ff ff       	call   f0103f96 <cprintf>
	{
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
f0104dbb:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dc0:	e9 45 06 00 00       	jmp    f010540a <syscall+0x6b9>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104dc5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104dcc:	00 
f0104dcd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104dd0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104dd7:	89 0c 24             	mov    %ecx,(%esp)
f0104dda:	e8 1e e9 ff ff       	call   f01036fd <envid2env>
f0104ddf:	85 c0                	test   %eax,%eax
f0104de1:	0f 88 23 06 00 00    	js     f010540a <syscall+0x6b9>
		return r;
	env_destroy(e);
f0104de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104dea:	89 04 24             	mov    %eax,(%esp)
f0104ded:	e8 c6 ee ff ff       	call   f0103cb8 <env_destroy>
	return 0;
f0104df2:	b8 00 00 00 00       	mov    $0x0,%eax
			return sys_cgetc();
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_env_destroy:
			return sys_env_destroy((envid_t)a1);
f0104df7:	e9 0e 06 00 00       	jmp    f010540a <syscall+0x6b9>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104dfc:	e8 3b 19 00 00       	call   f010673c <cpunum>
f0104e01:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e04:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0104e0a:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_env_destroy:
			return sys_env_destroy((envid_t)a1);
		case SYS_getenvid:
			return sys_getenvid();
f0104e0d:	e9 f8 05 00 00       	jmp    f010540a <syscall+0x6b9>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104e12:	e8 fd fd ff ff       	call   f0104c14 <sched_yield>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	struct Env *new_env;
	int r; 
	if((r = env_alloc(&new_env, curenv->env_id)) < 0){
f0104e17:	e8 20 19 00 00       	call   f010673c <cpunum>
f0104e1c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e1f:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0104e25:	8b 40 48             	mov    0x48(%eax),%eax
f0104e28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e2f:	89 04 24             	mov    %eax,(%esp)
f0104e32:	e8 e1 e9 ff ff       	call   f0103818 <env_alloc>
f0104e37:	85 c0                	test   %eax,%eax
f0104e39:	0f 88 cb 05 00 00    	js     f010540a <syscall+0x6b9>
#endif

		return r;
	}
	// @yuhangj: set new env status and copy the register
	new_env -> env_status = ENV_NOT_RUNNABLE;
f0104e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e42:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memmove(&new_env->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
f0104e49:	e8 ee 18 00 00       	call   f010673c <cpunum>
f0104e4e:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104e55:	00 
f0104e56:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e59:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0104e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e66:	89 04 24             	mov    %eax,(%esp)
f0104e69:	e8 85 12 00 00       	call   f01060f3 <memmove>

	// @yuhangj: set the return value stored in the eax
	new_env -> env_tf.tf_regs.reg_eax = 0;
f0104e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e71:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

#ifdef FORK_DEBUG
	cprintf("new_env->env_id:[%d]\n", new_env->env_id);
#endif

	return new_env -> env_id;
f0104e78:	8b 40 48             	mov    0x48(%eax),%eax
			sys_yield();
			return 0;
		// @yuhangj
		// Lab4 PartA:
		case SYS_exofork:
			return sys_exofork();
f0104e7b:	e9 8a 05 00 00       	jmp    f010540a <syscall+0x6b9>

	// LAB 4: Your code here.
	struct Env *e;
	if ((status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE) < 0)
		return -E_INVAL;
	if (envid2env(envid, &e, 1))
f0104e80:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e87:	00 
f0104e88:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e92:	89 04 24             	mov    %eax,(%esp)
f0104e95:	e8 63 e8 ff ff       	call   f01036fd <envid2env>
f0104e9a:	85 c0                	test   %eax,%eax
f0104e9c:	75 13                	jne    f0104eb1 <syscall+0x160>
		return -E_BAD_ENV;
	e -> env_status = status;
f0104e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ea1:	8b 55 10             	mov    0x10(%ebp),%edx
f0104ea4:	89 50 54             	mov    %edx,0x54(%eax)
	return 0;
f0104ea7:	b8 00 00 00 00       	mov    $0x0,%eax
f0104eac:	e9 59 05 00 00       	jmp    f010540a <syscall+0x6b9>
	// LAB 4: Your code here.
	struct Env *e;
	if ((status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE) < 0)
		return -E_INVAL;
	if (envid2env(envid, &e, 1))
		return -E_BAD_ENV;
f0104eb1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		// @yuhangj
		// Lab4 PartA:
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
f0104eb6:	e9 4f 05 00 00       	jmp    f010540a <syscall+0x6b9>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;
	if(envid2env(envid, &e, 1))
f0104ebb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ec2:	00 
f0104ec3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104ec6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104ecd:	89 0c 24             	mov    %ecx,(%esp)
f0104ed0:	e8 28 e8 ff ff       	call   f01036fd <envid2env>
f0104ed5:	85 c0                	test   %eax,%eax
f0104ed7:	75 13                	jne    f0104eec <syscall+0x19b>
		return -E_BAD_ENV;
	e->env_pgfault_upcall = func;
f0104ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104edc:	8b 55 10             	mov    0x10(%ebp),%edx
f0104edf:	89 50 64             	mov    %edx,0x64(%eax)
	return 0;
f0104ee2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ee7:	e9 1e 05 00 00       	jmp    f010540a <syscall+0x6b9>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;
	if(envid2env(envid, &e, 1))
		return -E_BAD_ENV;
f0104eec:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
f0104ef1:	e9 14 05 00 00       	jmp    f010540a <syscall+0x6b9>
#ifdef SYS_CALL_DEBUG
	cprintf("in function sys_page_alloc()\n");
#endif 
	struct Env* e;
	struct Page *p;
	void *alignment_va = ROUNDDOWN(va, PGSIZE);
f0104ef6:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ef9:	25 00 f0 ff ff       	and    $0xfffff000,%eax

	if((perm & (PTE_U|PTE_P)) != (PTE_P|PTE_U) && 
f0104efe:	8b 55 14             	mov    0x14(%ebp),%edx
f0104f01:	83 e2 05             	and    $0x5,%edx
f0104f04:	83 fa 05             	cmp    $0x5,%edx
f0104f07:	74 4a                	je     f0104f53 <syscall+0x202>
		(perm|PTE_AVAIL|PTE_W) != (PTE_U|PTE_P|PTE_AVAIL|PTE_W)){
f0104f09:	8b 55 14             	mov    0x14(%ebp),%edx
f0104f0c:	81 ca 02 0e 00 00    	or     $0xe02,%edx
#endif 
	struct Env* e;
	struct Page *p;
	void *alignment_va = ROUNDDOWN(va, PGSIZE);

	if((perm & (PTE_U|PTE_P)) != (PTE_P|PTE_U) && 
f0104f12:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f0104f18:	74 39                	je     f0104f53 <syscall+0x202>
		(perm|PTE_AVAIL|PTE_W) != (PTE_U|PTE_P|PTE_AVAIL|PTE_W)){
		cprintf("check perm failed!\n");
f0104f1a:	c7 04 24 ff 86 10 f0 	movl   $0xf01086ff,(%esp)
f0104f21:	e8 70 f0 ff ff       	call   f0103f96 <cprintf>
		cprintf("perm[0x%x]:PTE_U|PTE_P|PTE_AVAIL[0x%x]:PTE_U|PTE_P[0x%x]\n", 
f0104f26:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0104f2d:	00 
f0104f2e:	c7 44 24 08 05 0e 00 	movl   $0xe05,0x8(%esp)
f0104f35:	00 
f0104f36:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104f39:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104f3d:	c7 04 24 84 87 10 f0 	movl   $0xf0108784,(%esp)
f0104f44:	e8 4d f0 ff ff       	call   f0103f96 <cprintf>
			perm, PTE_U|PTE_P|PTE_AVAIL, PTE_U|PTE_P);
		return -E_INVAL;
f0104f49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f4e:	e9 b7 04 00 00       	jmp    f010540a <syscall+0x6b9>
	}
	if((size_t)va >= UTOP || va != alignment_va){
f0104f53:	3b 45 10             	cmp    0x10(%ebp),%eax
f0104f56:	75 09                	jne    f0104f61 <syscall+0x210>
f0104f58:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104f5f:	76 21                	jbe    f0104f82 <syscall+0x231>
		cprintf("Over bound[UTOP] or not aligned at va[%p][align:%p]\n", 
f0104f61:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104f65:	8b 45 10             	mov    0x10(%ebp),%eax
f0104f68:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f6c:	c7 04 24 c0 87 10 f0 	movl   $0xf01087c0,(%esp)
f0104f73:	e8 1e f0 ff ff       	call   f0103f96 <cprintf>
			va,alignment_va);
		return -E_INVAL;
f0104f78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f7d:	e9 88 04 00 00       	jmp    f010540a <syscall+0x6b9>
	}
	if(envid2env(envid, &e, 1)){
f0104f82:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f89:	00 
f0104f8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104f8d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f91:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f94:	89 14 24             	mov    %edx,(%esp)
f0104f97:	e8 61 e7 ff ff       	call   f01036fd <envid2env>
f0104f9c:	85 c0                	test   %eax,%eax
f0104f9e:	74 29                	je     f0104fc9 <syscall+0x278>
		cprintf("check envid2env failed:");
f0104fa0:	c7 04 24 13 87 10 f0 	movl   $0xf0108713,(%esp)
f0104fa7:	e8 ea ef ff ff       	call   f0103f96 <cprintf>
		cprintf("envid[0x%x]:&e[%p]\n", &e);
f0104fac:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104faf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fb3:	c7 04 24 2b 87 10 f0 	movl   $0xf010872b,(%esp)
f0104fba:	e8 d7 ef ff ff       	call   f0103f96 <cprintf>
		return -E_BAD_ENV;
f0104fbf:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104fc4:	e9 41 04 00 00       	jmp    f010540a <syscall+0x6b9>
	}
	if(!(p = page_alloc(ALLOC_ZERO))){
f0104fc9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104fd0:	e8 1f c3 ff ff       	call   f01012f4 <page_alloc>
f0104fd5:	89 c3                	mov    %eax,%ebx
f0104fd7:	85 c0                	test   %eax,%eax
f0104fd9:	75 1e                	jne    f0104ff9 <syscall+0x2a8>
		cprintf("no memory [%p]\n", p);
f0104fdb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104fe2:	00 
f0104fe3:	c7 04 24 3f 87 10 f0 	movl   $0xf010873f,(%esp)
f0104fea:	e8 a7 ef ff ff       	call   f0103f96 <cprintf>
		return -E_NO_MEM;
f0104fef:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104ff4:	e9 11 04 00 00       	jmp    f010540a <syscall+0x6b9>
	}
	if(page_insert(e->env_pgdir, p, va, perm)){
f0104ff9:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104ffc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105000:	8b 45 10             	mov    0x10(%ebp),%eax
f0105003:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105007:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010500b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010500e:	8b 40 60             	mov    0x60(%eax),%eax
f0105011:	89 04 24             	mov    %eax,(%esp)
f0105014:	e8 30 c6 ff ff       	call   f0101649 <page_insert>
f0105019:	85 c0                	test   %eax,%eax
f010501b:	74 12                	je     f010502f <syscall+0x2de>
		page_free(p);
f010501d:	89 1c 24             	mov    %ebx,(%esp)
f0105020:	e8 4e c3 ff ff       	call   f0101373 <page_free>
		return -E_NO_MEM;
f0105025:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010502a:	e9 db 03 00 00       	jmp    f010540a <syscall+0x6b9>
	}		
	return 0;
f010502f:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void*)a2, (int)a3);
f0105034:	e9 d1 03 00 00       	jmp    f010540a <syscall+0x6b9>
	struct Page *src_page;
	pte_t *src_pte;

	// -E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
	// or the caller doesn't have permission to change one of them.
	if(envid2env(srcenvid, &src_env, 1) | envid2env(dstenvid, &dst_env, 1))
f0105039:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105040:	00 
f0105041:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105044:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105048:	8b 55 0c             	mov    0xc(%ebp),%edx
f010504b:	89 14 24             	mov    %edx,(%esp)
f010504e:	e8 aa e6 ff ff       	call   f01036fd <envid2env>
f0105053:	89 c3                	mov    %eax,%ebx
f0105055:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010505c:	00 
f010505d:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0105060:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105064:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0105067:	89 0c 24             	mov    %ecx,(%esp)
f010506a:	e8 8e e6 ff ff       	call   f01036fd <envid2env>
f010506f:	09 d8                	or     %ebx,%eax
f0105071:	0f 85 6c 01 00 00    	jne    f01051e3 <syscall+0x492>
		return -E_BAD_ENV;

	// check perm
	// -E_INVAL if perm is inappropriate (see sys_page_alloc).
	if((perm & (PTE_U|PTE_P)) != (PTE_P|PTE_U) && 
f0105077:	8b 45 1c             	mov    0x1c(%ebp),%eax
f010507a:	83 e0 05             	and    $0x5,%eax
f010507d:	83 f8 05             	cmp    $0x5,%eax
f0105080:	74 46                	je     f01050c8 <syscall+0x377>
		(perm|PTE_AVAIL) != (PTE_U|PTE_P|PTE_AVAIL)){
f0105082:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0105085:	80 cc 0e             	or     $0xe,%ah
	if(envid2env(srcenvid, &src_env, 1) | envid2env(dstenvid, &dst_env, 1))
		return -E_BAD_ENV;

	// check perm
	// -E_INVAL if perm is inappropriate (see sys_page_alloc).
	if((perm & (PTE_U|PTE_P)) != (PTE_P|PTE_U) && 
f0105088:	3d 05 0e 00 00       	cmp    $0xe05,%eax
f010508d:	74 39                	je     f01050c8 <syscall+0x377>
		(perm|PTE_AVAIL) != (PTE_U|PTE_P|PTE_AVAIL)){
		cprintf("check perm failed!\n");
f010508f:	c7 04 24 ff 86 10 f0 	movl   $0xf01086ff,(%esp)
f0105096:	e8 fb ee ff ff       	call   f0103f96 <cprintf>
		cprintf("perm[0x%x]:PTE_U|PTE_P|PTE_AVAIL[0x%x]:PTE_U|PTE_P[0x%x]\n", 
f010509b:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f01050a2:	00 
f01050a3:	c7 44 24 08 05 0e 00 	movl   $0xe05,0x8(%esp)
f01050aa:	00 
f01050ab:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01050ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050b2:	c7 04 24 84 87 10 f0 	movl   $0xf0108784,(%esp)
f01050b9:	e8 d8 ee ff ff       	call   f0103f96 <cprintf>
			perm, PTE_U|PTE_P|PTE_AVAIL, PTE_U|PTE_P);
		return -E_INVAL;
f01050be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050c3:	e9 42 03 00 00       	jmp    f010540a <syscall+0x6b9>
	}

	// check va of scr_env and dst_env
	// -E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	// or dstva >= UTOP or dstva is not page-aligned.
	alignment_va = ROUNDDOWN(srcva, PGSIZE);
f01050c8:	8b 45 10             	mov    0x10(%ebp),%eax
f01050cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if((size_t)srcva >= UTOP || srcva != alignment_va){
f01050d0:	3b 45 10             	cmp    0x10(%ebp),%eax
f01050d3:	75 09                	jne    f01050de <syscall+0x38d>
f01050d5:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01050dc:	76 29                	jbe    f0105107 <syscall+0x3b6>
		cprintf("Overbound: srcva[%p][align:%p], UTOP[0x%x]\n", 
f01050de:	c7 44 24 0c 00 00 c0 	movl   $0xeec00000,0xc(%esp)
f01050e5:	ee 
f01050e6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050ea:	8b 55 10             	mov    0x10(%ebp),%edx
f01050ed:	89 54 24 04          	mov    %edx,0x4(%esp)
f01050f1:	c7 04 24 f8 87 10 f0 	movl   $0xf01087f8,(%esp)
f01050f8:	e8 99 ee ff ff       	call   f0103f96 <cprintf>
			srcva, alignment_va, UTOP);
		return -E_INVAL;
f01050fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105102:	e9 03 03 00 00       	jmp    f010540a <syscall+0x6b9>
	}
	alignment_va = ROUNDDOWN(dstva, PGSIZE);
f0105107:	8b 45 18             	mov    0x18(%ebp),%eax
f010510a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if((size_t)dstva >= UTOP || dstva != alignment_va){
f010510f:	3b 45 18             	cmp    0x18(%ebp),%eax
f0105112:	75 09                	jne    f010511d <syscall+0x3cc>
f0105114:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010511b:	76 29                	jbe    f0105146 <syscall+0x3f5>
		cprintf("Overbound: dstva[%p][align:%p], UTOP[0x%x]\n", 
f010511d:	c7 44 24 0c 00 00 c0 	movl   $0xeec00000,0xc(%esp)
f0105124:	ee 
f0105125:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105129:	8b 4d 18             	mov    0x18(%ebp),%ecx
f010512c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105130:	c7 04 24 24 88 10 f0 	movl   $0xf0108824,(%esp)
f0105137:	e8 5a ee ff ff       	call   f0103f96 <cprintf>
			dstva, alignment_va, UTOP);
		return -E_INVAL;
f010513c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105141:	e9 c4 02 00 00       	jmp    f010540a <syscall+0x6b9>
	}


	if(!(src_page = page_lookup(src_env->env_pgdir, srcva, &src_pte))){
f0105146:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105149:	89 44 24 08          	mov    %eax,0x8(%esp)
f010514d:	8b 45 10             	mov    0x10(%ebp),%eax
f0105150:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105154:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105157:	8b 40 60             	mov    0x60(%eax),%eax
f010515a:	89 04 24             	mov    %eax,(%esp)
f010515d:	e8 e3 c3 ff ff       	call   f0101545 <page_lookup>
f0105162:	85 c0                	test   %eax,%eax
f0105164:	75 16                	jne    f010517c <syscall+0x42b>
		cprintf("page_lookup() failed\n");
f0105166:	c7 04 24 4f 87 10 f0 	movl   $0xf010874f,(%esp)
f010516d:	e8 24 ee ff ff       	call   f0103f96 <cprintf>
		return -E_INVAL;
f0105172:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105177:	e9 8e 02 00 00       	jmp    f010540a <syscall+0x6b9>
	}
	// -E_NO_MEM if there's no memory to allocate any necessary page tables.
	if(page_insert(dst_env->env_pgdir, src_page, dstva, perm)){
f010517c:	8b 55 1c             	mov    0x1c(%ebp),%edx
f010517f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105183:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105186:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010518a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010518e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105191:	8b 40 60             	mov    0x60(%eax),%eax
f0105194:	89 04 24             	mov    %eax,(%esp)
f0105197:	e8 ad c4 ff ff       	call   f0101649 <page_insert>
f010519c:	85 c0                	test   %eax,%eax
f010519e:	74 16                	je     f01051b6 <syscall+0x465>
		cprintf("no memory\n");
f01051a0:	c7 04 24 65 87 10 f0 	movl   $0xf0108765,(%esp)
f01051a7:	e8 ea ed ff ff       	call   f0103f96 <cprintf>
		return -E_NO_MEM;
f01051ac:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01051b1:	e9 54 02 00 00       	jmp    f010540a <syscall+0x6b9>
	// address space.
	if((perm & PTE_W) && !(*src_pte & PTE_W)){
		cprintf("check PTE_W failed\n");
		return -E_INVAL;
	}
	return 0;
f01051b6:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("no memory\n");
		return -E_NO_MEM;
	}
	// -E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
	// address space.
	if((perm & PTE_W) && !(*src_pte & PTE_W)){
f01051bb:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01051bf:	0f 84 45 02 00 00    	je     f010540a <syscall+0x6b9>
f01051c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01051c8:	f6 00 02             	testb  $0x2,(%eax)
f01051cb:	75 20                	jne    f01051ed <syscall+0x49c>
		cprintf("check PTE_W failed\n");
f01051cd:	c7 04 24 70 87 10 f0 	movl   $0xf0108770,(%esp)
f01051d4:	e8 bd ed ff ff       	call   f0103f96 <cprintf>
		return -E_INVAL;
f01051d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051de:	e9 27 02 00 00       	jmp    f010540a <syscall+0x6b9>
	pte_t *src_pte;

	// -E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
	// or the caller doesn't have permission to change one of them.
	if(envid2env(srcenvid, &src_env, 1) | envid2env(dstenvid, &dst_env, 1))
		return -E_BAD_ENV;
f01051e3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01051e8:	e9 1d 02 00 00       	jmp    f010540a <syscall+0x6b9>
	// address space.
	if((perm & PTE_W) && !(*src_pte & PTE_W)){
		cprintf("check PTE_W failed\n");
		return -E_INVAL;
	}
	return 0;
f01051ed:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void*)a2, (int)a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void*)a2, (envid_t)a3, (void*)a4, (int)a5);
f01051f2:	e9 13 02 00 00       	jmp    f010540a <syscall+0x6b9>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void*)a2);
f01051f7:	8b 55 10             	mov    0x10(%ebp),%edx
f01051fa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051fd:	e8 ee fa ff ff       	call   f0104cf0 <sys_page_unmap>
f0105202:	e9 03 02 00 00       	jmp    f010540a <syscall+0x6b9>
	// LAB 4: Your code here.
	struct Page *p;
	struct Env *e;
	pte_t *pte;

	if(envid2env(envid, &e, 0))
f0105207:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010520e:	00 
f010520f:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0105212:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105216:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105219:	89 04 24             	mov    %eax,(%esp)
f010521c:	e8 dc e4 ff ff       	call   f01036fd <envid2env>
f0105221:	85 c0                	test   %eax,%eax
f0105223:	0f 85 fe 00 00 00    	jne    f0105327 <syscall+0x5d6>
		return -E_BAD_ENV;
	if((!e -> env_ipc_recving) || e->env_ipc_from > 0)
f0105229:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010522c:	83 78 68 00          	cmpl   $0x0,0x68(%eax)
f0105230:	0f 84 fb 00 00 00    	je     f0105331 <syscall+0x5e0>
f0105236:	83 78 74 00          	cmpl   $0x0,0x74(%eax)
f010523a:	0f 8f fb 00 00 00    	jg     f010533b <syscall+0x5ea>
		return -E_IPC_NOT_RECV;
	if (srcva < (void*) UTOP){
f0105240:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105247:	0f 87 9b 00 00 00    	ja     f01052e8 <syscall+0x597>
		if(ROUNDDOWN(srcva, PGSIZE) != srcva)
f010524d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105250:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105255:	39 45 14             	cmp    %eax,0x14(%ebp)
f0105258:	0f 85 e7 00 00 00    	jne    f0105345 <syscall+0x5f4>
			return -E_INVAL;
		if(((perm & (PTE_P|PTE_U)) != (PTE_P|PTE_U)) &&
f010525e:	8b 45 18             	mov    0x18(%ebp),%eax
f0105261:	83 e0 05             	and    $0x5,%eax
f0105264:	83 f8 05             	cmp    $0x5,%eax
f0105267:	74 13                	je     f010527c <syscall+0x52b>
			(perm|PTE_AVAIL|PTE_W) != (PTE_U|PTE_P|PTE_AVAIL|PTE_W))
f0105269:	8b 45 18             	mov    0x18(%ebp),%eax
f010526c:	0d 02 0e 00 00       	or     $0xe02,%eax
	if((!e -> env_ipc_recving) || e->env_ipc_from > 0)
		return -E_IPC_NOT_RECV;
	if (srcva < (void*) UTOP){
		if(ROUNDDOWN(srcva, PGSIZE) != srcva)
			return -E_INVAL;
		if(((perm & (PTE_P|PTE_U)) != (PTE_P|PTE_U)) &&
f0105271:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0105276:	0f 85 d3 00 00 00    	jne    f010534f <syscall+0x5fe>
			(perm|PTE_AVAIL|PTE_W) != (PTE_U|PTE_P|PTE_AVAIL|PTE_W))
			return -E_INVAL;
		if(!(p = page_lookup(curenv->env_pgdir, srcva, &pte)))
f010527c:	e8 bb 14 00 00       	call   f010673c <cpunum>
f0105281:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0105284:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105288:	8b 55 14             	mov    0x14(%ebp),%edx
f010528b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010528f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105292:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0105298:	8b 40 60             	mov    0x60(%eax),%eax
f010529b:	89 04 24             	mov    %eax,(%esp)
f010529e:	e8 a2 c2 ff ff       	call   f0101545 <page_lookup>
f01052a3:	85 c0                	test   %eax,%eax
f01052a5:	0f 84 ae 00 00 00    	je     f0105359 <syscall+0x608>
			return -E_INVAL;
		if(!(*pte & PTE_W))
f01052ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01052ae:	f6 02 02             	testb  $0x2,(%edx)
f01052b1:	0f 84 ac 00 00 00    	je     f0105363 <syscall+0x612>
			return -E_INVAL;
		if(page_insert(e->env_pgdir, p, e->env_ipc_dstva, perm) < 0)
f01052b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01052ba:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01052bd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01052c1:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f01052c4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01052c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052cc:	8b 42 60             	mov    0x60(%edx),%eax
f01052cf:	89 04 24             	mov    %eax,(%esp)
f01052d2:	e8 72 c3 ff ff       	call   f0101649 <page_insert>
f01052d7:	85 c0                	test   %eax,%eax
f01052d9:	0f 88 8e 00 00 00    	js     f010536d <syscall+0x61c>
			return -E_NO_MEM;
		e->env_ipc_perm = perm;
f01052df:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01052e2:	8b 55 18             	mov    0x18(%ebp),%edx
f01052e5:	89 50 78             	mov    %edx,0x78(%eax)
	}

	e->env_ipc_recving = 0;
f01052e8:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01052eb:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)
	e->env_ipc_from = curenv->env_id;
f01052f2:	e8 45 14 00 00       	call   f010673c <cpunum>
f01052f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01052fa:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f0105300:	8b 40 48             	mov    0x48(%eax),%eax
f0105303:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value;
f0105306:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105309:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010530c:	89 48 70             	mov    %ecx,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f010530f:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0105316:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f010531d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105322:	e9 e3 00 00 00       	jmp    f010540a <syscall+0x6b9>
	struct Page *p;
	struct Env *e;
	pte_t *pte;

	if(envid2env(envid, &e, 0))
		return -E_BAD_ENV;
f0105327:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010532c:	e9 d9 00 00 00       	jmp    f010540a <syscall+0x6b9>
	if((!e -> env_ipc_recving) || e->env_ipc_from > 0)
		return -E_IPC_NOT_RECV;
f0105331:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0105336:	e9 cf 00 00 00       	jmp    f010540a <syscall+0x6b9>
f010533b:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0105340:	e9 c5 00 00 00       	jmp    f010540a <syscall+0x6b9>
	if (srcva < (void*) UTOP){
		if(ROUNDDOWN(srcva, PGSIZE) != srcva)
			return -E_INVAL;
f0105345:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010534a:	e9 bb 00 00 00       	jmp    f010540a <syscall+0x6b9>
		if(((perm & (PTE_P|PTE_U)) != (PTE_P|PTE_U)) &&
			(perm|PTE_AVAIL|PTE_W) != (PTE_U|PTE_P|PTE_AVAIL|PTE_W))
			return -E_INVAL;
f010534f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105354:	e9 b1 00 00 00       	jmp    f010540a <syscall+0x6b9>
		if(!(p = page_lookup(curenv->env_pgdir, srcva, &pte)))
			return -E_INVAL;
f0105359:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010535e:	e9 a7 00 00 00       	jmp    f010540a <syscall+0x6b9>
		if(!(*pte & PTE_W))
			return -E_INVAL;
f0105363:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105368:	e9 9d 00 00 00       	jmp    f010540a <syscall+0x6b9>
		if(page_insert(e->env_pgdir, p, e->env_ipc_dstva, perm) < 0)
			return -E_NO_MEM;
f010536d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void*)a2);

		// Lab4 IPC:
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, a2, (void*)a3, (unsigned)a4);
f0105372:	e9 93 00 00 00       	jmp    f010540a <syscall+0x6b9>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if(dstva < (void*)UTOP && (ROUNDDOWN(dstva, PGSIZE) != dstva))
f0105377:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f010537e:	77 0d                	ja     f010538d <syscall+0x63c>
f0105380:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105383:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105388:	39 45 0c             	cmp    %eax,0xc(%ebp)
f010538b:	75 78                	jne    f0105405 <syscall+0x6b4>
		return -E_INVAL;

	sys_page_unmap(curenv->env_id, dstva);
f010538d:	e8 aa 13 00 00       	call   f010673c <cpunum>
f0105392:	6b c0 74             	imul   $0x74,%eax,%eax
f0105395:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f010539b:	8b 40 48             	mov    0x48(%eax),%eax
f010539e:	8b 55 0c             	mov    0xc(%ebp),%edx
f01053a1:	e8 4a f9 ff ff       	call   f0104cf0 <sys_page_unmap>

	curenv->env_status = ENV_NOT_RUNNABLE;
f01053a6:	e8 91 13 00 00       	call   f010673c <cpunum>
f01053ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01053ae:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f01053b4:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_recving = 1;
f01053bb:	e8 7c 13 00 00       	call   f010673c <cpunum>
f01053c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01053c3:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f01053c9:	c7 40 68 01 00 00 00 	movl   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f01053d0:	e8 67 13 00 00       	call   f010673c <cpunum>
f01053d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01053d8:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f01053de:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_ipc_dstva = dstva;
f01053e5:	e8 52 13 00 00       	call   f010673c <cpunum>
f01053ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01053ed:	8b 80 28 70 1d f0    	mov    -0xfe28fd8(%eax),%eax
f01053f3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01053f6:	89 50 6c             	mov    %edx,0x6c(%eax)
	sched_yield();
f01053f9:	e8 16 f8 ff ff       	call   f0104c14 <sched_yield>
			return sys_ipc_try_send((envid_t)a1, a2, (void*)a3, (unsigned)a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void*) a1);

		default:
			return -E_INVAL;
f01053fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105403:	eb 05                	jmp    f010540a <syscall+0x6b9>

		// Lab4 IPC:
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, a2, (void*)a3, (unsigned)a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void*) a1);
f0105405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

		default:
			return -E_INVAL;
	}
}
f010540a:	83 c4 24             	add    $0x24,%esp
f010540d:	5b                   	pop    %ebx
f010540e:	5d                   	pop    %ebp
f010540f:	c3                   	ret    

f0105410 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105410:	55                   	push   %ebp
f0105411:	89 e5                	mov    %esp,%ebp
f0105413:	57                   	push   %edi
f0105414:	56                   	push   %esi
f0105415:	53                   	push   %ebx
f0105416:	83 ec 14             	sub    $0x14,%esp
f0105419:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010541c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010541f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105422:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105425:	8b 1a                	mov    (%edx),%ebx
f0105427:	8b 01                	mov    (%ecx),%eax
f0105429:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f010542c:	39 c3                	cmp    %eax,%ebx
f010542e:	0f 8f 9f 00 00 00    	jg     f01054d3 <stab_binsearch+0xc3>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0105434:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010543b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010543e:	01 d8                	add    %ebx,%eax
f0105440:	89 c7                	mov    %eax,%edi
f0105442:	c1 ef 1f             	shr    $0x1f,%edi
f0105445:	01 c7                	add    %eax,%edi
f0105447:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105449:	39 df                	cmp    %ebx,%edi
f010544b:	0f 8c ce 00 00 00    	jl     f010551f <stab_binsearch+0x10f>
f0105451:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105454:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0105457:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f010545c:	39 f0                	cmp    %esi,%eax
f010545e:	0f 84 c0 00 00 00    	je     f0105524 <stab_binsearch+0x114>
f0105464:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105468:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010546c:	89 f8                	mov    %edi,%eax
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010546e:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105471:	39 d8                	cmp    %ebx,%eax
f0105473:	0f 8c a6 00 00 00    	jl     f010551f <stab_binsearch+0x10f>
f0105479:	0f b6 0a             	movzbl (%edx),%ecx
f010547c:	83 ea 0c             	sub    $0xc,%edx
f010547f:	39 f1                	cmp    %esi,%ecx
f0105481:	75 eb                	jne    f010546e <stab_binsearch+0x5e>
f0105483:	e9 9e 00 00 00       	jmp    f0105526 <stab_binsearch+0x116>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105488:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010548b:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f010548d:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105490:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105497:	eb 2b                	jmp    f01054c4 <stab_binsearch+0xb4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105499:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010549c:	76 14                	jbe    f01054b2 <stab_binsearch+0xa2>
			*region_right = m - 1;
f010549e:	83 e8 01             	sub    $0x1,%eax
f01054a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01054a4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01054a7:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01054a9:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01054b0:	eb 12                	jmp    f01054c4 <stab_binsearch+0xb4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01054b2:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01054b5:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f01054b7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01054bb:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01054bd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f01054c4:	3b 5d ec             	cmp    -0x14(%ebp),%ebx
f01054c7:	0f 8e 6e ff ff ff    	jle    f010543b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01054cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01054d1:	75 0f                	jne    f01054e2 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f01054d3:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01054d6:	8b 02                	mov    (%edx),%eax
f01054d8:	83 e8 01             	sub    $0x1,%eax
f01054db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01054de:	89 01                	mov    %eax,(%ecx)
f01054e0:	eb 5c                	jmp    f010553e <stab_binsearch+0x12e>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01054e2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01054e5:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01054e7:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01054ea:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01054ec:	39 c8                	cmp    %ecx,%eax
f01054ee:	7e 28                	jle    f0105518 <stab_binsearch+0x108>
		     l > *region_left && stabs[l].n_type != type;
f01054f0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01054f3:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01054f6:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01054fb:	39 f2                	cmp    %esi,%edx
f01054fd:	74 19                	je     f0105518 <stab_binsearch+0x108>
f01054ff:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105503:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105507:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010550a:	39 c8                	cmp    %ecx,%eax
f010550c:	7e 0a                	jle    f0105518 <stab_binsearch+0x108>
		     l > *region_left && stabs[l].n_type != type;
f010550e:	0f b6 1a             	movzbl (%edx),%ebx
f0105511:	83 ea 0c             	sub    $0xc,%edx
f0105514:	39 f3                	cmp    %esi,%ebx
f0105516:	75 ef                	jne    f0105507 <stab_binsearch+0xf7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105518:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010551b:	89 02                	mov    %eax,(%edx)
f010551d:	eb 1f                	jmp    f010553e <stab_binsearch+0x12e>
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010551f:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105522:	eb a0                	jmp    f01054c4 <stab_binsearch+0xb4>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105524:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105526:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105529:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f010552c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105530:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105533:	0f 82 4f ff ff ff    	jb     f0105488 <stab_binsearch+0x78>
f0105539:	e9 5b ff ff ff       	jmp    f0105499 <stab_binsearch+0x89>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010553e:	83 c4 14             	add    $0x14,%esp
f0105541:	5b                   	pop    %ebx
f0105542:	5e                   	pop    %esi
f0105543:	5f                   	pop    %edi
f0105544:	5d                   	pop    %ebp
f0105545:	c3                   	ret    

f0105546 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105546:	55                   	push   %ebp
f0105547:	89 e5                	mov    %esp,%ebp
f0105549:	57                   	push   %edi
f010554a:	56                   	push   %esi
f010554b:	53                   	push   %ebx
f010554c:	83 ec 5c             	sub    $0x5c,%esp
f010554f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105555:	c7 03 88 88 10 f0    	movl   $0xf0108888,(%ebx)
	info->eip_line = 0;
f010555b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105562:	c7 43 08 88 88 10 f0 	movl   $0xf0108888,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105569:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105570:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105573:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010557a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105580:	77 21                	ja     f01055a3 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0105582:	a1 00 00 20 00       	mov    0x200000,%eax
f0105587:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010558a:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010558f:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0105595:	89 55 bc             	mov    %edx,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0105598:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f010559e:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f01055a1:	eb 1a                	jmp    f01055bd <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01055a3:	c7 45 c0 38 71 11 f0 	movl   $0xf0117138,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01055aa:	c7 45 bc a5 3a 11 f0 	movl   $0xf0113aa5,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01055b1:	b8 a4 3a 11 f0       	mov    $0xf0113aa4,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01055b6:	c7 45 c4 30 8e 10 f0 	movl   $0xf0108e30,-0x3c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01055bd:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01055c0:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f01055c3:	0f 83 b9 01 00 00    	jae    f0105782 <debuginfo_eip+0x23c>
f01055c9:	80 7a ff 00          	cmpb   $0x0,-0x1(%edx)
f01055cd:	0f 85 b6 01 00 00    	jne    f0105789 <debuginfo_eip+0x243>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01055d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01055da:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f01055dd:	c1 f8 02             	sar    $0x2,%eax
f01055e0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01055e6:	83 e8 01             	sub    $0x1,%eax
f01055e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01055ec:	89 74 24 04          	mov    %esi,0x4(%esp)
f01055f0:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01055f7:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01055fa:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01055fd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105600:	e8 0b fe ff ff       	call   f0105410 <stab_binsearch>
	if (lfile == 0)
f0105605:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105608:	85 c0                	test   %eax,%eax
f010560a:	0f 84 80 01 00 00    	je     f0105790 <debuginfo_eip+0x24a>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105610:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105613:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105616:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105619:	89 74 24 04          	mov    %esi,0x4(%esp)
f010561d:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105624:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105627:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010562a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010562d:	e8 de fd ff ff       	call   f0105410 <stab_binsearch>

	if (lfun <= rfun) {
f0105632:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105635:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0105638:	39 c8                	cmp    %ecx,%eax
f010563a:	7f 32                	jg     f010566e <debuginfo_eip+0x128>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010563c:	8d 3c 40             	lea    (%eax,%eax,2),%edi
f010563f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105642:	8d 3c ba             	lea    (%edx,%edi,4),%edi
f0105645:	8b 17                	mov    (%edi),%edx
f0105647:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f010564a:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010564d:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105650:	39 55 b4             	cmp    %edx,-0x4c(%ebp)
f0105653:	73 09                	jae    f010565e <debuginfo_eip+0x118>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105655:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0105658:	03 55 bc             	add    -0x44(%ebp),%edx
f010565b:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010565e:	8b 57 08             	mov    0x8(%edi),%edx
f0105661:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105664:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105666:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105669:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010566c:	eb 0f                	jmp    f010567d <debuginfo_eip+0x137>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010566e:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105671:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105674:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105677:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010567a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010567d:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105684:	00 
f0105685:	8b 43 08             	mov    0x8(%ebx),%eax
f0105688:	89 04 24             	mov    %eax,(%esp)
f010568b:	e8 db 09 00 00       	call   f010606b <strfind>
f0105690:	2b 43 08             	sub    0x8(%ebx),%eax
f0105693:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105696:	89 74 24 04          	mov    %esi,0x4(%esp)
f010569a:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01056a1:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01056a4:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01056a7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01056aa:	e8 61 fd ff ff       	call   f0105410 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f01056af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01056b2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01056b5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01056b8:	0f b7 54 91 06       	movzwl 0x6(%ecx,%edx,4),%edx
f01056bd:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01056c0:	89 c2                	mov    %eax,%edx
f01056c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01056c5:	39 f8                	cmp    %edi,%eax
f01056c7:	7c 6c                	jl     f0105735 <debuginfo_eip+0x1ef>
	       && stabs[lline].n_type != N_SOL
f01056c9:	8d 34 40             	lea    (%eax,%eax,2),%esi
f01056cc:	8d 34 b1             	lea    (%ecx,%esi,4),%esi
f01056cf:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f01056d3:	88 4d b4             	mov    %cl,-0x4c(%ebp)
f01056d6:	80 f9 84             	cmp    $0x84,%cl
f01056d9:	74 42                	je     f010571d <debuginfo_eip+0x1d7>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01056db:	8d 44 40 fd          	lea    -0x3(%eax,%eax,2),%eax
f01056df:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01056e2:	8d 0c 81             	lea    (%ecx,%eax,4),%ecx
f01056e5:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f01056e8:	0f b6 4d b4          	movzbl -0x4c(%ebp),%ecx
f01056ec:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01056ef:	eb 1a                	jmp    f010570b <debuginfo_eip+0x1c5>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01056f1:	83 ea 01             	sub    $0x1,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01056f4:	39 fa                	cmp    %edi,%edx
f01056f6:	7c 3d                	jl     f0105735 <debuginfo_eip+0x1ef>
	       && stabs[lline].n_type != N_SOL
f01056f8:	89 c6                	mov    %eax,%esi
f01056fa:	83 e8 0c             	sub    $0xc,%eax
f01056fd:	0f b6 48 10          	movzbl 0x10(%eax),%ecx
f0105701:	80 f9 84             	cmp    $0x84,%cl
f0105704:	75 05                	jne    f010570b <debuginfo_eip+0x1c5>
f0105706:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105709:	eb 12                	jmp    f010571d <debuginfo_eip+0x1d7>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010570b:	80 f9 64             	cmp    $0x64,%cl
f010570e:	75 e1                	jne    f01056f1 <debuginfo_eip+0x1ab>
f0105710:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0105714:	74 db                	je     f01056f1 <debuginfo_eip+0x1ab>
f0105716:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105719:	39 d7                	cmp    %edx,%edi
f010571b:	7f 18                	jg     f0105735 <debuginfo_eip+0x1ef>
f010571d:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0105720:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105723:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0105726:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105729:	2b 55 bc             	sub    -0x44(%ebp),%edx
f010572c:	39 d0                	cmp    %edx,%eax
f010572e:	73 05                	jae    f0105735 <debuginfo_eip+0x1ef>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105730:	03 45 bc             	add    -0x44(%ebp),%eax
f0105733:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105735:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105738:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f010573b:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105740:	39 f2                	cmp    %esi,%edx
f0105742:	7d 66                	jge    f01057aa <debuginfo_eip+0x264>
		for (lline = lfun + 1;
f0105744:	8d 42 01             	lea    0x1(%edx),%eax
f0105747:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010574a:	39 c6                	cmp    %eax,%esi
f010574c:	7e 49                	jle    f0105797 <debuginfo_eip+0x251>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010574e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105751:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105754:	80 7c 81 04 a0       	cmpb   $0xa0,0x4(%ecx,%eax,4)
f0105759:	75 43                	jne    f010579e <debuginfo_eip+0x258>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010575b:	8d 42 02             	lea    0x2(%edx),%eax

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010575e:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105761:	8d 54 91 1c          	lea    0x1c(%ecx,%edx,4),%edx
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105765:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105769:	39 f0                	cmp    %esi,%eax
f010576b:	74 38                	je     f01057a5 <debuginfo_eip+0x25f>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010576d:	0f b6 0a             	movzbl (%edx),%ecx
f0105770:	83 c0 01             	add    $0x1,%eax
f0105773:	83 c2 0c             	add    $0xc,%edx
f0105776:	80 f9 a0             	cmp    $0xa0,%cl
f0105779:	74 ea                	je     f0105765 <debuginfo_eip+0x21f>
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f010577b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105780:	eb 28                	jmp    f01057aa <debuginfo_eip+0x264>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105782:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105787:	eb 21                	jmp    f01057aa <debuginfo_eip+0x264>
f0105789:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010578e:	eb 1a                	jmp    f01057aa <debuginfo_eip+0x264>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105790:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105795:	eb 13                	jmp    f01057aa <debuginfo_eip+0x264>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0105797:	b8 00 00 00 00       	mov    $0x0,%eax
f010579c:	eb 0c                	jmp    f01057aa <debuginfo_eip+0x264>
f010579e:	b8 00 00 00 00       	mov    $0x0,%eax
f01057a3:	eb 05                	jmp    f01057aa <debuginfo_eip+0x264>
f01057a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057aa:	83 c4 5c             	add    $0x5c,%esp
f01057ad:	5b                   	pop    %ebx
f01057ae:	5e                   	pop    %esi
f01057af:	5f                   	pop    %edi
f01057b0:	5d                   	pop    %ebp
f01057b1:	c3                   	ret    
f01057b2:	66 90                	xchg   %ax,%ax
f01057b4:	66 90                	xchg   %ax,%ax
f01057b6:	66 90                	xchg   %ax,%ax
f01057b8:	66 90                	xchg   %ax,%ax
f01057ba:	66 90                	xchg   %ax,%ax
f01057bc:	66 90                	xchg   %ax,%ax
f01057be:	66 90                	xchg   %ax,%ax

f01057c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01057c0:	55                   	push   %ebp
f01057c1:	89 e5                	mov    %esp,%ebp
f01057c3:	57                   	push   %edi
f01057c4:	56                   	push   %esi
f01057c5:	53                   	push   %ebx
f01057c6:	83 ec 4c             	sub    $0x4c,%esp
f01057c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01057cc:	89 d7                	mov    %edx,%edi
f01057ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01057d1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f01057d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01057d7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01057da:	b8 00 00 00 00       	mov    $0x0,%eax
f01057df:	39 d8                	cmp    %ebx,%eax
f01057e1:	72 17                	jb     f01057fa <printnum+0x3a>
f01057e3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01057e6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
f01057e9:	76 0f                	jbe    f01057fa <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01057eb:	8b 75 14             	mov    0x14(%ebp),%esi
f01057ee:	83 ee 01             	sub    $0x1,%esi
f01057f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01057f4:	85 f6                	test   %esi,%esi
f01057f6:	7f 63                	jg     f010585b <printnum+0x9b>
f01057f8:	eb 75                	jmp    f010586f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01057fa:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01057fd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0105801:	8b 45 14             	mov    0x14(%ebp),%eax
f0105804:	83 e8 01             	sub    $0x1,%eax
f0105807:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010580b:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010580e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105812:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105816:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010581a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010581d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105820:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105827:	00 
f0105828:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f010582b:	89 1c 24             	mov    %ebx,(%esp)
f010582e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105831:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105835:	e8 86 13 00 00       	call   f0106bc0 <__udivdi3>
f010583a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010583d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105840:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105844:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105848:	89 04 24             	mov    %eax,(%esp)
f010584b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010584f:	89 fa                	mov    %edi,%edx
f0105851:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105854:	e8 67 ff ff ff       	call   f01057c0 <printnum>
f0105859:	eb 14                	jmp    f010586f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010585b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010585f:	8b 45 18             	mov    0x18(%ebp),%eax
f0105862:	89 04 24             	mov    %eax,(%esp)
f0105865:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105867:	83 ee 01             	sub    $0x1,%esi
f010586a:	75 ef                	jne    f010585b <printnum+0x9b>
f010586c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010586f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105873:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105877:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010587a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010587e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105885:	00 
f0105886:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0105889:	89 1c 24             	mov    %ebx,(%esp)
f010588c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010588f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105893:	e8 78 14 00 00       	call   f0106d10 <__umoddi3>
f0105898:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010589c:	0f be 80 92 88 10 f0 	movsbl -0xfef776e(%eax),%eax
f01058a3:	89 04 24             	mov    %eax,(%esp)
f01058a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01058a9:	ff d0                	call   *%eax
}
f01058ab:	83 c4 4c             	add    $0x4c,%esp
f01058ae:	5b                   	pop    %ebx
f01058af:	5e                   	pop    %esi
f01058b0:	5f                   	pop    %edi
f01058b1:	5d                   	pop    %ebp
f01058b2:	c3                   	ret    

f01058b3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01058b3:	55                   	push   %ebp
f01058b4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01058b6:	83 fa 01             	cmp    $0x1,%edx
f01058b9:	7e 0e                	jle    f01058c9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01058bb:	8b 10                	mov    (%eax),%edx
f01058bd:	8d 4a 08             	lea    0x8(%edx),%ecx
f01058c0:	89 08                	mov    %ecx,(%eax)
f01058c2:	8b 02                	mov    (%edx),%eax
f01058c4:	8b 52 04             	mov    0x4(%edx),%edx
f01058c7:	eb 22                	jmp    f01058eb <getuint+0x38>
	else if (lflag)
f01058c9:	85 d2                	test   %edx,%edx
f01058cb:	74 10                	je     f01058dd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01058cd:	8b 10                	mov    (%eax),%edx
f01058cf:	8d 4a 04             	lea    0x4(%edx),%ecx
f01058d2:	89 08                	mov    %ecx,(%eax)
f01058d4:	8b 02                	mov    (%edx),%eax
f01058d6:	ba 00 00 00 00       	mov    $0x0,%edx
f01058db:	eb 0e                	jmp    f01058eb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01058dd:	8b 10                	mov    (%eax),%edx
f01058df:	8d 4a 04             	lea    0x4(%edx),%ecx
f01058e2:	89 08                	mov    %ecx,(%eax)
f01058e4:	8b 02                	mov    (%edx),%eax
f01058e6:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01058eb:	5d                   	pop    %ebp
f01058ec:	c3                   	ret    

f01058ed <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01058ed:	55                   	push   %ebp
f01058ee:	89 e5                	mov    %esp,%ebp
f01058f0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01058f3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01058f7:	8b 10                	mov    (%eax),%edx
f01058f9:	3b 50 04             	cmp    0x4(%eax),%edx
f01058fc:	73 0a                	jae    f0105908 <sprintputch+0x1b>
		*b->buf++ = ch;
f01058fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105901:	88 0a                	mov    %cl,(%edx)
f0105903:	83 c2 01             	add    $0x1,%edx
f0105906:	89 10                	mov    %edx,(%eax)
}
f0105908:	5d                   	pop    %ebp
f0105909:	c3                   	ret    

f010590a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010590a:	55                   	push   %ebp
f010590b:	89 e5                	mov    %esp,%ebp
f010590d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105910:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105913:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105917:	8b 45 10             	mov    0x10(%ebp),%eax
f010591a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010591e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105921:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105925:	8b 45 08             	mov    0x8(%ebp),%eax
f0105928:	89 04 24             	mov    %eax,(%esp)
f010592b:	e8 02 00 00 00       	call   f0105932 <vprintfmt>
	va_end(ap);
}
f0105930:	c9                   	leave  
f0105931:	c3                   	ret    

f0105932 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105932:	55                   	push   %ebp
f0105933:	89 e5                	mov    %esp,%ebp
f0105935:	57                   	push   %edi
f0105936:	56                   	push   %esi
f0105937:	53                   	push   %ebx
f0105938:	83 ec 4c             	sub    $0x4c,%esp
f010593b:	8b 75 08             	mov    0x8(%ebp),%esi
f010593e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105941:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105944:	eb 11                	jmp    f0105957 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105946:	85 c0                	test   %eax,%eax
f0105948:	0f 84 db 03 00 00    	je     f0105d29 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
f010594e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105952:	89 04 24             	mov    %eax,(%esp)
f0105955:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105957:	0f b6 07             	movzbl (%edi),%eax
f010595a:	83 c7 01             	add    $0x1,%edi
f010595d:	83 f8 25             	cmp    $0x25,%eax
f0105960:	75 e4                	jne    f0105946 <vprintfmt+0x14>
f0105962:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
f0105966:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f010596d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0105974:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010597b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105980:	eb 2b                	jmp    f01059ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105982:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105985:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
f0105989:	eb 22                	jmp    f01059ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010598b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010598e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
f0105992:	eb 19                	jmp    f01059ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105994:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105997:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010599e:	eb 0d                	jmp    f01059ad <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01059a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01059a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01059a6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059ad:	0f b6 0f             	movzbl (%edi),%ecx
f01059b0:	8d 47 01             	lea    0x1(%edi),%eax
f01059b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01059b6:	0f b6 07             	movzbl (%edi),%eax
f01059b9:	83 e8 23             	sub    $0x23,%eax
f01059bc:	3c 55                	cmp    $0x55,%al
f01059be:	0f 87 40 03 00 00    	ja     f0105d04 <vprintfmt+0x3d2>
f01059c4:	0f b6 c0             	movzbl %al,%eax
f01059c7:	ff 24 85 e0 89 10 f0 	jmp    *-0xfef7620(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01059ce:	83 e9 30             	sub    $0x30,%ecx
f01059d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
f01059d4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
f01059d8:	8d 48 d0             	lea    -0x30(%eax),%ecx
f01059db:	83 f9 09             	cmp    $0x9,%ecx
f01059de:	77 57                	ja     f0105a37 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059e0:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01059e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01059e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01059e9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f01059ec:	8d 14 92             	lea    (%edx,%edx,4),%edx
f01059ef:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f01059f3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f01059f6:	8d 48 d0             	lea    -0x30(%eax),%ecx
f01059f9:	83 f9 09             	cmp    $0x9,%ecx
f01059fc:	76 eb                	jbe    f01059e9 <vprintfmt+0xb7>
f01059fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105a01:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105a04:	eb 34                	jmp    f0105a3a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105a06:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a09:	8d 48 04             	lea    0x4(%eax),%ecx
f0105a0c:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105a0f:	8b 00                	mov    (%eax),%eax
f0105a11:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a14:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105a17:	eb 21                	jmp    f0105a3a <vprintfmt+0x108>

		case '.':
			if (width < 0)
f0105a19:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105a1d:	0f 88 71 ff ff ff    	js     f0105994 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a23:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105a26:	eb 85                	jmp    f01059ad <vprintfmt+0x7b>
f0105a28:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105a2b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0105a32:	e9 76 ff ff ff       	jmp    f01059ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a37:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0105a3a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105a3e:	0f 89 69 ff ff ff    	jns    f01059ad <vprintfmt+0x7b>
f0105a44:	e9 57 ff ff ff       	jmp    f01059a0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105a49:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a4c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105a4f:	e9 59 ff ff ff       	jmp    f01059ad <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105a54:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a57:	8d 50 04             	lea    0x4(%eax),%edx
f0105a5a:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a61:	8b 00                	mov    (%eax),%eax
f0105a63:	89 04 24             	mov    %eax,(%esp)
f0105a66:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a68:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105a6b:	e9 e7 fe ff ff       	jmp    f0105957 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105a70:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a73:	8d 50 04             	lea    0x4(%eax),%edx
f0105a76:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a79:	8b 00                	mov    (%eax),%eax
f0105a7b:	89 c2                	mov    %eax,%edx
f0105a7d:	c1 fa 1f             	sar    $0x1f,%edx
f0105a80:	31 d0                	xor    %edx,%eax
f0105a82:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105a84:	83 f8 0f             	cmp    $0xf,%eax
f0105a87:	7f 0b                	jg     f0105a94 <vprintfmt+0x162>
f0105a89:	8b 14 85 40 8b 10 f0 	mov    -0xfef74c0(,%eax,4),%edx
f0105a90:	85 d2                	test   %edx,%edx
f0105a92:	75 20                	jne    f0105ab4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
f0105a94:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a98:	c7 44 24 08 aa 88 10 	movl   $0xf01088aa,0x8(%esp)
f0105a9f:	f0 
f0105aa0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105aa4:	89 34 24             	mov    %esi,(%esp)
f0105aa7:	e8 5e fe ff ff       	call   f010590a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105aac:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105aaf:	e9 a3 fe ff ff       	jmp    f0105957 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0105ab4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105ab8:	c7 44 24 08 39 7f 10 	movl   $0xf0107f39,0x8(%esp)
f0105abf:	f0 
f0105ac0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ac4:	89 34 24             	mov    %esi,(%esp)
f0105ac7:	e8 3e fe ff ff       	call   f010590a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105acc:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105acf:	e9 83 fe ff ff       	jmp    f0105957 <vprintfmt+0x25>
f0105ad4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105ad7:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0105ada:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105add:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ae0:	8d 50 04             	lea    0x4(%eax),%edx
f0105ae3:	89 55 14             	mov    %edx,0x14(%ebp)
f0105ae6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105ae8:	85 ff                	test   %edi,%edi
f0105aea:	b8 a3 88 10 f0       	mov    $0xf01088a3,%eax
f0105aef:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105af2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
f0105af6:	74 06                	je     f0105afe <vprintfmt+0x1cc>
f0105af8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0105afc:	7f 16                	jg     f0105b14 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105afe:	0f b6 17             	movzbl (%edi),%edx
f0105b01:	0f be c2             	movsbl %dl,%eax
f0105b04:	83 c7 01             	add    $0x1,%edi
f0105b07:	85 c0                	test   %eax,%eax
f0105b09:	0f 85 9f 00 00 00    	jne    f0105bae <vprintfmt+0x27c>
f0105b0f:	e9 8b 00 00 00       	jmp    f0105b9f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105b14:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105b18:	89 3c 24             	mov    %edi,(%esp)
f0105b1b:	e8 92 03 00 00       	call   f0105eb2 <strnlen>
f0105b20:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0105b23:	29 c2                	sub    %eax,%edx
f0105b25:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0105b28:	85 d2                	test   %edx,%edx
f0105b2a:	7e d2                	jle    f0105afe <vprintfmt+0x1cc>
					putch(padc, putdat);
f0105b2c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
f0105b30:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0105b33:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105b36:	89 d7                	mov    %edx,%edi
f0105b38:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b3f:	89 04 24             	mov    %eax,(%esp)
f0105b42:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105b44:	83 ef 01             	sub    $0x1,%edi
f0105b47:	75 ef                	jne    f0105b38 <vprintfmt+0x206>
f0105b49:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0105b4c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0105b4f:	eb ad                	jmp    f0105afe <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105b51:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0105b55:	74 20                	je     f0105b77 <vprintfmt+0x245>
f0105b57:	0f be d2             	movsbl %dl,%edx
f0105b5a:	83 ea 20             	sub    $0x20,%edx
f0105b5d:	83 fa 5e             	cmp    $0x5e,%edx
f0105b60:	76 15                	jbe    f0105b77 <vprintfmt+0x245>
					putch('?', putdat);
f0105b62:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105b65:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105b69:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105b70:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105b73:	ff d1                	call   *%ecx
f0105b75:	eb 0f                	jmp    f0105b86 <vprintfmt+0x254>
				else
					putch(ch, putdat);
f0105b77:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105b7a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105b7e:	89 04 24             	mov    %eax,(%esp)
f0105b81:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105b84:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105b86:	83 eb 01             	sub    $0x1,%ebx
f0105b89:	0f b6 17             	movzbl (%edi),%edx
f0105b8c:	0f be c2             	movsbl %dl,%eax
f0105b8f:	83 c7 01             	add    $0x1,%edi
f0105b92:	85 c0                	test   %eax,%eax
f0105b94:	75 24                	jne    f0105bba <vprintfmt+0x288>
f0105b96:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0105b99:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105b9c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b9f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105ba2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105ba6:	0f 8e ab fd ff ff    	jle    f0105957 <vprintfmt+0x25>
f0105bac:	eb 20                	jmp    f0105bce <vprintfmt+0x29c>
f0105bae:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0105bb1:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0105bb4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0105bb7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105bba:	85 f6                	test   %esi,%esi
f0105bbc:	78 93                	js     f0105b51 <vprintfmt+0x21f>
f0105bbe:	83 ee 01             	sub    $0x1,%esi
f0105bc1:	79 8e                	jns    f0105b51 <vprintfmt+0x21f>
f0105bc3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0105bc6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105bc9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105bcc:	eb d1                	jmp    f0105b9f <vprintfmt+0x26d>
f0105bce:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105bd1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105bd5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105bdc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105bde:	83 ef 01             	sub    $0x1,%edi
f0105be1:	75 ee                	jne    f0105bd1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105be3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105be6:	e9 6c fd ff ff       	jmp    f0105957 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105beb:	83 fa 01             	cmp    $0x1,%edx
f0105bee:	66 90                	xchg   %ax,%ax
f0105bf0:	7e 16                	jle    f0105c08 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
f0105bf2:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bf5:	8d 50 08             	lea    0x8(%eax),%edx
f0105bf8:	89 55 14             	mov    %edx,0x14(%ebp)
f0105bfb:	8b 10                	mov    (%eax),%edx
f0105bfd:	8b 48 04             	mov    0x4(%eax),%ecx
f0105c00:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105c03:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0105c06:	eb 32                	jmp    f0105c3a <vprintfmt+0x308>
	else if (lflag)
f0105c08:	85 d2                	test   %edx,%edx
f0105c0a:	74 18                	je     f0105c24 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
f0105c0c:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c0f:	8d 50 04             	lea    0x4(%eax),%edx
f0105c12:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c15:	8b 00                	mov    (%eax),%eax
f0105c17:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105c1a:	89 c1                	mov    %eax,%ecx
f0105c1c:	c1 f9 1f             	sar    $0x1f,%ecx
f0105c1f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0105c22:	eb 16                	jmp    f0105c3a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
f0105c24:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c27:	8d 50 04             	lea    0x4(%eax),%edx
f0105c2a:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c2d:	8b 00                	mov    (%eax),%eax
f0105c2f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105c32:	89 c7                	mov    %eax,%edi
f0105c34:	c1 ff 1f             	sar    $0x1f,%edi
f0105c37:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105c3a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105c3d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105c40:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105c45:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105c49:	79 7d                	jns    f0105cc8 <vprintfmt+0x396>
				putch('-', putdat);
f0105c4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c4f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105c56:	ff d6                	call   *%esi
				num = -(long long) num;
f0105c58:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105c5b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105c5e:	f7 d8                	neg    %eax
f0105c60:	83 d2 00             	adc    $0x0,%edx
f0105c63:	f7 da                	neg    %edx
			}
			base = 10;
f0105c65:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105c6a:	eb 5c                	jmp    f0105cc8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105c6c:	8d 45 14             	lea    0x14(%ebp),%eax
f0105c6f:	e8 3f fc ff ff       	call   f01058b3 <getuint>
			base = 10;
f0105c74:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105c79:	eb 4d                	jmp    f0105cc8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0105c7b:	8d 45 14             	lea    0x14(%ebp),%eax
f0105c7e:	e8 30 fc ff ff       	call   f01058b3 <getuint>
			base = 8;
f0105c83:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105c88:	eb 3e                	jmp    f0105cc8 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0105c8a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c8e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105c95:	ff d6                	call   *%esi
			putch('x', putdat);
f0105c97:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c9b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105ca2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105ca4:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ca7:	8d 50 04             	lea    0x4(%eax),%edx
f0105caa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105cad:	8b 00                	mov    (%eax),%eax
f0105caf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105cb4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105cb9:	eb 0d                	jmp    f0105cc8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105cbb:	8d 45 14             	lea    0x14(%ebp),%eax
f0105cbe:	e8 f0 fb ff ff       	call   f01058b3 <getuint>
			base = 16;
f0105cc3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105cc8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
f0105ccc:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0105cd0:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0105cd3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105cd7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105cdb:	89 04 24             	mov    %eax,(%esp)
f0105cde:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ce2:	89 da                	mov    %ebx,%edx
f0105ce4:	89 f0                	mov    %esi,%eax
f0105ce6:	e8 d5 fa ff ff       	call   f01057c0 <printnum>
			break;
f0105ceb:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105cee:	e9 64 fc ff ff       	jmp    f0105957 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105cf3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105cf7:	89 0c 24             	mov    %ecx,(%esp)
f0105cfa:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cfc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105cff:	e9 53 fc ff ff       	jmp    f0105957 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105d04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d08:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105d0f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105d11:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105d15:	0f 84 3c fc ff ff    	je     f0105957 <vprintfmt+0x25>
f0105d1b:	83 ef 01             	sub    $0x1,%edi
f0105d1e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105d22:	75 f7                	jne    f0105d1b <vprintfmt+0x3e9>
f0105d24:	e9 2e fc ff ff       	jmp    f0105957 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0105d29:	83 c4 4c             	add    $0x4c,%esp
f0105d2c:	5b                   	pop    %ebx
f0105d2d:	5e                   	pop    %esi
f0105d2e:	5f                   	pop    %edi
f0105d2f:	5d                   	pop    %ebp
f0105d30:	c3                   	ret    

f0105d31 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105d31:	55                   	push   %ebp
f0105d32:	89 e5                	mov    %esp,%ebp
f0105d34:	83 ec 28             	sub    $0x28,%esp
f0105d37:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d3a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105d3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105d40:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105d44:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105d47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105d4e:	85 d2                	test   %edx,%edx
f0105d50:	7e 30                	jle    f0105d82 <vsnprintf+0x51>
f0105d52:	85 c0                	test   %eax,%eax
f0105d54:	74 2c                	je     f0105d82 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105d56:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d59:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d5d:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d60:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d64:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105d67:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d6b:	c7 04 24 ed 58 10 f0 	movl   $0xf01058ed,(%esp)
f0105d72:	e8 bb fb ff ff       	call   f0105932 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105d77:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105d7a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105d80:	eb 05                	jmp    f0105d87 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105d82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105d87:	c9                   	leave  
f0105d88:	c3                   	ret    

f0105d89 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105d89:	55                   	push   %ebp
f0105d8a:	89 e5                	mov    %esp,%ebp
f0105d8c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105d8f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105d92:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d96:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d99:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d9d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105da0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105da4:	8b 45 08             	mov    0x8(%ebp),%eax
f0105da7:	89 04 24             	mov    %eax,(%esp)
f0105daa:	e8 82 ff ff ff       	call   f0105d31 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105daf:	c9                   	leave  
f0105db0:	c3                   	ret    
f0105db1:	66 90                	xchg   %ax,%ax
f0105db3:	66 90                	xchg   %ax,%ax
f0105db5:	66 90                	xchg   %ax,%ax
f0105db7:	66 90                	xchg   %ax,%ax
f0105db9:	66 90                	xchg   %ax,%ax
f0105dbb:	66 90                	xchg   %ax,%ax
f0105dbd:	66 90                	xchg   %ax,%ax
f0105dbf:	90                   	nop

f0105dc0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105dc0:	55                   	push   %ebp
f0105dc1:	89 e5                	mov    %esp,%ebp
f0105dc3:	57                   	push   %edi
f0105dc4:	56                   	push   %esi
f0105dc5:	53                   	push   %ebx
f0105dc6:	83 ec 1c             	sub    $0x1c,%esp
f0105dc9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105dcc:	85 c0                	test   %eax,%eax
f0105dce:	74 10                	je     f0105de0 <readline+0x20>
		cprintf("%s", prompt);
f0105dd0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105dd4:	c7 04 24 39 7f 10 f0 	movl   $0xf0107f39,(%esp)
f0105ddb:	e8 b6 e1 ff ff       	call   f0103f96 <cprintf>

	i = 0;
	echoing = iscons(0);
f0105de0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105de7:	e8 1a aa ff ff       	call   f0100806 <iscons>
f0105dec:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105dee:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105df3:	e8 fd a9 ff ff       	call   f01007f5 <getchar>
f0105df8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105dfa:	85 c0                	test   %eax,%eax
f0105dfc:	79 17                	jns    f0105e15 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105dfe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e02:	c7 04 24 9f 8b 10 f0 	movl   $0xf0108b9f,(%esp)
f0105e09:	e8 88 e1 ff ff       	call   f0103f96 <cprintf>
			return NULL;
f0105e0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e13:	eb 6d                	jmp    f0105e82 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105e15:	83 f8 7f             	cmp    $0x7f,%eax
f0105e18:	74 05                	je     f0105e1f <readline+0x5f>
f0105e1a:	83 f8 08             	cmp    $0x8,%eax
f0105e1d:	75 19                	jne    f0105e38 <readline+0x78>
f0105e1f:	85 f6                	test   %esi,%esi
f0105e21:	7e 15                	jle    f0105e38 <readline+0x78>
			if (echoing)
f0105e23:	85 ff                	test   %edi,%edi
f0105e25:	74 0c                	je     f0105e33 <readline+0x73>
				cputchar('\b');
f0105e27:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105e2e:	e8 b2 a9 ff ff       	call   f01007e5 <cputchar>
			i--;
f0105e33:	83 ee 01             	sub    $0x1,%esi
f0105e36:	eb bb                	jmp    f0105df3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105e38:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105e3e:	7f 1c                	jg     f0105e5c <readline+0x9c>
f0105e40:	83 fb 1f             	cmp    $0x1f,%ebx
f0105e43:	7e 17                	jle    f0105e5c <readline+0x9c>
			if (echoing)
f0105e45:	85 ff                	test   %edi,%edi
f0105e47:	74 08                	je     f0105e51 <readline+0x91>
				cputchar(c);
f0105e49:	89 1c 24             	mov    %ebx,(%esp)
f0105e4c:	e8 94 a9 ff ff       	call   f01007e5 <cputchar>
			buf[i++] = c;
f0105e51:	88 9e 80 6a 1d f0    	mov    %bl,-0xfe29580(%esi)
f0105e57:	83 c6 01             	add    $0x1,%esi
f0105e5a:	eb 97                	jmp    f0105df3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105e5c:	83 fb 0d             	cmp    $0xd,%ebx
f0105e5f:	74 05                	je     f0105e66 <readline+0xa6>
f0105e61:	83 fb 0a             	cmp    $0xa,%ebx
f0105e64:	75 8d                	jne    f0105df3 <readline+0x33>
			if (echoing)
f0105e66:	85 ff                	test   %edi,%edi
f0105e68:	74 0c                	je     f0105e76 <readline+0xb6>
				cputchar('\n');
f0105e6a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105e71:	e8 6f a9 ff ff       	call   f01007e5 <cputchar>
			buf[i] = 0;
f0105e76:	c6 86 80 6a 1d f0 00 	movb   $0x0,-0xfe29580(%esi)
			return buf;
f0105e7d:	b8 80 6a 1d f0       	mov    $0xf01d6a80,%eax
		}
	}
}
f0105e82:	83 c4 1c             	add    $0x1c,%esp
f0105e85:	5b                   	pop    %ebx
f0105e86:	5e                   	pop    %esi
f0105e87:	5f                   	pop    %edi
f0105e88:	5d                   	pop    %ebp
f0105e89:	c3                   	ret    
f0105e8a:	66 90                	xchg   %ax,%ax
f0105e8c:	66 90                	xchg   %ax,%ax
f0105e8e:	66 90                	xchg   %ax,%ax

f0105e90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105e90:	55                   	push   %ebp
f0105e91:	89 e5                	mov    %esp,%ebp
f0105e93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105e96:	80 3a 00             	cmpb   $0x0,(%edx)
f0105e99:	74 10                	je     f0105eab <strlen+0x1b>
f0105e9b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105ea0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105ea3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105ea7:	75 f7                	jne    f0105ea0 <strlen+0x10>
f0105ea9:	eb 05                	jmp    f0105eb0 <strlen+0x20>
f0105eab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105eb0:	5d                   	pop    %ebp
f0105eb1:	c3                   	ret    

f0105eb2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105eb2:	55                   	push   %ebp
f0105eb3:	89 e5                	mov    %esp,%ebp
f0105eb5:	53                   	push   %ebx
f0105eb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105eb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105ebc:	85 c9                	test   %ecx,%ecx
f0105ebe:	74 1c                	je     f0105edc <strnlen+0x2a>
f0105ec0:	80 3b 00             	cmpb   $0x0,(%ebx)
f0105ec3:	74 1e                	je     f0105ee3 <strnlen+0x31>
f0105ec5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0105eca:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105ecc:	39 ca                	cmp    %ecx,%edx
f0105ece:	74 18                	je     f0105ee8 <strnlen+0x36>
f0105ed0:	83 c2 01             	add    $0x1,%edx
f0105ed3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0105ed8:	75 f0                	jne    f0105eca <strnlen+0x18>
f0105eda:	eb 0c                	jmp    f0105ee8 <strnlen+0x36>
f0105edc:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ee1:	eb 05                	jmp    f0105ee8 <strnlen+0x36>
f0105ee3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105ee8:	5b                   	pop    %ebx
f0105ee9:	5d                   	pop    %ebp
f0105eea:	c3                   	ret    

f0105eeb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105eeb:	55                   	push   %ebp
f0105eec:	89 e5                	mov    %esp,%ebp
f0105eee:	53                   	push   %ebx
f0105eef:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ef2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105ef5:	89 c2                	mov    %eax,%edx
f0105ef7:	0f b6 19             	movzbl (%ecx),%ebx
f0105efa:	88 1a                	mov    %bl,(%edx)
f0105efc:	83 c2 01             	add    $0x1,%edx
f0105eff:	83 c1 01             	add    $0x1,%ecx
f0105f02:	84 db                	test   %bl,%bl
f0105f04:	75 f1                	jne    f0105ef7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105f06:	5b                   	pop    %ebx
f0105f07:	5d                   	pop    %ebp
f0105f08:	c3                   	ret    

f0105f09 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105f09:	55                   	push   %ebp
f0105f0a:	89 e5                	mov    %esp,%ebp
f0105f0c:	53                   	push   %ebx
f0105f0d:	83 ec 08             	sub    $0x8,%esp
f0105f10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105f13:	89 1c 24             	mov    %ebx,(%esp)
f0105f16:	e8 75 ff ff ff       	call   f0105e90 <strlen>
	strcpy(dst + len, src);
f0105f1b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f1e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105f22:	01 d8                	add    %ebx,%eax
f0105f24:	89 04 24             	mov    %eax,(%esp)
f0105f27:	e8 bf ff ff ff       	call   f0105eeb <strcpy>
	return dst;
}
f0105f2c:	89 d8                	mov    %ebx,%eax
f0105f2e:	83 c4 08             	add    $0x8,%esp
f0105f31:	5b                   	pop    %ebx
f0105f32:	5d                   	pop    %ebp
f0105f33:	c3                   	ret    

f0105f34 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105f34:	55                   	push   %ebp
f0105f35:	89 e5                	mov    %esp,%ebp
f0105f37:	56                   	push   %esi
f0105f38:	53                   	push   %ebx
f0105f39:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f3c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105f42:	85 db                	test   %ebx,%ebx
f0105f44:	74 16                	je     f0105f5c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
f0105f46:	01 f3                	add    %esi,%ebx
f0105f48:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
f0105f4a:	0f b6 02             	movzbl (%edx),%eax
f0105f4d:	88 01                	mov    %al,(%ecx)
f0105f4f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105f52:	80 3a 01             	cmpb   $0x1,(%edx)
f0105f55:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105f58:	39 d9                	cmp    %ebx,%ecx
f0105f5a:	75 ee                	jne    f0105f4a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105f5c:	89 f0                	mov    %esi,%eax
f0105f5e:	5b                   	pop    %ebx
f0105f5f:	5e                   	pop    %esi
f0105f60:	5d                   	pop    %ebp
f0105f61:	c3                   	ret    

f0105f62 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105f62:	55                   	push   %ebp
f0105f63:	89 e5                	mov    %esp,%ebp
f0105f65:	57                   	push   %edi
f0105f66:	56                   	push   %esi
f0105f67:	53                   	push   %ebx
f0105f68:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105f6e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105f71:	89 f8                	mov    %edi,%eax
f0105f73:	85 f6                	test   %esi,%esi
f0105f75:	74 33                	je     f0105faa <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
f0105f77:	83 fe 01             	cmp    $0x1,%esi
f0105f7a:	74 25                	je     f0105fa1 <strlcpy+0x3f>
f0105f7c:	0f b6 0b             	movzbl (%ebx),%ecx
f0105f7f:	84 c9                	test   %cl,%cl
f0105f81:	74 22                	je     f0105fa5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0105f83:	83 ee 02             	sub    $0x2,%esi
f0105f86:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105f8b:	88 08                	mov    %cl,(%eax)
f0105f8d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105f90:	39 f2                	cmp    %esi,%edx
f0105f92:	74 13                	je     f0105fa7 <strlcpy+0x45>
f0105f94:	83 c2 01             	add    $0x1,%edx
f0105f97:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105f9b:	84 c9                	test   %cl,%cl
f0105f9d:	75 ec                	jne    f0105f8b <strlcpy+0x29>
f0105f9f:	eb 06                	jmp    f0105fa7 <strlcpy+0x45>
f0105fa1:	89 f8                	mov    %edi,%eax
f0105fa3:	eb 02                	jmp    f0105fa7 <strlcpy+0x45>
f0105fa5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105fa7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105faa:	29 f8                	sub    %edi,%eax
}
f0105fac:	5b                   	pop    %ebx
f0105fad:	5e                   	pop    %esi
f0105fae:	5f                   	pop    %edi
f0105faf:	5d                   	pop    %ebp
f0105fb0:	c3                   	ret    

f0105fb1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105fb1:	55                   	push   %ebp
f0105fb2:	89 e5                	mov    %esp,%ebp
f0105fb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105fb7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105fba:	0f b6 01             	movzbl (%ecx),%eax
f0105fbd:	84 c0                	test   %al,%al
f0105fbf:	74 15                	je     f0105fd6 <strcmp+0x25>
f0105fc1:	3a 02                	cmp    (%edx),%al
f0105fc3:	75 11                	jne    f0105fd6 <strcmp+0x25>
		p++, q++;
f0105fc5:	83 c1 01             	add    $0x1,%ecx
f0105fc8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105fcb:	0f b6 01             	movzbl (%ecx),%eax
f0105fce:	84 c0                	test   %al,%al
f0105fd0:	74 04                	je     f0105fd6 <strcmp+0x25>
f0105fd2:	3a 02                	cmp    (%edx),%al
f0105fd4:	74 ef                	je     f0105fc5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105fd6:	0f b6 c0             	movzbl %al,%eax
f0105fd9:	0f b6 12             	movzbl (%edx),%edx
f0105fdc:	29 d0                	sub    %edx,%eax
}
f0105fde:	5d                   	pop    %ebp
f0105fdf:	c3                   	ret    

f0105fe0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105fe0:	55                   	push   %ebp
f0105fe1:	89 e5                	mov    %esp,%ebp
f0105fe3:	56                   	push   %esi
f0105fe4:	53                   	push   %ebx
f0105fe5:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105fe8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105feb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f0105fee:	85 f6                	test   %esi,%esi
f0105ff0:	74 29                	je     f010601b <strncmp+0x3b>
f0105ff2:	0f b6 03             	movzbl (%ebx),%eax
f0105ff5:	84 c0                	test   %al,%al
f0105ff7:	74 30                	je     f0106029 <strncmp+0x49>
f0105ff9:	3a 02                	cmp    (%edx),%al
f0105ffb:	75 2c                	jne    f0106029 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
f0105ffd:	8d 43 01             	lea    0x1(%ebx),%eax
f0106000:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
f0106002:	89 c3                	mov    %eax,%ebx
f0106004:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106007:	39 f0                	cmp    %esi,%eax
f0106009:	74 17                	je     f0106022 <strncmp+0x42>
f010600b:	0f b6 08             	movzbl (%eax),%ecx
f010600e:	84 c9                	test   %cl,%cl
f0106010:	74 17                	je     f0106029 <strncmp+0x49>
f0106012:	83 c0 01             	add    $0x1,%eax
f0106015:	3a 0a                	cmp    (%edx),%cl
f0106017:	74 e9                	je     f0106002 <strncmp+0x22>
f0106019:	eb 0e                	jmp    f0106029 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f010601b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106020:	eb 0f                	jmp    f0106031 <strncmp+0x51>
f0106022:	b8 00 00 00 00       	mov    $0x0,%eax
f0106027:	eb 08                	jmp    f0106031 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106029:	0f b6 03             	movzbl (%ebx),%eax
f010602c:	0f b6 12             	movzbl (%edx),%edx
f010602f:	29 d0                	sub    %edx,%eax
}
f0106031:	5b                   	pop    %ebx
f0106032:	5e                   	pop    %esi
f0106033:	5d                   	pop    %ebp
f0106034:	c3                   	ret    

f0106035 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106035:	55                   	push   %ebp
f0106036:	89 e5                	mov    %esp,%ebp
f0106038:	53                   	push   %ebx
f0106039:	8b 45 08             	mov    0x8(%ebp),%eax
f010603c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f010603f:	0f b6 18             	movzbl (%eax),%ebx
f0106042:	84 db                	test   %bl,%bl
f0106044:	74 1d                	je     f0106063 <strchr+0x2e>
f0106046:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f0106048:	38 d3                	cmp    %dl,%bl
f010604a:	75 06                	jne    f0106052 <strchr+0x1d>
f010604c:	eb 1a                	jmp    f0106068 <strchr+0x33>
f010604e:	38 ca                	cmp    %cl,%dl
f0106050:	74 16                	je     f0106068 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0106052:	83 c0 01             	add    $0x1,%eax
f0106055:	0f b6 10             	movzbl (%eax),%edx
f0106058:	84 d2                	test   %dl,%dl
f010605a:	75 f2                	jne    f010604e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f010605c:	b8 00 00 00 00       	mov    $0x0,%eax
f0106061:	eb 05                	jmp    f0106068 <strchr+0x33>
f0106063:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106068:	5b                   	pop    %ebx
f0106069:	5d                   	pop    %ebp
f010606a:	c3                   	ret    

f010606b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010606b:	55                   	push   %ebp
f010606c:	89 e5                	mov    %esp,%ebp
f010606e:	53                   	push   %ebx
f010606f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106072:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f0106075:	0f b6 18             	movzbl (%eax),%ebx
f0106078:	84 db                	test   %bl,%bl
f010607a:	74 16                	je     f0106092 <strfind+0x27>
f010607c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f010607e:	38 d3                	cmp    %dl,%bl
f0106080:	75 06                	jne    f0106088 <strfind+0x1d>
f0106082:	eb 0e                	jmp    f0106092 <strfind+0x27>
f0106084:	38 ca                	cmp    %cl,%dl
f0106086:	74 0a                	je     f0106092 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0106088:	83 c0 01             	add    $0x1,%eax
f010608b:	0f b6 10             	movzbl (%eax),%edx
f010608e:	84 d2                	test   %dl,%dl
f0106090:	75 f2                	jne    f0106084 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
f0106092:	5b                   	pop    %ebx
f0106093:	5d                   	pop    %ebp
f0106094:	c3                   	ret    

f0106095 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106095:	55                   	push   %ebp
f0106096:	89 e5                	mov    %esp,%ebp
f0106098:	83 ec 0c             	sub    $0xc,%esp
f010609b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010609e:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01060a1:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01060a4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01060a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01060aa:	85 c9                	test   %ecx,%ecx
f01060ac:	74 36                	je     f01060e4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01060ae:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01060b4:	75 28                	jne    f01060de <memset+0x49>
f01060b6:	f6 c1 03             	test   $0x3,%cl
f01060b9:	75 23                	jne    f01060de <memset+0x49>
		c &= 0xFF;
f01060bb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01060bf:	89 d3                	mov    %edx,%ebx
f01060c1:	c1 e3 08             	shl    $0x8,%ebx
f01060c4:	89 d6                	mov    %edx,%esi
f01060c6:	c1 e6 18             	shl    $0x18,%esi
f01060c9:	89 d0                	mov    %edx,%eax
f01060cb:	c1 e0 10             	shl    $0x10,%eax
f01060ce:	09 f0                	or     %esi,%eax
f01060d0:	09 c2                	or     %eax,%edx
f01060d2:	89 d0                	mov    %edx,%eax
f01060d4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01060d6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01060d9:	fc                   	cld    
f01060da:	f3 ab                	rep stos %eax,%es:(%edi)
f01060dc:	eb 06                	jmp    f01060e4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01060de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01060e1:	fc                   	cld    
f01060e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
f01060e4:	89 f8                	mov    %edi,%eax
f01060e6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01060e9:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01060ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01060ef:	89 ec                	mov    %ebp,%esp
f01060f1:	5d                   	pop    %ebp
f01060f2:	c3                   	ret    

f01060f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01060f3:	55                   	push   %ebp
f01060f4:	89 e5                	mov    %esp,%ebp
f01060f6:	83 ec 08             	sub    $0x8,%esp
f01060f9:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01060fc:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01060ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0106102:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106105:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106108:	39 c6                	cmp    %eax,%esi
f010610a:	73 36                	jae    f0106142 <memmove+0x4f>
f010610c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010610f:	39 d0                	cmp    %edx,%eax
f0106111:	73 2f                	jae    f0106142 <memmove+0x4f>
		s += n;
		d += n;
f0106113:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106116:	f6 c2 03             	test   $0x3,%dl
f0106119:	75 1b                	jne    f0106136 <memmove+0x43>
f010611b:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106121:	75 13                	jne    f0106136 <memmove+0x43>
f0106123:	f6 c1 03             	test   $0x3,%cl
f0106126:	75 0e                	jne    f0106136 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106128:	83 ef 04             	sub    $0x4,%edi
f010612b:	8d 72 fc             	lea    -0x4(%edx),%esi
f010612e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0106131:	fd                   	std    
f0106132:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106134:	eb 09                	jmp    f010613f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0106136:	83 ef 01             	sub    $0x1,%edi
f0106139:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010613c:	fd                   	std    
f010613d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010613f:	fc                   	cld    
f0106140:	eb 20                	jmp    f0106162 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106142:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106148:	75 13                	jne    f010615d <memmove+0x6a>
f010614a:	a8 03                	test   $0x3,%al
f010614c:	75 0f                	jne    f010615d <memmove+0x6a>
f010614e:	f6 c1 03             	test   $0x3,%cl
f0106151:	75 0a                	jne    f010615d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0106153:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0106156:	89 c7                	mov    %eax,%edi
f0106158:	fc                   	cld    
f0106159:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010615b:	eb 05                	jmp    f0106162 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010615d:	89 c7                	mov    %eax,%edi
f010615f:	fc                   	cld    
f0106160:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106162:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106165:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106168:	89 ec                	mov    %ebp,%esp
f010616a:	5d                   	pop    %ebp
f010616b:	c3                   	ret    

f010616c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f010616c:	55                   	push   %ebp
f010616d:	89 e5                	mov    %esp,%ebp
f010616f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106172:	8b 45 10             	mov    0x10(%ebp),%eax
f0106175:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106179:	8b 45 0c             	mov    0xc(%ebp),%eax
f010617c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106180:	8b 45 08             	mov    0x8(%ebp),%eax
f0106183:	89 04 24             	mov    %eax,(%esp)
f0106186:	e8 68 ff ff ff       	call   f01060f3 <memmove>
}
f010618b:	c9                   	leave  
f010618c:	c3                   	ret    

f010618d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010618d:	55                   	push   %ebp
f010618e:	89 e5                	mov    %esp,%ebp
f0106190:	57                   	push   %edi
f0106191:	56                   	push   %esi
f0106192:	53                   	push   %ebx
f0106193:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106196:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106199:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010619c:	8d 78 ff             	lea    -0x1(%eax),%edi
f010619f:	85 c0                	test   %eax,%eax
f01061a1:	74 36                	je     f01061d9 <memcmp+0x4c>
		if (*s1 != *s2)
f01061a3:	0f b6 03             	movzbl (%ebx),%eax
f01061a6:	0f b6 0e             	movzbl (%esi),%ecx
f01061a9:	38 c8                	cmp    %cl,%al
f01061ab:	75 17                	jne    f01061c4 <memcmp+0x37>
f01061ad:	ba 00 00 00 00       	mov    $0x0,%edx
f01061b2:	eb 1a                	jmp    f01061ce <memcmp+0x41>
f01061b4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f01061b9:	83 c2 01             	add    $0x1,%edx
f01061bc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01061c0:	38 c8                	cmp    %cl,%al
f01061c2:	74 0a                	je     f01061ce <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f01061c4:	0f b6 c0             	movzbl %al,%eax
f01061c7:	0f b6 c9             	movzbl %cl,%ecx
f01061ca:	29 c8                	sub    %ecx,%eax
f01061cc:	eb 10                	jmp    f01061de <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01061ce:	39 fa                	cmp    %edi,%edx
f01061d0:	75 e2                	jne    f01061b4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01061d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01061d7:	eb 05                	jmp    f01061de <memcmp+0x51>
f01061d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01061de:	5b                   	pop    %ebx
f01061df:	5e                   	pop    %esi
f01061e0:	5f                   	pop    %edi
f01061e1:	5d                   	pop    %ebp
f01061e2:	c3                   	ret    

f01061e3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01061e3:	55                   	push   %ebp
f01061e4:	89 e5                	mov    %esp,%ebp
f01061e6:	53                   	push   %ebx
f01061e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01061ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
f01061ed:	89 c2                	mov    %eax,%edx
f01061ef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01061f2:	39 d0                	cmp    %edx,%eax
f01061f4:	73 13                	jae    f0106209 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
f01061f6:	89 d9                	mov    %ebx,%ecx
f01061f8:	38 18                	cmp    %bl,(%eax)
f01061fa:	75 06                	jne    f0106202 <memfind+0x1f>
f01061fc:	eb 0b                	jmp    f0106209 <memfind+0x26>
f01061fe:	38 08                	cmp    %cl,(%eax)
f0106200:	74 07                	je     f0106209 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106202:	83 c0 01             	add    $0x1,%eax
f0106205:	39 d0                	cmp    %edx,%eax
f0106207:	75 f5                	jne    f01061fe <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106209:	5b                   	pop    %ebx
f010620a:	5d                   	pop    %ebp
f010620b:	c3                   	ret    

f010620c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010620c:	55                   	push   %ebp
f010620d:	89 e5                	mov    %esp,%ebp
f010620f:	57                   	push   %edi
f0106210:	56                   	push   %esi
f0106211:	53                   	push   %ebx
f0106212:	83 ec 04             	sub    $0x4,%esp
f0106215:	8b 55 08             	mov    0x8(%ebp),%edx
f0106218:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010621b:	0f b6 02             	movzbl (%edx),%eax
f010621e:	3c 09                	cmp    $0x9,%al
f0106220:	74 04                	je     f0106226 <strtol+0x1a>
f0106222:	3c 20                	cmp    $0x20,%al
f0106224:	75 0e                	jne    f0106234 <strtol+0x28>
		s++;
f0106226:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106229:	0f b6 02             	movzbl (%edx),%eax
f010622c:	3c 09                	cmp    $0x9,%al
f010622e:	74 f6                	je     f0106226 <strtol+0x1a>
f0106230:	3c 20                	cmp    $0x20,%al
f0106232:	74 f2                	je     f0106226 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106234:	3c 2b                	cmp    $0x2b,%al
f0106236:	75 0a                	jne    f0106242 <strtol+0x36>
		s++;
f0106238:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010623b:	bf 00 00 00 00       	mov    $0x0,%edi
f0106240:	eb 10                	jmp    f0106252 <strtol+0x46>
f0106242:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0106247:	3c 2d                	cmp    $0x2d,%al
f0106249:	75 07                	jne    f0106252 <strtol+0x46>
		s++, neg = 1;
f010624b:	83 c2 01             	add    $0x1,%edx
f010624e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106252:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0106258:	75 15                	jne    f010626f <strtol+0x63>
f010625a:	80 3a 30             	cmpb   $0x30,(%edx)
f010625d:	75 10                	jne    f010626f <strtol+0x63>
f010625f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106263:	75 0a                	jne    f010626f <strtol+0x63>
		s += 2, base = 16;
f0106265:	83 c2 02             	add    $0x2,%edx
f0106268:	bb 10 00 00 00       	mov    $0x10,%ebx
f010626d:	eb 10                	jmp    f010627f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
f010626f:	85 db                	test   %ebx,%ebx
f0106271:	75 0c                	jne    f010627f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106273:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106275:	80 3a 30             	cmpb   $0x30,(%edx)
f0106278:	75 05                	jne    f010627f <strtol+0x73>
		s++, base = 8;
f010627a:	83 c2 01             	add    $0x1,%edx
f010627d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f010627f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106284:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106287:	0f b6 0a             	movzbl (%edx),%ecx
f010628a:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010628d:	89 f3                	mov    %esi,%ebx
f010628f:	80 fb 09             	cmp    $0x9,%bl
f0106292:	77 08                	ja     f010629c <strtol+0x90>
			dig = *s - '0';
f0106294:	0f be c9             	movsbl %cl,%ecx
f0106297:	83 e9 30             	sub    $0x30,%ecx
f010629a:	eb 22                	jmp    f01062be <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
f010629c:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010629f:	89 f3                	mov    %esi,%ebx
f01062a1:	80 fb 19             	cmp    $0x19,%bl
f01062a4:	77 08                	ja     f01062ae <strtol+0xa2>
			dig = *s - 'a' + 10;
f01062a6:	0f be c9             	movsbl %cl,%ecx
f01062a9:	83 e9 57             	sub    $0x57,%ecx
f01062ac:	eb 10                	jmp    f01062be <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
f01062ae:	8d 71 bf             	lea    -0x41(%ecx),%esi
f01062b1:	89 f3                	mov    %esi,%ebx
f01062b3:	80 fb 19             	cmp    $0x19,%bl
f01062b6:	77 16                	ja     f01062ce <strtol+0xc2>
			dig = *s - 'A' + 10;
f01062b8:	0f be c9             	movsbl %cl,%ecx
f01062bb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01062be:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f01062c1:	7d 0f                	jge    f01062d2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f01062c3:	83 c2 01             	add    $0x1,%edx
f01062c6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
f01062ca:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01062cc:	eb b9                	jmp    f0106287 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01062ce:	89 c1                	mov    %eax,%ecx
f01062d0:	eb 02                	jmp    f01062d4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01062d2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01062d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01062d8:	74 05                	je     f01062df <strtol+0xd3>
		*endptr = (char *) s;
f01062da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01062dd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01062df:	89 ca                	mov    %ecx,%edx
f01062e1:	f7 da                	neg    %edx
f01062e3:	85 ff                	test   %edi,%edi
f01062e5:	0f 45 c2             	cmovne %edx,%eax
}
f01062e8:	83 c4 04             	add    $0x4,%esp
f01062eb:	5b                   	pop    %ebx
f01062ec:	5e                   	pop    %esi
f01062ed:	5f                   	pop    %edi
f01062ee:	5d                   	pop    %ebp
f01062ef:	c3                   	ret    

f01062f0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01062f0:	fa                   	cli    

	xorw    %ax, %ax
f01062f1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01062f3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01062f5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01062f7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01062f9:	0f 01 16             	lgdtl  (%esi)
f01062fc:	74 70                	je     f010636e <mpentry_end+0x4>
	movl    %cr0, %eax
f01062fe:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106301:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106305:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106308:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010630e:	08 00                	or     %al,(%eax)

f0106310 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106310:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106314:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106316:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106318:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010631a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010631e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106320:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106322:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0106327:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010632a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f010632d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106332:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in mem_init()
	movl    mpentry_kstack, %esp
f0106335:	8b 25 84 6e 1d f0    	mov    0xf01d6e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010633b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106340:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0106345:	ff d0                	call   *%eax

f0106347 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106347:	eb fe                	jmp    f0106347 <spin>
f0106349:	8d 76 00             	lea    0x0(%esi),%esi

f010634c <gdt>:
	...
f0106354:	ff                   	(bad)  
f0106355:	ff 00                	incl   (%eax)
f0106357:	00 00                	add    %al,(%eax)
f0106359:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106360:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106364 <gdtdesc>:
f0106364:	17                   	pop    %ss
f0106365:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010636a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010636a:	90                   	nop
f010636b:	66 90                	xchg   %ax,%ax
f010636d:	66 90                	xchg   %ax,%ax
f010636f:	90                   	nop

f0106370 <sum>:
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106370:	85 d2                	test   %edx,%edx
f0106372:	7e 1c                	jle    f0106390 <sum+0x20>
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0106374:	55                   	push   %ebp
f0106375:	89 e5                	mov    %esp,%ebp
f0106377:	53                   	push   %ebx
f0106378:	89 c1                	mov    %eax,%ecx
#define MPIOAPIC  0x02  // One per I/O APIC
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
f010637a:	8d 1c 10             	lea    (%eax,%edx,1),%ebx
{
	int i, sum;

	sum = 0;
f010637d:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0106382:	0f b6 11             	movzbl (%ecx),%edx
f0106385:	01 d0                	add    %edx,%eax
f0106387:	83 c1 01             	add    $0x1,%ecx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010638a:	39 d9                	cmp    %ebx,%ecx
f010638c:	75 f4                	jne    f0106382 <sum+0x12>
f010638e:	eb 06                	jmp    f0106396 <sum+0x26>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106390:	b8 00 00 00 00       	mov    $0x0,%eax
f0106395:	c3                   	ret    
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0106396:	5b                   	pop    %ebx
f0106397:	5d                   	pop    %ebp
f0106398:	c3                   	ret    

f0106399 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106399:	55                   	push   %ebp
f010639a:	89 e5                	mov    %esp,%ebp
f010639c:	56                   	push   %esi
f010639d:	53                   	push   %ebx
f010639e:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01063a1:	8b 0d 88 6e 1d f0    	mov    0xf01d6e88,%ecx
f01063a7:	89 c3                	mov    %eax,%ebx
f01063a9:	c1 eb 0c             	shr    $0xc,%ebx
f01063ac:	39 cb                	cmp    %ecx,%ebx
f01063ae:	72 20                	jb     f01063d0 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01063b4:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f01063bb:	f0 
f01063bc:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01063c3:	00 
f01063c4:	c7 04 24 3d 8d 10 f0 	movl   $0xf0108d3d,(%esp)
f01063cb:	e8 70 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01063d0:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01063d6:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01063d9:	89 f0                	mov    %esi,%eax
f01063db:	c1 e8 0c             	shr    $0xc,%eax
f01063de:	39 c1                	cmp    %eax,%ecx
f01063e0:	77 20                	ja     f0106402 <mpsearch1+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01063e6:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f01063ed:	f0 
f01063ee:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01063f5:	00 
f01063f6:	c7 04 24 3d 8d 10 f0 	movl   $0xf0108d3d,(%esp)
f01063fd:	e8 3e 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106402:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106408:	39 f3                	cmp    %esi,%ebx
f010640a:	73 3a                	jae    f0106446 <mpsearch1+0xad>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010640c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106413:	00 
f0106414:	c7 44 24 04 4d 8d 10 	movl   $0xf0108d4d,0x4(%esp)
f010641b:	f0 
f010641c:	89 1c 24             	mov    %ebx,(%esp)
f010641f:	e8 69 fd ff ff       	call   f010618d <memcmp>
f0106424:	85 c0                	test   %eax,%eax
f0106426:	75 10                	jne    f0106438 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0106428:	ba 10 00 00 00       	mov    $0x10,%edx
f010642d:	89 d8                	mov    %ebx,%eax
f010642f:	e8 3c ff ff ff       	call   f0106370 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106434:	84 c0                	test   %al,%al
f0106436:	74 13                	je     f010644b <mpsearch1+0xb2>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106438:	83 c3 10             	add    $0x10,%ebx
f010643b:	39 f3                	cmp    %esi,%ebx
f010643d:	72 cd                	jb     f010640c <mpsearch1+0x73>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010643f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106444:	eb 05                	jmp    f010644b <mpsearch1+0xb2>
f0106446:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010644b:	89 d8                	mov    %ebx,%eax
f010644d:	83 c4 10             	add    $0x10,%esp
f0106450:	5b                   	pop    %ebx
f0106451:	5e                   	pop    %esi
f0106452:	5d                   	pop    %ebp
f0106453:	c3                   	ret    

f0106454 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106454:	55                   	push   %ebp
f0106455:	89 e5                	mov    %esp,%ebp
f0106457:	57                   	push   %edi
f0106458:	56                   	push   %esi
f0106459:	53                   	push   %ebx
f010645a:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010645d:	c7 05 c0 73 1d f0 20 	movl   $0xf01d7020,0xf01d73c0
f0106464:	70 1d f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106467:	83 3d 88 6e 1d f0 00 	cmpl   $0x0,0xf01d6e88
f010646e:	75 24                	jne    f0106494 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106470:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106477:	00 
f0106478:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f010647f:	f0 
f0106480:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106487:	00 
f0106488:	c7 04 24 3d 8d 10 f0 	movl   $0xf0108d3d,(%esp)
f010648f:	e8 ac 9b ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106494:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f010649b:	85 c0                	test   %eax,%eax
f010649d:	74 16                	je     f01064b5 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f010649f:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01064a2:	ba 00 04 00 00       	mov    $0x400,%edx
f01064a7:	e8 ed fe ff ff       	call   f0106399 <mpsearch1>
f01064ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01064af:	85 c0                	test   %eax,%eax
f01064b1:	75 3c                	jne    f01064ef <mp_init+0x9b>
f01064b3:	eb 20                	jmp    f01064d5 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01064b5:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01064bc:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01064bf:	2d 00 04 00 00       	sub    $0x400,%eax
f01064c4:	ba 00 04 00 00       	mov    $0x400,%edx
f01064c9:	e8 cb fe ff ff       	call   f0106399 <mpsearch1>
f01064ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01064d1:	85 c0                	test   %eax,%eax
f01064d3:	75 1a                	jne    f01064ef <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01064d5:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064da:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01064df:	e8 b5 fe ff ff       	call   f0106399 <mpsearch1>
f01064e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01064e7:	85 c0                	test   %eax,%eax
f01064e9:	0f 84 2a 02 00 00    	je     f0106719 <mp_init+0x2c5>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01064ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01064f2:	8b 78 04             	mov    0x4(%eax),%edi
f01064f5:	85 ff                	test   %edi,%edi
f01064f7:	74 06                	je     f01064ff <mp_init+0xab>
f01064f9:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01064fd:	74 11                	je     f0106510 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01064ff:	c7 04 24 b0 8b 10 f0 	movl   $0xf0108bb0,(%esp)
f0106506:	e8 8b da ff ff       	call   f0103f96 <cprintf>
f010650b:	e9 09 02 00 00       	jmp    f0106719 <mp_init+0x2c5>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106510:	89 f8                	mov    %edi,%eax
f0106512:	c1 e8 0c             	shr    $0xc,%eax
f0106515:	3b 05 88 6e 1d f0    	cmp    0xf01d6e88,%eax
f010651b:	72 20                	jb     f010653d <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010651d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106521:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f0106528:	f0 
f0106529:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106530:	00 
f0106531:	c7 04 24 3d 8d 10 f0 	movl   $0xf0108d3d,(%esp)
f0106538:	e8 03 9b ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010653d:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106543:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010654a:	00 
f010654b:	c7 44 24 04 52 8d 10 	movl   $0xf0108d52,0x4(%esp)
f0106552:	f0 
f0106553:	89 3c 24             	mov    %edi,(%esp)
f0106556:	e8 32 fc ff ff       	call   f010618d <memcmp>
f010655b:	85 c0                	test   %eax,%eax
f010655d:	74 11                	je     f0106570 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010655f:	c7 04 24 e0 8b 10 f0 	movl   $0xf0108be0,(%esp)
f0106566:	e8 2b da ff ff       	call   f0103f96 <cprintf>
f010656b:	e9 a9 01 00 00       	jmp    f0106719 <mp_init+0x2c5>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106570:	0f b7 5f 04          	movzwl 0x4(%edi),%ebx
f0106574:	0f b7 d3             	movzwl %bx,%edx
f0106577:	89 f8                	mov    %edi,%eax
f0106579:	e8 f2 fd ff ff       	call   f0106370 <sum>
f010657e:	84 c0                	test   %al,%al
f0106580:	74 11                	je     f0106593 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106582:	c7 04 24 14 8c 10 f0 	movl   $0xf0108c14,(%esp)
f0106589:	e8 08 da ff ff       	call   f0103f96 <cprintf>
f010658e:	e9 86 01 00 00       	jmp    f0106719 <mp_init+0x2c5>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106593:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f0106597:	3c 04                	cmp    $0x4,%al
f0106599:	74 1f                	je     f01065ba <mp_init+0x166>
f010659b:	3c 01                	cmp    $0x1,%al
f010659d:	8d 76 00             	lea    0x0(%esi),%esi
f01065a0:	74 18                	je     f01065ba <mp_init+0x166>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01065a2:	0f b6 c0             	movzbl %al,%eax
f01065a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065a9:	c7 04 24 38 8c 10 f0 	movl   $0xf0108c38,(%esp)
f01065b0:	e8 e1 d9 ff ff       	call   f0103f96 <cprintf>
f01065b5:	e9 5f 01 00 00       	jmp    f0106719 <mp_init+0x2c5>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f01065ba:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f01065be:	0f b7 db             	movzwl %bx,%ebx
f01065c1:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01065c4:	e8 a7 fd ff ff       	call   f0106370 <sum>
f01065c9:	3a 47 2a             	cmp    0x2a(%edi),%al
f01065cc:	74 11                	je     f01065df <mp_init+0x18b>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01065ce:	c7 04 24 58 8c 10 f0 	movl   $0xf0108c58,(%esp)
f01065d5:	e8 bc d9 ff ff       	call   f0103f96 <cprintf>
f01065da:	e9 3a 01 00 00       	jmp    f0106719 <mp_init+0x2c5>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01065df:	85 ff                	test   %edi,%edi
f01065e1:	0f 84 32 01 00 00    	je     f0106719 <mp_init+0x2c5>
		return;
	ismp = 1;
f01065e7:	c7 05 00 70 1d f0 01 	movl   $0x1,0xf01d7000
f01065ee:	00 00 00 
	lapic = (uint32_t *)conf->lapicaddr;
f01065f1:	8b 47 24             	mov    0x24(%edi),%eax
f01065f4:	a3 00 80 21 f0       	mov    %eax,0xf0218000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01065f9:	8d 77 2c             	lea    0x2c(%edi),%esi
f01065fc:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0106601:	0f 84 97 00 00 00    	je     f010669e <mp_init+0x24a>
f0106607:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (*p) {
f010660c:	0f b6 06             	movzbl (%esi),%eax
f010660f:	84 c0                	test   %al,%al
f0106611:	74 06                	je     f0106619 <mp_init+0x1c5>
f0106613:	3c 04                	cmp    $0x4,%al
f0106615:	77 57                	ja     f010666e <mp_init+0x21a>
f0106617:	eb 50                	jmp    f0106669 <mp_init+0x215>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106619:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f010661d:	8d 76 00             	lea    0x0(%esi),%esi
f0106620:	74 11                	je     f0106633 <mp_init+0x1df>
				bootcpu = &cpus[ncpu];
f0106622:	6b 05 c4 73 1d f0 74 	imul   $0x74,0xf01d73c4,%eax
f0106629:	05 20 70 1d f0       	add    $0xf01d7020,%eax
f010662e:	a3 c0 73 1d f0       	mov    %eax,0xf01d73c0
			if (ncpu < NCPU) {
f0106633:	a1 c4 73 1d f0       	mov    0xf01d73c4,%eax
f0106638:	83 f8 07             	cmp    $0x7,%eax
f010663b:	7f 13                	jg     f0106650 <mp_init+0x1fc>
				cpus[ncpu].cpu_id = ncpu;
f010663d:	6b d0 74             	imul   $0x74,%eax,%edx
f0106640:	88 82 20 70 1d f0    	mov    %al,-0xfe28fe0(%edx)
				ncpu++;
f0106646:	83 c0 01             	add    $0x1,%eax
f0106649:	a3 c4 73 1d f0       	mov    %eax,0xf01d73c4
f010664e:	eb 14                	jmp    f0106664 <mp_init+0x210>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106650:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0106654:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106658:	c7 04 24 88 8c 10 f0 	movl   $0xf0108c88,(%esp)
f010665f:	e8 32 d9 ff ff       	call   f0103f96 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106664:	83 c6 14             	add    $0x14,%esi
			continue;
f0106667:	eb 26                	jmp    f010668f <mp_init+0x23b>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106669:	83 c6 08             	add    $0x8,%esi
			continue;
f010666c:	eb 21                	jmp    f010668f <mp_init+0x23b>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010666e:	0f b6 c0             	movzbl %al,%eax
f0106671:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106675:	c7 04 24 b0 8c 10 f0 	movl   $0xf0108cb0,(%esp)
f010667c:	e8 15 d9 ff ff       	call   f0103f96 <cprintf>
			ismp = 0;
f0106681:	c7 05 00 70 1d f0 00 	movl   $0x0,0xf01d7000
f0106688:	00 00 00 
			i = conf->entry;
f010668b:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint32_t *)conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010668f:	83 c3 01             	add    $0x1,%ebx
f0106692:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0106696:	39 d8                	cmp    %ebx,%eax
f0106698:	0f 87 6e ff ff ff    	ja     f010660c <mp_init+0x1b8>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010669e:	a1 c0 73 1d f0       	mov    0xf01d73c0,%eax
f01066a3:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01066aa:	83 3d 00 70 1d f0 00 	cmpl   $0x0,0xf01d7000
f01066b1:	75 22                	jne    f01066d5 <mp_init+0x281>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01066b3:	c7 05 c4 73 1d f0 01 	movl   $0x1,0xf01d73c4
f01066ba:	00 00 00 
		lapic = NULL;
f01066bd:	c7 05 00 80 21 f0 00 	movl   $0x0,0xf0218000
f01066c4:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01066c7:	c7 04 24 d0 8c 10 f0 	movl   $0xf0108cd0,(%esp)
f01066ce:	e8 c3 d8 ff ff       	call   f0103f96 <cprintf>
f01066d3:	eb 44                	jmp    f0106719 <mp_init+0x2c5>
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01066d5:	8b 15 c4 73 1d f0    	mov    0xf01d73c4,%edx
f01066db:	89 54 24 08          	mov    %edx,0x8(%esp)
f01066df:	0f b6 00             	movzbl (%eax),%eax
f01066e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066e6:	c7 04 24 57 8d 10 f0 	movl   $0xf0108d57,(%esp)
f01066ed:	e8 a4 d8 ff ff       	call   f0103f96 <cprintf>

	if (mp->imcrp) {
f01066f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01066f5:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01066f9:	74 1e                	je     f0106719 <mp_init+0x2c5>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01066fb:	c7 04 24 fc 8c 10 f0 	movl   $0xf0108cfc,(%esp)
f0106702:	e8 8f d8 ff ff       	call   f0103f96 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106707:	ba 22 00 00 00       	mov    $0x22,%edx
f010670c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106711:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106712:	b2 23                	mov    $0x23,%dl
f0106714:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106715:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106718:	ee                   	out    %al,(%dx)
	}
}
f0106719:	83 c4 2c             	add    $0x2c,%esp
f010671c:	5b                   	pop    %ebx
f010671d:	5e                   	pop    %esi
f010671e:	5f                   	pop    %edi
f010671f:	5d                   	pop    %ebp
f0106720:	c3                   	ret    
f0106721:	66 90                	xchg   %ax,%ax
f0106723:	90                   	nop

f0106724 <lapicw>:

volatile uint32_t *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
f0106724:	55                   	push   %ebp
f0106725:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106727:	8b 0d 00 80 21 f0    	mov    0xf0218000,%ecx
f010672d:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106730:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106732:	a1 00 80 21 f0       	mov    0xf0218000,%eax
f0106737:	8b 40 20             	mov    0x20(%eax),%eax
}
f010673a:	5d                   	pop    %ebp
f010673b:	c3                   	ret    

f010673c <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010673c:	55                   	push   %ebp
f010673d:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010673f:	a1 00 80 21 f0       	mov    0xf0218000,%eax
f0106744:	85 c0                	test   %eax,%eax
f0106746:	74 08                	je     f0106750 <cpunum+0x14>
		return lapic[ID] >> 24;
f0106748:	8b 40 20             	mov    0x20(%eax),%eax
f010674b:	c1 e8 18             	shr    $0x18,%eax
f010674e:	eb 05                	jmp    f0106755 <cpunum+0x19>
	return 0;
f0106750:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106755:	5d                   	pop    %ebp
f0106756:	c3                   	ret    

f0106757 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapic) 
f0106757:	83 3d 00 80 21 f0 00 	cmpl   $0x0,0xf0218000
f010675e:	0f 84 0b 01 00 00    	je     f010686f <lapic_init+0x118>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106764:	55                   	push   %ebp
f0106765:	89 e5                	mov    %esp,%ebp
	if (!lapic) 
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106767:	ba 27 01 00 00       	mov    $0x127,%edx
f010676c:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106771:	e8 ae ff ff ff       	call   f0106724 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106776:	ba 0b 00 00 00       	mov    $0xb,%edx
f010677b:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106780:	e8 9f ff ff ff       	call   f0106724 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106785:	ba 20 00 02 00       	mov    $0x20020,%edx
f010678a:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010678f:	e8 90 ff ff ff       	call   f0106724 <lapicw>
	lapicw(TICR, 10000000); 
f0106794:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106799:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010679e:	e8 81 ff ff ff       	call   f0106724 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01067a3:	e8 94 ff ff ff       	call   f010673c <cpunum>
f01067a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01067ab:	05 20 70 1d f0       	add    $0xf01d7020,%eax
f01067b0:	39 05 c0 73 1d f0    	cmp    %eax,0xf01d73c0
f01067b6:	74 0f                	je     f01067c7 <lapic_init+0x70>
		lapicw(LINT0, MASKED);
f01067b8:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067bd:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01067c2:	e8 5d ff ff ff       	call   f0106724 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01067c7:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067cc:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01067d1:	e8 4e ff ff ff       	call   f0106724 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01067d6:	a1 00 80 21 f0       	mov    0xf0218000,%eax
f01067db:	8b 40 30             	mov    0x30(%eax),%eax
f01067de:	c1 e8 10             	shr    $0x10,%eax
f01067e1:	3c 03                	cmp    $0x3,%al
f01067e3:	76 0f                	jbe    f01067f4 <lapic_init+0x9d>
		lapicw(PCINT, MASKED);
f01067e5:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067ea:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01067ef:	e8 30 ff ff ff       	call   f0106724 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01067f4:	ba 33 00 00 00       	mov    $0x33,%edx
f01067f9:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01067fe:	e8 21 ff ff ff       	call   f0106724 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106803:	ba 00 00 00 00       	mov    $0x0,%edx
f0106808:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010680d:	e8 12 ff ff ff       	call   f0106724 <lapicw>
	lapicw(ESR, 0);
f0106812:	ba 00 00 00 00       	mov    $0x0,%edx
f0106817:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010681c:	e8 03 ff ff ff       	call   f0106724 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106821:	ba 00 00 00 00       	mov    $0x0,%edx
f0106826:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010682b:	e8 f4 fe ff ff       	call   f0106724 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106830:	ba 00 00 00 00       	mov    $0x0,%edx
f0106835:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010683a:	e8 e5 fe ff ff       	call   f0106724 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010683f:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106844:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106849:	e8 d6 fe ff ff       	call   f0106724 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010684e:	8b 15 00 80 21 f0    	mov    0xf0218000,%edx
f0106854:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010685a:	f6 c4 10             	test   $0x10,%ah
f010685d:	75 f5                	jne    f0106854 <lapic_init+0xfd>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010685f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106864:	b8 20 00 00 00       	mov    $0x20,%eax
f0106869:	e8 b6 fe ff ff       	call   f0106724 <lapicw>
}
f010686e:	5d                   	pop    %ebp
f010686f:	f3 c3                	repz ret 

f0106871 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106871:	83 3d 00 80 21 f0 00 	cmpl   $0x0,0xf0218000
f0106878:	74 13                	je     f010688d <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010687a:	55                   	push   %ebp
f010687b:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f010687d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106882:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106887:	e8 98 fe ff ff       	call   f0106724 <lapicw>
}
f010688c:	5d                   	pop    %ebp
f010688d:	f3 c3                	repz ret 

f010688f <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010688f:	55                   	push   %ebp
f0106890:	89 e5                	mov    %esp,%ebp
f0106892:	56                   	push   %esi
f0106893:	53                   	push   %ebx
f0106894:	83 ec 10             	sub    $0x10,%esp
f0106897:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010689a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010689d:	ba 70 00 00 00       	mov    $0x70,%edx
f01068a2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01068a7:	ee                   	out    %al,(%dx)
f01068a8:	b2 71                	mov    $0x71,%dl
f01068aa:	b8 0a 00 00 00       	mov    $0xa,%eax
f01068af:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01068b0:	83 3d 88 6e 1d f0 00 	cmpl   $0x0,0xf01d6e88
f01068b7:	75 24                	jne    f01068dd <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01068b9:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01068c0:	00 
f01068c1:	c7 44 24 08 e8 6e 10 	movl   $0xf0106ee8,0x8(%esp)
f01068c8:	f0 
f01068c9:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f01068d0:	00 
f01068d1:	c7 04 24 74 8d 10 f0 	movl   $0xf0108d74,(%esp)
f01068d8:	e8 63 97 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01068dd:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01068e4:	00 00 
	wrv[1] = addr >> 4;
f01068e6:	89 f0                	mov    %esi,%eax
f01068e8:	c1 e8 04             	shr    $0x4,%eax
f01068eb:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01068f1:	c1 e3 18             	shl    $0x18,%ebx
f01068f4:	89 da                	mov    %ebx,%edx
f01068f6:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01068fb:	e8 24 fe ff ff       	call   f0106724 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106900:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106905:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010690a:	e8 15 fe ff ff       	call   f0106724 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010690f:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106914:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106919:	e8 06 fe ff ff       	call   f0106724 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010691e:	c1 ee 0c             	shr    $0xc,%esi
f0106921:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106927:	89 da                	mov    %ebx,%edx
f0106929:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010692e:	e8 f1 fd ff ff       	call   f0106724 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106933:	89 f2                	mov    %esi,%edx
f0106935:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010693a:	e8 e5 fd ff ff       	call   f0106724 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010693f:	89 da                	mov    %ebx,%edx
f0106941:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106946:	e8 d9 fd ff ff       	call   f0106724 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010694b:	89 f2                	mov    %esi,%edx
f010694d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106952:	e8 cd fd ff ff       	call   f0106724 <lapicw>
		microdelay(200);
	}
}
f0106957:	83 c4 10             	add    $0x10,%esp
f010695a:	5b                   	pop    %ebx
f010695b:	5e                   	pop    %esi
f010695c:	5d                   	pop    %ebp
f010695d:	c3                   	ret    

f010695e <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010695e:	55                   	push   %ebp
f010695f:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106961:	8b 55 08             	mov    0x8(%ebp),%edx
f0106964:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010696a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010696f:	e8 b0 fd ff ff       	call   f0106724 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106974:	8b 15 00 80 21 f0    	mov    0xf0218000,%edx
f010697a:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106980:	f6 c4 10             	test   $0x10,%ah
f0106983:	75 f5                	jne    f010697a <lapic_ipi+0x1c>
		;
}
f0106985:	5d                   	pop    %ebp
f0106986:	c3                   	ret    
f0106987:	90                   	nop

f0106988 <holding>:

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106988:	83 38 00             	cmpl   $0x0,(%eax)
f010698b:	74 21                	je     f01069ae <holding+0x26>
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f010698d:	55                   	push   %ebp
f010698e:	89 e5                	mov    %esp,%ebp
f0106990:	53                   	push   %ebx
f0106991:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0106994:	8b 58 08             	mov    0x8(%eax),%ebx
f0106997:	e8 a0 fd ff ff       	call   f010673c <cpunum>
f010699c:	6b c0 74             	imul   $0x74,%eax,%eax
f010699f:	05 20 70 1d f0       	add    $0xf01d7020,%eax
f01069a4:	39 c3                	cmp    %eax,%ebx
f01069a6:	0f 94 c0             	sete   %al
f01069a9:	0f b6 c0             	movzbl %al,%eax
f01069ac:	eb 06                	jmp    f01069b4 <holding+0x2c>
f01069ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01069b3:	c3                   	ret    
}
f01069b4:	83 c4 04             	add    $0x4,%esp
f01069b7:	5b                   	pop    %ebx
f01069b8:	5d                   	pop    %ebp
f01069b9:	c3                   	ret    

f01069ba <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01069ba:	55                   	push   %ebp
f01069bb:	89 e5                	mov    %esp,%ebp
f01069bd:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01069c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01069c6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01069c9:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01069cc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01069d3:	5d                   	pop    %ebp
f01069d4:	c3                   	ret    

f01069d5 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01069d5:	55                   	push   %ebp
f01069d6:	89 e5                	mov    %esp,%ebp
f01069d8:	53                   	push   %ebx
f01069d9:	83 ec 24             	sub    $0x24,%esp
f01069dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01069df:	89 d8                	mov    %ebx,%eax
f01069e1:	e8 a2 ff ff ff       	call   f0106988 <holding>
f01069e6:	85 c0                	test   %eax,%eax
f01069e8:	75 12                	jne    f01069fc <spin_lock+0x27>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01069ea:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01069ec:	b0 01                	mov    $0x1,%al
f01069ee:	f0 87 03             	lock xchg %eax,(%ebx)
f01069f1:	b9 01 00 00 00       	mov    $0x1,%ecx
f01069f6:	85 c0                	test   %eax,%eax
f01069f8:	75 2e                	jne    f0106a28 <spin_lock+0x53>
f01069fa:	eb 37                	jmp    f0106a33 <spin_lock+0x5e>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01069fc:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01069ff:	e8 38 fd ff ff       	call   f010673c <cpunum>
f0106a04:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106a08:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106a0c:	c7 44 24 08 84 8d 10 	movl   $0xf0108d84,0x8(%esp)
f0106a13:	f0 
f0106a14:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
f0106a1b:	00 
f0106a1c:	c7 04 24 e8 8d 10 f0 	movl   $0xf0108de8,(%esp)
f0106a23:	e8 18 96 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106a28:	f3 90                	pause  
f0106a2a:	89 c8                	mov    %ecx,%eax
f0106a2c:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106a2f:	85 c0                	test   %eax,%eax
f0106a31:	75 f5                	jne    f0106a28 <spin_lock+0x53>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106a33:	e8 04 fd ff ff       	call   f010673c <cpunum>
f0106a38:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a3b:	05 20 70 1d f0       	add    $0xf01d7020,%eax
f0106a40:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106a43:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0106a46:	89 e8                	mov    %ebp,%eax
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
		    || ebp >= (uint32_t *)IOMEMBASE)
f0106a48:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0106a4e:	81 fa ff ff 7f 0e    	cmp    $0xe7fffff,%edx
f0106a54:	76 3a                	jbe    f0106a90 <spin_lock+0xbb>
f0106a56:	eb 31                	jmp    f0106a89 <spin_lock+0xb4>
		    || ebp >= (uint32_t *)IOMEMBASE)
f0106a58:	8d 9a 00 00 80 10    	lea    0x10800000(%edx),%ebx
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0106a5e:	81 fb ff ff 7f 0e    	cmp    $0xe7fffff,%ebx
f0106a64:	77 12                	ja     f0106a78 <spin_lock+0xa3>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106a66:	8b 5a 04             	mov    0x4(%edx),%ebx
f0106a69:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106a6c:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106a6e:	83 c0 01             	add    $0x1,%eax
f0106a71:	83 f8 0a             	cmp    $0xa,%eax
f0106a74:	75 e2                	jne    f0106a58 <spin_lock+0x83>
f0106a76:	eb 27                	jmp    f0106a9f <spin_lock+0xca>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106a78:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106a7f:	83 c0 01             	add    $0x1,%eax
f0106a82:	83 f8 09             	cmp    $0x9,%eax
f0106a85:	7e f1                	jle    f0106a78 <spin_lock+0xa3>
f0106a87:	eb 16                	jmp    f0106a9f <spin_lock+0xca>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106a89:	b8 00 00 00 00       	mov    $0x0,%eax
f0106a8e:	eb e8                	jmp    f0106a78 <spin_lock+0xa3>
		if (ebp == 0 || ebp < (uint32_t *)ULIM
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106a90:	8b 50 04             	mov    0x4(%eax),%edx
f0106a93:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106a96:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106a98:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a9d:	eb b9                	jmp    f0106a58 <spin_lock+0x83>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106a9f:	83 c4 24             	add    $0x24,%esp
f0106aa2:	5b                   	pop    %ebx
f0106aa3:	5d                   	pop    %ebp
f0106aa4:	c3                   	ret    

f0106aa5 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106aa5:	55                   	push   %ebp
f0106aa6:	89 e5                	mov    %esp,%ebp
f0106aa8:	83 ec 78             	sub    $0x78,%esp
f0106aab:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0106aae:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0106ab1:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106ab4:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106ab7:	89 d8                	mov    %ebx,%eax
f0106ab9:	e8 ca fe ff ff       	call   f0106988 <holding>
f0106abe:	85 c0                	test   %eax,%eax
f0106ac0:	0f 85 d4 00 00 00    	jne    f0106b9a <spin_unlock+0xf5>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106ac6:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106acd:	00 
f0106ace:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ad5:	8d 45 c0             	lea    -0x40(%ebp),%eax
f0106ad8:	89 04 24             	mov    %eax,(%esp)
f0106adb:	e8 13 f6 ff ff       	call   f01060f3 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106ae0:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106ae3:	0f b6 30             	movzbl (%eax),%esi
f0106ae6:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106ae9:	e8 4e fc ff ff       	call   f010673c <cpunum>
f0106aee:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106af2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106af6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106afa:	c7 04 24 b0 8d 10 f0 	movl   $0xf0108db0,(%esp)
f0106b01:	e8 90 d4 ff ff       	call   f0103f96 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106b06:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0106b09:	85 c0                	test   %eax,%eax
f0106b0b:	74 71                	je     f0106b7e <spin_unlock+0xd9>
f0106b0d:	8d 5d c0             	lea    -0x40(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106b10:	8d 7d e4             	lea    -0x1c(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106b13:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0106b16:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106b1a:	89 04 24             	mov    %eax,(%esp)
f0106b1d:	e8 24 ea ff ff       	call   f0105546 <debuginfo_eip>
f0106b22:	85 c0                	test   %eax,%eax
f0106b24:	78 39                	js     f0106b5f <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106b26:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106b28:	89 c2                	mov    %eax,%edx
f0106b2a:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106b2d:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106b31:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0106b34:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106b38:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106b3b:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106b3f:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0106b42:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106b46:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106b49:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b51:	c7 04 24 f8 8d 10 f0 	movl   $0xf0108df8,(%esp)
f0106b58:	e8 39 d4 ff ff       	call   f0103f96 <cprintf>
f0106b5d:	eb 12                	jmp    f0106b71 <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106b5f:	8b 03                	mov    (%ebx),%eax
f0106b61:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b65:	c7 04 24 0f 8e 10 f0 	movl   $0xf0108e0f,(%esp)
f0106b6c:	e8 25 d4 ff ff       	call   f0103f96 <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106b71:	39 fb                	cmp    %edi,%ebx
f0106b73:	74 09                	je     f0106b7e <spin_unlock+0xd9>
f0106b75:	83 c3 04             	add    $0x4,%ebx
f0106b78:	8b 03                	mov    (%ebx),%eax
f0106b7a:	85 c0                	test   %eax,%eax
f0106b7c:	75 98                	jne    f0106b16 <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106b7e:	c7 44 24 08 17 8e 10 	movl   $0xf0108e17,0x8(%esp)
f0106b85:	f0 
f0106b86:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
f0106b8d:	00 
f0106b8e:	c7 04 24 e8 8d 10 f0 	movl   $0xf0108de8,(%esp)
f0106b95:	e8 a6 94 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106b9a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106ba1:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106ba8:	b8 00 00 00 00       	mov    $0x0,%eax
f0106bad:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106bb0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106bb3:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106bb6:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106bb9:	89 ec                	mov    %ebp,%esp
f0106bbb:	5d                   	pop    %ebp
f0106bbc:	c3                   	ret    
f0106bbd:	66 90                	xchg   %ax,%ax
f0106bbf:	90                   	nop

f0106bc0 <__udivdi3>:
f0106bc0:	83 ec 1c             	sub    $0x1c,%esp
f0106bc3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0106bc7:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106bcb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106bcf:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0106bd3:	8b 7c 24 20          	mov    0x20(%esp),%edi
f0106bd7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
f0106bdb:	85 c0                	test   %eax,%eax
f0106bdd:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106be1:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106be5:	89 ea                	mov    %ebp,%edx
f0106be7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106beb:	75 33                	jne    f0106c20 <__udivdi3+0x60>
f0106bed:	39 e9                	cmp    %ebp,%ecx
f0106bef:	77 6f                	ja     f0106c60 <__udivdi3+0xa0>
f0106bf1:	85 c9                	test   %ecx,%ecx
f0106bf3:	89 ce                	mov    %ecx,%esi
f0106bf5:	75 0b                	jne    f0106c02 <__udivdi3+0x42>
f0106bf7:	b8 01 00 00 00       	mov    $0x1,%eax
f0106bfc:	31 d2                	xor    %edx,%edx
f0106bfe:	f7 f1                	div    %ecx
f0106c00:	89 c6                	mov    %eax,%esi
f0106c02:	31 d2                	xor    %edx,%edx
f0106c04:	89 e8                	mov    %ebp,%eax
f0106c06:	f7 f6                	div    %esi
f0106c08:	89 c5                	mov    %eax,%ebp
f0106c0a:	89 f8                	mov    %edi,%eax
f0106c0c:	f7 f6                	div    %esi
f0106c0e:	89 ea                	mov    %ebp,%edx
f0106c10:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106c14:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106c18:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106c1c:	83 c4 1c             	add    $0x1c,%esp
f0106c1f:	c3                   	ret    
f0106c20:	39 e8                	cmp    %ebp,%eax
f0106c22:	77 24                	ja     f0106c48 <__udivdi3+0x88>
f0106c24:	0f bd c8             	bsr    %eax,%ecx
f0106c27:	83 f1 1f             	xor    $0x1f,%ecx
f0106c2a:	89 0c 24             	mov    %ecx,(%esp)
f0106c2d:	75 49                	jne    f0106c78 <__udivdi3+0xb8>
f0106c2f:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106c33:	39 74 24 04          	cmp    %esi,0x4(%esp)
f0106c37:	0f 86 ab 00 00 00    	jbe    f0106ce8 <__udivdi3+0x128>
f0106c3d:	39 e8                	cmp    %ebp,%eax
f0106c3f:	0f 82 a3 00 00 00    	jb     f0106ce8 <__udivdi3+0x128>
f0106c45:	8d 76 00             	lea    0x0(%esi),%esi
f0106c48:	31 d2                	xor    %edx,%edx
f0106c4a:	31 c0                	xor    %eax,%eax
f0106c4c:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106c50:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106c54:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106c58:	83 c4 1c             	add    $0x1c,%esp
f0106c5b:	c3                   	ret    
f0106c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106c60:	89 f8                	mov    %edi,%eax
f0106c62:	f7 f1                	div    %ecx
f0106c64:	31 d2                	xor    %edx,%edx
f0106c66:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106c6a:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106c6e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106c72:	83 c4 1c             	add    $0x1c,%esp
f0106c75:	c3                   	ret    
f0106c76:	66 90                	xchg   %ax,%ax
f0106c78:	0f b6 0c 24          	movzbl (%esp),%ecx
f0106c7c:	89 c6                	mov    %eax,%esi
f0106c7e:	b8 20 00 00 00       	mov    $0x20,%eax
f0106c83:	8b 6c 24 04          	mov    0x4(%esp),%ebp
f0106c87:	2b 04 24             	sub    (%esp),%eax
f0106c8a:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106c8e:	d3 e6                	shl    %cl,%esi
f0106c90:	89 c1                	mov    %eax,%ecx
f0106c92:	d3 ed                	shr    %cl,%ebp
f0106c94:	0f b6 0c 24          	movzbl (%esp),%ecx
f0106c98:	09 f5                	or     %esi,%ebp
f0106c9a:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106c9e:	d3 e6                	shl    %cl,%esi
f0106ca0:	89 c1                	mov    %eax,%ecx
f0106ca2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106ca6:	89 d6                	mov    %edx,%esi
f0106ca8:	d3 ee                	shr    %cl,%esi
f0106caa:	0f b6 0c 24          	movzbl (%esp),%ecx
f0106cae:	d3 e2                	shl    %cl,%edx
f0106cb0:	89 c1                	mov    %eax,%ecx
f0106cb2:	d3 ef                	shr    %cl,%edi
f0106cb4:	09 d7                	or     %edx,%edi
f0106cb6:	89 f2                	mov    %esi,%edx
f0106cb8:	89 f8                	mov    %edi,%eax
f0106cba:	f7 f5                	div    %ebp
f0106cbc:	89 d6                	mov    %edx,%esi
f0106cbe:	89 c7                	mov    %eax,%edi
f0106cc0:	f7 64 24 04          	mull   0x4(%esp)
f0106cc4:	39 d6                	cmp    %edx,%esi
f0106cc6:	72 30                	jb     f0106cf8 <__udivdi3+0x138>
f0106cc8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0106ccc:	0f b6 0c 24          	movzbl (%esp),%ecx
f0106cd0:	d3 e5                	shl    %cl,%ebp
f0106cd2:	39 c5                	cmp    %eax,%ebp
f0106cd4:	73 04                	jae    f0106cda <__udivdi3+0x11a>
f0106cd6:	39 d6                	cmp    %edx,%esi
f0106cd8:	74 1e                	je     f0106cf8 <__udivdi3+0x138>
f0106cda:	89 f8                	mov    %edi,%eax
f0106cdc:	31 d2                	xor    %edx,%edx
f0106cde:	e9 69 ff ff ff       	jmp    f0106c4c <__udivdi3+0x8c>
f0106ce3:	90                   	nop
f0106ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106ce8:	31 d2                	xor    %edx,%edx
f0106cea:	b8 01 00 00 00       	mov    $0x1,%eax
f0106cef:	e9 58 ff ff ff       	jmp    f0106c4c <__udivdi3+0x8c>
f0106cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106cf8:	8d 47 ff             	lea    -0x1(%edi),%eax
f0106cfb:	31 d2                	xor    %edx,%edx
f0106cfd:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106d01:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106d05:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106d09:	83 c4 1c             	add    $0x1c,%esp
f0106d0c:	c3                   	ret    
f0106d0d:	66 90                	xchg   %ax,%ax
f0106d0f:	90                   	nop

f0106d10 <__umoddi3>:
f0106d10:	83 ec 2c             	sub    $0x2c,%esp
f0106d13:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0106d17:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0106d1b:	89 74 24 20          	mov    %esi,0x20(%esp)
f0106d1f:	8b 74 24 38          	mov    0x38(%esp),%esi
f0106d23:	89 7c 24 24          	mov    %edi,0x24(%esp)
f0106d27:	8b 7c 24 34          	mov    0x34(%esp),%edi
f0106d2b:	85 c0                	test   %eax,%eax
f0106d2d:	89 c2                	mov    %eax,%edx
f0106d2f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
f0106d33:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f0106d37:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106d3b:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106d3f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0106d43:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0106d47:	75 1f                	jne    f0106d68 <__umoddi3+0x58>
f0106d49:	39 fe                	cmp    %edi,%esi
f0106d4b:	76 63                	jbe    f0106db0 <__umoddi3+0xa0>
f0106d4d:	89 c8                	mov    %ecx,%eax
f0106d4f:	89 fa                	mov    %edi,%edx
f0106d51:	f7 f6                	div    %esi
f0106d53:	89 d0                	mov    %edx,%eax
f0106d55:	31 d2                	xor    %edx,%edx
f0106d57:	8b 74 24 20          	mov    0x20(%esp),%esi
f0106d5b:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0106d5f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f0106d63:	83 c4 2c             	add    $0x2c,%esp
f0106d66:	c3                   	ret    
f0106d67:	90                   	nop
f0106d68:	39 f8                	cmp    %edi,%eax
f0106d6a:	77 64                	ja     f0106dd0 <__umoddi3+0xc0>
f0106d6c:	0f bd e8             	bsr    %eax,%ebp
f0106d6f:	83 f5 1f             	xor    $0x1f,%ebp
f0106d72:	75 74                	jne    f0106de8 <__umoddi3+0xd8>
f0106d74:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106d78:	39 7c 24 10          	cmp    %edi,0x10(%esp)
f0106d7c:	0f 87 0e 01 00 00    	ja     f0106e90 <__umoddi3+0x180>
f0106d82:	8b 7c 24 0c          	mov    0xc(%esp),%edi
f0106d86:	29 f1                	sub    %esi,%ecx
f0106d88:	19 c7                	sbb    %eax,%edi
f0106d8a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0106d8e:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0106d92:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106d96:	8b 54 24 18          	mov    0x18(%esp),%edx
f0106d9a:	8b 74 24 20          	mov    0x20(%esp),%esi
f0106d9e:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0106da2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f0106da6:	83 c4 2c             	add    $0x2c,%esp
f0106da9:	c3                   	ret    
f0106daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106db0:	85 f6                	test   %esi,%esi
f0106db2:	89 f5                	mov    %esi,%ebp
f0106db4:	75 0b                	jne    f0106dc1 <__umoddi3+0xb1>
f0106db6:	b8 01 00 00 00       	mov    $0x1,%eax
f0106dbb:	31 d2                	xor    %edx,%edx
f0106dbd:	f7 f6                	div    %esi
f0106dbf:	89 c5                	mov    %eax,%ebp
f0106dc1:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106dc5:	31 d2                	xor    %edx,%edx
f0106dc7:	f7 f5                	div    %ebp
f0106dc9:	89 c8                	mov    %ecx,%eax
f0106dcb:	f7 f5                	div    %ebp
f0106dcd:	eb 84                	jmp    f0106d53 <__umoddi3+0x43>
f0106dcf:	90                   	nop
f0106dd0:	89 c8                	mov    %ecx,%eax
f0106dd2:	89 fa                	mov    %edi,%edx
f0106dd4:	8b 74 24 20          	mov    0x20(%esp),%esi
f0106dd8:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0106ddc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f0106de0:	83 c4 2c             	add    $0x2c,%esp
f0106de3:	c3                   	ret    
f0106de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106de8:	8b 44 24 10          	mov    0x10(%esp),%eax
f0106dec:	be 20 00 00 00       	mov    $0x20,%esi
f0106df1:	89 e9                	mov    %ebp,%ecx
f0106df3:	29 ee                	sub    %ebp,%esi
f0106df5:	d3 e2                	shl    %cl,%edx
f0106df7:	89 f1                	mov    %esi,%ecx
f0106df9:	d3 e8                	shr    %cl,%eax
f0106dfb:	89 e9                	mov    %ebp,%ecx
f0106dfd:	09 d0                	or     %edx,%eax
f0106dff:	89 fa                	mov    %edi,%edx
f0106e01:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106e05:	8b 44 24 10          	mov    0x10(%esp),%eax
f0106e09:	d3 e0                	shl    %cl,%eax
f0106e0b:	89 f1                	mov    %esi,%ecx
f0106e0d:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106e11:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0106e15:	d3 ea                	shr    %cl,%edx
f0106e17:	89 e9                	mov    %ebp,%ecx
f0106e19:	d3 e7                	shl    %cl,%edi
f0106e1b:	89 f1                	mov    %esi,%ecx
f0106e1d:	d3 e8                	shr    %cl,%eax
f0106e1f:	89 e9                	mov    %ebp,%ecx
f0106e21:	09 f8                	or     %edi,%eax
f0106e23:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0106e27:	f7 74 24 0c          	divl   0xc(%esp)
f0106e2b:	d3 e7                	shl    %cl,%edi
f0106e2d:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0106e31:	89 d7                	mov    %edx,%edi
f0106e33:	f7 64 24 10          	mull   0x10(%esp)
f0106e37:	39 d7                	cmp    %edx,%edi
f0106e39:	89 c1                	mov    %eax,%ecx
f0106e3b:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106e3f:	72 3b                	jb     f0106e7c <__umoddi3+0x16c>
f0106e41:	39 44 24 18          	cmp    %eax,0x18(%esp)
f0106e45:	72 31                	jb     f0106e78 <__umoddi3+0x168>
f0106e47:	8b 44 24 18          	mov    0x18(%esp),%eax
f0106e4b:	29 c8                	sub    %ecx,%eax
f0106e4d:	19 d7                	sbb    %edx,%edi
f0106e4f:	89 e9                	mov    %ebp,%ecx
f0106e51:	89 fa                	mov    %edi,%edx
f0106e53:	d3 e8                	shr    %cl,%eax
f0106e55:	89 f1                	mov    %esi,%ecx
f0106e57:	d3 e2                	shl    %cl,%edx
f0106e59:	89 e9                	mov    %ebp,%ecx
f0106e5b:	09 d0                	or     %edx,%eax
f0106e5d:	89 fa                	mov    %edi,%edx
f0106e5f:	d3 ea                	shr    %cl,%edx
f0106e61:	8b 74 24 20          	mov    0x20(%esp),%esi
f0106e65:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0106e69:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f0106e6d:	83 c4 2c             	add    $0x2c,%esp
f0106e70:	c3                   	ret    
f0106e71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106e78:	39 d7                	cmp    %edx,%edi
f0106e7a:	75 cb                	jne    f0106e47 <__umoddi3+0x137>
f0106e7c:	8b 54 24 14          	mov    0x14(%esp),%edx
f0106e80:	89 c1                	mov    %eax,%ecx
f0106e82:	2b 4c 24 10          	sub    0x10(%esp),%ecx
f0106e86:	1b 54 24 0c          	sbb    0xc(%esp),%edx
f0106e8a:	eb bb                	jmp    f0106e47 <__umoddi3+0x137>
f0106e8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106e90:	3b 44 24 18          	cmp    0x18(%esp),%eax
f0106e94:	0f 82 e8 fe ff ff    	jb     f0106d82 <__umoddi3+0x72>
f0106e9a:	e9 f3 fe ff ff       	jmp    f0106d92 <__umoddi3+0x82>
