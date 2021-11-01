MAP:   {

TileScreenLocs: .byte 0, 1, 2, 40, 41, 42, 80, 81, 82
Row:            .byte 0
Col:            .byte 0
CurTileIdx:     .byte 0
Draw:  {
       .break
            lda #<SCREEN
            sta scr + 1
            lda #>SCREEN
            sta scr + 2

            lda #<COLOR
            sta col + 1
            lda #>COLOR
            sta col + 2

            lda #<tile_map_data
            sta Tile + 1
            lda #>tile_map_data
            sta Tile + 2

            lda #0
            sta CurTileIdx
            sta Row
!row_loop:
            lda #0
            sta Col
!col_loop:
            ldy #$00

!tile_loop:
            lda #$00
            sta TileLookup + 2

Tile:
            lda $BEEF         // current map tile index
            sta CurTileIdx
            sta TileLookup + 1    // * 8
            asl TileLookup + 1
            rol TileLookup + 2
            asl TileLookup + 1
            rol TileLookup + 2
            asl TileLookup + 1
            rol TileLookup + 2
            // + INDX
            clc
            lda TileLookup + 1
            adc CurTileIdx
            sta TileLookup + 1
            lda TileLookup + 2
            adc #$0
            sta TileLookup + 2

            clc
            lda #<tileset_data   // + addr of tileset_data
            adc TileLookup + 1
            sta TileLookup + 1
            lda #>tileset_data
            adc TileLookup + 2
            sta TileLookup + 2

TileLookup:
            lda $BEEF, y   // should point to tileset_data+tile*4, y
            ldx TileScreenLocs, y

scr:
            sta $BEEF,x
            ldx CurTileIdx
            lda tileset_attrib_data,x
            ldx TileScreenLocs,y
col:
            sta $BEEF,x
            iny
            cpy #$09

            bne !tile_loop-

            // Increment tile index
            clc
            lda Tile + 1
            adc #$01
            sta Tile + 1
            lda Tile + 2
            adc #$00
            sta Tile + 2

            // Update screen & colors
            clc
            lda scr + 1
            adc #$03
            sta scr + 1
            sta col + 1
            bcc !+
            inc scr + 2
            inc col + 2
!:
            inc Col
            lda Col
            cmp #TILE_COLS
            beq !+
            jmp !col_loop-
!:
                // Increment tile index
            clc
            lda Tile + 1
            adc #$03
            sta Tile + 1
            lda Tile + 2
            adc #$00
            sta Tile + 2

//             sec
//             lda scr + 1
//             sbc #$1
//             sta scr + 1
//             sta col + 1
//             bcs !+
//             dec scr + 2
//             dec col + 2
// !:

            // Add 40 to screen and cols
            clc
            lda scr + 1
            adc #40*2+1
            sta scr + 1
            sta col + 1
            bcc !+
            inc scr + 2
            inc col + 2
!:

            inc Row
            lda Row
            cmp #TILE_ROWS
            beq !+
            jmp !row_loop-
!:

            rts
  }

}
