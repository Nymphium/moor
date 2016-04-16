#!/bin/bash

target="init_spec"
output="compiled/test.lua"

moonc "${target}".moon

correct_size=$(($(wc -c "${target}".lua | awk '{print $1}') - 1))

dd if="${target}".lua of="${output}" bs=1 count="${correct_size}"

rm "${target}".lua

