.export _cd


.proc _cd
    cd_path := userzp
    ; Let's malloc
    MALLOC(KERNEL_MAX_PATH_LENGTH)
    sta     cd_path
    sty     cd_path+1

    ldx     #$01
    jsr     _orix_get_opt

    ; copy in malloc args
    ldy     #$00
@L1:
    lda     ORIX_ARGV,y
    beq     @S1
    sta     (cd_path),y
    iny
    bne     @L1
@S1:    
    sta     (cd_path),y

    ; check if it's . or ..
    ; FIXME : add trim
    
    ldy     #$00
    lda     (cd_path),y
    cmp     #'.'
    bne     @not_dot
    iny
    lda     (cd_path),y
    beq     @only_one_dot
    cmp     #'.'
    bne     free_cd_memory ; it's  'cd .' only then, jump. 
    ; Here we have 'cd ..'
    ; let's pull folder
    BRK_ORIX XGETCWD_ROUTINE  ; Get A & Y 
    sta     cd_path
    sty     cd_path+1
    ; loop until we reach 0
    ldy     #$00
@L2:    
    lda     (cd_path),y
    beq     @end_of_string_found
    iny
    bne     @L2
    rts     ; Error overflow return with no error
@end_of_string_found:
    ; now let's find last '/'
    dey
@L3:    
    lda     (cd_path),y
    cmp     #'/'
    beq     @slash_found
    dey
    bne     @L3
    ; We reached 0 : then we are in "/" root
@only_one_dot:    
    rts


@slash_found:
    lda     #$00
    sta     (cd_path),y
    
    ; modify path now
    lda     cd_path
    ldy     cd_path+1
    BRK_KERNEL   XPUTCWD_ROUTINE
    ; and free
    jmp     free_cd_memory


@not_dot:
    lda     cd_path
    ldx     cd_path+1
    ldy     #O_RDONLY

    BRK_KERNEL XOPEN

    cmp     #NULL
    bne     @not_null
    cpy     #NULL
    bne     @not_null

    PRINT str_not_a_directory
    ; Error
    jmp     free_cd_memory

@not_null:
    lda     cd_path
    ldy     cd_path+1
    BRK_KERNEL   XPUTCWD_ROUTINE


free_cd_memory:
    lda     cd_path
    ldy     cd_path+1
    BRK_KERNEL XFREE
    rts
str_not_a_directory:
    .byte "Not a directory",$0D,$0A,0	
str_max_level:
    .byte "Limit is ",$30+(ORIX_MAX_PATH_LENGTH-1)," chars",0
str_root:
    .asciiz "/"
.endproc

