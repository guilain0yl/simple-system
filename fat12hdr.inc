BS_OEMName	db	'ForrestY'	;OEM String,����8���ֽ�

BPB_BytsPerSec	dw	512		;ÿ�����ֽ���
BPB_SecPerClus	db	1		;ÿ�ض�������
BPB_RsvdSecCnt	dw	1		;Boot��¼ռ�ö�������
BPB_NumFATs	db	2		;���ж���FAT��
BPB_RootEntCnt	dw	224		;��Ŀ¼�ļ������ֵ
BPB_TotSec16	dw	2880		;�߼�������
BPB_Media	db	0xf0		;ý��������
BPB_FATSz16	dw	9		;ÿFAT������
BPB_SecPerTrk	dw	18		;ÿ�ŵ�������
BPB_NumHeads	dw	2		;��ͷ��(����)
BPB_HiddSec	dd	0		;����������
BPB_TotSec32	dd	0		;���wTotalSectorCount16��0�������ֵ��¼����

BS_DrvNum	db	0		;�ж�13��������
BS_Reserved1	db	0		;δʹ��
BS_BootSig	db	29h		;��չ�������
BS_VolID	dd	0		;�����к�
BS_VolLab	db	'OrangeS0.02'	;���꣬����11���ֽ�
BS_FileSysType	db	'FAT12   '	;�ļ�ϵͳ���ͣ�����8���ֽ�


;------------------------------------------------------
;����FAT12ͷ��һЩ�������壬���ͷ��Ϣ�ı䣬���泣��Ҳ��Ҫ�ı�
;------------------------------------------------------
;BPB_FATSz16

FATSz			equ	9

;��Ŀ¼ռ�ÿռ�

RootDirSectors=((BPB_RootEntCnt*32)+(BPB_BytsPerSec-1))/BPB_BytsPerSec

RootDirSectors		equ	14

;Root Directory�ĵ�һ��������  =BPB_RsvdSecCnt+(BPB_NumFATs*FATSz)

SectorNoOfRootDirectory	equ	19

;FAT1�ĵ�һ��������=BPB_RsvdSecCnt
SectorNoOfFAT1		equ	1

;DeltaSectorNo=BPB_RsvdSecCnt+(BPB_NumFATs*FATSz)-2
;�ļ��Ŀ�ʼSector��=DirEntry�еĿ�ʼSetor��+��Ŀ¼ռ��Sector��Ŀ+DeltaSectorNo
DeltaSectorNo		equ	17