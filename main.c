/*******************************************************************************
* File Name:   main.c
*
* Description: This is a quick demo for RTT.
*
* Related Document: See README.md
*******************************************************************************/

/*******************************************************************************
* Header Files
*******************************************************************************/
#include "cy_syslib.h"
#include <stdint.h>
#include "cybsp.h"
#include "SEGGER_RTT.h"

/******************************************************************************
* Macros
*******************************************************************************/

#define RTT_CHANNEL_0 0
#define RTT_CHANNEL_1 1
#define RTT_USE_FAST_RTT  1
#define buffer_size 4*32

/*******************************************************************************
* Global Variables
*******************************************************************************/
static uint8_t UpBuf0[buffer_size];
static uint8_t DownBuf0[buffer_size];

static uint8_t UpBuf1[buffer_size];
static uint8_t DownBuf1[buffer_size];

uint32_t symbol='!';

/*******************************************************************************
* Function Name: main - test RTT
*********************************************************************************/

int main(void)
{
    cy_rslt_t result;

#if defined (CY_DEVICE_SECURE) && defined (CY_USING_HAL)
    cyhal_wdt_t wdt_obj;

    /* Clear watchdog timer so that it doesn't trigger a reset */
    result = cyhal_wdt_init(&wdt_obj, cyhal_wdt_get_max_timeout_ms());
    CY_ASSERT(CY_RSLT_SUCCESS == result);
    cyhal_wdt_free(&wdt_obj);
#endif

    /* Initialize the device and board peripherals */
    result = cybsp_init();

    /* Board init failed. Stop program execution */
    if (result != CY_RSLT_SUCCESS)
    {
        CY_ASSERT(0);
    }

    /* Enable global interrupts */
    __enable_irq();

    SEGGER_RTT_Init();
    // Setup buffers for both channels
    SEGGER_RTT_ConfigUpBuffer(RTT_CHANNEL_0, "RTT_0", &UpBuf0, sizeof(UpBuf0), SEGGER_RTT_MODE_NO_BLOCK_TRIM);
    SEGGER_RTT_ConfigDownBuffer(RTT_CHANNEL_0, "RTT_0", DownBuf0, sizeof(DownBuf0), SEGGER_RTT_MODE_BLOCK_IF_FIFO_FULL);

    SEGGER_RTT_ConfigUpBuffer(RTT_CHANNEL_1, "RTT_1", &UpBuf1, sizeof(UpBuf1), SEGGER_RTT_MODE_NO_BLOCK_TRIM);
    SEGGER_RTT_ConfigDownBuffer(RTT_CHANNEL_1, "RTT_1", DownBuf1, sizeof(DownBuf1), SEGGER_RTT_MODE_BLOCK_IF_FIFO_FULL);

    for (;;)
    {
        Cy_SysLib_Delay(10);
        symbol=symbol+1;
        if(symbol%'~'==0)
        {
            symbol='!';
        }
        // Setup buffers for both channels
        SEGGER_RTT_Write(RTT_CHANNEL_0, &symbol, sizeof(symbol));
        SEGGER_RTT_printf(RTT_CHANNEL_1, "Testing Printf on channel 1: %c\r\n", symbol);
    }
}

/* [] END OF FILE */
