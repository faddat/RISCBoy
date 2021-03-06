#include <stdint.h>
#include <stdbool.h>

#define CLK_SYS_MHZ 12
#include "gpio.h"
#include "lcd.h"
#include "pwm.h"

int main()
{
	gpio_fsel(PIN_LCD_PWM, 1);
	pwm_enable(false);
	pwm_invert(true);
	lcd_init(st7789_init_seq);

	uint8_t buf[2];

	st7789_start_pixels();
	for (int y = 0; y < 240; ++y)
	{
		for (int x = 0; x < 240; ++x)
		{
			uint32_t colour = x & 0x1f | ((y & 0x1f) << 11) | (((x + y) >> 3) << 5);
			buf[0] = colour >> 8;
			buf[1] = colour & 0xff;
			lcd_write(buf, 2);
		}
	}
}