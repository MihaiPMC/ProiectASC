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
singleInput: .asciz "%d"
doubleInput: .asciz "%d %d"
addOutput: .asciz "%d: ((%d, %d), (%d, %d))\n"

.text
print:
    pushl %ebp
    movl %esp, %ebp

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
        cmpl %eax, i
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
            cmpl %eax, j
            jge forLine_end

            ;#isSpaceOnLine = 1;
            movl $1, isSpaceOnLine

            ;#for(int k = 0; k < nmax - len + 1; k++)
            movl $0, k
            forCol:
                movl nmax, %eax
                sub len, %eax
                add $1, %eax
                cmpl %eax, k
                jge forCol_end

                ;#hasSpace = 1;
                movl $1, hasSpace

                ;#for(int l = k; l < k + len; l++)
                movl k, %ebx
                movl %ebx, l
                forCheckIfSpace:
                    movl l, %eax
                    add len, %eax
                    cmpl %eax, l
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
                    movl l, %eax
                    add len, %eax
                    cmpl %eax, l
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
                movl descriptor, %eax
                movl j, %ebx
                movl %ebx, startLinie(, %eax, 4)

                ;#startColoana[descriptor] = k;
                movl descriptor, %eax
                movl k, %ebx
                movl %ebx, startColoana(, %eax, 4)

                ;#length[descriptor] = len;
                movl descriptor, %eax
                movl len, %ebx
                movl %ebx, length(, %eax, 4)

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


        pushl $0
        call fflush
        popl %ebx

        add $1, i
        jmp forReadFiles
    forReadFiles_end:
   

    popl %ebp
    ret

oppGet:
    pushl %ebp
    movl %esp, %ebp

    popl %ebp
    ret

oppDelete:
    pushl %ebp
    movl %esp, %ebp

    popl %ebp
    ret

oppDefragAdd:
    pushl %ebp
    movl %esp, %ebp

    popl %ebp
    ret

oppDefrag:
    pushl %ebp
    movl %esp, %ebp

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
        cmpl $0, nrop
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
