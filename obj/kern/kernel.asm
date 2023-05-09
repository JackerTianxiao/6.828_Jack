
obj/kern/kernel：     文件格式 elf32-i386


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
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 e0 18 10 f0       	push   $0xf01018e0
f0100050:	e8 2e 09 00 00       	call   f0100983 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7f 27                	jg     f0100083 <test_backtrace+0x43>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010005c:	83 ec 04             	sub    $0x4,%esp
f010005f:	6a 00                	push   $0x0
f0100061:	6a 00                	push   $0x0
f0100063:	6a 00                	push   $0x0
f0100065:	e8 29 07 00 00       	call   f0100793 <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 fc 18 10 f0       	push   $0xf01018fc
f0100076:	e8 08 09 00 00       	call   f0100983 <cprintf>
}
f010007b:	83 c4 10             	add    $0x10,%esp
f010007e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100081:	c9                   	leave  
f0100082:	c3                   	ret    
		test_backtrace(x-1);
f0100083:	83 ec 0c             	sub    $0xc,%esp
f0100086:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100089:	50                   	push   %eax
f010008a:	e8 b1 ff ff ff       	call   f0100040 <test_backtrace>
f010008f:	83 c4 10             	add    $0x10,%esp
f0100092:	eb d9                	jmp    f010006d <test_backtrace+0x2d>

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 d7 13 00 00       	call   f0101488 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 b5 04 00 00       	call   f010056b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 17 19 10 f0       	push   $0xf0101917
f01000c3:	e8 bb 08 00 00       	call   f0100983 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 36 07 00 00       	call   f0100817 <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000f5:	74 0f                	je     f0100106 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 16 07 00 00       	call   f0100817 <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <_panic+0x11>
	panicstr = fmt;
f0100106:	89 35 40 29 11 f0    	mov    %esi,0xf0112940
	asm volatile("cli; cld");
f010010c:	fa                   	cli    
f010010d:	fc                   	cld    
	va_start(ap, fmt);
f010010e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100111:	83 ec 04             	sub    $0x4,%esp
f0100114:	ff 75 0c             	pushl  0xc(%ebp)
f0100117:	ff 75 08             	pushl  0x8(%ebp)
f010011a:	68 32 19 10 f0       	push   $0xf0101932
f010011f:	e8 5f 08 00 00       	call   f0100983 <cprintf>
	vcprintf(fmt, ap);
f0100124:	83 c4 08             	add    $0x8,%esp
f0100127:	53                   	push   %ebx
f0100128:	56                   	push   %esi
f0100129:	e8 2f 08 00 00       	call   f010095d <vcprintf>
	cprintf("\n");
f010012e:	c7 04 24 6e 19 10 f0 	movl   $0xf010196e,(%esp)
f0100135:	e8 49 08 00 00       	call   f0100983 <cprintf>
f010013a:	83 c4 10             	add    $0x10,%esp
f010013d:	eb b8                	jmp    f01000f7 <_panic+0x11>

f010013f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013f:	55                   	push   %ebp
f0100140:	89 e5                	mov    %esp,%ebp
f0100142:	53                   	push   %ebx
f0100143:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100146:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100149:	ff 75 0c             	pushl  0xc(%ebp)
f010014c:	ff 75 08             	pushl  0x8(%ebp)
f010014f:	68 4a 19 10 f0       	push   $0xf010194a
f0100154:	e8 2a 08 00 00       	call   f0100983 <cprintf>
	vcprintf(fmt, ap);
f0100159:	83 c4 08             	add    $0x8,%esp
f010015c:	53                   	push   %ebx
f010015d:	ff 75 10             	pushl  0x10(%ebp)
f0100160:	e8 f8 07 00 00       	call   f010095d <vcprintf>
	cprintf("\n");
f0100165:	c7 04 24 6e 19 10 f0 	movl   $0xf010196e,(%esp)
f010016c:	e8 12 08 00 00       	call   f0100983 <cprintf>
	va_end(ap);
}
f0100171:	83 c4 10             	add    $0x10,%esp
f0100174:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100177:	c9                   	leave  
f0100178:	c3                   	ret    

f0100179 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100179:	55                   	push   %ebp
f010017a:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100181:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100182:	a8 01                	test   $0x1,%al
f0100184:	74 0b                	je     f0100191 <serial_proc_data+0x18>
f0100186:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010018b:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018c:	0f b6 c0             	movzbl %al,%eax
}
f010018f:	5d                   	pop    %ebp
f0100190:	c3                   	ret    
		return -1;
f0100191:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100196:	eb f7                	jmp    f010018f <serial_proc_data+0x16>

f0100198 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100198:	55                   	push   %ebp
f0100199:	89 e5                	mov    %esp,%ebp
f010019b:	53                   	push   %ebx
f010019c:	83 ec 04             	sub    $0x4,%esp
f010019f:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001a1:	ff d3                	call   *%ebx
f01001a3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001a6:	74 2d                	je     f01001d5 <cons_intr+0x3d>
		if (c == 0)
f01001a8:	85 c0                	test   %eax,%eax
f01001aa:	74 f5                	je     f01001a1 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01001ac:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001b2:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b5:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001bb:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001c1:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c7:	75 d8                	jne    f01001a1 <cons_intr+0x9>
			cons.wpos = 0;
f01001c9:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001d0:	00 00 00 
f01001d3:	eb cc                	jmp    f01001a1 <cons_intr+0x9>
	}
}
f01001d5:	83 c4 04             	add    $0x4,%esp
f01001d8:	5b                   	pop    %ebx
f01001d9:	5d                   	pop    %ebp
f01001da:	c3                   	ret    

f01001db <kbd_proc_data>:
{
f01001db:	55                   	push   %ebp
f01001dc:	89 e5                	mov    %esp,%ebp
f01001de:	53                   	push   %ebx
f01001df:	83 ec 04             	sub    $0x4,%esp
f01001e2:	ba 64 00 00 00       	mov    $0x64,%edx
f01001e7:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001e8:	a8 01                	test   $0x1,%al
f01001ea:	0f 84 fa 00 00 00    	je     f01002ea <kbd_proc_data+0x10f>
	if (stat & KBS_TERR)
f01001f0:	a8 20                	test   $0x20,%al
f01001f2:	0f 85 f9 00 00 00    	jne    f01002f1 <kbd_proc_data+0x116>
f01001f8:	ba 60 00 00 00       	mov    $0x60,%edx
f01001fd:	ec                   	in     (%dx),%al
f01001fe:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100200:	3c e0                	cmp    $0xe0,%al
f0100202:	0f 84 8e 00 00 00    	je     f0100296 <kbd_proc_data+0xbb>
	} else if (data & 0x80) {
f0100208:	84 c0                	test   %al,%al
f010020a:	0f 88 99 00 00 00    	js     f01002a9 <kbd_proc_data+0xce>
	} else if (shift & E0ESC) {
f0100210:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100216:	f6 c1 40             	test   $0x40,%cl
f0100219:	74 0e                	je     f0100229 <kbd_proc_data+0x4e>
		data |= 0x80;
f010021b:	83 c8 80             	or     $0xffffff80,%eax
f010021e:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100220:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100223:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	shift |= shiftcode[data];
f0100229:	0f b6 d2             	movzbl %dl,%edx
f010022c:	0f b6 82 c0 1a 10 f0 	movzbl -0xfefe540(%edx),%eax
f0100233:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f0100239:	0f b6 8a c0 19 10 f0 	movzbl -0xfefe640(%edx),%ecx
f0100240:	31 c8                	xor    %ecx,%eax
f0100242:	a3 00 23 11 f0       	mov    %eax,0xf0112300
	c = charcode[shift & (CTL | SHIFT)][data];
f0100247:	89 c1                	mov    %eax,%ecx
f0100249:	83 e1 03             	and    $0x3,%ecx
f010024c:	8b 0c 8d a0 19 10 f0 	mov    -0xfefe660(,%ecx,4),%ecx
f0100253:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100257:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010025a:	a8 08                	test   $0x8,%al
f010025c:	74 0d                	je     f010026b <kbd_proc_data+0x90>
		if ('a' <= c && c <= 'z')
f010025e:	89 da                	mov    %ebx,%edx
f0100260:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100263:	83 f9 19             	cmp    $0x19,%ecx
f0100266:	77 74                	ja     f01002dc <kbd_proc_data+0x101>
			c += 'A' - 'a';
f0100268:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010026b:	f7 d0                	not    %eax
f010026d:	a8 06                	test   $0x6,%al
f010026f:	75 31                	jne    f01002a2 <kbd_proc_data+0xc7>
f0100271:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100277:	75 29                	jne    f01002a2 <kbd_proc_data+0xc7>
		cprintf("Rebooting!\n");
f0100279:	83 ec 0c             	sub    $0xc,%esp
f010027c:	68 64 19 10 f0       	push   $0xf0101964
f0100281:	e8 fd 06 00 00       	call   f0100983 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100286:	b8 03 00 00 00       	mov    $0x3,%eax
f010028b:	ba 92 00 00 00       	mov    $0x92,%edx
f0100290:	ee                   	out    %al,(%dx)
f0100291:	83 c4 10             	add    $0x10,%esp
f0100294:	eb 0c                	jmp    f01002a2 <kbd_proc_data+0xc7>
		shift |= E0ESC;
f0100296:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f010029d:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01002a2:	89 d8                	mov    %ebx,%eax
f01002a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002a7:	c9                   	leave  
f01002a8:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002a9:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f01002af:	89 cb                	mov    %ecx,%ebx
f01002b1:	83 e3 40             	and    $0x40,%ebx
f01002b4:	83 e0 7f             	and    $0x7f,%eax
f01002b7:	85 db                	test   %ebx,%ebx
f01002b9:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002bc:	0f b6 d2             	movzbl %dl,%edx
f01002bf:	0f b6 82 c0 1a 10 f0 	movzbl -0xfefe540(%edx),%eax
f01002c6:	83 c8 40             	or     $0x40,%eax
f01002c9:	0f b6 c0             	movzbl %al,%eax
f01002cc:	f7 d0                	not    %eax
f01002ce:	21 c8                	and    %ecx,%eax
f01002d0:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f01002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002da:	eb c6                	jmp    f01002a2 <kbd_proc_data+0xc7>
		else if ('A' <= c && c <= 'Z')
f01002dc:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002df:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002e2:	83 fa 1a             	cmp    $0x1a,%edx
f01002e5:	0f 42 d9             	cmovb  %ecx,%ebx
f01002e8:	eb 81                	jmp    f010026b <kbd_proc_data+0x90>
		return -1;
f01002ea:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01002ef:	eb b1                	jmp    f01002a2 <kbd_proc_data+0xc7>
		return -1;
f01002f1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01002f6:	eb aa                	jmp    f01002a2 <kbd_proc_data+0xc7>

f01002f8 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f8:	55                   	push   %ebp
f01002f9:	89 e5                	mov    %esp,%ebp
f01002fb:	57                   	push   %edi
f01002fc:	56                   	push   %esi
f01002fd:	53                   	push   %ebx
f01002fe:	83 ec 1c             	sub    $0x1c,%esp
f0100301:	89 c7                	mov    %eax,%edi
	for (i = 0;
f0100303:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100308:	be fd 03 00 00       	mov    $0x3fd,%esi
f010030d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100312:	eb 09                	jmp    f010031d <cons_putc+0x25>
f0100314:	89 ca                	mov    %ecx,%edx
f0100316:	ec                   	in     (%dx),%al
f0100317:	ec                   	in     (%dx),%al
f0100318:	ec                   	in     (%dx),%al
f0100319:	ec                   	in     (%dx),%al
	     i++)
f010031a:	83 c3 01             	add    $0x1,%ebx
f010031d:	89 f2                	mov    %esi,%edx
f010031f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100320:	a8 20                	test   $0x20,%al
f0100322:	75 08                	jne    f010032c <cons_putc+0x34>
f0100324:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010032a:	7e e8                	jle    f0100314 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f010032c:	89 f8                	mov    %edi,%eax
f010032e:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100331:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100336:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100337:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010033c:	be 79 03 00 00       	mov    $0x379,%esi
f0100341:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100346:	eb 09                	jmp    f0100351 <cons_putc+0x59>
f0100348:	89 ca                	mov    %ecx,%edx
f010034a:	ec                   	in     (%dx),%al
f010034b:	ec                   	in     (%dx),%al
f010034c:	ec                   	in     (%dx),%al
f010034d:	ec                   	in     (%dx),%al
f010034e:	83 c3 01             	add    $0x1,%ebx
f0100351:	89 f2                	mov    %esi,%edx
f0100353:	ec                   	in     (%dx),%al
f0100354:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010035a:	7f 04                	jg     f0100360 <cons_putc+0x68>
f010035c:	84 c0                	test   %al,%al
f010035e:	79 e8                	jns    f0100348 <cons_putc+0x50>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100360:	ba 78 03 00 00       	mov    $0x378,%edx
f0100365:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100369:	ee                   	out    %al,(%dx)
f010036a:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010036f:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100374:	ee                   	out    %al,(%dx)
f0100375:	b8 08 00 00 00       	mov    $0x8,%eax
f010037a:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f010037b:	89 fa                	mov    %edi,%edx
f010037d:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100383:	89 f8                	mov    %edi,%eax
f0100385:	80 cc 07             	or     $0x7,%ah
f0100388:	85 d2                	test   %edx,%edx
f010038a:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f010038d:	89 f8                	mov    %edi,%eax
f010038f:	0f b6 c0             	movzbl %al,%eax
f0100392:	83 f8 09             	cmp    $0x9,%eax
f0100395:	0f 84 b6 00 00 00    	je     f0100451 <cons_putc+0x159>
f010039b:	83 f8 09             	cmp    $0x9,%eax
f010039e:	7e 73                	jle    f0100413 <cons_putc+0x11b>
f01003a0:	83 f8 0a             	cmp    $0xa,%eax
f01003a3:	0f 84 9b 00 00 00    	je     f0100444 <cons_putc+0x14c>
f01003a9:	83 f8 0d             	cmp    $0xd,%eax
f01003ac:	0f 85 d6 00 00 00    	jne    f0100488 <cons_putc+0x190>
		crt_pos -= (crt_pos % CRT_COLS);
f01003b2:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003b9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003bf:	c1 e8 16             	shr    $0x16,%eax
f01003c2:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003c5:	c1 e0 04             	shl    $0x4,%eax
f01003c8:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
	if (crt_pos >= CRT_SIZE) {
f01003ce:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f01003d5:	cf 07 
f01003d7:	0f 87 ce 00 00 00    	ja     f01004ab <cons_putc+0x1b3>
	outb(addr_6845, 14);
f01003dd:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01003e3:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003e8:	89 ca                	mov    %ecx,%edx
f01003ea:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003eb:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01003f2:	8d 71 01             	lea    0x1(%ecx),%esi
f01003f5:	89 d8                	mov    %ebx,%eax
f01003f7:	66 c1 e8 08          	shr    $0x8,%ax
f01003fb:	89 f2                	mov    %esi,%edx
f01003fd:	ee                   	out    %al,(%dx)
f01003fe:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100403:	89 ca                	mov    %ecx,%edx
f0100405:	ee                   	out    %al,(%dx)
f0100406:	89 d8                	mov    %ebx,%eax
f0100408:	89 f2                	mov    %esi,%edx
f010040a:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010040b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010040e:	5b                   	pop    %ebx
f010040f:	5e                   	pop    %esi
f0100410:	5f                   	pop    %edi
f0100411:	5d                   	pop    %ebp
f0100412:	c3                   	ret    
	switch (c & 0xff) {
f0100413:	83 f8 08             	cmp    $0x8,%eax
f0100416:	75 70                	jne    f0100488 <cons_putc+0x190>
		if (crt_pos > 0) {
f0100418:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010041f:	66 85 c0             	test   %ax,%ax
f0100422:	74 b9                	je     f01003dd <cons_putc+0xe5>
			crt_pos--;
f0100424:	83 e8 01             	sub    $0x1,%eax
f0100427:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010042d:	0f b7 c0             	movzwl %ax,%eax
f0100430:	66 81 e7 00 ff       	and    $0xff00,%di
f0100435:	83 cf 20             	or     $0x20,%edi
f0100438:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f010043e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100442:	eb 8a                	jmp    f01003ce <cons_putc+0xd6>
		crt_pos += CRT_COLS;
f0100444:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f010044b:	50 
f010044c:	e9 61 ff ff ff       	jmp    f01003b2 <cons_putc+0xba>
		cons_putc(' ');
f0100451:	b8 20 00 00 00       	mov    $0x20,%eax
f0100456:	e8 9d fe ff ff       	call   f01002f8 <cons_putc>
		cons_putc(' ');
f010045b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100460:	e8 93 fe ff ff       	call   f01002f8 <cons_putc>
		cons_putc(' ');
f0100465:	b8 20 00 00 00       	mov    $0x20,%eax
f010046a:	e8 89 fe ff ff       	call   f01002f8 <cons_putc>
		cons_putc(' ');
f010046f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100474:	e8 7f fe ff ff       	call   f01002f8 <cons_putc>
		cons_putc(' ');
f0100479:	b8 20 00 00 00       	mov    $0x20,%eax
f010047e:	e8 75 fe ff ff       	call   f01002f8 <cons_putc>
f0100483:	e9 46 ff ff ff       	jmp    f01003ce <cons_putc+0xd6>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100488:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010048f:	8d 50 01             	lea    0x1(%eax),%edx
f0100492:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f0100499:	0f b7 c0             	movzwl %ax,%eax
f010049c:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01004a2:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004a6:	e9 23 ff ff ff       	jmp    f01003ce <cons_putc+0xd6>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004ab:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f01004b0:	83 ec 04             	sub    $0x4,%esp
f01004b3:	68 00 0f 00 00       	push   $0xf00
f01004b8:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004be:	52                   	push   %edx
f01004bf:	50                   	push   %eax
f01004c0:	e8 10 10 00 00       	call   f01014d5 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004c5:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01004cb:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004d1:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004d7:	83 c4 10             	add    $0x10,%esp
f01004da:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004df:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004e2:	39 d0                	cmp    %edx,%eax
f01004e4:	75 f4                	jne    f01004da <cons_putc+0x1e2>
		crt_pos -= CRT_COLS;
f01004e6:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004ed:	50 
f01004ee:	e9 ea fe ff ff       	jmp    f01003dd <cons_putc+0xe5>

f01004f3 <serial_intr>:
	if (serial_exists)
f01004f3:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004fa:	75 02                	jne    f01004fe <serial_intr+0xb>
f01004fc:	f3 c3                	repz ret 
{
f01004fe:	55                   	push   %ebp
f01004ff:	89 e5                	mov    %esp,%ebp
f0100501:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100504:	b8 79 01 10 f0       	mov    $0xf0100179,%eax
f0100509:	e8 8a fc ff ff       	call   f0100198 <cons_intr>
}
f010050e:	c9                   	leave  
f010050f:	c3                   	ret    

f0100510 <kbd_intr>:
{
f0100510:	55                   	push   %ebp
f0100511:	89 e5                	mov    %esp,%ebp
f0100513:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100516:	b8 db 01 10 f0       	mov    $0xf01001db,%eax
f010051b:	e8 78 fc ff ff       	call   f0100198 <cons_intr>
}
f0100520:	c9                   	leave  
f0100521:	c3                   	ret    

f0100522 <cons_getc>:
{
f0100522:	55                   	push   %ebp
f0100523:	89 e5                	mov    %esp,%ebp
f0100525:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100528:	e8 c6 ff ff ff       	call   f01004f3 <serial_intr>
	kbd_intr();
f010052d:	e8 de ff ff ff       	call   f0100510 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100532:	8b 15 20 25 11 f0    	mov    0xf0112520,%edx
	return 0;
f0100538:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f010053d:	3b 15 24 25 11 f0    	cmp    0xf0112524,%edx
f0100543:	74 18                	je     f010055d <cons_getc+0x3b>
		c = cons.buf[cons.rpos++];
f0100545:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100548:	89 0d 20 25 11 f0    	mov    %ecx,0xf0112520
f010054e:	0f b6 82 20 23 11 f0 	movzbl -0xfeedce0(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100555:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f010055b:	74 02                	je     f010055f <cons_getc+0x3d>
}
f010055d:	c9                   	leave  
f010055e:	c3                   	ret    
			cons.rpos = 0;
f010055f:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100566:	00 00 00 
f0100569:	eb f2                	jmp    f010055d <cons_getc+0x3b>

f010056b <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010056b:	55                   	push   %ebp
f010056c:	89 e5                	mov    %esp,%ebp
f010056e:	57                   	push   %edi
f010056f:	56                   	push   %esi
f0100570:	53                   	push   %ebx
f0100571:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100574:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010057b:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100582:	5a a5 
	if (*cp != 0xA55A) {
f0100584:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010058b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010058f:	0f 84 b7 00 00 00    	je     f010064c <cons_init+0xe1>
		addr_6845 = MONO_BASE;
f0100595:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f010059c:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010059f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01005a4:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005aa:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005af:	89 fa                	mov    %edi,%edx
f01005b1:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005b2:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b5:	89 ca                	mov    %ecx,%edx
f01005b7:	ec                   	in     (%dx),%al
f01005b8:	0f b6 c0             	movzbl %al,%eax
f01005bb:	c1 e0 08             	shl    $0x8,%eax
f01005be:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c0:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005c5:	89 fa                	mov    %edi,%edx
f01005c7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c8:	89 ca                	mov    %ecx,%edx
f01005ca:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01005cb:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	pos |= inb(addr_6845 + 1);
f01005d1:	0f b6 c0             	movzbl %al,%eax
f01005d4:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01005d6:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005dc:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005e1:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01005e6:	89 d8                	mov    %ebx,%eax
f01005e8:	89 ca                	mov    %ecx,%edx
f01005ea:	ee                   	out    %al,(%dx)
f01005eb:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01005f0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005f5:	89 fa                	mov    %edi,%edx
f01005f7:	ee                   	out    %al,(%dx)
f01005f8:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005fd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100602:	ee                   	out    %al,(%dx)
f0100603:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100608:	89 d8                	mov    %ebx,%eax
f010060a:	89 f2                	mov    %esi,%edx
f010060c:	ee                   	out    %al,(%dx)
f010060d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100612:	89 fa                	mov    %edi,%edx
f0100614:	ee                   	out    %al,(%dx)
f0100615:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010061a:	89 d8                	mov    %ebx,%eax
f010061c:	ee                   	out    %al,(%dx)
f010061d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100622:	89 f2                	mov    %esi,%edx
f0100624:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100625:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010062a:	ec                   	in     (%dx),%al
f010062b:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010062d:	3c ff                	cmp    $0xff,%al
f010062f:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100636:	89 ca                	mov    %ecx,%edx
f0100638:	ec                   	in     (%dx),%al
f0100639:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010063e:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010063f:	80 fb ff             	cmp    $0xff,%bl
f0100642:	74 23                	je     f0100667 <cons_init+0xfc>
		cprintf("Serial port does not exist!\n");
}
f0100644:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100647:	5b                   	pop    %ebx
f0100648:	5e                   	pop    %esi
f0100649:	5f                   	pop    %edi
f010064a:	5d                   	pop    %ebp
f010064b:	c3                   	ret    
		*cp = was;
f010064c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100653:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f010065a:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010065d:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100662:	e9 3d ff ff ff       	jmp    f01005a4 <cons_init+0x39>
		cprintf("Serial port does not exist!\n");
f0100667:	83 ec 0c             	sub    $0xc,%esp
f010066a:	68 70 19 10 f0       	push   $0xf0101970
f010066f:	e8 0f 03 00 00       	call   f0100983 <cprintf>
f0100674:	83 c4 10             	add    $0x10,%esp
}
f0100677:	eb cb                	jmp    f0100644 <cons_init+0xd9>

f0100679 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100679:	55                   	push   %ebp
f010067a:	89 e5                	mov    %esp,%ebp
f010067c:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010067f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100682:	e8 71 fc ff ff       	call   f01002f8 <cons_putc>
}
f0100687:	c9                   	leave  
f0100688:	c3                   	ret    

f0100689 <getchar>:

int
getchar(void)
{
f0100689:	55                   	push   %ebp
f010068a:	89 e5                	mov    %esp,%ebp
f010068c:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010068f:	e8 8e fe ff ff       	call   f0100522 <cons_getc>
f0100694:	85 c0                	test   %eax,%eax
f0100696:	74 f7                	je     f010068f <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100698:	c9                   	leave  
f0100699:	c3                   	ret    

f010069a <iscons>:

int
iscons(int fdnum)
{
f010069a:	55                   	push   %ebp
f010069b:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010069d:	b8 01 00 00 00       	mov    $0x1,%eax
f01006a2:	5d                   	pop    %ebp
f01006a3:	c3                   	ret    

f01006a4 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006a4:	55                   	push   %ebp
f01006a5:	89 e5                	mov    %esp,%ebp
f01006a7:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006aa:	68 c0 1b 10 f0       	push   $0xf0101bc0
f01006af:	68 de 1b 10 f0       	push   $0xf0101bde
f01006b4:	68 e3 1b 10 f0       	push   $0xf0101be3
f01006b9:	e8 c5 02 00 00       	call   f0100983 <cprintf>
f01006be:	83 c4 0c             	add    $0xc,%esp
f01006c1:	68 78 1c 10 f0       	push   $0xf0101c78
f01006c6:	68 ec 1b 10 f0       	push   $0xf0101bec
f01006cb:	68 e3 1b 10 f0       	push   $0xf0101be3
f01006d0:	e8 ae 02 00 00       	call   f0100983 <cprintf>
f01006d5:	83 c4 0c             	add    $0xc,%esp
f01006d8:	68 a0 1c 10 f0       	push   $0xf0101ca0
f01006dd:	68 f5 1b 10 f0       	push   $0xf0101bf5
f01006e2:	68 e3 1b 10 f0       	push   $0xf0101be3
f01006e7:	e8 97 02 00 00       	call   f0100983 <cprintf>
	return 0;
}
f01006ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01006f1:	c9                   	leave  
f01006f2:	c3                   	ret    

f01006f3 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006f3:	55                   	push   %ebp
f01006f4:	89 e5                	mov    %esp,%ebp
f01006f6:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006f9:	68 ff 1b 10 f0       	push   $0xf0101bff
f01006fe:	e8 80 02 00 00       	call   f0100983 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100703:	83 c4 08             	add    $0x8,%esp
f0100706:	68 0c 00 10 00       	push   $0x10000c
f010070b:	68 c8 1c 10 f0       	push   $0xf0101cc8
f0100710:	e8 6e 02 00 00       	call   f0100983 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100715:	83 c4 0c             	add    $0xc,%esp
f0100718:	68 0c 00 10 00       	push   $0x10000c
f010071d:	68 0c 00 10 f0       	push   $0xf010000c
f0100722:	68 f0 1c 10 f0       	push   $0xf0101cf0
f0100727:	e8 57 02 00 00       	call   f0100983 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010072c:	83 c4 0c             	add    $0xc,%esp
f010072f:	68 c9 18 10 00       	push   $0x1018c9
f0100734:	68 c9 18 10 f0       	push   $0xf01018c9
f0100739:	68 14 1d 10 f0       	push   $0xf0101d14
f010073e:	e8 40 02 00 00       	call   f0100983 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100743:	83 c4 0c             	add    $0xc,%esp
f0100746:	68 00 23 11 00       	push   $0x112300
f010074b:	68 00 23 11 f0       	push   $0xf0112300
f0100750:	68 38 1d 10 f0       	push   $0xf0101d38
f0100755:	e8 29 02 00 00       	call   f0100983 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010075a:	83 c4 0c             	add    $0xc,%esp
f010075d:	68 44 29 11 00       	push   $0x112944
f0100762:	68 44 29 11 f0       	push   $0xf0112944
f0100767:	68 5c 1d 10 f0       	push   $0xf0101d5c
f010076c:	e8 12 02 00 00       	call   f0100983 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100771:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100774:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100779:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010077e:	c1 f8 0a             	sar    $0xa,%eax
f0100781:	50                   	push   %eax
f0100782:	68 80 1d 10 f0       	push   $0xf0101d80
f0100787:	e8 f7 01 00 00       	call   f0100983 <cprintf>
	return 0;
}
f010078c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100791:	c9                   	leave  
f0100792:	c3                   	ret    

f0100793 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100793:	55                   	push   %ebp
f0100794:	89 e5                	mov    %esp,%ebp
f0100796:	57                   	push   %edi
f0100797:	56                   	push   %esi
f0100798:	53                   	push   %ebx
f0100799:	83 ec 38             	sub    $0x38,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010079c:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t *ebp = (uint32_t *)read_ebp();
	//__asm__("movl %%ebp, %0" : "=r" (ebp)  内联汇编实现
	cprintf("Stack backtrace:\n");
f010079e:	68 18 1c 10 f0       	push   $0xf0101c18
f01007a3:	e8 db 01 00 00       	call   f0100983 <cprintf>
	// circle -> back
	
	for(;ebp!=0;ebp=(uint32_t*)(*ebp)){
f01007a8:	83 c4 10             	add    $0x10,%esp
		uint32_t eip = *(ebp+1);
		cprintf(" ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp,eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6));
		if(debuginfo_eip(eip, &info)==0){
f01007ab:	8d 7d d0             	lea    -0x30(%ebp),%edi
	for(;ebp!=0;ebp=(uint32_t*)(*ebp)){
f01007ae:	eb 02                	jmp    f01007b2 <mon_backtrace+0x1f>
f01007b0:	8b 1b                	mov    (%ebx),%ebx
f01007b2:	85 db                	test   %ebx,%ebx
f01007b4:	74 54                	je     f010080a <mon_backtrace+0x77>
		uint32_t eip = *(ebp+1);
f01007b6:	8b 73 04             	mov    0x4(%ebx),%esi
		cprintf(" ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp,eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6));
f01007b9:	ff 73 18             	pushl  0x18(%ebx)
f01007bc:	ff 73 14             	pushl  0x14(%ebx)
f01007bf:	ff 73 10             	pushl  0x10(%ebx)
f01007c2:	ff 73 0c             	pushl  0xc(%ebx)
f01007c5:	ff 73 08             	pushl  0x8(%ebx)
f01007c8:	56                   	push   %esi
f01007c9:	53                   	push   %ebx
f01007ca:	68 ac 1d 10 f0       	push   $0xf0101dac
f01007cf:	e8 af 01 00 00       	call   f0100983 <cprintf>
		if(debuginfo_eip(eip, &info)==0){
f01007d4:	83 c4 18             	add    $0x18,%esp
f01007d7:	57                   	push   %edi
f01007d8:	56                   	push   %esi
f01007d9:	e8 a9 02 00 00       	call   f0100a87 <debuginfo_eip>
f01007de:	83 c4 10             	add    $0x10,%esp
f01007e1:	85 c0                	test   %eax,%eax
f01007e3:	75 cb                	jne    f01007b0 <mon_backtrace+0x1d>
			cprintf(" %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *(ebp+1)-info.eip_fn_addr);
f01007e5:	83 ec 08             	sub    $0x8,%esp
f01007e8:	8b 43 04             	mov    0x4(%ebx),%eax
f01007eb:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01007ee:	50                   	push   %eax
f01007ef:	ff 75 d8             	pushl  -0x28(%ebp)
f01007f2:	ff 75 dc             	pushl  -0x24(%ebp)
f01007f5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007f8:	ff 75 d0             	pushl  -0x30(%ebp)
f01007fb:	68 2a 1c 10 f0       	push   $0xf0101c2a
f0100800:	e8 7e 01 00 00       	call   f0100983 <cprintf>
f0100805:	83 c4 20             	add    $0x20,%esp
f0100808:	eb a6                	jmp    f01007b0 <mon_backtrace+0x1d>
		}
	}
	return 0;
}
f010080a:	b8 00 00 00 00       	mov    $0x0,%eax
f010080f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100812:	5b                   	pop    %ebx
f0100813:	5e                   	pop    %esi
f0100814:	5f                   	pop    %edi
f0100815:	5d                   	pop    %ebp
f0100816:	c3                   	ret    

f0100817 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100817:	55                   	push   %ebp
f0100818:	89 e5                	mov    %esp,%ebp
f010081a:	57                   	push   %edi
f010081b:	56                   	push   %esi
f010081c:	53                   	push   %ebx
f010081d:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100820:	68 e0 1d 10 f0       	push   $0xf0101de0
f0100825:	e8 59 01 00 00       	call   f0100983 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010082a:	c7 04 24 04 1e 10 f0 	movl   $0xf0101e04,(%esp)
f0100831:	e8 4d 01 00 00       	call   f0100983 <cprintf>
f0100836:	83 c4 10             	add    $0x10,%esp
f0100839:	eb 47                	jmp    f0100882 <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f010083b:	83 ec 08             	sub    $0x8,%esp
f010083e:	0f be c0             	movsbl %al,%eax
f0100841:	50                   	push   %eax
f0100842:	68 3f 1c 10 f0       	push   $0xf0101c3f
f0100847:	e8 ff 0b 00 00       	call   f010144b <strchr>
f010084c:	83 c4 10             	add    $0x10,%esp
f010084f:	85 c0                	test   %eax,%eax
f0100851:	74 0a                	je     f010085d <monitor+0x46>
			*buf++ = 0;
f0100853:	c6 03 00             	movb   $0x0,(%ebx)
f0100856:	89 fe                	mov    %edi,%esi
f0100858:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010085b:	eb 6b                	jmp    f01008c8 <monitor+0xb1>
		if (*buf == 0)
f010085d:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100860:	74 73                	je     f01008d5 <monitor+0xbe>
		if (argc == MAXARGS-1) {
f0100862:	83 ff 0f             	cmp    $0xf,%edi
f0100865:	74 09                	je     f0100870 <monitor+0x59>
		argv[argc++] = buf;
f0100867:	8d 77 01             	lea    0x1(%edi),%esi
f010086a:	89 5c bd a8          	mov    %ebx,-0x58(%ebp,%edi,4)
f010086e:	eb 39                	jmp    f01008a9 <monitor+0x92>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100870:	83 ec 08             	sub    $0x8,%esp
f0100873:	6a 10                	push   $0x10
f0100875:	68 44 1c 10 f0       	push   $0xf0101c44
f010087a:	e8 04 01 00 00       	call   f0100983 <cprintf>
f010087f:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100882:	83 ec 0c             	sub    $0xc,%esp
f0100885:	68 3b 1c 10 f0       	push   $0xf0101c3b
f010088a:	e8 9f 09 00 00       	call   f010122e <readline>
f010088f:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100891:	83 c4 10             	add    $0x10,%esp
f0100894:	85 c0                	test   %eax,%eax
f0100896:	74 ea                	je     f0100882 <monitor+0x6b>
	argv[argc] = 0;
f0100898:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f010089f:	bf 00 00 00 00       	mov    $0x0,%edi
f01008a4:	eb 24                	jmp    f01008ca <monitor+0xb3>
			buf++;
f01008a6:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f01008a9:	0f b6 03             	movzbl (%ebx),%eax
f01008ac:	84 c0                	test   %al,%al
f01008ae:	74 18                	je     f01008c8 <monitor+0xb1>
f01008b0:	83 ec 08             	sub    $0x8,%esp
f01008b3:	0f be c0             	movsbl %al,%eax
f01008b6:	50                   	push   %eax
f01008b7:	68 3f 1c 10 f0       	push   $0xf0101c3f
f01008bc:	e8 8a 0b 00 00       	call   f010144b <strchr>
f01008c1:	83 c4 10             	add    $0x10,%esp
f01008c4:	85 c0                	test   %eax,%eax
f01008c6:	74 de                	je     f01008a6 <monitor+0x8f>
			*buf++ = 0;
f01008c8:	89 f7                	mov    %esi,%edi
		while (*buf && strchr(WHITESPACE, *buf))
f01008ca:	0f b6 03             	movzbl (%ebx),%eax
f01008cd:	84 c0                	test   %al,%al
f01008cf:	0f 85 66 ff ff ff    	jne    f010083b <monitor+0x24>
	argv[argc] = 0;
f01008d5:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f01008dc:	00 
	if (argc == 0)
f01008dd:	85 ff                	test   %edi,%edi
f01008df:	74 a1                	je     f0100882 <monitor+0x6b>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01008e1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f01008e6:	83 ec 08             	sub    $0x8,%esp
f01008e9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008ec:	ff 34 85 40 1e 10 f0 	pushl  -0xfefe1c0(,%eax,4)
f01008f3:	ff 75 a8             	pushl  -0x58(%ebp)
f01008f6:	e8 f2 0a 00 00       	call   f01013ed <strcmp>
f01008fb:	83 c4 10             	add    $0x10,%esp
f01008fe:	85 c0                	test   %eax,%eax
f0100900:	74 20                	je     f0100922 <monitor+0x10b>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100902:	83 c3 01             	add    $0x1,%ebx
f0100905:	83 fb 03             	cmp    $0x3,%ebx
f0100908:	75 dc                	jne    f01008e6 <monitor+0xcf>
	cprintf("Unknown command '%s'\n", argv[0]);
f010090a:	83 ec 08             	sub    $0x8,%esp
f010090d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100910:	68 61 1c 10 f0       	push   $0xf0101c61
f0100915:	e8 69 00 00 00       	call   f0100983 <cprintf>
f010091a:	83 c4 10             	add    $0x10,%esp
f010091d:	e9 60 ff ff ff       	jmp    f0100882 <monitor+0x6b>
			return commands[i].func(argc, argv, tf);
f0100922:	83 ec 04             	sub    $0x4,%esp
f0100925:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100928:	ff 75 08             	pushl  0x8(%ebp)
f010092b:	8d 55 a8             	lea    -0x58(%ebp),%edx
f010092e:	52                   	push   %edx
f010092f:	57                   	push   %edi
f0100930:	ff 14 85 48 1e 10 f0 	call   *-0xfefe1b8(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100937:	83 c4 10             	add    $0x10,%esp
f010093a:	85 c0                	test   %eax,%eax
f010093c:	0f 89 40 ff ff ff    	jns    f0100882 <monitor+0x6b>
				break;
	}
}
f0100942:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100945:	5b                   	pop    %ebx
f0100946:	5e                   	pop    %esi
f0100947:	5f                   	pop    %edi
f0100948:	5d                   	pop    %ebp
f0100949:	c3                   	ret    

f010094a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010094a:	55                   	push   %ebp
f010094b:	89 e5                	mov    %esp,%ebp
f010094d:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100950:	ff 75 08             	pushl  0x8(%ebp)
f0100953:	e8 21 fd ff ff       	call   f0100679 <cputchar>
	*cnt++;
}
f0100958:	83 c4 10             	add    $0x10,%esp
f010095b:	c9                   	leave  
f010095c:	c3                   	ret    

f010095d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010095d:	55                   	push   %ebp
f010095e:	89 e5                	mov    %esp,%ebp
f0100960:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100963:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010096a:	ff 75 0c             	pushl  0xc(%ebp)
f010096d:	ff 75 08             	pushl  0x8(%ebp)
f0100970:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100973:	50                   	push   %eax
f0100974:	68 4a 09 10 f0       	push   $0xf010094a
f0100979:	e8 c5 03 00 00       	call   f0100d43 <vprintfmt>
	return cnt;
}
f010097e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100981:	c9                   	leave  
f0100982:	c3                   	ret    

f0100983 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100983:	55                   	push   %ebp
f0100984:	89 e5                	mov    %esp,%ebp
f0100986:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100989:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010098c:	50                   	push   %eax
f010098d:	ff 75 08             	pushl  0x8(%ebp)
f0100990:	e8 c8 ff ff ff       	call   f010095d <vcprintf>
	va_end(ap);

	return cnt;
}
f0100995:	c9                   	leave  
f0100996:	c3                   	ret    

f0100997 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100997:	55                   	push   %ebp
f0100998:	89 e5                	mov    %esp,%ebp
f010099a:	57                   	push   %edi
f010099b:	56                   	push   %esi
f010099c:	53                   	push   %ebx
f010099d:	83 ec 14             	sub    $0x14,%esp
f01009a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01009a3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01009a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01009a9:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009ac:	8b 32                	mov    (%edx),%esi
f01009ae:	8b 01                	mov    (%ecx),%eax
f01009b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009b3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009ba:	eb 2f                	jmp    f01009eb <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01009bc:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f01009bf:	39 c6                	cmp    %eax,%esi
f01009c1:	7f 49                	jg     f0100a0c <stab_binsearch+0x75>
f01009c3:	0f b6 0a             	movzbl (%edx),%ecx
f01009c6:	83 ea 0c             	sub    $0xc,%edx
f01009c9:	39 f9                	cmp    %edi,%ecx
f01009cb:	75 ef                	jne    f01009bc <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009cd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009d0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009d3:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01009d7:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01009da:	73 35                	jae    f0100a11 <stab_binsearch+0x7a>
			*region_left = m;
f01009dc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009df:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f01009e1:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f01009e4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01009eb:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01009ee:	7f 4e                	jg     f0100a3e <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f01009f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009f3:	01 f0                	add    %esi,%eax
f01009f5:	89 c3                	mov    %eax,%ebx
f01009f7:	c1 eb 1f             	shr    $0x1f,%ebx
f01009fa:	01 c3                	add    %eax,%ebx
f01009fc:	d1 fb                	sar    %ebx
f01009fe:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a01:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a04:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100a08:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100a0a:	eb b3                	jmp    f01009bf <stab_binsearch+0x28>
			l = true_m + 1;
f0100a0c:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100a0f:	eb da                	jmp    f01009eb <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100a11:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100a14:	76 14                	jbe    f0100a2a <stab_binsearch+0x93>
			*region_right = m - 1;
f0100a16:	83 e8 01             	sub    $0x1,%eax
f0100a19:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a1c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100a1f:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100a21:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a28:	eb c1                	jmp    f01009eb <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a2a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a2d:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a2f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a33:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100a35:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a3c:	eb ad                	jmp    f01009eb <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100a3e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a42:	74 16                	je     f0100a5a <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a44:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a47:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a49:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a4c:	8b 0e                	mov    (%esi),%ecx
f0100a4e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a51:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a54:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100a58:	eb 12                	jmp    f0100a6c <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100a5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a5d:	8b 00                	mov    (%eax),%eax
f0100a5f:	83 e8 01             	sub    $0x1,%eax
f0100a62:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100a65:	89 07                	mov    %eax,(%edi)
f0100a67:	eb 16                	jmp    f0100a7f <stab_binsearch+0xe8>
		     l--)
f0100a69:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100a6c:	39 c1                	cmp    %eax,%ecx
f0100a6e:	7d 0a                	jge    f0100a7a <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100a70:	0f b6 1a             	movzbl (%edx),%ebx
f0100a73:	83 ea 0c             	sub    $0xc,%edx
f0100a76:	39 fb                	cmp    %edi,%ebx
f0100a78:	75 ef                	jne    f0100a69 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100a7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100a7d:	89 07                	mov    %eax,(%edi)
	}
}
f0100a7f:	83 c4 14             	add    $0x14,%esp
f0100a82:	5b                   	pop    %ebx
f0100a83:	5e                   	pop    %esi
f0100a84:	5f                   	pop    %edi
f0100a85:	5d                   	pop    %ebp
f0100a86:	c3                   	ret    

f0100a87 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a87:	55                   	push   %ebp
f0100a88:	89 e5                	mov    %esp,%ebp
f0100a8a:	57                   	push   %edi
f0100a8b:	56                   	push   %esi
f0100a8c:	53                   	push   %ebx
f0100a8d:	83 ec 1c             	sub    $0x1c,%esp
f0100a90:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100a93:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a96:	c7 06 64 1e 10 f0    	movl   $0xf0101e64,(%esi)
	info->eip_line = 0;
f0100a9c:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100aa3:	c7 46 08 64 1e 10 f0 	movl   $0xf0101e64,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100aaa:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100ab1:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100ab4:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100abb:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100ac1:	0f 86 df 00 00 00    	jbe    f0100ba6 <debuginfo_eip+0x11f>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ac7:	b8 a3 77 10 f0       	mov    $0xf01077a3,%eax
f0100acc:	3d f9 5d 10 f0       	cmp    $0xf0105df9,%eax
f0100ad1:	0f 86 61 01 00 00    	jbe    f0100c38 <debuginfo_eip+0x1b1>
f0100ad7:	80 3d a2 77 10 f0 00 	cmpb   $0x0,0xf01077a2
f0100ade:	0f 85 5b 01 00 00    	jne    f0100c3f <debuginfo_eip+0x1b8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100ae4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100aeb:	b8 f8 5d 10 f0       	mov    $0xf0105df8,%eax
f0100af0:	2d 9c 20 10 f0       	sub    $0xf010209c,%eax
f0100af5:	c1 f8 02             	sar    $0x2,%eax
f0100af8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100afe:	83 e8 01             	sub    $0x1,%eax
f0100b01:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b04:	83 ec 08             	sub    $0x8,%esp
f0100b07:	57                   	push   %edi
f0100b08:	6a 64                	push   $0x64
f0100b0a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b0d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b10:	b8 9c 20 10 f0       	mov    $0xf010209c,%eax
f0100b15:	e8 7d fe ff ff       	call   f0100997 <stab_binsearch>
	if (lfile == 0)
f0100b1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b1d:	83 c4 10             	add    $0x10,%esp
f0100b20:	85 c0                	test   %eax,%eax
f0100b22:	0f 84 1e 01 00 00    	je     f0100c46 <debuginfo_eip+0x1bf>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b28:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b2e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b31:	83 ec 08             	sub    $0x8,%esp
f0100b34:	57                   	push   %edi
f0100b35:	6a 24                	push   $0x24
f0100b37:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b3a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b3d:	b8 9c 20 10 f0       	mov    $0xf010209c,%eax
f0100b42:	e8 50 fe ff ff       	call   f0100997 <stab_binsearch>

	if (lfun <= rfun) {
f0100b47:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100b4a:	83 c4 10             	add    $0x10,%esp
f0100b4d:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100b50:	7f 68                	jg     f0100bba <debuginfo_eip+0x133>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b52:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b55:	c1 e0 02             	shl    $0x2,%eax
f0100b58:	8d 90 9c 20 10 f0    	lea    -0xfefdf64(%eax),%edx
f0100b5e:	8b 88 9c 20 10 f0    	mov    -0xfefdf64(%eax),%ecx
f0100b64:	b8 a3 77 10 f0       	mov    $0xf01077a3,%eax
f0100b69:	2d f9 5d 10 f0       	sub    $0xf0105df9,%eax
f0100b6e:	39 c1                	cmp    %eax,%ecx
f0100b70:	73 09                	jae    f0100b7b <debuginfo_eip+0xf4>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b72:	81 c1 f9 5d 10 f0    	add    $0xf0105df9,%ecx
f0100b78:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b7b:	8b 42 08             	mov    0x8(%edx),%eax
f0100b7e:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b81:	83 ec 08             	sub    $0x8,%esp
f0100b84:	6a 3a                	push   $0x3a
f0100b86:	ff 76 08             	pushl  0x8(%esi)
f0100b89:	e8 de 08 00 00       	call   f010146c <strfind>
f0100b8e:	2b 46 08             	sub    0x8(%esi),%eax
f0100b91:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b97:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b9a:	8d 04 85 a0 20 10 f0 	lea    -0xfefdf60(,%eax,4),%eax
f0100ba1:	83 c4 10             	add    $0x10,%esp
f0100ba4:	eb 22                	jmp    f0100bc8 <debuginfo_eip+0x141>
  	        panic("User address");
f0100ba6:	83 ec 04             	sub    $0x4,%esp
f0100ba9:	68 6e 1e 10 f0       	push   $0xf0101e6e
f0100bae:	6a 7f                	push   $0x7f
f0100bb0:	68 7b 1e 10 f0       	push   $0xf0101e7b
f0100bb5:	e8 2c f5 ff ff       	call   f01000e6 <_panic>
		info->eip_fn_addr = addr;
f0100bba:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100bbd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100bc0:	eb bf                	jmp    f0100b81 <debuginfo_eip+0xfa>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100bc2:	83 eb 01             	sub    $0x1,%ebx
f0100bc5:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100bc8:	39 df                	cmp    %ebx,%edi
f0100bca:	7f 33                	jg     f0100bff <debuginfo_eip+0x178>
	       && stabs[lline].n_type != N_SOL
f0100bcc:	0f b6 10             	movzbl (%eax),%edx
f0100bcf:	80 fa 84             	cmp    $0x84,%dl
f0100bd2:	74 0b                	je     f0100bdf <debuginfo_eip+0x158>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100bd4:	80 fa 64             	cmp    $0x64,%dl
f0100bd7:	75 e9                	jne    f0100bc2 <debuginfo_eip+0x13b>
f0100bd9:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100bdd:	74 e3                	je     f0100bc2 <debuginfo_eip+0x13b>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100bdf:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100be2:	8b 14 85 9c 20 10 f0 	mov    -0xfefdf64(,%eax,4),%edx
f0100be9:	b8 a3 77 10 f0       	mov    $0xf01077a3,%eax
f0100bee:	2d f9 5d 10 f0       	sub    $0xf0105df9,%eax
f0100bf3:	39 c2                	cmp    %eax,%edx
f0100bf5:	73 08                	jae    f0100bff <debuginfo_eip+0x178>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100bf7:	81 c2 f9 5d 10 f0    	add    $0xf0105df9,%edx
f0100bfd:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100bff:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100c02:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c05:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100c0a:	39 cb                	cmp    %ecx,%ebx
f0100c0c:	7d 44                	jge    f0100c52 <debuginfo_eip+0x1cb>
		for (lline = lfun + 1;
f0100c0e:	8d 53 01             	lea    0x1(%ebx),%edx
f0100c11:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c14:	8d 04 85 ac 20 10 f0 	lea    -0xfefdf54(,%eax,4),%eax
f0100c1b:	eb 07                	jmp    f0100c24 <debuginfo_eip+0x19d>
			info->eip_fn_narg++;
f0100c1d:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline++)
f0100c21:	83 c2 01             	add    $0x1,%edx
		for (lline = lfun + 1;
f0100c24:	39 d1                	cmp    %edx,%ecx
f0100c26:	74 25                	je     f0100c4d <debuginfo_eip+0x1c6>
f0100c28:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c2b:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100c2f:	74 ec                	je     f0100c1d <debuginfo_eip+0x196>
	return 0;
f0100c31:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c36:	eb 1a                	jmp    f0100c52 <debuginfo_eip+0x1cb>
		return -1;
f0100c38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c3d:	eb 13                	jmp    f0100c52 <debuginfo_eip+0x1cb>
f0100c3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c44:	eb 0c                	jmp    f0100c52 <debuginfo_eip+0x1cb>
		return -1;
f0100c46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c4b:	eb 05                	jmp    f0100c52 <debuginfo_eip+0x1cb>
	return 0;
f0100c4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c52:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c55:	5b                   	pop    %ebx
f0100c56:	5e                   	pop    %esi
f0100c57:	5f                   	pop    %edi
f0100c58:	5d                   	pop    %ebp
f0100c59:	c3                   	ret    

f0100c5a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100c5a:	55                   	push   %ebp
f0100c5b:	89 e5                	mov    %esp,%ebp
f0100c5d:	57                   	push   %edi
f0100c5e:	56                   	push   %esi
f0100c5f:	53                   	push   %ebx
f0100c60:	83 ec 1c             	sub    $0x1c,%esp
f0100c63:	89 c7                	mov    %eax,%edi
f0100c65:	89 d6                	mov    %edx,%esi
f0100c67:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c6a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100c6d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100c70:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100c73:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100c76:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c7b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100c7e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100c81:	39 d3                	cmp    %edx,%ebx
f0100c83:	72 05                	jb     f0100c8a <printnum+0x30>
f0100c85:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100c88:	77 7a                	ja     f0100d04 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100c8a:	83 ec 0c             	sub    $0xc,%esp
f0100c8d:	ff 75 18             	pushl  0x18(%ebp)
f0100c90:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c93:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100c96:	53                   	push   %ebx
f0100c97:	ff 75 10             	pushl  0x10(%ebp)
f0100c9a:	83 ec 08             	sub    $0x8,%esp
f0100c9d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100ca0:	ff 75 e0             	pushl  -0x20(%ebp)
f0100ca3:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ca6:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ca9:	e8 e2 09 00 00       	call   f0101690 <__udivdi3>
f0100cae:	83 c4 18             	add    $0x18,%esp
f0100cb1:	52                   	push   %edx
f0100cb2:	50                   	push   %eax
f0100cb3:	89 f2                	mov    %esi,%edx
f0100cb5:	89 f8                	mov    %edi,%eax
f0100cb7:	e8 9e ff ff ff       	call   f0100c5a <printnum>
f0100cbc:	83 c4 20             	add    $0x20,%esp
f0100cbf:	eb 13                	jmp    f0100cd4 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100cc1:	83 ec 08             	sub    $0x8,%esp
f0100cc4:	56                   	push   %esi
f0100cc5:	ff 75 18             	pushl  0x18(%ebp)
f0100cc8:	ff d7                	call   *%edi
f0100cca:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100ccd:	83 eb 01             	sub    $0x1,%ebx
f0100cd0:	85 db                	test   %ebx,%ebx
f0100cd2:	7f ed                	jg     f0100cc1 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100cd4:	83 ec 08             	sub    $0x8,%esp
f0100cd7:	56                   	push   %esi
f0100cd8:	83 ec 04             	sub    $0x4,%esp
f0100cdb:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100cde:	ff 75 e0             	pushl  -0x20(%ebp)
f0100ce1:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ce4:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ce7:	e8 c4 0a 00 00       	call   f01017b0 <__umoddi3>
f0100cec:	83 c4 14             	add    $0x14,%esp
f0100cef:	0f be 80 89 1e 10 f0 	movsbl -0xfefe177(%eax),%eax
f0100cf6:	50                   	push   %eax
f0100cf7:	ff d7                	call   *%edi
}
f0100cf9:	83 c4 10             	add    $0x10,%esp
f0100cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cff:	5b                   	pop    %ebx
f0100d00:	5e                   	pop    %esi
f0100d01:	5f                   	pop    %edi
f0100d02:	5d                   	pop    %ebp
f0100d03:	c3                   	ret    
f0100d04:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100d07:	eb c4                	jmp    f0100ccd <printnum+0x73>

f0100d09 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d09:	55                   	push   %ebp
f0100d0a:	89 e5                	mov    %esp,%ebp
f0100d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d0f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100d13:	8b 10                	mov    (%eax),%edx
f0100d15:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d18:	73 0a                	jae    f0100d24 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100d1a:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100d1d:	89 08                	mov    %ecx,(%eax)
f0100d1f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d22:	88 02                	mov    %al,(%edx)
}
f0100d24:	5d                   	pop    %ebp
f0100d25:	c3                   	ret    

f0100d26 <printfmt>:
{
f0100d26:	55                   	push   %ebp
f0100d27:	89 e5                	mov    %esp,%ebp
f0100d29:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100d2c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100d2f:	50                   	push   %eax
f0100d30:	ff 75 10             	pushl  0x10(%ebp)
f0100d33:	ff 75 0c             	pushl  0xc(%ebp)
f0100d36:	ff 75 08             	pushl  0x8(%ebp)
f0100d39:	e8 05 00 00 00       	call   f0100d43 <vprintfmt>
}
f0100d3e:	83 c4 10             	add    $0x10,%esp
f0100d41:	c9                   	leave  
f0100d42:	c3                   	ret    

f0100d43 <vprintfmt>:
{
f0100d43:	55                   	push   %ebp
f0100d44:	89 e5                	mov    %esp,%ebp
f0100d46:	57                   	push   %edi
f0100d47:	56                   	push   %esi
f0100d48:	53                   	push   %ebx
f0100d49:	83 ec 2c             	sub    $0x2c,%esp
f0100d4c:	8b 75 08             	mov    0x8(%ebp),%esi
f0100d4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100d52:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100d55:	e9 c1 03 00 00       	jmp    f010111b <vprintfmt+0x3d8>
		padc = ' ';
f0100d5a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100d5e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100d65:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0100d6c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100d73:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100d78:	8d 47 01             	lea    0x1(%edi),%eax
f0100d7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d7e:	0f b6 17             	movzbl (%edi),%edx
f0100d81:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100d84:	3c 55                	cmp    $0x55,%al
f0100d86:	0f 87 12 04 00 00    	ja     f010119e <vprintfmt+0x45b>
f0100d8c:	0f b6 c0             	movzbl %al,%eax
f0100d8f:	ff 24 85 18 1f 10 f0 	jmp    *-0xfefe0e8(,%eax,4)
f0100d96:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100d99:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100d9d:	eb d9                	jmp    f0100d78 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100d9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0100da2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100da6:	eb d0                	jmp    f0100d78 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100da8:	0f b6 d2             	movzbl %dl,%edx
f0100dab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0100dae:	b8 00 00 00 00       	mov    $0x0,%eax
f0100db3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0100db6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100db9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100dbd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100dc0:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100dc3:	83 f9 09             	cmp    $0x9,%ecx
f0100dc6:	77 55                	ja     f0100e1d <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
f0100dc8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0100dcb:	eb e9                	jmp    f0100db6 <vprintfmt+0x73>
			precision = va_arg(ap, int);
f0100dcd:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dd0:	8b 00                	mov    (%eax),%eax
f0100dd2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100dd5:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dd8:	8d 40 04             	lea    0x4(%eax),%eax
f0100ddb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100dde:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0100de1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100de5:	79 91                	jns    f0100d78 <vprintfmt+0x35>
				width = precision, precision = -1;
f0100de7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100dea:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ded:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100df4:	eb 82                	jmp    f0100d78 <vprintfmt+0x35>
f0100df6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100df9:	85 c0                	test   %eax,%eax
f0100dfb:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e00:	0f 49 d0             	cmovns %eax,%edx
f0100e03:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100e06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e09:	e9 6a ff ff ff       	jmp    f0100d78 <vprintfmt+0x35>
f0100e0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0100e11:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100e18:	e9 5b ff ff ff       	jmp    f0100d78 <vprintfmt+0x35>
f0100e1d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100e20:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e23:	eb bc                	jmp    f0100de1 <vprintfmt+0x9e>
			lflag++;
f0100e25:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100e28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0100e2b:	e9 48 ff ff ff       	jmp    f0100d78 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0100e30:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e33:	8d 78 04             	lea    0x4(%eax),%edi
f0100e36:	83 ec 08             	sub    $0x8,%esp
f0100e39:	53                   	push   %ebx
f0100e3a:	ff 30                	pushl  (%eax)
f0100e3c:	ff d6                	call   *%esi
			break;
f0100e3e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0100e41:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0100e44:	e9 cf 02 00 00       	jmp    f0101118 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
f0100e49:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e4c:	8d 78 04             	lea    0x4(%eax),%edi
f0100e4f:	8b 00                	mov    (%eax),%eax
f0100e51:	99                   	cltd   
f0100e52:	31 d0                	xor    %edx,%eax
f0100e54:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100e56:	83 f8 06             	cmp    $0x6,%eax
f0100e59:	7f 23                	jg     f0100e7e <vprintfmt+0x13b>
f0100e5b:	8b 14 85 70 20 10 f0 	mov    -0xfefdf90(,%eax,4),%edx
f0100e62:	85 d2                	test   %edx,%edx
f0100e64:	74 18                	je     f0100e7e <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
f0100e66:	52                   	push   %edx
f0100e67:	68 aa 1e 10 f0       	push   $0xf0101eaa
f0100e6c:	53                   	push   %ebx
f0100e6d:	56                   	push   %esi
f0100e6e:	e8 b3 fe ff ff       	call   f0100d26 <printfmt>
f0100e73:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100e76:	89 7d 14             	mov    %edi,0x14(%ebp)
f0100e79:	e9 9a 02 00 00       	jmp    f0101118 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
f0100e7e:	50                   	push   %eax
f0100e7f:	68 a1 1e 10 f0       	push   $0xf0101ea1
f0100e84:	53                   	push   %ebx
f0100e85:	56                   	push   %esi
f0100e86:	e8 9b fe ff ff       	call   f0100d26 <printfmt>
f0100e8b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100e8e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0100e91:	e9 82 02 00 00       	jmp    f0101118 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
f0100e96:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e99:	83 c0 04             	add    $0x4,%eax
f0100e9c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100e9f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ea2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100ea4:	85 ff                	test   %edi,%edi
f0100ea6:	b8 9a 1e 10 f0       	mov    $0xf0101e9a,%eax
f0100eab:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100eae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100eb2:	0f 8e bd 00 00 00    	jle    f0100f75 <vprintfmt+0x232>
f0100eb8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100ebc:	75 0e                	jne    f0100ecc <vprintfmt+0x189>
f0100ebe:	89 75 08             	mov    %esi,0x8(%ebp)
f0100ec1:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ec4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ec7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100eca:	eb 6d                	jmp    f0100f39 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ecc:	83 ec 08             	sub    $0x8,%esp
f0100ecf:	ff 75 d0             	pushl  -0x30(%ebp)
f0100ed2:	57                   	push   %edi
f0100ed3:	e8 50 04 00 00       	call   f0101328 <strnlen>
f0100ed8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100edb:	29 c1                	sub    %eax,%ecx
f0100edd:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100ee0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100ee3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100ee7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100eea:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100eed:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100eef:	eb 0f                	jmp    f0100f00 <vprintfmt+0x1bd>
					putch(padc, putdat);
f0100ef1:	83 ec 08             	sub    $0x8,%esp
f0100ef4:	53                   	push   %ebx
f0100ef5:	ff 75 e0             	pushl  -0x20(%ebp)
f0100ef8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100efa:	83 ef 01             	sub    $0x1,%edi
f0100efd:	83 c4 10             	add    $0x10,%esp
f0100f00:	85 ff                	test   %edi,%edi
f0100f02:	7f ed                	jg     f0100ef1 <vprintfmt+0x1ae>
f0100f04:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100f07:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100f0a:	85 c9                	test   %ecx,%ecx
f0100f0c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f11:	0f 49 c1             	cmovns %ecx,%eax
f0100f14:	29 c1                	sub    %eax,%ecx
f0100f16:	89 75 08             	mov    %esi,0x8(%ebp)
f0100f19:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100f1c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100f1f:	89 cb                	mov    %ecx,%ebx
f0100f21:	eb 16                	jmp    f0100f39 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
f0100f23:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100f27:	75 31                	jne    f0100f5a <vprintfmt+0x217>
					putch(ch, putdat);
f0100f29:	83 ec 08             	sub    $0x8,%esp
f0100f2c:	ff 75 0c             	pushl  0xc(%ebp)
f0100f2f:	50                   	push   %eax
f0100f30:	ff 55 08             	call   *0x8(%ebp)
f0100f33:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f36:	83 eb 01             	sub    $0x1,%ebx
f0100f39:	83 c7 01             	add    $0x1,%edi
f0100f3c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0100f40:	0f be c2             	movsbl %dl,%eax
f0100f43:	85 c0                	test   %eax,%eax
f0100f45:	74 59                	je     f0100fa0 <vprintfmt+0x25d>
f0100f47:	85 f6                	test   %esi,%esi
f0100f49:	78 d8                	js     f0100f23 <vprintfmt+0x1e0>
f0100f4b:	83 ee 01             	sub    $0x1,%esi
f0100f4e:	79 d3                	jns    f0100f23 <vprintfmt+0x1e0>
f0100f50:	89 df                	mov    %ebx,%edi
f0100f52:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f58:	eb 37                	jmp    f0100f91 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
f0100f5a:	0f be d2             	movsbl %dl,%edx
f0100f5d:	83 ea 20             	sub    $0x20,%edx
f0100f60:	83 fa 5e             	cmp    $0x5e,%edx
f0100f63:	76 c4                	jbe    f0100f29 <vprintfmt+0x1e6>
					putch('?', putdat);
f0100f65:	83 ec 08             	sub    $0x8,%esp
f0100f68:	ff 75 0c             	pushl  0xc(%ebp)
f0100f6b:	6a 3f                	push   $0x3f
f0100f6d:	ff 55 08             	call   *0x8(%ebp)
f0100f70:	83 c4 10             	add    $0x10,%esp
f0100f73:	eb c1                	jmp    f0100f36 <vprintfmt+0x1f3>
f0100f75:	89 75 08             	mov    %esi,0x8(%ebp)
f0100f78:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100f7b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100f7e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100f81:	eb b6                	jmp    f0100f39 <vprintfmt+0x1f6>
				putch(' ', putdat);
f0100f83:	83 ec 08             	sub    $0x8,%esp
f0100f86:	53                   	push   %ebx
f0100f87:	6a 20                	push   $0x20
f0100f89:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0100f8b:	83 ef 01             	sub    $0x1,%edi
f0100f8e:	83 c4 10             	add    $0x10,%esp
f0100f91:	85 ff                	test   %edi,%edi
f0100f93:	7f ee                	jg     f0100f83 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
f0100f95:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100f98:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f9b:	e9 78 01 00 00       	jmp    f0101118 <vprintfmt+0x3d5>
f0100fa0:	89 df                	mov    %ebx,%edi
f0100fa2:	8b 75 08             	mov    0x8(%ebp),%esi
f0100fa5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100fa8:	eb e7                	jmp    f0100f91 <vprintfmt+0x24e>
	if (lflag >= 2)
f0100faa:	83 f9 01             	cmp    $0x1,%ecx
f0100fad:	7e 3f                	jle    f0100fee <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
f0100faf:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fb2:	8b 50 04             	mov    0x4(%eax),%edx
f0100fb5:	8b 00                	mov    (%eax),%eax
f0100fb7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100fba:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100fbd:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fc0:	8d 40 08             	lea    0x8(%eax),%eax
f0100fc3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0100fc6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100fca:	79 5c                	jns    f0101028 <vprintfmt+0x2e5>
				putch('-', putdat);
f0100fcc:	83 ec 08             	sub    $0x8,%esp
f0100fcf:	53                   	push   %ebx
f0100fd0:	6a 2d                	push   $0x2d
f0100fd2:	ff d6                	call   *%esi
				num = -(long long) num;
f0100fd4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100fd7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100fda:	f7 da                	neg    %edx
f0100fdc:	83 d1 00             	adc    $0x0,%ecx
f0100fdf:	f7 d9                	neg    %ecx
f0100fe1:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0100fe4:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fe9:	e9 10 01 00 00       	jmp    f01010fe <vprintfmt+0x3bb>
	else if (lflag)
f0100fee:	85 c9                	test   %ecx,%ecx
f0100ff0:	75 1b                	jne    f010100d <vprintfmt+0x2ca>
		return va_arg(*ap, int);
f0100ff2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff5:	8b 00                	mov    (%eax),%eax
f0100ff7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100ffa:	89 c1                	mov    %eax,%ecx
f0100ffc:	c1 f9 1f             	sar    $0x1f,%ecx
f0100fff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101002:	8b 45 14             	mov    0x14(%ebp),%eax
f0101005:	8d 40 04             	lea    0x4(%eax),%eax
f0101008:	89 45 14             	mov    %eax,0x14(%ebp)
f010100b:	eb b9                	jmp    f0100fc6 <vprintfmt+0x283>
		return va_arg(*ap, long);
f010100d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101010:	8b 00                	mov    (%eax),%eax
f0101012:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101015:	89 c1                	mov    %eax,%ecx
f0101017:	c1 f9 1f             	sar    $0x1f,%ecx
f010101a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010101d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101020:	8d 40 04             	lea    0x4(%eax),%eax
f0101023:	89 45 14             	mov    %eax,0x14(%ebp)
f0101026:	eb 9e                	jmp    f0100fc6 <vprintfmt+0x283>
			num = getint(&ap, lflag);
f0101028:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010102b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010102e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101033:	e9 c6 00 00 00       	jmp    f01010fe <vprintfmt+0x3bb>
	if (lflag >= 2)
f0101038:	83 f9 01             	cmp    $0x1,%ecx
f010103b:	7e 18                	jle    f0101055 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
f010103d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101040:	8b 10                	mov    (%eax),%edx
f0101042:	8b 48 04             	mov    0x4(%eax),%ecx
f0101045:	8d 40 08             	lea    0x8(%eax),%eax
f0101048:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010104b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101050:	e9 a9 00 00 00       	jmp    f01010fe <vprintfmt+0x3bb>
	else if (lflag)
f0101055:	85 c9                	test   %ecx,%ecx
f0101057:	75 1a                	jne    f0101073 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
f0101059:	8b 45 14             	mov    0x14(%ebp),%eax
f010105c:	8b 10                	mov    (%eax),%edx
f010105e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101063:	8d 40 04             	lea    0x4(%eax),%eax
f0101066:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101069:	b8 0a 00 00 00       	mov    $0xa,%eax
f010106e:	e9 8b 00 00 00       	jmp    f01010fe <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f0101073:	8b 45 14             	mov    0x14(%ebp),%eax
f0101076:	8b 10                	mov    (%eax),%edx
f0101078:	b9 00 00 00 00       	mov    $0x0,%ecx
f010107d:	8d 40 04             	lea    0x4(%eax),%eax
f0101080:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101083:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101088:	eb 74                	jmp    f01010fe <vprintfmt+0x3bb>
	if (lflag >= 2)
f010108a:	83 f9 01             	cmp    $0x1,%ecx
f010108d:	7e 15                	jle    f01010a4 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
f010108f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101092:	8b 10                	mov    (%eax),%edx
f0101094:	8b 48 04             	mov    0x4(%eax),%ecx
f0101097:	8d 40 08             	lea    0x8(%eax),%eax
f010109a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010109d:	b8 08 00 00 00       	mov    $0x8,%eax
f01010a2:	eb 5a                	jmp    f01010fe <vprintfmt+0x3bb>
	else if (lflag)
f01010a4:	85 c9                	test   %ecx,%ecx
f01010a6:	75 17                	jne    f01010bf <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
f01010a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ab:	8b 10                	mov    (%eax),%edx
f01010ad:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010b2:	8d 40 04             	lea    0x4(%eax),%eax
f01010b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01010b8:	b8 08 00 00 00       	mov    $0x8,%eax
f01010bd:	eb 3f                	jmp    f01010fe <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f01010bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c2:	8b 10                	mov    (%eax),%edx
f01010c4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010c9:	8d 40 04             	lea    0x4(%eax),%eax
f01010cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01010cf:	b8 08 00 00 00       	mov    $0x8,%eax
f01010d4:	eb 28                	jmp    f01010fe <vprintfmt+0x3bb>
			putch('0', putdat);
f01010d6:	83 ec 08             	sub    $0x8,%esp
f01010d9:	53                   	push   %ebx
f01010da:	6a 30                	push   $0x30
f01010dc:	ff d6                	call   *%esi
			putch('x', putdat);
f01010de:	83 c4 08             	add    $0x8,%esp
f01010e1:	53                   	push   %ebx
f01010e2:	6a 78                	push   $0x78
f01010e4:	ff d6                	call   *%esi
			num = (unsigned long long)
f01010e6:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e9:	8b 10                	mov    (%eax),%edx
f01010eb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01010f0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01010f3:	8d 40 04             	lea    0x4(%eax),%eax
f01010f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01010f9:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01010fe:	83 ec 0c             	sub    $0xc,%esp
f0101101:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101105:	57                   	push   %edi
f0101106:	ff 75 e0             	pushl  -0x20(%ebp)
f0101109:	50                   	push   %eax
f010110a:	51                   	push   %ecx
f010110b:	52                   	push   %edx
f010110c:	89 da                	mov    %ebx,%edx
f010110e:	89 f0                	mov    %esi,%eax
f0101110:	e8 45 fb ff ff       	call   f0100c5a <printnum>
			break;
f0101115:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0101118:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010111b:	83 c7 01             	add    $0x1,%edi
f010111e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101122:	83 f8 25             	cmp    $0x25,%eax
f0101125:	0f 84 2f fc ff ff    	je     f0100d5a <vprintfmt+0x17>
			if (ch == '\0')
f010112b:	85 c0                	test   %eax,%eax
f010112d:	0f 84 8b 00 00 00    	je     f01011be <vprintfmt+0x47b>
			putch(ch, putdat);
f0101133:	83 ec 08             	sub    $0x8,%esp
f0101136:	53                   	push   %ebx
f0101137:	50                   	push   %eax
f0101138:	ff d6                	call   *%esi
f010113a:	83 c4 10             	add    $0x10,%esp
f010113d:	eb dc                	jmp    f010111b <vprintfmt+0x3d8>
	if (lflag >= 2)
f010113f:	83 f9 01             	cmp    $0x1,%ecx
f0101142:	7e 15                	jle    f0101159 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
f0101144:	8b 45 14             	mov    0x14(%ebp),%eax
f0101147:	8b 10                	mov    (%eax),%edx
f0101149:	8b 48 04             	mov    0x4(%eax),%ecx
f010114c:	8d 40 08             	lea    0x8(%eax),%eax
f010114f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101152:	b8 10 00 00 00       	mov    $0x10,%eax
f0101157:	eb a5                	jmp    f01010fe <vprintfmt+0x3bb>
	else if (lflag)
f0101159:	85 c9                	test   %ecx,%ecx
f010115b:	75 17                	jne    f0101174 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
f010115d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101160:	8b 10                	mov    (%eax),%edx
f0101162:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101167:	8d 40 04             	lea    0x4(%eax),%eax
f010116a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010116d:	b8 10 00 00 00       	mov    $0x10,%eax
f0101172:	eb 8a                	jmp    f01010fe <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f0101174:	8b 45 14             	mov    0x14(%ebp),%eax
f0101177:	8b 10                	mov    (%eax),%edx
f0101179:	b9 00 00 00 00       	mov    $0x0,%ecx
f010117e:	8d 40 04             	lea    0x4(%eax),%eax
f0101181:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101184:	b8 10 00 00 00       	mov    $0x10,%eax
f0101189:	e9 70 ff ff ff       	jmp    f01010fe <vprintfmt+0x3bb>
			putch(ch, putdat);
f010118e:	83 ec 08             	sub    $0x8,%esp
f0101191:	53                   	push   %ebx
f0101192:	6a 25                	push   $0x25
f0101194:	ff d6                	call   *%esi
			break;
f0101196:	83 c4 10             	add    $0x10,%esp
f0101199:	e9 7a ff ff ff       	jmp    f0101118 <vprintfmt+0x3d5>
			putch('%', putdat);
f010119e:	83 ec 08             	sub    $0x8,%esp
f01011a1:	53                   	push   %ebx
f01011a2:	6a 25                	push   $0x25
f01011a4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01011a6:	83 c4 10             	add    $0x10,%esp
f01011a9:	89 f8                	mov    %edi,%eax
f01011ab:	eb 03                	jmp    f01011b0 <vprintfmt+0x46d>
f01011ad:	83 e8 01             	sub    $0x1,%eax
f01011b0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01011b4:	75 f7                	jne    f01011ad <vprintfmt+0x46a>
f01011b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01011b9:	e9 5a ff ff ff       	jmp    f0101118 <vprintfmt+0x3d5>
}
f01011be:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011c1:	5b                   	pop    %ebx
f01011c2:	5e                   	pop    %esi
f01011c3:	5f                   	pop    %edi
f01011c4:	5d                   	pop    %ebp
f01011c5:	c3                   	ret    

f01011c6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01011c6:	55                   	push   %ebp
f01011c7:	89 e5                	mov    %esp,%ebp
f01011c9:	83 ec 18             	sub    $0x18,%esp
f01011cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01011cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01011d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01011d5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01011d9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01011dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01011e3:	85 c0                	test   %eax,%eax
f01011e5:	74 26                	je     f010120d <vsnprintf+0x47>
f01011e7:	85 d2                	test   %edx,%edx
f01011e9:	7e 22                	jle    f010120d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01011eb:	ff 75 14             	pushl  0x14(%ebp)
f01011ee:	ff 75 10             	pushl  0x10(%ebp)
f01011f1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011f4:	50                   	push   %eax
f01011f5:	68 09 0d 10 f0       	push   $0xf0100d09
f01011fa:	e8 44 fb ff ff       	call   f0100d43 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101202:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101205:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101208:	83 c4 10             	add    $0x10,%esp
}
f010120b:	c9                   	leave  
f010120c:	c3                   	ret    
		return -E_INVAL;
f010120d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101212:	eb f7                	jmp    f010120b <vsnprintf+0x45>

f0101214 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101214:	55                   	push   %ebp
f0101215:	89 e5                	mov    %esp,%ebp
f0101217:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010121a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010121d:	50                   	push   %eax
f010121e:	ff 75 10             	pushl  0x10(%ebp)
f0101221:	ff 75 0c             	pushl  0xc(%ebp)
f0101224:	ff 75 08             	pushl  0x8(%ebp)
f0101227:	e8 9a ff ff ff       	call   f01011c6 <vsnprintf>
	va_end(ap);

	return rc;
}
f010122c:	c9                   	leave  
f010122d:	c3                   	ret    

f010122e <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010122e:	55                   	push   %ebp
f010122f:	89 e5                	mov    %esp,%ebp
f0101231:	57                   	push   %edi
f0101232:	56                   	push   %esi
f0101233:	53                   	push   %ebx
f0101234:	83 ec 0c             	sub    $0xc,%esp
f0101237:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010123a:	85 c0                	test   %eax,%eax
f010123c:	74 11                	je     f010124f <readline+0x21>
		cprintf("%s", prompt);
f010123e:	83 ec 08             	sub    $0x8,%esp
f0101241:	50                   	push   %eax
f0101242:	68 aa 1e 10 f0       	push   $0xf0101eaa
f0101247:	e8 37 f7 ff ff       	call   f0100983 <cprintf>
f010124c:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010124f:	83 ec 0c             	sub    $0xc,%esp
f0101252:	6a 00                	push   $0x0
f0101254:	e8 41 f4 ff ff       	call   f010069a <iscons>
f0101259:	89 c7                	mov    %eax,%edi
f010125b:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010125e:	be 00 00 00 00       	mov    $0x0,%esi
f0101263:	eb 3f                	jmp    f01012a4 <readline+0x76>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0101265:	83 ec 08             	sub    $0x8,%esp
f0101268:	50                   	push   %eax
f0101269:	68 8c 20 10 f0       	push   $0xf010208c
f010126e:	e8 10 f7 ff ff       	call   f0100983 <cprintf>
			return NULL;
f0101273:	83 c4 10             	add    $0x10,%esp
f0101276:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010127b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010127e:	5b                   	pop    %ebx
f010127f:	5e                   	pop    %esi
f0101280:	5f                   	pop    %edi
f0101281:	5d                   	pop    %ebp
f0101282:	c3                   	ret    
			if (echoing)
f0101283:	85 ff                	test   %edi,%edi
f0101285:	75 05                	jne    f010128c <readline+0x5e>
			i--;
f0101287:	83 ee 01             	sub    $0x1,%esi
f010128a:	eb 18                	jmp    f01012a4 <readline+0x76>
				cputchar('\b');
f010128c:	83 ec 0c             	sub    $0xc,%esp
f010128f:	6a 08                	push   $0x8
f0101291:	e8 e3 f3 ff ff       	call   f0100679 <cputchar>
f0101296:	83 c4 10             	add    $0x10,%esp
f0101299:	eb ec                	jmp    f0101287 <readline+0x59>
			buf[i++] = c;
f010129b:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f01012a1:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f01012a4:	e8 e0 f3 ff ff       	call   f0100689 <getchar>
f01012a9:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01012ab:	85 c0                	test   %eax,%eax
f01012ad:	78 b6                	js     f0101265 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01012af:	83 f8 08             	cmp    $0x8,%eax
f01012b2:	0f 94 c2             	sete   %dl
f01012b5:	83 f8 7f             	cmp    $0x7f,%eax
f01012b8:	0f 94 c0             	sete   %al
f01012bb:	08 c2                	or     %al,%dl
f01012bd:	74 04                	je     f01012c3 <readline+0x95>
f01012bf:	85 f6                	test   %esi,%esi
f01012c1:	7f c0                	jg     f0101283 <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01012c3:	83 fb 1f             	cmp    $0x1f,%ebx
f01012c6:	7e 1a                	jle    f01012e2 <readline+0xb4>
f01012c8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01012ce:	7f 12                	jg     f01012e2 <readline+0xb4>
			if (echoing)
f01012d0:	85 ff                	test   %edi,%edi
f01012d2:	74 c7                	je     f010129b <readline+0x6d>
				cputchar(c);
f01012d4:	83 ec 0c             	sub    $0xc,%esp
f01012d7:	53                   	push   %ebx
f01012d8:	e8 9c f3 ff ff       	call   f0100679 <cputchar>
f01012dd:	83 c4 10             	add    $0x10,%esp
f01012e0:	eb b9                	jmp    f010129b <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f01012e2:	83 fb 0a             	cmp    $0xa,%ebx
f01012e5:	74 05                	je     f01012ec <readline+0xbe>
f01012e7:	83 fb 0d             	cmp    $0xd,%ebx
f01012ea:	75 b8                	jne    f01012a4 <readline+0x76>
			if (echoing)
f01012ec:	85 ff                	test   %edi,%edi
f01012ee:	75 11                	jne    f0101301 <readline+0xd3>
			buf[i] = 0;
f01012f0:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01012f7:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
f01012fc:	e9 7a ff ff ff       	jmp    f010127b <readline+0x4d>
				cputchar('\n');
f0101301:	83 ec 0c             	sub    $0xc,%esp
f0101304:	6a 0a                	push   $0xa
f0101306:	e8 6e f3 ff ff       	call   f0100679 <cputchar>
f010130b:	83 c4 10             	add    $0x10,%esp
f010130e:	eb e0                	jmp    f01012f0 <readline+0xc2>

f0101310 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101310:	55                   	push   %ebp
f0101311:	89 e5                	mov    %esp,%ebp
f0101313:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101316:	b8 00 00 00 00       	mov    $0x0,%eax
f010131b:	eb 03                	jmp    f0101320 <strlen+0x10>
		n++;
f010131d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0101320:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101324:	75 f7                	jne    f010131d <strlen+0xd>
	return n;
}
f0101326:	5d                   	pop    %ebp
f0101327:	c3                   	ret    

f0101328 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101328:	55                   	push   %ebp
f0101329:	89 e5                	mov    %esp,%ebp
f010132b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010132e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101331:	b8 00 00 00 00       	mov    $0x0,%eax
f0101336:	eb 03                	jmp    f010133b <strnlen+0x13>
		n++;
f0101338:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010133b:	39 d0                	cmp    %edx,%eax
f010133d:	74 06                	je     f0101345 <strnlen+0x1d>
f010133f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101343:	75 f3                	jne    f0101338 <strnlen+0x10>
	return n;
}
f0101345:	5d                   	pop    %ebp
f0101346:	c3                   	ret    

f0101347 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101347:	55                   	push   %ebp
f0101348:	89 e5                	mov    %esp,%ebp
f010134a:	53                   	push   %ebx
f010134b:	8b 45 08             	mov    0x8(%ebp),%eax
f010134e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101351:	89 c2                	mov    %eax,%edx
f0101353:	83 c1 01             	add    $0x1,%ecx
f0101356:	83 c2 01             	add    $0x1,%edx
f0101359:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010135d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101360:	84 db                	test   %bl,%bl
f0101362:	75 ef                	jne    f0101353 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101364:	5b                   	pop    %ebx
f0101365:	5d                   	pop    %ebp
f0101366:	c3                   	ret    

f0101367 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101367:	55                   	push   %ebp
f0101368:	89 e5                	mov    %esp,%ebp
f010136a:	53                   	push   %ebx
f010136b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010136e:	53                   	push   %ebx
f010136f:	e8 9c ff ff ff       	call   f0101310 <strlen>
f0101374:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101377:	ff 75 0c             	pushl  0xc(%ebp)
f010137a:	01 d8                	add    %ebx,%eax
f010137c:	50                   	push   %eax
f010137d:	e8 c5 ff ff ff       	call   f0101347 <strcpy>
	return dst;
}
f0101382:	89 d8                	mov    %ebx,%eax
f0101384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101387:	c9                   	leave  
f0101388:	c3                   	ret    

f0101389 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101389:	55                   	push   %ebp
f010138a:	89 e5                	mov    %esp,%ebp
f010138c:	56                   	push   %esi
f010138d:	53                   	push   %ebx
f010138e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101391:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101394:	89 f3                	mov    %esi,%ebx
f0101396:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101399:	89 f2                	mov    %esi,%edx
f010139b:	eb 0f                	jmp    f01013ac <strncpy+0x23>
		*dst++ = *src;
f010139d:	83 c2 01             	add    $0x1,%edx
f01013a0:	0f b6 01             	movzbl (%ecx),%eax
f01013a3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01013a6:	80 39 01             	cmpb   $0x1,(%ecx)
f01013a9:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f01013ac:	39 da                	cmp    %ebx,%edx
f01013ae:	75 ed                	jne    f010139d <strncpy+0x14>
	}
	return ret;
}
f01013b0:	89 f0                	mov    %esi,%eax
f01013b2:	5b                   	pop    %ebx
f01013b3:	5e                   	pop    %esi
f01013b4:	5d                   	pop    %ebp
f01013b5:	c3                   	ret    

f01013b6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01013b6:	55                   	push   %ebp
f01013b7:	89 e5                	mov    %esp,%ebp
f01013b9:	56                   	push   %esi
f01013ba:	53                   	push   %ebx
f01013bb:	8b 75 08             	mov    0x8(%ebp),%esi
f01013be:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01013c4:	89 f0                	mov    %esi,%eax
f01013c6:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01013ca:	85 c9                	test   %ecx,%ecx
f01013cc:	75 0b                	jne    f01013d9 <strlcpy+0x23>
f01013ce:	eb 17                	jmp    f01013e7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01013d0:	83 c2 01             	add    $0x1,%edx
f01013d3:	83 c0 01             	add    $0x1,%eax
f01013d6:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01013d9:	39 d8                	cmp    %ebx,%eax
f01013db:	74 07                	je     f01013e4 <strlcpy+0x2e>
f01013dd:	0f b6 0a             	movzbl (%edx),%ecx
f01013e0:	84 c9                	test   %cl,%cl
f01013e2:	75 ec                	jne    f01013d0 <strlcpy+0x1a>
		*dst = '\0';
f01013e4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01013e7:	29 f0                	sub    %esi,%eax
}
f01013e9:	5b                   	pop    %ebx
f01013ea:	5e                   	pop    %esi
f01013eb:	5d                   	pop    %ebp
f01013ec:	c3                   	ret    

f01013ed <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01013ed:	55                   	push   %ebp
f01013ee:	89 e5                	mov    %esp,%ebp
f01013f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013f6:	eb 06                	jmp    f01013fe <strcmp+0x11>
		p++, q++;
f01013f8:	83 c1 01             	add    $0x1,%ecx
f01013fb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01013fe:	0f b6 01             	movzbl (%ecx),%eax
f0101401:	84 c0                	test   %al,%al
f0101403:	74 04                	je     f0101409 <strcmp+0x1c>
f0101405:	3a 02                	cmp    (%edx),%al
f0101407:	74 ef                	je     f01013f8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101409:	0f b6 c0             	movzbl %al,%eax
f010140c:	0f b6 12             	movzbl (%edx),%edx
f010140f:	29 d0                	sub    %edx,%eax
}
f0101411:	5d                   	pop    %ebp
f0101412:	c3                   	ret    

f0101413 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101413:	55                   	push   %ebp
f0101414:	89 e5                	mov    %esp,%ebp
f0101416:	53                   	push   %ebx
f0101417:	8b 45 08             	mov    0x8(%ebp),%eax
f010141a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010141d:	89 c3                	mov    %eax,%ebx
f010141f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101422:	eb 06                	jmp    f010142a <strncmp+0x17>
		n--, p++, q++;
f0101424:	83 c0 01             	add    $0x1,%eax
f0101427:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f010142a:	39 d8                	cmp    %ebx,%eax
f010142c:	74 16                	je     f0101444 <strncmp+0x31>
f010142e:	0f b6 08             	movzbl (%eax),%ecx
f0101431:	84 c9                	test   %cl,%cl
f0101433:	74 04                	je     f0101439 <strncmp+0x26>
f0101435:	3a 0a                	cmp    (%edx),%cl
f0101437:	74 eb                	je     f0101424 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101439:	0f b6 00             	movzbl (%eax),%eax
f010143c:	0f b6 12             	movzbl (%edx),%edx
f010143f:	29 d0                	sub    %edx,%eax
}
f0101441:	5b                   	pop    %ebx
f0101442:	5d                   	pop    %ebp
f0101443:	c3                   	ret    
		return 0;
f0101444:	b8 00 00 00 00       	mov    $0x0,%eax
f0101449:	eb f6                	jmp    f0101441 <strncmp+0x2e>

f010144b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010144b:	55                   	push   %ebp
f010144c:	89 e5                	mov    %esp,%ebp
f010144e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101451:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101455:	0f b6 10             	movzbl (%eax),%edx
f0101458:	84 d2                	test   %dl,%dl
f010145a:	74 09                	je     f0101465 <strchr+0x1a>
		if (*s == c)
f010145c:	38 ca                	cmp    %cl,%dl
f010145e:	74 0a                	je     f010146a <strchr+0x1f>
	for (; *s; s++)
f0101460:	83 c0 01             	add    $0x1,%eax
f0101463:	eb f0                	jmp    f0101455 <strchr+0xa>
			return (char *) s;
	return 0;
f0101465:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010146a:	5d                   	pop    %ebp
f010146b:	c3                   	ret    

f010146c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010146c:	55                   	push   %ebp
f010146d:	89 e5                	mov    %esp,%ebp
f010146f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101472:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101476:	eb 03                	jmp    f010147b <strfind+0xf>
f0101478:	83 c0 01             	add    $0x1,%eax
f010147b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010147e:	38 ca                	cmp    %cl,%dl
f0101480:	74 04                	je     f0101486 <strfind+0x1a>
f0101482:	84 d2                	test   %dl,%dl
f0101484:	75 f2                	jne    f0101478 <strfind+0xc>
			break;
	return (char *) s;
}
f0101486:	5d                   	pop    %ebp
f0101487:	c3                   	ret    

f0101488 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101488:	55                   	push   %ebp
f0101489:	89 e5                	mov    %esp,%ebp
f010148b:	57                   	push   %edi
f010148c:	56                   	push   %esi
f010148d:	53                   	push   %ebx
f010148e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101491:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101494:	85 c9                	test   %ecx,%ecx
f0101496:	74 13                	je     f01014ab <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101498:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010149e:	75 05                	jne    f01014a5 <memset+0x1d>
f01014a0:	f6 c1 03             	test   $0x3,%cl
f01014a3:	74 0d                	je     f01014b2 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01014a5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014a8:	fc                   	cld    
f01014a9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01014ab:	89 f8                	mov    %edi,%eax
f01014ad:	5b                   	pop    %ebx
f01014ae:	5e                   	pop    %esi
f01014af:	5f                   	pop    %edi
f01014b0:	5d                   	pop    %ebp
f01014b1:	c3                   	ret    
		c &= 0xFF;
f01014b2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01014b6:	89 d3                	mov    %edx,%ebx
f01014b8:	c1 e3 08             	shl    $0x8,%ebx
f01014bb:	89 d0                	mov    %edx,%eax
f01014bd:	c1 e0 18             	shl    $0x18,%eax
f01014c0:	89 d6                	mov    %edx,%esi
f01014c2:	c1 e6 10             	shl    $0x10,%esi
f01014c5:	09 f0                	or     %esi,%eax
f01014c7:	09 c2                	or     %eax,%edx
f01014c9:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f01014cb:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01014ce:	89 d0                	mov    %edx,%eax
f01014d0:	fc                   	cld    
f01014d1:	f3 ab                	rep stos %eax,%es:(%edi)
f01014d3:	eb d6                	jmp    f01014ab <memset+0x23>

f01014d5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01014d5:	55                   	push   %ebp
f01014d6:	89 e5                	mov    %esp,%ebp
f01014d8:	57                   	push   %edi
f01014d9:	56                   	push   %esi
f01014da:	8b 45 08             	mov    0x8(%ebp),%eax
f01014dd:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01014e3:	39 c6                	cmp    %eax,%esi
f01014e5:	73 35                	jae    f010151c <memmove+0x47>
f01014e7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01014ea:	39 c2                	cmp    %eax,%edx
f01014ec:	76 2e                	jbe    f010151c <memmove+0x47>
		s += n;
		d += n;
f01014ee:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014f1:	89 d6                	mov    %edx,%esi
f01014f3:	09 fe                	or     %edi,%esi
f01014f5:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014fb:	74 0c                	je     f0101509 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01014fd:	83 ef 01             	sub    $0x1,%edi
f0101500:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101503:	fd                   	std    
f0101504:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101506:	fc                   	cld    
f0101507:	eb 21                	jmp    f010152a <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101509:	f6 c1 03             	test   $0x3,%cl
f010150c:	75 ef                	jne    f01014fd <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010150e:	83 ef 04             	sub    $0x4,%edi
f0101511:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101514:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101517:	fd                   	std    
f0101518:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010151a:	eb ea                	jmp    f0101506 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010151c:	89 f2                	mov    %esi,%edx
f010151e:	09 c2                	or     %eax,%edx
f0101520:	f6 c2 03             	test   $0x3,%dl
f0101523:	74 09                	je     f010152e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101525:	89 c7                	mov    %eax,%edi
f0101527:	fc                   	cld    
f0101528:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010152a:	5e                   	pop    %esi
f010152b:	5f                   	pop    %edi
f010152c:	5d                   	pop    %ebp
f010152d:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010152e:	f6 c1 03             	test   $0x3,%cl
f0101531:	75 f2                	jne    f0101525 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101533:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101536:	89 c7                	mov    %eax,%edi
f0101538:	fc                   	cld    
f0101539:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010153b:	eb ed                	jmp    f010152a <memmove+0x55>

f010153d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010153d:	55                   	push   %ebp
f010153e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101540:	ff 75 10             	pushl  0x10(%ebp)
f0101543:	ff 75 0c             	pushl  0xc(%ebp)
f0101546:	ff 75 08             	pushl  0x8(%ebp)
f0101549:	e8 87 ff ff ff       	call   f01014d5 <memmove>
}
f010154e:	c9                   	leave  
f010154f:	c3                   	ret    

f0101550 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101550:	55                   	push   %ebp
f0101551:	89 e5                	mov    %esp,%ebp
f0101553:	56                   	push   %esi
f0101554:	53                   	push   %ebx
f0101555:	8b 45 08             	mov    0x8(%ebp),%eax
f0101558:	8b 55 0c             	mov    0xc(%ebp),%edx
f010155b:	89 c6                	mov    %eax,%esi
f010155d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101560:	39 f0                	cmp    %esi,%eax
f0101562:	74 1c                	je     f0101580 <memcmp+0x30>
		if (*s1 != *s2)
f0101564:	0f b6 08             	movzbl (%eax),%ecx
f0101567:	0f b6 1a             	movzbl (%edx),%ebx
f010156a:	38 d9                	cmp    %bl,%cl
f010156c:	75 08                	jne    f0101576 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010156e:	83 c0 01             	add    $0x1,%eax
f0101571:	83 c2 01             	add    $0x1,%edx
f0101574:	eb ea                	jmp    f0101560 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0101576:	0f b6 c1             	movzbl %cl,%eax
f0101579:	0f b6 db             	movzbl %bl,%ebx
f010157c:	29 d8                	sub    %ebx,%eax
f010157e:	eb 05                	jmp    f0101585 <memcmp+0x35>
	}

	return 0;
f0101580:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101585:	5b                   	pop    %ebx
f0101586:	5e                   	pop    %esi
f0101587:	5d                   	pop    %ebp
f0101588:	c3                   	ret    

f0101589 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101589:	55                   	push   %ebp
f010158a:	89 e5                	mov    %esp,%ebp
f010158c:	8b 45 08             	mov    0x8(%ebp),%eax
f010158f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101592:	89 c2                	mov    %eax,%edx
f0101594:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101597:	39 d0                	cmp    %edx,%eax
f0101599:	73 09                	jae    f01015a4 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010159b:	38 08                	cmp    %cl,(%eax)
f010159d:	74 05                	je     f01015a4 <memfind+0x1b>
	for (; s < ends; s++)
f010159f:	83 c0 01             	add    $0x1,%eax
f01015a2:	eb f3                	jmp    f0101597 <memfind+0xe>
			break;
	return (void *) s;
}
f01015a4:	5d                   	pop    %ebp
f01015a5:	c3                   	ret    

f01015a6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01015a6:	55                   	push   %ebp
f01015a7:	89 e5                	mov    %esp,%ebp
f01015a9:	57                   	push   %edi
f01015aa:	56                   	push   %esi
f01015ab:	53                   	push   %ebx
f01015ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015b2:	eb 03                	jmp    f01015b7 <strtol+0x11>
		s++;
f01015b4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01015b7:	0f b6 01             	movzbl (%ecx),%eax
f01015ba:	3c 20                	cmp    $0x20,%al
f01015bc:	74 f6                	je     f01015b4 <strtol+0xe>
f01015be:	3c 09                	cmp    $0x9,%al
f01015c0:	74 f2                	je     f01015b4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01015c2:	3c 2b                	cmp    $0x2b,%al
f01015c4:	74 2e                	je     f01015f4 <strtol+0x4e>
	int neg = 0;
f01015c6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01015cb:	3c 2d                	cmp    $0x2d,%al
f01015cd:	74 2f                	je     f01015fe <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01015cf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01015d5:	75 05                	jne    f01015dc <strtol+0x36>
f01015d7:	80 39 30             	cmpb   $0x30,(%ecx)
f01015da:	74 2c                	je     f0101608 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015dc:	85 db                	test   %ebx,%ebx
f01015de:	75 0a                	jne    f01015ea <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01015e0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01015e5:	80 39 30             	cmpb   $0x30,(%ecx)
f01015e8:	74 28                	je     f0101612 <strtol+0x6c>
		base = 10;
f01015ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01015ef:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01015f2:	eb 50                	jmp    f0101644 <strtol+0x9e>
		s++;
f01015f4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01015f7:	bf 00 00 00 00       	mov    $0x0,%edi
f01015fc:	eb d1                	jmp    f01015cf <strtol+0x29>
		s++, neg = 1;
f01015fe:	83 c1 01             	add    $0x1,%ecx
f0101601:	bf 01 00 00 00       	mov    $0x1,%edi
f0101606:	eb c7                	jmp    f01015cf <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101608:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010160c:	74 0e                	je     f010161c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f010160e:	85 db                	test   %ebx,%ebx
f0101610:	75 d8                	jne    f01015ea <strtol+0x44>
		s++, base = 8;
f0101612:	83 c1 01             	add    $0x1,%ecx
f0101615:	bb 08 00 00 00       	mov    $0x8,%ebx
f010161a:	eb ce                	jmp    f01015ea <strtol+0x44>
		s += 2, base = 16;
f010161c:	83 c1 02             	add    $0x2,%ecx
f010161f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101624:	eb c4                	jmp    f01015ea <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0101626:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101629:	89 f3                	mov    %esi,%ebx
f010162b:	80 fb 19             	cmp    $0x19,%bl
f010162e:	77 29                	ja     f0101659 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0101630:	0f be d2             	movsbl %dl,%edx
f0101633:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101636:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101639:	7d 30                	jge    f010166b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f010163b:	83 c1 01             	add    $0x1,%ecx
f010163e:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101642:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101644:	0f b6 11             	movzbl (%ecx),%edx
f0101647:	8d 72 d0             	lea    -0x30(%edx),%esi
f010164a:	89 f3                	mov    %esi,%ebx
f010164c:	80 fb 09             	cmp    $0x9,%bl
f010164f:	77 d5                	ja     f0101626 <strtol+0x80>
			dig = *s - '0';
f0101651:	0f be d2             	movsbl %dl,%edx
f0101654:	83 ea 30             	sub    $0x30,%edx
f0101657:	eb dd                	jmp    f0101636 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0101659:	8d 72 bf             	lea    -0x41(%edx),%esi
f010165c:	89 f3                	mov    %esi,%ebx
f010165e:	80 fb 19             	cmp    $0x19,%bl
f0101661:	77 08                	ja     f010166b <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101663:	0f be d2             	movsbl %dl,%edx
f0101666:	83 ea 37             	sub    $0x37,%edx
f0101669:	eb cb                	jmp    f0101636 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f010166b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010166f:	74 05                	je     f0101676 <strtol+0xd0>
		*endptr = (char *) s;
f0101671:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101674:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0101676:	89 c2                	mov    %eax,%edx
f0101678:	f7 da                	neg    %edx
f010167a:	85 ff                	test   %edi,%edi
f010167c:	0f 45 c2             	cmovne %edx,%eax
}
f010167f:	5b                   	pop    %ebx
f0101680:	5e                   	pop    %esi
f0101681:	5f                   	pop    %edi
f0101682:	5d                   	pop    %ebp
f0101683:	c3                   	ret    
f0101684:	66 90                	xchg   %ax,%ax
f0101686:	66 90                	xchg   %ax,%ax
f0101688:	66 90                	xchg   %ax,%ax
f010168a:	66 90                	xchg   %ax,%ax
f010168c:	66 90                	xchg   %ax,%ax
f010168e:	66 90                	xchg   %ax,%ax

f0101690 <__udivdi3>:
f0101690:	55                   	push   %ebp
f0101691:	57                   	push   %edi
f0101692:	56                   	push   %esi
f0101693:	53                   	push   %ebx
f0101694:	83 ec 1c             	sub    $0x1c,%esp
f0101697:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010169b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010169f:	8b 74 24 34          	mov    0x34(%esp),%esi
f01016a3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01016a7:	85 d2                	test   %edx,%edx
f01016a9:	75 35                	jne    f01016e0 <__udivdi3+0x50>
f01016ab:	39 f3                	cmp    %esi,%ebx
f01016ad:	0f 87 bd 00 00 00    	ja     f0101770 <__udivdi3+0xe0>
f01016b3:	85 db                	test   %ebx,%ebx
f01016b5:	89 d9                	mov    %ebx,%ecx
f01016b7:	75 0b                	jne    f01016c4 <__udivdi3+0x34>
f01016b9:	b8 01 00 00 00       	mov    $0x1,%eax
f01016be:	31 d2                	xor    %edx,%edx
f01016c0:	f7 f3                	div    %ebx
f01016c2:	89 c1                	mov    %eax,%ecx
f01016c4:	31 d2                	xor    %edx,%edx
f01016c6:	89 f0                	mov    %esi,%eax
f01016c8:	f7 f1                	div    %ecx
f01016ca:	89 c6                	mov    %eax,%esi
f01016cc:	89 e8                	mov    %ebp,%eax
f01016ce:	89 f7                	mov    %esi,%edi
f01016d0:	f7 f1                	div    %ecx
f01016d2:	89 fa                	mov    %edi,%edx
f01016d4:	83 c4 1c             	add    $0x1c,%esp
f01016d7:	5b                   	pop    %ebx
f01016d8:	5e                   	pop    %esi
f01016d9:	5f                   	pop    %edi
f01016da:	5d                   	pop    %ebp
f01016db:	c3                   	ret    
f01016dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01016e0:	39 f2                	cmp    %esi,%edx
f01016e2:	77 7c                	ja     f0101760 <__udivdi3+0xd0>
f01016e4:	0f bd fa             	bsr    %edx,%edi
f01016e7:	83 f7 1f             	xor    $0x1f,%edi
f01016ea:	0f 84 98 00 00 00    	je     f0101788 <__udivdi3+0xf8>
f01016f0:	89 f9                	mov    %edi,%ecx
f01016f2:	b8 20 00 00 00       	mov    $0x20,%eax
f01016f7:	29 f8                	sub    %edi,%eax
f01016f9:	d3 e2                	shl    %cl,%edx
f01016fb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01016ff:	89 c1                	mov    %eax,%ecx
f0101701:	89 da                	mov    %ebx,%edx
f0101703:	d3 ea                	shr    %cl,%edx
f0101705:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101709:	09 d1                	or     %edx,%ecx
f010170b:	89 f2                	mov    %esi,%edx
f010170d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101711:	89 f9                	mov    %edi,%ecx
f0101713:	d3 e3                	shl    %cl,%ebx
f0101715:	89 c1                	mov    %eax,%ecx
f0101717:	d3 ea                	shr    %cl,%edx
f0101719:	89 f9                	mov    %edi,%ecx
f010171b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010171f:	d3 e6                	shl    %cl,%esi
f0101721:	89 eb                	mov    %ebp,%ebx
f0101723:	89 c1                	mov    %eax,%ecx
f0101725:	d3 eb                	shr    %cl,%ebx
f0101727:	09 de                	or     %ebx,%esi
f0101729:	89 f0                	mov    %esi,%eax
f010172b:	f7 74 24 08          	divl   0x8(%esp)
f010172f:	89 d6                	mov    %edx,%esi
f0101731:	89 c3                	mov    %eax,%ebx
f0101733:	f7 64 24 0c          	mull   0xc(%esp)
f0101737:	39 d6                	cmp    %edx,%esi
f0101739:	72 0c                	jb     f0101747 <__udivdi3+0xb7>
f010173b:	89 f9                	mov    %edi,%ecx
f010173d:	d3 e5                	shl    %cl,%ebp
f010173f:	39 c5                	cmp    %eax,%ebp
f0101741:	73 5d                	jae    f01017a0 <__udivdi3+0x110>
f0101743:	39 d6                	cmp    %edx,%esi
f0101745:	75 59                	jne    f01017a0 <__udivdi3+0x110>
f0101747:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010174a:	31 ff                	xor    %edi,%edi
f010174c:	89 fa                	mov    %edi,%edx
f010174e:	83 c4 1c             	add    $0x1c,%esp
f0101751:	5b                   	pop    %ebx
f0101752:	5e                   	pop    %esi
f0101753:	5f                   	pop    %edi
f0101754:	5d                   	pop    %ebp
f0101755:	c3                   	ret    
f0101756:	8d 76 00             	lea    0x0(%esi),%esi
f0101759:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101760:	31 ff                	xor    %edi,%edi
f0101762:	31 c0                	xor    %eax,%eax
f0101764:	89 fa                	mov    %edi,%edx
f0101766:	83 c4 1c             	add    $0x1c,%esp
f0101769:	5b                   	pop    %ebx
f010176a:	5e                   	pop    %esi
f010176b:	5f                   	pop    %edi
f010176c:	5d                   	pop    %ebp
f010176d:	c3                   	ret    
f010176e:	66 90                	xchg   %ax,%ax
f0101770:	31 ff                	xor    %edi,%edi
f0101772:	89 e8                	mov    %ebp,%eax
f0101774:	89 f2                	mov    %esi,%edx
f0101776:	f7 f3                	div    %ebx
f0101778:	89 fa                	mov    %edi,%edx
f010177a:	83 c4 1c             	add    $0x1c,%esp
f010177d:	5b                   	pop    %ebx
f010177e:	5e                   	pop    %esi
f010177f:	5f                   	pop    %edi
f0101780:	5d                   	pop    %ebp
f0101781:	c3                   	ret    
f0101782:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101788:	39 f2                	cmp    %esi,%edx
f010178a:	72 06                	jb     f0101792 <__udivdi3+0x102>
f010178c:	31 c0                	xor    %eax,%eax
f010178e:	39 eb                	cmp    %ebp,%ebx
f0101790:	77 d2                	ja     f0101764 <__udivdi3+0xd4>
f0101792:	b8 01 00 00 00       	mov    $0x1,%eax
f0101797:	eb cb                	jmp    f0101764 <__udivdi3+0xd4>
f0101799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017a0:	89 d8                	mov    %ebx,%eax
f01017a2:	31 ff                	xor    %edi,%edi
f01017a4:	eb be                	jmp    f0101764 <__udivdi3+0xd4>
f01017a6:	66 90                	xchg   %ax,%ax
f01017a8:	66 90                	xchg   %ax,%ax
f01017aa:	66 90                	xchg   %ax,%ax
f01017ac:	66 90                	xchg   %ax,%ax
f01017ae:	66 90                	xchg   %ax,%ax

f01017b0 <__umoddi3>:
f01017b0:	55                   	push   %ebp
f01017b1:	57                   	push   %edi
f01017b2:	56                   	push   %esi
f01017b3:	53                   	push   %ebx
f01017b4:	83 ec 1c             	sub    $0x1c,%esp
f01017b7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01017bb:	8b 74 24 30          	mov    0x30(%esp),%esi
f01017bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01017c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01017c7:	85 ed                	test   %ebp,%ebp
f01017c9:	89 f0                	mov    %esi,%eax
f01017cb:	89 da                	mov    %ebx,%edx
f01017cd:	75 19                	jne    f01017e8 <__umoddi3+0x38>
f01017cf:	39 df                	cmp    %ebx,%edi
f01017d1:	0f 86 b1 00 00 00    	jbe    f0101888 <__umoddi3+0xd8>
f01017d7:	f7 f7                	div    %edi
f01017d9:	89 d0                	mov    %edx,%eax
f01017db:	31 d2                	xor    %edx,%edx
f01017dd:	83 c4 1c             	add    $0x1c,%esp
f01017e0:	5b                   	pop    %ebx
f01017e1:	5e                   	pop    %esi
f01017e2:	5f                   	pop    %edi
f01017e3:	5d                   	pop    %ebp
f01017e4:	c3                   	ret    
f01017e5:	8d 76 00             	lea    0x0(%esi),%esi
f01017e8:	39 dd                	cmp    %ebx,%ebp
f01017ea:	77 f1                	ja     f01017dd <__umoddi3+0x2d>
f01017ec:	0f bd cd             	bsr    %ebp,%ecx
f01017ef:	83 f1 1f             	xor    $0x1f,%ecx
f01017f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01017f6:	0f 84 b4 00 00 00    	je     f01018b0 <__umoddi3+0x100>
f01017fc:	b8 20 00 00 00       	mov    $0x20,%eax
f0101801:	89 c2                	mov    %eax,%edx
f0101803:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101807:	29 c2                	sub    %eax,%edx
f0101809:	89 c1                	mov    %eax,%ecx
f010180b:	89 f8                	mov    %edi,%eax
f010180d:	d3 e5                	shl    %cl,%ebp
f010180f:	89 d1                	mov    %edx,%ecx
f0101811:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101815:	d3 e8                	shr    %cl,%eax
f0101817:	09 c5                	or     %eax,%ebp
f0101819:	8b 44 24 04          	mov    0x4(%esp),%eax
f010181d:	89 c1                	mov    %eax,%ecx
f010181f:	d3 e7                	shl    %cl,%edi
f0101821:	89 d1                	mov    %edx,%ecx
f0101823:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101827:	89 df                	mov    %ebx,%edi
f0101829:	d3 ef                	shr    %cl,%edi
f010182b:	89 c1                	mov    %eax,%ecx
f010182d:	89 f0                	mov    %esi,%eax
f010182f:	d3 e3                	shl    %cl,%ebx
f0101831:	89 d1                	mov    %edx,%ecx
f0101833:	89 fa                	mov    %edi,%edx
f0101835:	d3 e8                	shr    %cl,%eax
f0101837:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010183c:	09 d8                	or     %ebx,%eax
f010183e:	f7 f5                	div    %ebp
f0101840:	d3 e6                	shl    %cl,%esi
f0101842:	89 d1                	mov    %edx,%ecx
f0101844:	f7 64 24 08          	mull   0x8(%esp)
f0101848:	39 d1                	cmp    %edx,%ecx
f010184a:	89 c3                	mov    %eax,%ebx
f010184c:	89 d7                	mov    %edx,%edi
f010184e:	72 06                	jb     f0101856 <__umoddi3+0xa6>
f0101850:	75 0e                	jne    f0101860 <__umoddi3+0xb0>
f0101852:	39 c6                	cmp    %eax,%esi
f0101854:	73 0a                	jae    f0101860 <__umoddi3+0xb0>
f0101856:	2b 44 24 08          	sub    0x8(%esp),%eax
f010185a:	19 ea                	sbb    %ebp,%edx
f010185c:	89 d7                	mov    %edx,%edi
f010185e:	89 c3                	mov    %eax,%ebx
f0101860:	89 ca                	mov    %ecx,%edx
f0101862:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101867:	29 de                	sub    %ebx,%esi
f0101869:	19 fa                	sbb    %edi,%edx
f010186b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010186f:	89 d0                	mov    %edx,%eax
f0101871:	d3 e0                	shl    %cl,%eax
f0101873:	89 d9                	mov    %ebx,%ecx
f0101875:	d3 ee                	shr    %cl,%esi
f0101877:	d3 ea                	shr    %cl,%edx
f0101879:	09 f0                	or     %esi,%eax
f010187b:	83 c4 1c             	add    $0x1c,%esp
f010187e:	5b                   	pop    %ebx
f010187f:	5e                   	pop    %esi
f0101880:	5f                   	pop    %edi
f0101881:	5d                   	pop    %ebp
f0101882:	c3                   	ret    
f0101883:	90                   	nop
f0101884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101888:	85 ff                	test   %edi,%edi
f010188a:	89 f9                	mov    %edi,%ecx
f010188c:	75 0b                	jne    f0101899 <__umoddi3+0xe9>
f010188e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101893:	31 d2                	xor    %edx,%edx
f0101895:	f7 f7                	div    %edi
f0101897:	89 c1                	mov    %eax,%ecx
f0101899:	89 d8                	mov    %ebx,%eax
f010189b:	31 d2                	xor    %edx,%edx
f010189d:	f7 f1                	div    %ecx
f010189f:	89 f0                	mov    %esi,%eax
f01018a1:	f7 f1                	div    %ecx
f01018a3:	e9 31 ff ff ff       	jmp    f01017d9 <__umoddi3+0x29>
f01018a8:	90                   	nop
f01018a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018b0:	39 dd                	cmp    %ebx,%ebp
f01018b2:	72 08                	jb     f01018bc <__umoddi3+0x10c>
f01018b4:	39 f7                	cmp    %esi,%edi
f01018b6:	0f 87 21 ff ff ff    	ja     f01017dd <__umoddi3+0x2d>
f01018bc:	89 da                	mov    %ebx,%edx
f01018be:	89 f0                	mov    %esi,%eax
f01018c0:	29 f8                	sub    %edi,%eax
f01018c2:	19 ea                	sbb    %ebp,%edx
f01018c4:	e9 14 ff ff ff       	jmp    f01017dd <__umoddi3+0x2d>
