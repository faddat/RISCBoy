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

#define N_GPIOS 16

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