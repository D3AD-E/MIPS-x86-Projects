// ECOAR lab 2.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <cstdlib>
#include <stdio.h>


extern "C" int find_markers(unsigned char* bitmap, unsigned int* x_pos, unsigned int* y_pos);

int main(int argc, char* argv[])
{
    if (argc == 2)
    {
        FILE* f = fopen(argv[1], "rb+");
        if (f == NULL)
        {
            std::cout << "File not found\n";
            return 0;
        }

        fseek(f, 0, SEEK_END);
        long int size = ftell(f);
        //unsigned char* bitmap = (unsigned char*)malloc(size);
        fclose(f);


        f = fopen(argv[1], "rb+");
        unsigned char* bitmap = (unsigned char*)malloc(size);
        int bytes_read = fread(bitmap, sizeof(unsigned char), size, f);
        fclose(f);


        unsigned int* x_pos = new unsigned int[50];
        unsigned int* y_pos = new unsigned int[50];

        int markers_amount = find_markers(bitmap, x_pos, y_pos);

        if (markers_amount < 0)
        {
            std::cout << "Bad file format\n";
        }
	if(markers_amount == 0)
	{
	    std::cout<<"No markers found\n";
	}
        else
        {
            for (int i = 0; i < markers_amount; i++)
            {
                std::cout << x_pos[i] << ", " << y_pos[i] << "\n";
            }
        }

        delete[] x_pos;
        delete[] y_pos;
        free(bitmap);
    }
    else
    {
        std::cout << "Invalid parameters\n";
    }
}
