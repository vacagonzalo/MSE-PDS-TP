#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "sleep.h"

#define CFAR_BASE_ADDR 0x43c00000
#define ADDR_OFFSET 0x4

#define CFAR_SLV0_ADDR (CFAR_BASE_ADDR)
#define CFAR_SLV1_ADDR (CFAR_SLV0_ADDR + ADDR_OFFSET)
#define CFAR_SLV2_ADDR (CFAR_SLV1_ADDR + ADDR_OFFSET)
#define CFAR_SLV3_ADDR (CFAR_SLV2_ADDR + ADDR_OFFSET)

/* SLV0 bits (control) */
#define POS_CLOCK 0
#define POS_RESET 1
#define POS_ENABLE 2

#define SET_BIT(x, pos) (x |= (1U << pos))
#define CLEAR_BIT(x, pos) (x &= (~(1U<< pos)))

u32 cfar_slv0_val = 0;
u32 cfar_slv1_val = 0;
u32 cfar_slv2_val = 0;
u32 cfar_slv3_val = 0;

int main()
{
    init_platform();

    for(;;)
    {
		/* RESET TEST */
		print("Reset test...\r\n");
		SET_BIT(cfar_slv0_val, POS_ENABLE);
		Xil_Out32(CFAR_SLV0_ADDR, cfar_slv0_val);
		usleep(1000);

		for(u32 i = 0; i < 49; ++i)
		{
			SET_BIT(cfar_slv0_val, POS_CLOCK);
			Xil_Out32(CFAR_SLV0_ADDR, cfar_slv0_val);
			usleep(1000);

			CLEAR_BIT(cfar_slv0_val, POS_CLOCK);
			Xil_Out32(CFAR_SLV0_ADDR, cfar_slv0_val);
			usleep(1000);
		}
		cfar_slv3_val = Xil_In32(CFAR_SLV3_ADDR);
		if(cfar_slv3_val & 1)
		{
			/* Target detected */
			print("Reset test FAIL\r\n");
		}
		else
		{
			/* No target */
			print("Reset test PASS\r\n");
		}

		/* NO TARGET TEST */
		print("No_target test...\r\n");
		SET_BIT(cfar_slv0_val, POS_RESET);
		Xil_Out32(CFAR_SLV0_ADDR, cfar_slv0_val);
		usleep(1000);
		Xil_Out32(CFAR_SLV1_ADDR, cfar_slv1_val);
		usleep(1000);

		for(u32 i = 0; i < 49; ++i)
		{
			SET_BIT(cfar_slv0_val, POS_CLOCK);
			Xil_Out32(CFAR_SLV0_ADDR, cfar_slv0_val);
			usleep(1000);

			CLEAR_BIT(cfar_slv0_val, POS_CLOCK);
			Xil_Out32(CFAR_SLV0_ADDR, cfar_slv0_val);
			usleep(1000);
		}
		cfar_slv3_val = Xil_In32(CFAR_SLV3_ADDR);
		if(cfar_slv3_val & 1)
		{
			/* Target detected */
			print("No_target test FAIL\r\n");
		}
		else
		{
			/* No target */
			print("No_target test PASS\r\n");
		}

		/* Target test */
		print("Target_detected test...\r\n");

		cfar_slv2_val = 0xf;
		Xil_Out32(CFAR_SLV2_ADDR, cfar_slv2_val);
		usleep(1000);

		SET_BIT(cfar_slv0_val, POS_CLOCK);
		Xil_Out32(CFAR_SLV0_ADDR, cfar_slv0_val);
		usleep(1000);

		CLEAR_BIT(cfar_slv0_val, POS_CLOCK);
		Xil_Out32(CFAR_SLV0_ADDR, cfar_slv0_val);
		usleep(1000);

		cfar_slv2_val = 0xe;

		for(u32 i = 0; i < 25; ++i)
		{
			SET_BIT(cfar_slv0_val, POS_CLOCK);
			Xil_Out32(CFAR_SLV0_ADDR, cfar_slv0_val);
			usleep(1000);

			CLEAR_BIT(cfar_slv0_val, POS_CLOCK);
			Xil_Out32(CFAR_SLV0_ADDR, cfar_slv0_val);
			usleep(1000);
		}

		if(cfar_slv3_val & 1)
		{
			/* Target detected */
			print("Target_detected test PASS\r\n");
		}
		else
		{
			/* No target */
			print("Target_detected test FAIL\r\n");
		}


		CLEAR_BIT(cfar_slv0_val, POS_RESET);
		Xil_Out32(CFAR_SLV0_ADDR, cfar_slv0_val);
		usleep(1000);
		SET_BIT(cfar_slv0_val, POS_CLOCK);
		Xil_Out32(CFAR_SLV0_ADDR, cfar_slv0_val);
		usleep(1000);
		CLEAR_BIT(cfar_slv0_val, POS_CLOCK);
		Xil_Out32(CFAR_SLV0_ADDR, cfar_slv0_val);
		usleep(1000);


		cfar_slv0_val = 0;
		cfar_slv1_val = 0;
		cfar_slv2_val = 0;
		cfar_slv3_val = 0;
		usleep(2000000);
    }

    cleanup_platform();
    return 0;
}