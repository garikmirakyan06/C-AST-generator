#!/bin/bash

if make; then
    ./parser < test
	  ./makeGraph.sh

else
    echo "Build failed. Not running parser."
fi