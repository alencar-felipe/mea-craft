#pragma once

#include "mylib.h"

#define ROM_BASE            (0x00000000)
#define RAM_BASE            (0x10000000)
#define GPU_BASE            (0x20000000)
#define PERIPHERALS_BASE    (0x30000000)

/* GPU ====================================================================== */

#define CLUSTER_COUNT  (3)
#define CLUSTER_SIZE   (16)
#define TEXTURE_WIDTH  (64)
#define TEXTURE_HEIGHT (64)

typedef struct __attribute__((packed)) {
    uint32_t sx;
    uint32_t sy;
    uint32_t stx;
    uint32_t sty;
    uint32_t stw;
    uint32_t sth;
} sprite_t;

typedef struct __attribute__((packed)) {
    sprite_t sprites[CLUSTER_SIZE];
    uint32_t texture[TEXTURE_HEIGHT][TEXTURE_WIDTH];
} cluster_t;

typedef struct __attribute__((packed)) {
    cluster_t clusters[CLUSTER_COUNT];
} gpu_t;

#define GPU ( (volatile gpu_t *) (GPU_BASE) )

/* Peripherals ============================================================== */

#define UART_BASE           (PERIPHERALS_BASE + 0x000000)
#define GPIO_BASE           (PERIPHERALS_BASE + 0x010000)
#define PS2_BASE            (PERIPHERALS_BASE + 0x020000)

/* Peripherals / UART ======================================================= */

typedef struct __attribute__((packed)) {
    uint32_t data;
    uint8_t  sts_tx : 1;
    uint8_t  stx_rx : 1;
    uint32_t reserved : 30;
} uart_t;

#define UART ( (volatile uart_t *) (UART_BASE) )

/* Peripherals / GPIO ======================================================= */

#define GPIO_A              (GPIO_BASE + 0x0000)
#define GPIO_B              (GPIO_BASE + 0x0004)

typedef struct __attribute__((packed)) {
    uint16_t sw;
    uint8_t  btn_u : 1;
    uint8_t  btn_l : 1;
    uint8_t  btn_r : 1;
    uint8_t  btn_d : 1;
    uint32_t reserved : 12;
} gpio_a_in_t;

typedef struct __attribute__((packed)) {
    uint16_t led;
    uint32_t reserved : 28;
} gpio_a_out_t;

#define GPIO_A_IN ( (volatile gpio_a_in_t *) GPIO_A )
#define GPIO_A_OUT ( (volatile gpio_b_in_t *) GPIO_A )

/* Peripherals / PS2 ======================================================== */

// #define PS2_FRAME           (PS2_BASE + 0x0000)
// #define PS2_STS             (PS2_BASE + 0x0004)

// #define PS2_FRAME_POS       (0)
// #define PS2_FRAME_MSK       (0xFF << PS2_FRAME_POS)

// #define PS2_STS_POS         (0)
// #define PS2_STS_MSK         (1 << PS2_STS_POS)

/* Helpers ================================================================== */

#define WRITE_WORD(ADDR, WORD) (*((volatile uint32_t *)(ADDR)) = (uint32_t) (WORD))
#define WRITE_HALF(ADDR, HALF) (*((volatile uint16_t *)(ADDR)) = (uint16_t) (HALF))
#define WRITE_BYTE(ADDR, BYTE) (*((volatile uint8_t  *)(ADDR)) = (uint8_t ) (BYTE))
#define READ_WORD(ADDR) (*((volatile uint32_t *)(ADDR)))
#define READ_HALF(ADDR) (*((volatile uint16_t *)(ADDR)))
#define READ_BYTE(ADDR) (*((volatile uint8_t  *)(ADDR)))