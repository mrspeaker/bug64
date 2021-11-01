            BasicUpstart2(entry)

            .label SZ_CHARSET_DATA         = 2048
            .label COLOUR_CHAR_MC1 = 11
            .label COLOUR_CHAR_MC2 = 14
            .label TILE_COUNT = 5
            .label TILE_COLS = 13
            .label TILE_ROWS = 8
            .const NUM_TILES = TILE_COLS * TILE_ROWS

            .const VIC_BASE                = $c000
            .const SCREEN                  = VIC_BASE + $0
            .const COLOR                   = $d800
            .const ADDR_CHARSET_DATA       = VIC_BASE + $3000 // label = 'charset_data'        (size = $0800).
            .const ADDR_SPRITE_DATA        = $e000

#import "src/map.asm"

entry:
            sei

            lda #$7f
            sta $dc0d
            sta $dd0d
            cli

            lda #$1
            sta $d020
            sta $d021

            // bank out basic and kernel
            lda $1
            and #$f8
            ora #%00000101
            sta $1

            // vic bank 3 ($c000 - $ffff)
            lda $dd00
            and #%11111100 // 00 = vic bank 3
            sta $dd00

            // screen and char
            lda #%00001100 // 0000=screen $0. 110x=$3000-$37ff chars (relative to vic)
            sta $d018

            // multicolor mode
            lda $d016
            ora #%00010000
            sta $d016
            lda #COLOUR_CHAR_MC1
            sta $d022
            lda #COLOUR_CHAR_MC2
            sta $d023


            // irq
            lda #<irq
            sta $fffe
            lda #>irq
            sta $ffff

            lda $d011
            and #$7f // mask out high byte of raster
            sta $d011
            lda #$ff
            sta $d012

            lda #$01
            sta $d01a

            jsr init_sprites
            jsr MAP.Draw

            cli
            jmp *

init_sprites:
            lda #$ff
            sta $d01c

            ldx #$7
!:
            lda #(ADDR_SPRITE_DATA/64)
            sta VIC_BASE + $3f8,x

            lda #0
            sta $d027

            txa
            asl
            tay
            asl
            asl
            asl
            adc #$40
            sta $d000,y
            iny
            sta $d000,y
            dex
            bpl !-

            lda #$ff
            sta $d015
            rts


irq:
            pha
            txa
            pha
            tya
            pha

            asl $d019
            dec $d020

            clc
            lda player_x
            adc #[24-12]
            sta $d000
            clc
            lda player_y
            adc #[50-12]
            sta $d001

handle_joy:
            .label xo = TMP1
            .label yo = TMP2
            .label tmpYO = TMP3

            lda #0
            sta xo
            sta yo

            // rotate down the byte, checking lowest bit
            lda $dc00 // 0=up,1=down,2=left,3=right,4=fire
            lsr     // if bit 0 was 0 (active low!), carry will be clear
            bcs down
            dec yo
down:
            lsr
            bcs left
            inc yo
left:
            lsr
            bcs right
            dec xo
right:
            lsr
            bcs fire
            inc xo
fire:
            lsr
            bcs !+
            // fire!
!:

            // Move character with map collisions

            // get player x
            // add xo
            // check if (xo, player_y) is in wall.
            // if so,  set xo = 0
            clc
            lda player_y
            adc yo
            lsr // div 8
            lsr
            lsr
            tax
            lda tile_for_cell,x
            asl
            asl
            asl
            asl     // * 16 = y offset.
            sta tmpYO

            clc
            lda player_x
            adc xo
            lsr
            lsr
            lsr
            tax
            lda tile_for_cell,x // tile for xo
            clc
            adc tmpYO
            tax
            lda tile_map_data,x
            beq !+
            lda #0
            sta xo
            sta yo


!:

draw_sprites:
            // get player y
            // add yo
            // check if (xo, yo) is in wall
            // if so, set yo = 0

            // add xo and yo
            clc
            lda player_x
            adc xo
            sta player_x

            clc
            lda player_y
            adc yo
            sta player_y

            inc $d020
            pla
            tay
            pla
            tax
            pla
            rti


player_x:   .byte $3*8, 0
player_y:   .byte $3*8

// SCREEN_ROW_LSB:
//             .fill 25, <[SCREEN + i * 40]
// SCREEN_ROW_MSB:
                    //             .fill 25, >[SCREEN + i * 40]

tile_for_cell: .byte 0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13

// TILE SET DATA : 6 (2x2) tiles : total size is 24 ($0018) bytes.

//* =  ADDR_TILESET_DATA "tileset_data"
tileset_data:

.byte $00,$00,$00,$00,$20,$00,$00,$00,$00,$01,$02,$02,$01,$22,$02,$01
.byte $02,$02,$02,$02,$02,$02,$22,$02,$02,$02,$02,$21,$02,$02,$21,$02
.byte $02,$21,$02,$02,$01,$02,$23,$01,$02,$23,$01,$02,$23

// TILE SET ATTRIBUTE DATA : 6 attributes : total size is 6 ($0006) bytes.
// nb. Upper nybbles = Material, Lower nybbles = Colour.

//* =  ADDR_TILESET_ATTRIB_DATA "tileset_attrib_data"
tileset_attrib_data:

.byte $0e,$08,$08,$08,$08

// MAP DATA : 1 (20x13) map : total size is 260 ($0104) bytes.

// * =  ADDR_TILE_MAP_DATA "tile_map_data"
tile_map_data:
.byte $01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00
.byte $01,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00
.byte $01,$00,$00,$01,$00,$01,$02,$00,$01,$00,$01,$00,$01,$00,$00,$00
.byte $01,$00,$00,$00,$00,$00,$01,$00,$00,$00,$01,$00,$01,$00,$00,$00
.byte $01,$00,$01,$00,$03,$00,$01,$00,$04,$00,$01,$02,$02,$00,$00,$00
.byte $01,$00,$01,$00,$01,$00,$01,$00,$01,$02,$02,$00,$01,$00,$00,$00
.byte $01,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00
.byte $01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00


            *=ADDR_SPRITE_DATA "sprites"
spr:
            .byte $0a,$aa,$a0,$0a,$aa,$a0,$2a,$aa,$a8,$2a,$aa,$a8,$2a,$aa,$a8,$2a
            .byte $aa,$a8,$2a,$aa,$a8,$2a,$aa,$a8,$2a,$aa,$a8,$2a,$aa,$a8,$2a,$aa
            .byte $a8,$2a,$aa,$a8,$29,$55,$68,$25,$55,$58,$09,$55,$60,$0a,$aa,$a0
            .byte $02,$aa,$a0,$0a,$aa,$a8,$2a,$00,$28,$28,$00,$28,$00,$00,$00,$8e

spr2:
            .byte $03,$5f,$c0,$06,$af,$e0,$05,$5f
            .byte $c0,$0a,$bf,$90,$0f,$fe,$70,$0f
            .byte $f9,$f0,$34,$24,$3c,$38,$18,$9c
            .byte $30,$09,$1c,$38,$0c,$3c,$1c,$4f
            .byte $f8,$1f,$c7,$f8,$17,$cf,$d0,$17
            .byte $ef,$e8,$05,$ff,$a8,$11,$c1,$a0
            .byte $05,$ab,$28,$01,$e1,$80,$05,$ff
            .byte $80,$00,$ff,$20,$00,$00,$00,$01

#import "data/charset_data.asm"
#import "src/zero.asm"
