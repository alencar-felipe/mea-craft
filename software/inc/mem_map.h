#pragma once

#include <stdint.h>

#define ROM_BASE            (0x00000000)
#define RAM_BASE            (0x10000000)
#define RAM_BASE            (0x10000000)
#define VGA_BASE            (0x20000000)
#define PERIPHERALS_BASE    (0x30000000)

#define UART_BASE           (PERIPHERALS_BASE + 0x000000)
#define GPIO_BASE           (PERIPHERALS_BASE + 0x010000)
#define PS2_BASE            (PERIPHERALS_BASE + 0x020000)

#define UART_DATA           (UART_BASE + 0x0000)
#define UART_STS            (UART_BASE + 0x0004)

#define UART_DATA_POS       (0)
#define UART_DATA_MSK       (0xFF << UART_DATA_POS)

#define UART_STS_TX_POS     (0)
#define UART_STS_TX_MSK     (1 << UART_STS_TX_POS)
#define UART_STS_RX_POS     (1)
#define UART_STS_RX_MSK     (1 << UART_STR_RX_POS)

#define GPIO_A              (GPIO_BASE + 0x0000)
#define GPIO_B              (GPIO_BASE + 0x0004)

#define GPIO_A_SW_POS       (0)
#define GPIO_A_SW_MSK       (0xFFFF << GPIO_A_SW_POS)
#define GPIO_A_BTN_U_POS    (16)
#define GPIO_A_BTN_U_MSK    (1 << GPIO_A_BTN_U_POS)
#define GPIO_A_BTN_L_POS    (17)
#define GPIO_A_BTN_L_MSK    (1 << GPIO_A_BTN_L_POS)
#define GPIO_A_BTN_R_POS    (18)
#define GPIO_A_BTN_R_MSK    (1 << GPIO_A_BTN_R_POS)
#define GPIO_A_BTN_D_POS    (19)
#define GPIO_A_BTN_D_MSK    (1 << GPIO_A_BTN_D_POS)

#define GPIO_A_LED_POS      (0)
#define GPIO_A_LED_MSK      (0xFFFF << GPIO_A_LED_POS)

#define PS2_FRAME           (PS2_BASE + 0x0000)
#define PS2_STS             (PS2_BASE + 0x0004)

#define PS2_FRAME_POS       (0)
#define PS2_FRAME_MSK       (0xFF << PS2_FRAME_POS)

#define PS2_STS_POS         (0)
#define PS2_STS_MSK         (1 << PS2_STS_POS)

#define WRITE_WORD(ADDR, WORD) (*((volatile uint32_t *)(ADDR)) = (uint32_t) (WORD))
#define WRITE_HALF(ADDR, HALF) (*((volatile uint16_t *)(ADDR)) = (uint16_t) (HALF))
#define WRITE_BYTE(ADDR, BYTE) (*((volatile uint8_t  *)(ADDR)) = (uint8_t ) (BYTE))
#define READ_WORD(ADDR) (*((volatile uint32_t *)(ADDR)))
#define READ_HALF(ADDR) (*((volatile uint16_t *)(ADDR)))
#define READ_BYTE(ADDR) (*((volatile uint8_t  *)(ADDR)))