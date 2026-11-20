.MODEL SMALL
.STACK 100h

.DATA
    msg1      DB 'Byte de datos (00-FF): $'
    msg2      DB 13,10,'Operacion (A=AND, O=OR, X=XOR): $'
    msg3      DB 13,10,'Mascara (00-FF): $'
    msgDato   DB 13,10,13,10,'Dato original: $'
    msgMasc   DB 13,10,'Mascara:       $'
    msgRes    DB 13,10,'Resultado:     $'
    msgErr    DB 13,10,'Entrada invalida.',13,10,'$'
    salto     DB 13,10,'$'
    dato      DB ?
    mascara   DB ?
    oper      DB ?
    resultado DB ?

.CODE
inicio:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, msg1
    CALL imprimir
    CALL leerByteHex
    JC  errorEntrada
    MOV dato, AL

    LEA DX, msg2
    CALL imprimir
    MOV AH, 01h
    INT 21h
    AND AL, 0DFh            ; pasa la letra a mayuscula
    MOV oper, AL

    LEA DX, msg3
    CALL imprimir
    CALL leerByteHex
    JC  errorEntrada
    MOV mascara, AL

    MOV AL, dato
    MOV BL, mascara
    CMP oper, 'A'
    JE  hacerAnd
    CMP oper, 'O'
    JE  hacerOr
    CMP oper, 'X'
    JE  hacerXor
    JMP errorEntrada

hacerAnd:
    AND AL, BL
    JMP mostrar
hacerOr:
    OR  AL, BL
    JMP mostrar
hacerXor:
    XOR AL, BL

mostrar:
    MOV resultado, AL

    LEA DX, msgDato
    CALL imprimir
    MOV AL, dato
    CALL imprimirBinario

    LEA DX, msgMasc
    CALL imprimir
    MOV AL, mascara
    CALL imprimirBinario

    LEA DX, msgRes
    CALL imprimir
    MOV AL, resultado
    CALL imprimirBinario

    LEA DX, salto
    CALL imprimir
    JMP fin

errorEntrada:
    LEA DX, msgErr
    CALL imprimir

fin:
    MOV AH, 4Ch
    INT 21h

; ---------- Procedimientos ----------

imprimir PROC
    MOV AH, 09h
    INT 21h
    RET
imprimir ENDP

; Lee dos caracteres hex y devuelve el byte en AL (CF=1 si hay error)
leerByteHex PROC
    PUSH BX
    PUSH CX
    MOV AH, 01h
    INT 21h
    CALL hexANibble
    JC  finLeer
    MOV BL, AL
    MOV CL, 4
    SHL BL, CL
    MOV AH, 01h
    INT 21h
    CALL hexANibble
    JC  finLeer
    OR  AL, BL
finLeer:
    POP CX
    POP BX
    RET
leerByteHex ENDP

; Convierte el caracter en AL a su valor 0-15 (CF=1 si no es hex)
hexANibble PROC
    CMP AL, '0'
    JB  noHex
    CMP AL, '9'
    JBE esDigito
    CMP AL, 'A'
    JB  noHex
    CMP AL, 'F'
    JBE esMayus
    CMP AL, 'a'
    JB  noHex
    CMP AL, 'f'
    JA  noHex
    SUB AL, 20h
esMayus:
    SUB AL, 37h
    CLC
    RET
esDigito:
    SUB AL, 30h
    CLC
    RET
noHex:
    STC
    RET
hexANibble ENDP

; Imprime AL en binario de 8 bits seguido de la letra b
imprimirBinario PROC
    PUSH AX
    PUSH CX
    PUSH DX
    MOV DH, AL
    MOV CX, 8
cicloBin:
    MOV DL, '0'
    SHL DH, 1               ; el bit mas alto pasa a CF
    JNC esCero
    MOV DL, '1'
esCero:
    MOV AH, 02h
    INT 21h
    LOOP cicloBin
    MOV DL, 'b'
    MOV AH, 02h
    INT 21h
    POP DX
    POP CX
    POP AX
    RET
imprimirBinario ENDP

END inicio