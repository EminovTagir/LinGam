#!/bin/bash

if command -v python3 &> /dev/null; then
    if python3 -m pip --version &> /dev/null; then
        if [ -f "./requirements.txt" ]; then
            echo "Installing requirement lib..."
            python3 -m pip install -r requirements.txt --break-system-packages
            if [ $? -ne 0 ]; then
                echo "Error installing requirements."
                exit 1
            fi
        fi

        if [ -f "./generator.py" ]; then
            echo "Generating data..."
            python3 generator.py
            if [ $? -ne 0 ]; then
                echo "Error generating data."
                exit 1
            fi
        fi

        if [ -f "./banner_generate.py" ]; then
            echo "Generating banner..."
            python3 banner_generate.py
            if [ $? -ne 0 ]; then
                echo "Error generating banner."
                exit 1
            fi
        fi
    else
        echo "Python3-pip has not installed."
    fi
else
    echo "Python 3 has not installed."
fi

if command -v go &> /dev/null; then
    if [ -f "./main.go" ]; then
        echo "Generating binary file..."
        go build main.go
        if [ $? -ne 0 ]; then
            echo "Error generating binary file."
            exit 1
        fi
    fi
else
    echo "Golang has not installed."
fi
