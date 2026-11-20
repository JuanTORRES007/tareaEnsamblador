.MODEL SMALL
.STACK 100h

.DATA
    titulo  DB 'Contador hexadecimal de 0h a Fh',13,10,'$'
    final   DB 13,10,'Fin del conteo.',13,10,'$'

.CODE
inicio:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, titulo
    MOV AH, 09h
    INT 21h

    MOV CX, 16              ; 16 vueltas (0h a Fh)
    MOV BL, 0h              ; el contador arranca en 0h

cicloConteo:
    MOV DL, BL
    CMP DL, 9
    JBE esNumero
    ADD DL, 37h             ; A-F: suma 37h para pasar a ASCII
    JMP mostrar
esNumero:
    ADD DL, 30h             ; 0-9: suma 30h para pasar a ASCII
mostrar:
    MOV AH, 02h
    INT 21h

    CMP BL, 0Fh             ; ya es el ultimo digito?
    JNZ poneEspacio
    JMP siguiente
poneEspacio:
    MOV DL, ' '
    MOV AH, 02h
    INT 21h
siguiente:
    INC BL
    LOOP cicloConteo

    LEA DX, final
    MOV AH, 09h
    INT 21h

    MOV AH, 4Ch
    INT 21h
END inicio