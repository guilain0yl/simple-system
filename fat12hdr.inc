BS_OEMName	db	'ForrestY'	;OEM String,必须8个字节

BPB_BytsPerSec	dw	512		;每扇区字节数
BPB_SecPerClus	db	1		;每簇多少扇区
BPB_RsvdSecCnt	dw	1		;Boot记录占用多少扇区
BPB_NumFATs	db	2		;共有多少FAT表
BPB_RootEntCnt	dw	224		;根目录文件数最大值
BPB_TotSec16	dw	2880		;逻辑扇区数
BPB_Media	db	0xf0		;媒体描述符
BPB_FATSz16	dw	9		;每FAT扇区数
BPB_SecPerTrk	dw	18		;每磁道扇区数
BPB_NumHeads	dw	2		;磁头数(面数)
BPB_HiddSec	dd	0		;隐藏扇区数
BPB_TotSec32	dd	0		;如果wTotalSectorCount16是0，由这个值记录扇区

BS_DrvNum	db	0		;中断13的驱动号
BS_Reserved1	db	0		;未使用
BS_BootSig	db	29h		;扩展引导标记
BS_VolID	dd	0		;卷序列号
BS_VolLab	db	'OrangeS0.02'	;卷标，必须11个字节
BS_FileSysType	db	'FAT12   '	;文件系统类型，必须8个字节


;------------------------------------------------------
;基于FAT12头的一些常量定义，如果头信息改变，下面常量也需要改变
;------------------------------------------------------
;BPB_FATSz16

FATSz			equ	9

;根目录占用空间

RootDirSectors=((BPB_RootEntCnt*32)+(BPB_BytsPerSec-1))/BPB_BytsPerSec

RootDirSectors		equ	14

;Root Directory的第一个扇区号  =BPB_RsvdSecCnt+(BPB_NumFATs*FATSz)

SectorNoOfRootDirectory	equ	19

;FAT1的第一个扇区号=BPB_RsvdSecCnt
SectorNoOfFAT1		equ	1

;DeltaSectorNo=BPB_RsvdSecCnt+(BPB_NumFATs*FATSz)-2
;文件的开始Sector号=DirEntry中的开始Setor号+根目录占用Sector数目+DeltaSectorNo
DeltaSectorNo		equ	17