#!/bin/bash

# Set the environment variable
export CSeC=Awesome

# Create a temporary C file to generate the launcher
cat <<EOF > launcher.c
#include <unistd.h>  // Include the correct header for execv
#include <stdlib.h>

int main() {
    char *argv[] = {"YoS", NULL};  // Set argv[0] to YoS
    execv("./level3", argv);      // Replace "./level3" with the path to your ELF file
    return 0;  // execv will not return unless there's an error
}
EOF

# Compile the launcher
gcc -o launcher launcher.c

# Run the launcher executable
echo "Running YoS with CSeC=Awesome:"
./launcher

# Clean up
rm launcher launcher.c

