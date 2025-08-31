#!/bin/bash

target_dir="."
#param -r to del /build and Makefile
if [ "$1" == "-r" ]; then
    if [ -d $target_dir/build ]; then
        rm -rf $target_dir/build
        echo "./build was removed from $target_dir."
    fi

    if [ -e $target_dir/Makefile ]; then
        rm $target_dir/Makefile
        echo "Makefile was removed from $target_dir."
    fi

    exit 0
fi

# Check for Makefile and ./build
if [ -e $target_dir/Makefile ]; then
    echo "Makefile already exists in $target_dir."
else
    # Adding ./build
    if [ -d $target_dir/build ]; then
        echo "./build already exists in $target_dir."
    else
        mkdir $target_dir/build
        echo "./build created in $target_dir."
    fi

    # Creating Makefile
    cat > $target_dir/Makefile << EOF
CC = g++
CFLAGS = -Wall -g -std=c++11
BUILD_DIR = build

SRC := \$(wildcard $target_dir/*.c) \$(wildcard $target_dir/*.cpp)
OBJ := \$(SRC:\%.c=\$(BUILD_DIR)/\%.o)
OBJ := \$(OBJ:\%.cpp=\$(BUILD_DIR)/\%.o)

all: \$(BUILD_DIR)/program

\$(BUILD_DIR)/program: \$(OBJ)
	\$(CC) \$(CFLAGS) -o \$@ \$^ -lstdc++

\$(BUILD_DIR)/%.o: %.c
	\$(CC) \$(CFLAGS) -c -o \$@ \$<

\$(BUILD_DIR)/%.o: %.cpp
	\$(CC) \$(CFLAGS) -c -o \$@ \$<

clean:
	rm -rf \$(BUILD_DIR)
EOF

    echo "Makefile created in $target_dir."
fi
