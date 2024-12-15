.data
v: .space 4194304
startLinie: .space 1024
startColoana: .space 1024
length: .space 1024
ordineNumere: .space 1024
nmax: .long 1024
descriptor: .long 0
nrop: .long 0
op: .long 0
lungimeCurenta: .long 0
nrCurent: .long 0
size: .long 0
i: .long 0
j: .long 0
k: .long 0
l: .long 0
aux: .long 0
cnt: .long 0
len: .long 0
nrFiles: .long 0
isSpaceOnLine: .long 0
hasSpace: .long 0
currentLine: .long 0
currentCol: .long 0
d: .long 0
placed: .long 0
startCol: .long 0
singleInput: .asciz "%d"
doubleInput: .asciz "%d %d"
addOutput: .asciz "%d: ((%d, %d), (%d, %d))\n"
printOutput: .asciz "%d: ((%d, %d), (%d, %d))\n"
getOutput: .asciz "((%d, %d), (%d, %d))\n"
getOutputZero: .asciz "((0, 0), (0, 0))\n"
debugPrint: .asciz "TEST"

.text
flush:
    pushl %ebp
    movl %esp, %ebp

    pushl $0
    call fflush
    popl %ebx

    popl %ebp
    ret
print:
    pushl %ebp
    movl %esp, %ebp

    ;#for(int i = 0; i < nmax; i++)
    movl $0, i
    forPrint:
        movl nmax, %eax
        cmp %eax, i
        jge forPrint_end

        ;#for(int j = 0; j < nmax; j++)
        movl $0, j
        forPrintLine:
            movl nmax, %eax
            cmp %eax, j
            jge forPrintLine_end

            ;#if(v[i][j] != 0)
            lea v, %edi
            movl i, %eax
            imull nmax, %eax
            add j, %eax
            movl (%edi, %eax, 4), %eax

            cmp $0, %eax
            je printLineContinue

                ;#if(startColoana[v[i][j]] == j)
                lea startColoana, %edi
                movl (%edi, %eax, 4), %ebx
                cmp j, %ebx
                jne printLineContinue

                    ;#printf("%d: ((%d, %d), (%d, %d))\n", v[i][j], i, j, i, j + length[v[i][j]] - 1);
                    lea length, %edi
                    movl (%edi, %eax, 4), %ebx
                    sub $1, %ebx
                    add j, %ebx

                    pushl %ebx;#j + length[v[i][j]] - 1
                    pushl i;#i
                    pushl j;#j
                    pushl i;#i
                    pushl %eax;#v[i][j]
                    pushl $printOutput
                    call printf
                    popl %ebx
                    popl %ebx
                    popl %ebx
                    popl %ebx
                    popl %ebx
                    popl %ebx

                    call flush


            printLineContinue:
            add $1, j
            jmp forPrintLine
        forPrintLine_end:

        add $1, i
        jmp forPrint
    forPrint_end:

    popl %ebp
    ret

oppAdd:
    pushl %ebp
    movl %esp, %ebp

    ;#scanf("%d", &nrFiles);
    pushl $nrFiles
    pushl $singleInput
    call scanf
    popl %ebx
    popl %ebx

    
    
    
    ;#for(i = 0; i < nrFiles; i++)
    movl $0, i
    forReadFiles:
        movl nrFiles, %eax
        cmp %eax, i
        jge forReadFiles_end

        

        ;#scanf("%d %d", &descriptor, &size);
        pushl $size
        pushl $descriptor
        pushl $doubleInput
        call scanf
        popl %ebx
        popl %ebx
        popl %ebx

        ;#len = size / 8 + (size % 8 != 0);
        movl $0, %edx
        movl size, %eax
        movl $8, %ecx
        divl %ecx
        movl %eax, len

        cmp $0, %edx
        je cont
        add $1, len

        cont:

        ;#for(int j = 0; j < nmax; j++)
        movl $0, j
        forLine:
            movl nmax, %eax
            cmp %eax, j
            jge forLine_end

            ;#isSpaceOnLine = 1;
            movl $1, isSpaceOnLine

            ;#for(int k = 0; k < nmax - len + 1; k++)
            movl $0, k
            forCol:
                movl nmax, %eax
                sub len, %eax
                add $1, %eax
                cmp %eax, k
                jge forCol_end

                

                ;#hasSpace = 1;
                movl $1, hasSpace

                ;#for(int l = k; l < k + len; l++)
                movl k, %ebx
                movl %ebx, l
                forCheckIfSpace:
                    movl k, %eax
                    add len, %eax
                    cmp %eax, l
                    jge forCheckIfSpace_end

                    ;#if(v[j][l] != 0)
                    lea v, %edi
                    movl j, %eax
                    imull nmax, %eax
                    add l, %eax
                    movl (%edi, %eax, 4), %eax

                    cmp $0, %eax
                    je forCheckIfSpaceCont

                    ;#hasSpace = 0;
                    movl $0, hasSpace
                    jmp forCheckIfSpace_end

                    forCheckIfSpaceCont:
                        add $1, l
                        jmp forCheckIfSpace
                forCheckIfSpace_end:

                

                ;#if(hasSpace == 1)
                cmp $1, hasSpace
                jne forColCont

                ;#for(int l = k; l < k + len; l++)
                movl k, %ebx
                movl %ebx, l
                forAddFiles:
                    movl k, %eax
                    add len, %eax
                    cmp %eax, l
                    jge forAddFiles_end

                    ;#v[j][l] = descriptor;
                    lea v, %edi
                    movl j, %eax
                    imull nmax, %eax
                    add l, %eax
                    movl descriptor, %ebx
                    movl %ebx, (%edi, %eax, 4)

                    add $1, l
                    jmp forAddFiles

                forAddFiles_end:
                
                ;#startLinie[descriptor] = j;
                lea startLinie, %edi
                movl descriptor, %eax
                movl j, %ebx
                movl %ebx, (%edi, %eax, 4)

                ;#startColoana[descriptor] = k;
                lea startColoana, %edi
                movl descriptor, %eax
                movl k, %ebx
                movl %ebx, (%edi, %eax, 4)

                ;#length[descriptor] = len;
                lea length, %edi
                movl descriptor, %eax
                movl len, %ebx
                movl %ebx, (%edi, %eax, 4)

                ;#isSpaceOnLine = 0;
                movl $0, isSpaceOnLine

                ;#break;
                jmp forCol_end

                forColCont:
                    add $1, k
                    jmp forCol

            forCol_end:

            ;#if(isSpaceOnLine == 0)
            cmp $0, isSpaceOnLine
            je forLine_end

            add $1, j
            jmp forLine

        forLine_end:

        ;#printf("%d: ((%d, %d), (%d, %d))\n", descriptor, startLinie[descriptor], startColoana[descriptor], startLinie[descriptor], startColoana[descriptor] + length[descriptor] - 1);
        
        lea startColoana, %edi
        movl descriptor, %ecx
        movl (%edi, %ecx, 4), %edx

        lea length, %edi
        movl descriptor, %ecx
        movl (%edi, %ecx, 4), %eax
        sub $1, %eax
        add %edx, %eax

        lea startLinie, %edi
        movl descriptor, %ecx
        movl (%edi, %ecx, 4), %ebx

        pushl %eax;#startColoana[descriptor] + length[descriptor] - 1
        pushl %ebx;#startLinie[descriptor]
        pushl %edx;#startColoana[descriptor]
        pushl %ebx;#startLinie[descriptor]
        pushl descriptor
        pushl $addOutput
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx


        call flush

        add $1, i
        jmp forReadFiles
    forReadFiles_end:
   

    popl %ebp
    ret

oppGet:
    pushl %ebp
    movl %esp, %ebp

    ;#scanf("%d", &descriptor);
    pushl $descriptor
    pushl $singleInput
    call scanf
    popl %ebx
    popl %ebx

    ;#if(length[descriptor] == 0)
    lea length, %edi
    movl descriptor, %eax
    movl (%edi, %eax, 4), %eax

    cmp $0, %eax
    jne oppGetExist
    ;#printf("((0, 0), (0, 0))\n");
    pushl $getOutputZero
    call printf
    popl %ebx

    call flush

    jmp oppGetEnd

    oppGetExist:

    ;#printf("((%d, %d), (%d, %d))\n", startLinie[descriptor], startColoana[descriptor], startLinie[descriptor], startColoana[descriptor] + length[descriptor] - 1);
    
    lea startColoana, %edi
    movl descriptor, %ecx
    movl (%edi, %ecx, 4), %edx

    lea length, %edi
    movl descriptor, %ecx
    movl (%edi, %ecx, 4), %eax
    sub $1, %eax
    add %edx, %eax

    lea startLinie, %edi
    movl descriptor, %ecx
    movl (%edi, %ecx, 4), %ebx

    pushl %eax;#startColoana[descriptor] + length[descriptor] - 1
    pushl %ebx;#startLinie[descriptor]
    pushl %edx;#startColoana[descriptor]
    pushl %ebx;#startLinie[descriptor]
    pushl $getOutput
    call printf
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx

    call flush

    oppGetEnd:

    popl %ebp
    ret

oppDelete:
    pushl %ebp
    movl %esp, %ebp


    ;#for(int i = startColoana[descriptor]; i < startColoana[descriptor] + length[descriptor]; i++)
    lea startColoana, %edi
    movl descriptor, %eax
    movl (%edi, %eax, 4), %ebx
    movl %ebx, i
    movl %ebx, aux

    forDelete:
        lea length, %edi
        movl descriptor, %eax
        movl (%edi, %eax, 4), %eax
        add aux, %eax
        cmp %eax, i
        jge forDelete_end

        ;#v[startLinie[descriptor]][i] = 0;
        lea v, %edi
        lea startLinie, %eax
        movl descriptor, %ebx
        movl (%eax, %ebx, 4), %eax
        imull nmax, %eax
        add i, %eax
        movl $0, %ebx
        movl %ebx, (%edi, %eax, 4)

        add $1, i
        jmp forDelete
    forDelete_end:

    ;#startLinie[descriptor] = 0;
    lea startLinie, %edi
    movl descriptor, %eax
    xorl %ebx, %ebx 
    movl %ebx, (%edi, %eax, 4)

    ;#startColoana[descriptor] = 0;
    lea startColoana, %edi
    movl descriptor, %eax
    xorl %ebx, %ebx
    movl %ebx, (%edi, %eax, 4)

    ;#length[descriptor] = 0;
    lea length, %edi
    movl descriptor, %eax
    xorl %ebx, %ebx
    movl %ebx, (%edi, %eax, 4)


    popl %ebp
    ret

oppDefragAdd:
    pushl %ebp
    movl %esp, %ebp

    # currentLine = 0;
    movl $0, currentLine
    # currentCol = 0;
    movl $0, currentCol

    # for(idx = 0; idx < nrCurent; idx++)
    movl $0, i
    forIdx_defragAdd:
        movl nrCurent, %eax
        cmp %eax, i
        jge forIdx_defragAdd_end

        # d = ordineNumere[idx];
        lea ordineNumere, %edi
        movl i, %eax
        movl (%edi, %eax, 4), %ebx
        movl %ebx, d

        # len = length[d];
        lea length, %edi
        movl d, %eax
        movl (%edi, %eax, 4), %ebx
        movl %ebx, len

        # placed = false -> 0
        movl $0, placed

        # for(i = currentLine; i < nmax && !placed; i++)
        # We'll reuse `j` as loop counters inside. Let's use different registers carefully.

        # Load currentLine and currentCol
        movl currentLine, %eax
        movl %eax, aux  # aux will be 'i' for line loop
        forLine_defragAdd:
            movl aux, %eax
            movl placed, %ebx
            cmp $0, %ebx
            jne forLine_defragAdd_end # if placed != 0 break

            movl nmax, %ecx
            cmp %ecx, %eax
            jge forLine_defragAdd_end

            # i = aux (line)
            # startCol = (i == currentLine) ? currentCol : 0;
            movl aux, %edx
            movl currentLine, %ebx
            cmp %ebx, %edx
            jne notSameLine
            movl currentCol, %eax   ;# Move from memory (currentCol) to register %eax
            movl %eax, startCol     ;# Move from register %eax to memory (startCol)
            jmp setStartColDone
        notSameLine:
            movl $0, startCol
        setStartColDone:

            # for(j = startCol; j <= nmax - len && !placed; j++)
            movl startCol, %edx
            movl %edx, j
            forCol_defragAdd:
                movl placed, %ebx
                cmp $0, %ebx
                jne forCol_defragAdd_end

                movl nmax, %eax
                sub len, %eax
                cmp j, %eax
                jg forCol_defragAdd_end  # j > nmax - len means break

                # hasSpace = true (1)
                movl $1, hasSpace

                # Check space: for(k = j; k < j + len; k++)
                movl j, %eax
                movl %eax, k
                checkSpace_defragAdd:
                    movl j, %eax
                    add len, %eax
                    cmp %eax, k
                    jle checkSpace_end_defragAdd

                    # if (v[i][k] != 0) { hasSpace = false; break; }
                    # v[i][k] = v[line][col]
                    # line = aux, col = k
                    lea v, %edi
                    movl aux, %eax
                    imull nmax, %eax
                    add k, %eax
                    movl (%edi, %eax, 4), %ecx
                    cmp $0, %ecx
                    je continueCheckSpace

                    # hasSpace = 0;
                    movl $0, hasSpace
                    # break from space check
                    jmp checkSpace_end_defragAdd_break

                    continueCheckSpace:
                        add $1, k
                        jmp checkSpace_defragAdd
                checkSpace_end_defragAdd:
                checkSpace_end_defragAdd_break:

                # if(hasSpace)
                movl hasSpace, %eax
                cmp $1, %eax
                jne noSpaceFound_defragAdd

                # Place the block: for(k = j; k < j + len; k++)
                movl j, %eax
                movl %eax, k
                placeBlock_defragAdd:
                    movl j, %ecx
                    add len, %ecx
                    cmp %ecx, k
                    jle placeBlock_end_defragAdd

                    lea v, %edi
                    movl aux, %edx  # line
                    imull nmax, %edx
                    add k, %edx
                    movl d, %ebx
                    movl %ebx, (%edi, %edx, 4)

                    add $1, k
                    jmp placeBlock_defragAdd
                placeBlock_end_defragAdd:

                # startLinie[d] = i (which is aux)
                lea startLinie, %edi
                movl d, %eax
                movl aux, %ebx
                movl %ebx, (%edi, %eax, 4)

                # startColoana[d] = j
                lea startColoana, %edi
                movl d, %eax
                movl j, %ebx
                movl %ebx, (%edi, %eax, 4)

                # currentLine = i;
                movl aux, %eax
                movl %eax, currentLine

                # currentCol = j + len;
                movl j, %eax
                add len, %eax
                movl %eax, currentCol

                # if(currentCol >= nmax) { currentLine++; currentCol = 0; }
                movl currentCol, %eax
                movl nmax, %ebx
                cmp %ebx, %eax
                jl noLineIncrease_defragAdd

                add $1, currentLine
                movl $0, currentCol

                noLineIncrease_defragAdd:

                # placed = true
                movl $1, placed

                noSpaceFound_defragAdd:

                add $1, j
                jmp forCol_defragAdd
            forCol_defragAdd_end:

            add $1, aux
            jmp forLine_defragAdd
        forLine_defragAdd_end:

        add $1, i
        jmp forIdx_defragAdd
    forIdx_defragAdd_end:

    popl %ebp
    ret

oppDefrag:
    pushl %ebp
    movl %esp, %ebp

    # for (i = 0; i < nmax; i++)
    movl $0, i
    forI_opDefrag:
        movl nmax, %eax
        cmp %eax, i
        jge forI_opDefrag_end

        # for(j = 0; j < nmax; j++)
        movl $0, j
        forJ_opDefrag:
            movl nmax, %eax
            cmp %eax, j
            jge forJ_opDefrag_end

            # if (v[i][j] != 0)
            lea v, %edi
            movl i, %eax
            imull nmax, %eax
            add j, %eax
            movl (%edi, %eax, 4), %ebx
            cmp $0, %ebx
            je opDefrag_continueJ

            # aux = v[i][j]
            movl %ebx, aux

            # ordineNumere[nrCurent] = aux
            lea ordineNumere, %edi
            movl nrCurent, %eax
            movl aux, %ebx
            movl %ebx, (%edi, %eax, 4)

            # lungimeCurent = length[aux]
            lea length, %edi
            movl aux, %eax
            movl (%edi, %eax, 4), %ebx
            movl %ebx, lungimeCurenta

            # descriptor = aux
            movl aux, %eax          ;# Load aux into %eax
            movl %eax, descriptor   ;# Store %eax into descriptor


            # call opDelete() equivalent -> oppDelete
            call oppDelete

            # length[aux] = lungimeCurenta
            lea length, %edi
            movl aux, %eax
            movl lungimeCurenta, %ebx
            movl %ebx, (%edi, %eax, 4)

            # nrCurent++
            add $1, nrCurent

            opDefrag_continueJ:
            add $1, j
            jmp forJ_opDefrag
        forJ_opDefrag_end:

        add $1, i
        jmp forI_opDefrag
    forI_opDefrag_end:

    # defragAdd() -> oppDefragAdd
    call oppDefragAdd

    # nrCurent = 0;
    movl $0, nrCurent

    # print();
    call print

    popl %ebp
    ret

.global main
main:
    ;#scanf("%d", &nrop);

    pushl $nrop
    pushl $singleInput
    call scanf
    popl %ebx
    popl %ebx

    
    ;#while(nrop--)
    et_loop:
        cmp $0, nrop
        je et_exit
        sub $1, nrop

        

        ;#scanf("%d", &op);
        pushl $op
        pushl $singleInput
        call scanf
        popl %ebx
        popl %ebx   
        

    
        op1:;# if(op == 1)
            cmp $1, op
            jne op2 

            call oppAdd
            jmp switch_end

        op2:;# else if(op == 2)
            cmp $2, op
            jne op3

            call oppGet
            jmp switch_end


        op3:;# else if(op == 3)
            cmp $3, op
            jne op4
            
            ;#scanf("%d", &descriptor);
            pushl $descriptor
            pushl $singleInput
            call scanf
            popl %ebx
            popl %ebx

        
            call oppDelete
            
            call print

            jmp switch_end


        op4:;# else if(op == 4)
            cmp $4, op
            jne switch_end

            call oppDefrag
            jmp switch_end

        switch_end:
            jmp et_loop

et_exit:
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
