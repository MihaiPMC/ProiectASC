#include <stdio.h>

using namespace std;

int v[1000];
int start[256];
int length[256];

void print()
{
    for(int i = 0; i < 1000; i++)
    {
        if(v[i] != 0)
        {
            if(files[v[i]].start == i)
            {
                printf("%d: (%d, %d)\n", v[i], start[v[i]], start[v[i]] + length[v[i]] - 1);
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

        int len = 0;
        len = size / 8 + (size % 8 != 0);

        for(int j = 0; j < 1000; j++)
        {
            bool hasSpace = true;
            if(v[j] == 0)
            {
                for (int k = j; k < j + len; k++)
                {
                    if(v[k] != 0)
                    {
                        hasSpace = false;
                        break;
                    }
                }
                if(hasSpace)
                {
                    for (int k = j; k < j + len; k++)
                    {
                        v[k] = descriptor;
                    }
                    start[descriptor] = j;
                    length[descriptor] = len;
                    break;
                }
            }



        }

        printf("%d: (%d, %d)\n", descriptor, start[descriptor], start[descriptor] + length[descriptor] - 1);
    }
}

void oppGet()
{
    int descriptor;
    scanf("%d", &descriptor);

    printf("%d: (%d, %d)\n", descriptor, start[descriptor], start[descriptor] + length[descriptor] - 1);
}

void oppDelete()
{
    int descriptor;
    scanf("%d", &descriptor);

    for(int i = start[descriptor]; i < start[descriptor] + length[descriptor]; i++)
    {
        v[i] = 0;
    }

    start[descriptor] = 0;
    length[descriptor] = 0;

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
            if (i < start[v[i]])
            {
                start[v[i]] = i;
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