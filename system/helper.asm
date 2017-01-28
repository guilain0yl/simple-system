==================================================================Help_Document=====================================================================
This document is a helper!
Content is about CR register!
CR0:
=====================================================================================
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
P  C  N                                A     W                            N E T E M P
G  D  W                                M     P                            E T S M P E
=====================================================================================
If your computer is 64 bit,CR is a 64-bit register!
For example CR0:0~63,and the location of the 32~63 are reserved.
Bits	Mnemonlc	Description		R/W
====================================================
63~32	Reserved	Reserved,Must be Zero	
31	PG		Paging			R/W
30	CD		Cache Disable		R/W
29	NW		Not Wtitethrough	R/W
28~19	Reserved	Reserved		
18	AM		Alignment Mask		R/W
17	Reserved	Reserved		
16	WP		Write Protect		R/W
15~6	Reserved	Reserved		
5	NE		Numeric Error		R/W
4	ET		Extension Type		R
3	TS		Task Switched		R/W
2	EM		Emulation		R/W
1	MP		Monitor Coprpcessor	R/W
0	PE		Protection Enable	R/W
=====================================================

CR2:存放发生页错误时的虚拟地址	0~31 bit

CR3:用来存放最高级页目录地址(物理地址），各级页表项中存放的也是物理地址
32bit
0~2	Reaerved
3	PWT
4	PCD
5~11	Reserved
12~31	Page-Directory-Table Base Address
3-4
0~2	Reserved
3	PWT
4	PCD
5~31	Page-Directory-Pointer-Table Base Address
3-5
64bit
0~2	Reserved
3	PWT
4	PCD
5~11	Reserved
12~31	Page-Map Level-4 Table Base Address
32~51	Page-Map Level-4 Table Base Address(This is an architectural limit.A given implementation may support fewer bits.)
52~63	Reserved,MBZ


Page-Level Writethrough (PWT) Bit. Bit 3. Page-level writethrough indicates whether the highest-
level page-translation table has a writeback or writethrough caching policy. When PWT=0, the table
has a writeback caching policy. When PWT=1, the table has a writethrough caching policy.
Page-Level Cache Disable (PCD) Bit. Bit 4. PCD=1,表示最高目录表不可缓存，PCD=0,相反。
    图3-4中不使用PAE技术，有两层页表。最高层为页目录有1024项，占用4KB。page_directory_table base address为物理地址，指向4KB对齐的页目录地址。
    图3-5中，使用PAE技术，三层页表寻址。最高层为页目录指针，4项，占用32B空间。所以  page_directory_table base address为27位，指向32B对齐的页目录指针表。






CR4:
===============================================================================================
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11   10     9   8 7 6 5 4 3 2 1 0
                                       O                        OSXMM  OSF  P P M P P D T P V
				       S                        EXCPT  XSR  C G C A S E S V M
				       X                                    E E E E E   D I E
				       S
				       A
				       V
			               E
================================================================================================

Bits	Mnemonlc	Description					Access Type
===================================================================================
63~19	-		Reserved					Reserved,MBZ
18	OSXSAVE		XSAVE and Processor Extended States Enable Bit	R/W
17~11	-		Reserved					Reserved,MBZ
10	OSXMMEXCPT	Operating System Unmasked Exception Support	R/W
9	OSFXSR		Operating System FXSAVE/FXRSTOR Support		R/W
8	PCE		Performance-Monitoring Counter Enable		R/W
7	PGE		Page-Global Enable				R/W
6	MCE		Machine Check Enable				R/W
5	PAE		Physiacl-Address Extension			R/W
4	PSE		Page Size Extensions				R/W
3	DE		Debugging Extensions				R/W
2	TSD		Time Stamp Disable				R/W
1	PVI		Protected-Mode Virtual Interrupts		R/W
0	VME		Virtual-8086 Mode Extensions			R/W
============================================================================


Virtual-8086 Mode Extensions (VME) Bit. Bit 0. Setting VME to 1 enables hardware-supported
performance enhancements for software running in virtual-8086 mode. Clearing VME to 0 disables
this support. The enhancements enabled when VME=1 include:

Virtualized, maskable, external-interrupt control and notification using the VIF and VIP bits in the
rFLAGS register. Virtualizing affects the operation of several instructions that manipulate the
rFLAGS.IF bit.
Selective intercept of software interrupts (INTn instructions) using the interrupt-redirection
bitmap in the TSS.
Protected-Mode Virtual Interrupts (PVI) Bit. Bit 1. Setting PVI to 1 enables support for protected-
mode virtual interrupts. Clearing PVI to 0 disables this support. When PVI=1, hardware support of
two bits in the rFLAGS register, VIF and VIP, is enabled.
Only the STI and CLI instructions are affected by enabling PVI. Unlike the case when CR0.VME=1,
the interrupt-redirection bitmap in the TSS cannot be used for selective INTn interception.
PVI enhancements are also supported in long mode. See “Virtual Interrupts” on page 251 for more
information on using PVI.
Time-Stamp Disable (TSD) Bit. Bit 2. The TSD bit allows software to control the privilege level at
which the time-stamp counter can be read. When TSD is cleared to 0, software running at any privilege
level can read the time-stamp counter using the RDTSC or RDTSCP instructions. When TSD is set to
1, only software running at privilege-level 0 can execute the RDTSC or RDTSCP instructions.
Debugging Extensions (DE) Bit. Bit 3. Setting the DE bit to 1 enables the I/O breakpoint capability
and enforces treatment of the DR4 and DR5 registers as reserved. Software that accesses DR4 or DR5
when DE=1 causes a invalid opcode exception (#UD).
When the DE bit is cleared to 0, I/O breakpoint capabilities are disabled. Software references to the
DR4 and DR5 registers are aliased to the DR6 and DR7 registers, respectively.
Page-Size Extensions (PSE) Bit. Bit 4. PSE=1,启用PSE，PSE=0，不启用。
Physical-Address Extension (PAE) Bit. Bit 5.PAE=1,启用PAE，支持2MB的超级页（superpage）；PAE=0,不启用PAE。
Machine-Check Enable (MCE) Bit. Bit 6. Setting MCE to 1 enables the machine-check exception
mechanism. Clearing this bit to 0 disables the mechanism. When enabled, a machine-check exception
(#MC) occurs when an uncorrectable machine-check error is encountered.
Regardless of whether machine-check exceptions are enabled, the processor records enabled-errors
when they occur. Error-reporting is performed by the machine-check error-reporting register banks.
Each bank includes a control register for enabling error reporting and a status register for capturing
errors. Correctable machine-check errors are also reported, but they do not cause a machine-check
exception.
See Chapter 9, “Machine Check Mechanism,” for a description of the machine-check mechanism, the
registers used, and the types of errors captured by the mechanism.
Page-Global Enable (PGE) Bit. Bit 7. When page translation is enabled, system-software
performance can often be improved by making some page translations global to all tasks and
procedures. Setting PGE to 1 enables the global-page mechanism. Clearing this bit to 0 disables the
mechanism.
When PGE is enabled, system software can set the global-page (G) bit in the lowest level of the pagetranslation hierarchy to 1, indicating that the page translation is global. Page translations marked asglobal are not invalidated in the TLB when the page-translation-table base address (CR3) is updated.
When the G bit is cleared, the page translation is not global. All supported physical-page sizes also support the global-page mechanism. See “Global Pages” on page 142 for information on using the global-page mechanism.
Performance-Monitoring Counter Enable (PCE) Bit. Bit 8. Setting PCE to 1 allows software running at any privilege level to use the RDPMC instruction. Software uses the RDPMC instruction to read the performance-monitoring MSRs, PerfCtrn. Clearing PCE to 0 allows only the most-privileged software (CPL=0) to use the RDPMC instruction.
FXSAVE/FXRSTOR Support (OSFXSR) Bit. Bit 9. System software must set the OSFXSR bit to 1 to enable use of the 256-bit and 128-bit media instructions. When this bit is set to 1, it also indicates
that system software uses the FXSAVE and FXRSTOR instructions to save and restore the processor
state for the x87, 64-bit media, and 128-bit media instructions.
Clearing the OSFXSR bit to 0 indicates that 256-bit and 128-bit media instructions cannot be used.
Attempts to use those instructions while this bit is clear result in an invalid-opcode exception (#UD).
Software can continue to use the FXSAVE/FXRSTOR instructions for saving and restoring the processor state for the x87 and 64-bit media instructions.
Unmasked Exception Support (OSXMMEXCPT) Bit. Bit 10. System software must set the OSXMMEXCPT bit to 1 when it supports the SIMD floating-point exception (#XF) for handling of unmasked 256-bit and 128-bit media floating-point errors. Clearing the OSXMMEXCPT bit to 0 indicates the #XF handler is not supported. When OSXMMEXCPT=0, unmasked 128-bit media floating-point exceptions cause an invalid-opcode exception (#UD). See “SIMD Floating-Point Exception Causes” in Volume 1 for more information on unmasked SSE floating-point exceptions.
XSAVE and Extended States (OSXSAVE) Bit. Bit 18. If this bit is set to 1 then the operating system
supports the XGETBV, XSETBV, XSAVE and XRSTOR instructions. The processor will also be able
to execute XGETBV and XSETBV instructions in order to read and write XCR0. Also, if set, the
XSAVE and XRSTOR instructions can save and restore the x87 FPU state (including MMX registers),
the SSE state (YMM/XMM registers and MXCSR), along with other processor extended states
enabled in XCR0.




EFER:
=======================================================================================
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
                                                   F  L  S  N  L  M L               S
						   F  M  V  X  M  B M               C
						   X  S  M  E  A  Z E               E
						   S  L  E
						   R  E
========================================================================================


Bits	Mnemonlc	Description			R/W
===========================================================
63~15	Reserved,MBZ	Reserved,Must be Zero		
14	FFXSR		Fast FXSAVE/FXRSTOR		R/W
13	LMSLE		Long Mode Segment Limit Enable	R/W
12	SVME		Secure Virtual Machine Enable	R/W
11	NXE		No-Execute Enable		R/W
10	LMA		Long Mode Active		R
9	Reserved,MBZ	Reserved,Must be Zero		
8	LME		Long Mode Enable		R/W
7~1	Reserved,RAZ	Reserved,Must be Zero		
0	SCE		System Call Extensions		R/W
============================================================


System-Call Extension (SCE) Bit. Bit 0. Setting this bit to 1 enables the SYSCALL and SYSRET
instructions. Application software can use these instructions for low-latency system calls and returns in a non-segmented (flat) address space. See “Fast System Call and Return” on page 152 for additional information.
Long Mode Enable (LME) Bit. Bit 8. LME=1,启用long mode，注意必须先将CR0.PG=0后才能设置LME=1,然后再设置CR0.PG=1，则进入long mode。LME=0 ，使用legacy mode。
Long Mode Active (LMA) Bit. Bit 10, read-only. This bit indicates that long mode is active. The
processor sets LMA to 1 when both long mode and paging have been enabled by system software. See
Chapter 14, “Processor Initialization and Long Mode Activation,” for more information on activating long mode.
When LMA=1, the processor is running either in compatibility mode or 64-bit mode, depending on the
value of the L bit in a code-segment descriptor, as shown in Figure 1-6 on page 12.
When LMA=0, the processor is running in legacy mode. In this mode, the processor behaves like a
standard 32-bit x86 processor, with none of the new 64-bit features enabled.
No-Execute Enable (NXE) Bit. Bit 11. Setting this bit to 1 enables the no-execute page-protection
feature. The feature is disabled when this bit is cleared to 0. See “No Execute (NX) Bit” on page 145 for more information.
Before setting NXE, system software should verify the processor supports the feature by examining
the extended-feature flags returned by the CPUID instruction. For more information, see the CPUID
Specification, order# 25481.
Secure Virtual Machine Enable (SVME) Bit. Bit 12. Enables the SVM extensions. When this bit is
zero, the SVM instructions cause #UD exceptions. EFER.SVME defaults to a reset value of zero. The
effect of turning off EFER.SVME while a guest is running is undefined; therefore, the VMM should
always prevent guests from writing EFER. SVM extensions can be disabled  by setting  VM_CR.SVME_DISABLE .  For more information, see descriptions of LOCK and SMVE_DISABLE bits in Section 15.29.1, “VM_CR MSR (C001_0114h),” on page 431.
Long Mode Segment Limit Enable (LMSLE) bit. Bit 13. Setting this bit to 1 enables certain limit
checks in 64-bit mode. See Section 4.12.2, "Data Limit Checks in 64-bit Mode", for more information
on these limit checks.
Fast FXSAVE/FXRSTOR (FFXSR) Bit. Bit 14. Setting this bit to 1 enables the FXSAVE and FXRSTOR instructions to execute faster in 64-bit mode at CPL 0. This is accomplished by not saving or restoring the XMM registers (XMM0-XMM15). The FFXSR bit has no effect when the FXSAVE/FXRSTOR instructions are executed in non 64-bit mode, or when CPL > 0. The FFXSR bit does not affect the save/restore of the legacy x87 floating-point state, or the save/restore of MXCSR.
Before setting FFXSR, system software should verify whether this feature is supported by examining
the CPUID extended feature flags returned by the CPUID instruction. For more information, see
"Function 8000_0001h: Processor Signature and AMD Features" in Volume 3.




