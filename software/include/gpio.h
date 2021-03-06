#ifndef _GPIO_H_
#define _GPIO_H_

#include <stdint.h>
#include <stdbool.h>

#include "addressmap.h"
#include "hw/gpio_regs.h"

DECL_REG(GPIO_BASE + GPIO_OUT_OFFS, GPIO_OUT);
DECL_REG(GPIO_BASE + GPIO_DIR_OFFS, GPIO_DIR);
DECL_REG(GPIO_BASE + GPIO_IN_OFFS, GPIO_IN);
DECL_REG(GPIO_BASE + GPIO_FSEL0_OFFS, GPIO_FSEL0);

#define GPIO_FSEL_WIDTH GPIO_FSEL0_P0_BITS
#define GPIO_FSEL_MASK ((1ul << GPIO_FSEL_WIDTH) - 1ul)

// Dodgy token-pasting macro only works for GPIOs in the first FSEL regsister
#define _GPIO_FSEL_MASK_PINNUM(x) GPIO_FSEL0_P##x##_MASK
#define GPIO_FSEL_MASK_PIN(p) _GPIO_FSEL_MASK_PINNUM(p)

#define N_GPIOS 25

#define PIN_LED         0

#define PIN_DPAD_U      1
#define PIN_DPAD_D      2
#define PIN_DPAD_L      3
#define PIN_DPAD_R      4
#define PIN_BTN_A       5
#define PIN_BTN_B       6
#define PIN_BTN_X       7
#define PIN_BTN_Y       8
#define PIN_BTN_START   9
#define PIN_BTN_SELECT  10

#define PIN_FLASH_CS    11
#define PIN_FLASH_SCLK  12
#define PIN_FLASH_MOSI  13
#define PIN_FLASH_MISO  14

#define PIN_LCD_SCL     15
#define PIN_LCD_SDO     16
#define PIN_LCD_CS      17
#define PIN_LCD_DC      18
#define PIN_LCD_PWM     19
#define PIN_LCD_RST     20
#define PIN_UART_RX     21
#define PIN_UART_TX     22
#define PIN_UART_CTS    23
#define PIN_UART_RTS    24

static inline void gpio_out(uint32_t val)
{
	*GPIO_OUT = val;
}

static inline void gpio_out_pin(int pin, bool val)
{
	*GPIO_OUT = *GPIO_OUT & ~(1ul << pin) | ((int)val << pin);
}

static inline void gpio_dir(uint32_t val)
{
	*GPIO_DIR = val;
}

static inline void gpio_dir_pin(int pin, bool val)
{
	*GPIO_DIR = *GPIO_DIR & ~(1ul << pin) | ((int)val << pin);
}

static inline uint32_t gpio_in()
{
	return *GPIO_IN;
}

static inline bool gpio_in_pin(int pin)
{
	return !!(*GPIO_IN & (1ul << pin));
}

static inline void gpio_fsel(int pin, int func)
{
	func &= GPIO_FSEL_MASK;
	int bitoffs = pin * GPIO_FSEL_WIDTH; // Let's try to keep this a power of two :)
	*GPIO_FSEL0 = *GPIO_FSEL0
		& ~(GPIO_FSEL_MASK << bitoffs)
		| (func << bitoffs);
}

#endif // _GPIO_H_
