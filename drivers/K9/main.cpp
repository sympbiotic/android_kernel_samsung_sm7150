#include "kernel.h"

int main(int argc,char **argv)
{
	PACKAGENAME* bm="com.tencent.tmgp.pubgmhd";
	getPID(bm);
	printf("pid = %d\n", pid);
	uint64_t add=GetModuleBaseAddr("libUE4.so");
	printf("base = %lX\n", add);

	uint64_t add1=ReadValue(add+0x1073E0B8);
	printf("指针 = %lX\n",add1);
    uint64_t Gname = ReadValue(add + 0x1014B650);
	printf("世界 = %lX\n",Gname);
    uint64_t Matrix = ReadValue(ReadValue(add + 0x107114E0) + 0x20) + 0x270;//270矩阵
    printf("矩阵 = %lX\n",Matrix);
};
