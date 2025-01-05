#include <stdio.h>
#include <dirent.h>     // opendir, readdir, closedir
#include <sys/stat.h>   // fstat, struct stat
#include <fcntl.h>      // open
#include <unistd.h>     // close
#include <stdio.h>      // sprintf, fscanf
#include <string.h>     // strcmp

const int NMAX = 1024;

int v[NMAX][NMAX];
int nrop;
int startLinie[256];
int startColoana[256];
int length[256];
int ordineNumere[256];
int nrCurent = 0;
int lungimeCurent = 0;
int descriptor = 0;
char folderPath[1024];
char fullPath[1024];

FILE *inputFile;
FILE *outputFile;

void print()
{
    for (int i = 0; i < NMAX; i++)
    {
        for (int j = 0; j < NMAX; j++)
        {
            if (v[i][j] != 0)
            {
                if (startColoana[v[i][j]] == j)
                {
                    fprintf(outputFile, "%d: ((%d, %d), (%d, %d))\n", v[i][j], i, j, i, j + length[v[i][j]] - 1);
                }
            }
        }
    }
}

void opAdd()
{
    int nrFiles;
    fscanf(inputFile, "%d", &nrFiles);

    for (int i = 1; i <= nrFiles; i++)
    {
        int descriptor, size;
        fscanf(inputFile, "%d %d", &descriptor, &size);

        int len = size / 8 + (size % 8 != 0);

        if(len >= 2)
        {

            for (int j = 0; j < NMAX; j++) // linie
            {
                bool isSpaceOnLine = true;
                for (int k = 0; k < NMAX - len + 1; k++) // coloana
                {
                    bool hasSpace = true;

                    for (int l = k; l < k + len; l++)
                    {
                        if (v[j][l] != 0)
                        {
                            hasSpace = false;
                            break;
                        }
                    }

                    if (hasSpace)
                    {
                        for (int l = k; l < k + len; l++)
                        {
                            v[j][l] = descriptor;
                        }

                        startLinie[descriptor] = j;
                        startColoana[descriptor] = k;
                        length[descriptor] = len;

                        isSpaceOnLine = false;
                        break;
                    }
                }
                if (!isSpaceOnLine)
                {
                    break;
                }
            }

        
        }

    }

    print();
}

void opGet()
{
    int descriptor;
    fscanf(inputFile, "%d", &descriptor);

    if (length[descriptor] == 0)
    {
        fprintf(outputFile, "((0, 0), (0, 0))\n");
    }
    else
    {
        fprintf(outputFile, "((%d, %d), (%d, %d))\n", startLinie[descriptor], startColoana[descriptor], startLinie[descriptor], startColoana[descriptor] + length[descriptor] - 1);
    }
}

void opDelete()
{
    for (int i = startColoana[descriptor]; i < startColoana[descriptor] + length[descriptor]; i++)
    {
        v[startLinie[descriptor]][i] = 0;
    }

    startColoana[descriptor] = 0;
    startLinie[descriptor] = 0;
    length[descriptor] = 0;
}

void defragAdd()
{
    int currentLine = 0;
    int currentCol = 0;

    for (int idx = 0; idx < nrCurent; idx++)
    {
        int d = ordineNumere[idx];
        int len = length[d];

        bool placed = false;
        for (int i = currentLine; i < NMAX && placed == false; i++)
        {
            // If this is not the starting line, we start from column 0 again
            int startCol;
            if (i == currentLine)
            {
                startCol = currentCol;
            }
            else
            {
                startCol = 0;
            }

            for (int j = startCol; j < NMAX - len + 1 && placed == false; j++)
            {
                bool hasSpace = true;
                for (int k = j; k < j + len; k++)
                {
                    if (v[i][k] != 0)
                    {
                        hasSpace = false;
                        break;
                    }
                }

                if (hasSpace)
                {
                    for (int k = j; k < j + len; k++)
                    {
                        v[i][k] = d;
                    }

                    startLinie[d] = i;
                    startColoana[d] = j;

                    currentLine = i;
                    currentCol = j + len;
                    if (currentCol >= NMAX)
                    {
                        currentLine++;
                        currentCol = 0;
                    }

                    placed = true;
                }
            }
        }
    }
}

void opDefrag()
{
    for (int i = 0; i < NMAX; i++)
    {
        for (int j = 0; j < NMAX; j++)
        {
            if (v[i][j] != 0)
            {
                int aux2 = v[i][j];
                ordineNumere[nrCurent] = aux2;
                lungimeCurent = length[aux2];

                descriptor = aux2;
                opDelete();

                length[aux2] = lungimeCurent;

                nrCurent++;
            }
        }
    }

    defragAdd();

    nrCurent = 0;

    print();
}

void opConcrete()
{
    scanf("%s", folderPath);

    DIR* dp = opendir(folderPath);
    struct dirent *entry;

    while ((entry = readdir(dp)) != NULL)
    {
        //Skip . and ..

        if (entry->d_name[0] == '.' && entry->d_name[1] == '\0')
            continue;

        if (entry->d_name[0] == '.' && entry->d_name[1] == '.' && entry->d_name[2] == '\0')
            continue;


        int idx = 0;
        while (folderPath[idx] != '\0')
        {
            fullPath[idx] = folderPath[idx];
            idx++;
        }

        fullPath[idx] = '/';
        idx++;///////////////////////////////////////

        int idx2 = 0;
        while (entry->d_name[idx2] != '\0')
        {
            fullPath[idx] = entry->d_name[idx2];
            idx++;
            idx2++;
        }
        fullPath[idx] = '\0';

        int fds = open(fullPath, O_RDONLY);
        int descriptor = (fds % 255) + 1;

        printf("%d\n", descriptor);

        struct stat fileStat;
        fstat(fds, &fileStat);
        int size = fileStat.st_size / 1024;

        int len  = size / 8 + (size % 8 != 0);
        printf("%d\n", len);
        //close (fds);//----------------------------------------------------------------

        if(len >= 2)
        {

            for (int j = 0; j < NMAX; j++) // linie
            {
                bool isSpaceOnLine = true;
                for (int k = 0; k < NMAX - len + 1; k++) // coloana
                {
                    bool hasSpace = true;

                    for (int l = k; l < k + len; l++)
                    {
                        if (v[j][l] != 0)
                        {
                            hasSpace = false;
                            break;
                        }
                    }

                    if (hasSpace)
                    {
                        for (int l = k; l < k + len; l++)
                        {
                            v[j][l] = descriptor;
                        }

                        startLinie[descriptor] = j;
                        startColoana[descriptor] = k;
                        length[descriptor] = len;

                        printf("%d: ((%d, %d), (%d, %d))\n", descriptor, j, k, j, k + len - 1);

                        isSpaceOnLine = false;
                        break;
                    }
                }
                if (!isSpaceOnLine)
                {
                    break;
                }
            }


        }

    }



}


int main()
{
    inputFile = fopen("input.txt", "r");
    outputFile = fopen("output.txt", "w");

    

    fscanf(inputFile, "%d", &nrop);

    while (nrop--)
    {
        int op;
        fscanf(inputFile, "%d", &op);

        if (op == 1)
        {
            //fprintf(outputFile, "opAdd\n");
            opAdd();
        }
        else if (op == 2)
        {
            //fprintf(outputFile, "opGet\n");
            opGet();
        }
        else if (op == 3)
        {
            //fprintf(outputFile, "opDelete\n");

            fscanf(inputFile, "%d", &descriptor);
            opDelete();
            print();
        }
        else if (op == 4)
        {
            //fprintf(outputFile, "opDefrag\n");
            opDefrag();
        }
        else if(op == 5)
        {
            opConcrete();
        }
    }

    fclose(inputFile);
    fclose(outputFile);

    return 0;
}