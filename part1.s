.data
v: .space 4000
start: .space 1024
length: .space 1024
nmax: .long 1000
outputString: .asciz "%d : (%d, %d)\n"
getOutputString: .asciz "(%d, %d)\n"
auxOutput: .asciz "%d %d\n"
singleInput: .asciz "%d"
doubleInput: .asciz "%d %d"
debugOutput: .asciz "%d "
debugOutput2: .asciz "%d: %d %d\n"
nextLine: .asciz "\n"
descriptor: .long 0
size: .long 0
nrop: .long 0
op: .long 0
nrFiles: .long 0
i: .long 0
j: .long 0
k: .long 0
len: .long 0
hasSpace: .long 0
cnt: .long 0
aux: .long 0

.text
debugPrint:
    pushl %ebp
    movl %esp, %ebp

    ;#for (i = 0; i < nmax; i++)
    movl $0, i
    forDebug:
        movl nmax, %eax
        cmp %eax, i
        jge forDebug_end

        lea v, %edi
        movl i, %ecx
        movl (%edi, %ecx, 4), %edx

        pushl %edx
        pushl $debugOutput
        call printf
        popl %ebx
        popl %ebx

        add $1, i
        jmp forDebug
    forDebug_end:

    pushl $nextLine
    call printf
    popl %ebx

    pushl $0
    call fflush
    popl %ebx

    popl %ebp
    ret
debugStart:
    pushl %ebp
    movl %esp, %ebp

    ;#for (i = 0; i < nmax; i++)
    movl $0, i
    startDebug:
        movl $256, %eax
        cmp %eax, i
        jge endDebug

        lea start, %edi
        movl i, %ecx
        movl (%edi, %ecx, 4), %edx

        lea length, %edi
        movl i, %ecx
        movl (%edi, %ecx, 4), %eax

        pushl %eax
        pushl %edx
        pushl i
        pushl $debugOutput2
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx

        add $1, i
        jmp startDebug
    endDebug:

    pushl $nextLine
    call printf
    popl %ebx

    pushl $0
    call fflush
    popl %ebx

    popl %ebp
    ret
print:
    pushl %ebp
    movl %esp, %ebp
    
    ;#for (i = 0; i < nmax; i++)
    movl $0, i

    printFiles:
        movl nmax, %eax
        cmp %eax, i
        jge printFiles_end

        ;#if (v[i] != 0)
        lea v, %edi
        movl i, %ecx
        movl (%edi, %ecx, 4), %edx

        cmp $0, %edx
        jne continuePrintFiles
        
        jmp notPrintFiles

        continuePrintFiles:
            ;#if(start[v[i]] = i)
            lea start, %edi
            movl %edx, %ecx
            movl (%edi, %ecx, 4), %eax

            cmp i, %eax
            jne notPrintFiles

            ;#printf("%d: (%d, %d)\n", v[i], start[v[i]], start[v[i]] + length[v[i]] - 1);
            lea length, %edi
            movl %edx, %ecx
            movl (%edi, %ecx, 4), %ebx
            sub $1, %ebx
            add %eax, %ebx

            pushl %ebx
            pushl %eax
            pushl %edx
            pushl $outputString
            call printf
            popl %ebx
            popl %ebx
            popl %ebx
            popl %ebx

            pushl $0
            call fflush
            popl %ebx


        notPrintFiles:
        add $1, i
        jmp printFiles
    printFiles_end:

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

    ;#for (i = 0; i < nrFiles; i++)
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

        ;#for (j = 0; j < nmax - len; j++)
        movl $0, j
        putFiles:
            movl nmax, %eax
            cmp %eax, j
            jge putFiles_end

            

            ;#if (v[j] == 0)
            lea v, %edi
            movl j, %ecx
            movl (%edi, %ecx, 4), %edx
            cmp $0, %edx
            je checkIfSpace
            jmp continuePutFiles

            checkIfSpace:
                ;#hasSpace = 1;
                movl $1, hasSpace

                ;#for (k = j; k < j + len; k++)
                movl j, %ebx
                movl %ebx, k
                checkEnoughSpace:
                    movl j, %eax
                    add len, %eax
                    cmp %eax, k
                    jge checkEnoughSpace_end

                    ;#if (v[k] != 0)
                    lea v, %edi
                    movl k, %ecx

                    movl (%edi, %ecx, 4), %edx
                    cmp $0, %edx
                    jne notEnoughSpace

                    jmp continueCheckEnoughSpace

                    notEnoughSpace:
                        ;#hasSpace = 0;
                        movl $0, hasSpace
                        jmp checkEnoughSpace_end

                    continueCheckEnoughSpace:

                    add $1, k
                    jmp checkEnoughSpace            
                checkEnoughSpace_end:
                

                ;#if (hasSpace == 1)
                cmp $1, hasSpace
                jne continuePutFiles

                ;#for (k = j; k < j + len; k++)
                movl j, %ebx
                movl %ebx, k
                addFiles:
                    movl j, %eax
                    add len, %eax
                    cmp %eax, k
                    jge addFiles_end

                    ;#v[k] = descriptor;
                    lea v, %edi
                    movl k, %ecx
                    movl descriptor, %edx

                    movl %edx, (%edi, %ecx, 4)

                    add $1, k
                    jmp addFiles
                addFiles_end:

                ;#start[descriptor] = j;
                lea start, %edi
                movl descriptor, %ecx
                movl j, %edx

                movl %edx, (%edi, %ecx, 4)

                ;#length[descriptor] = len;
                lea length, %edi
                movl descriptor, %ecx
                movl len, %edx

                movl %edx, (%edi, %ecx, 4)

                jmp putFiles_end


            continuePutFiles:

            add $1, j
            jmp putFiles
        putFiles_end:

        ;#printf("%d: (%d, %d)\n", descriptor, start[descriptor], start[descriptor] + length[descriptor] - 1);

        lea start, %edi
        movl descriptor, %ecx
        movl (%edi, %ecx, 4), %edx


        lea length, %edi
        movl descriptor, %ecx
        movl (%edi, %ecx, 4), %eax
        sub $1, %eax
        add %edx, %eax

        pushl %eax
        pushl %edx
        pushl descriptor
        pushl $outputString
        call printf
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

    ;#scanf("%d", &descriptor);
    pushl $descriptor
    pushl $singleInput
    call scanf
    popl %ebx
    popl %ebx

    ;#printf("(%d, %d)\n", start[descriptor], start[descriptor] + length[descriptor] - 1);
    lea start, %edi
    movl descriptor, %ecx
    movl (%edi, %ecx, 4), %edx

    lea length, %edi
    movl descriptor, %ecx
    movl (%edi, %ecx, 4), %eax
    sub $1, %eax
    add %edx, %eax

    pushl %eax
    pushl %edx
    pushl $getOutputString
    call printf
    popl %ebx
    popl %ebx  
    popl %ebx

    pushl $0
    call fflush
    popl %ebx

    popl %ebp
    ret

oppDelete:
    pushl %ebp
    movl %esp, %ebp

    ;#scanf("%d", &descriptor);
    pushl $descriptor
    pushl $singleInput
    call scanf
    popl %ebx
    popl %ebx

    ;#for (i = start[descriptor]; i < start[descriptor] + length[descriptor]; i++)
    lea start, %edi
    movl descriptor, %ecx
    movl (%edi, %ecx, 4), %edx
    movl %edx, i

    lea length, %edi
    movl descriptor, %ecx
    movl (%edi, %ecx, 4), %eax
    
    add %edx, %eax

    deleteFiles:
        cmp %eax, i
        jge deleteFiles_end

        ;#v[i] = 0;
        lea v, %edi
        movl i, %ecx
        movl $0, %edx

        movl %edx, (%edi, %ecx, 4)

        add $1, i
        jmp deleteFiles
    deleteFiles_end:

    ;#start[descriptor] = 0;
    lea start, %edi
    movl descriptor, %ecx
    movl $0, %edx

    movl %edx, (%edi, %ecx, 4)

    ;#length[descriptor] = 0;
    lea length, %edi
    movl descriptor, %ecx
    movl $0, %edx

    movl %edx, (%edi, %ecx, 4)

    call print

    popl %ebp
    ret

oppDefragmentation:
    pushl %ebp
    movl %esp, %ebp

    ;#for (i = 0; i < nmax; i++)
    movl $0, i
    forDefrag:
        movl nmax, %eax
        cmp %eax, i
        jge forDefrag_end

        ;#if (v[i] != 0)
        lea v, %edi
        movl i, %ecx
        movl (%edi, %ecx, 4), %edx
        cmp $0, %edx
        jne continueDefrag

        jmp notContinueDefrag

        continueDefrag:
            ;#swap(v[i], v[cnt]);
            lea v, %edi
            movl i, %ecx
            movl (%edi, %ecx, 4), %eax

            lea v, %edi
            movl cnt, %edx
            movl (%edi, %edx, 4), %ebx

            movl %ebx, (%edi, %ecx, 4)
            movl %eax, (%edi, %edx, 4)


            ;#cnt++;
            add $1, cnt
        notContinueDefrag:
        add $1, i
        jmp forDefrag
    forDefrag_end:


    ;#for (i = 0; i < nmax; i++)
    movl $0, i
    forDefrag2:
        movl nmax, %eax
        cmp %eax, i
        jge forDefrag2_end

        ;#if (v[i] != 0)
        lea v, %edi
        movl i, %ecx
        movl (%edi, %ecx, 4), %edx
        cmp $0, %edx

        jne updateStart

        jmp notUpdateStart

        updateStart:
            ;#if(i < start[v[i]])
            lea start, %edi
            movl %edx, %ecx
            movl (%edi, %ecx, 4), %eax
            cmp i, %eax
            jle notUpdateStart

            ;#start[v[i]] = i;
            lea start, %edi
            movl %edx, %ecx
            movl i, %edx

            movl %edx, (%edi, %ecx, 4)


        notUpdateStart:
        add $1, i
        jmp forDefrag2
    forDefrag2_end:

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

    et_loop:;# while(nrop--)
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

            call oppDelete
            jmp switch_end


        op4:;# else if(op == 4)
            cmp $4, op
            jne switch_end

            call oppDefragmentation
            jmp switch_end



        switch_end:
            jmp et_loop


et_exit:


    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
