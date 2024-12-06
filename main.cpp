#include <stdio.h>

using namespace std;

struct file{
    int start;
    int length;
};

int v[1000];
file files[256];

void print()
{
    for(int i = 0; i < 1000; i++)
    {
        if(v[i] != 0)
        {
            if(files[v[i]].start == i)
            {
                printf("%d: (%d, %d)\n", v[i], files[v[i]].start, files[v[i]].start + files[v[i]].length - 1);
            }
        }
    }
}

void oppAdd()
{
    int nrFile = 0;
    scanf("%d", &nrFile);

    for(int i = 0; i < nrFile; i++)
    {
        int descriptor, size;
        scanf("%d %d", &descriptor, &size);

        int length = 0;
        length = size / 8 + (size % 8 != 0);

        for(int j = 0; j < 1000; j++)
        {
            bool hasSpace = true;
            if(v[j] == 0)
            {
                for (int k = j; k < j + length; k++)
                {
                    if(v[k] != 0)
                    {
                        hasSpace = false;
                        break;
                    }
                }
                if(hasSpace)
                {
                    for (int k = j; k < j + length; k++)
                    {
                        v[k] = descriptor;
                    }
                    files[descriptor].start = j;
                    files[descriptor].length = length;
                    break;
                }
            }



        }

        printf("%d: (%d, %d)\n", descriptor, files[descriptor].start, files[descriptor].start + files[descriptor].length - 1);
    }
}

void oppGet()
{
    int descriptor;
    scanf("%d", &descriptor);

    printf("%d: (%d, %d)\n", descriptor, files[descriptor].start, files[descriptor].start + files[descriptor].length - 1);
}

void oppDelete()
{
    int descriptor;
    scanf("%d", &descriptor);

    for(int i = files[descriptor].start; i < files[descriptor].start + files[descriptor].length; i++)
    {
        v[i] = 0;
    }

    files[descriptor].start = 0;
    files[descriptor].length = 0;

    print();
}

void oppDefragmentation()
{
    int cnt = 0;

    for (int i = 0; i < 1000; i++)
    {
        if(v[i] != 0)
        {
            int aux;
            aux = v[i];
            v[i] = v[cnt];
            v[cnt] = aux;
            cnt++;
        }
    }

    for (int i = 0; i < 1000; i++)
    {
        if (v[i] != 0)
        {
            if (i < files[v[i]].start)
            {
                files[v[i]].start = i;
            }
        }
    }

    print();

}

int main()
{
    int nrop;
    scanf("%d", &nrop);

    while(nrop--)
    {
        int op;
        scanf("%d", &op);

        if(op == 1)
            oppAdd();
        else if(op == 2)
            oppGet();
        else if(op == 3)
            oppDelete();
        else if(op == 4)
            oppDefragmentation();
    }


    return 0;
}