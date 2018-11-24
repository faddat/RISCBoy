#ifndef _UART_H_
#define _UART_H_

#include <stdint.h>
#include <stdbool.h>

#include "addressmap.h"
#include "hw/uart_regs.h"

DECL_REG(UART_BASE + UART_CSR_OFFS, UART_CSR);
DECL_REG(UART_BASE + UART_DIV_OFFS, UART_DIV);
DECL_REG(UART_BASE + UART_FSTAT_OFFS, UART_FSTAT);
DECL_REG(UART_BASE + UART_TX_OFFS, UART_TX);
DECL_REG(UART_BASE + UART_RX_OFFS, UART_RX);

static inline void uart_enable(bool en)
{
	*UART_CSR = *UART_CSR & ~UART_CSR_EN_MASK | (!!en << UART_CSR_EN_LSB);
}

// 16.8 fixed point format.
// Encodes number of clock cycles per clock enable.
// Each baud period is 16 clock enables (default modparam)
static inline void uart_clkdiv(uint32_t div)
{
	*UART_DIV = div;
}

static inline bool uart_tx_full()
{
	return !!(*UART_FSTAT & UART_FSTAT_TXFULL_MASK);
}

static inline bool uart_tx_empty()
{
	return !!(*UART_FSTAT & UART_FSTAT_TXEMPTY_MASK);
}

static inline size_t uart_tx_level()
{
	return (*UART_FSTAT & UART_FSTAT_TXLEVEL_MASK) >> UART_FSTAT_TXLEVEL_LSB;
}

static inline bool uart_rx_full()
{
	return !!(*UART_FSTAT & UART_FSTAT_RXFULL_MASK);
}

static inline bool uart_rx_empty()
{
	return !!(*UART_FSTAT & UART_FSTAT_RXEMPTY_MASK);
}


static inline size_t uart_rx_level()
{
	return (*UART_FSTAT & UART_FSTAT_RXLEVEL_MASK) >> UART_FSTAT_RXLEVEL_LSB;
}

static inline void uart_put(uint8_t x)
{
	while (uart_tx_full())
		;
	*(volatile uint8_t * const)UART_TX = x;
}

static inline uint8_t uart_get()
{
	while (uart_rx_empty())
		;
	return *(volatile uint8_t * const)UART_RX;
}

static inline void uart_puts(const char *s)
{
	while (*s)
		uart_put((uint8_t)(*s++));
}

static inline void uart_wait_done()
{
	while (*UART_CSR & UART_CSR_BUSY_MASK)
		;
}

static inline void uart_init()
{
	*UART_CSR = 0;
	while (*UART_CSR & UART_CSR_BUSY_MASK)
		;
	while (!uart_rx_empty())
		(void)uart_get();
	uart_enable(true);
}

#endif // _UART_H_