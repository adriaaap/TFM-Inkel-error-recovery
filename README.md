# Inkel Pentiun processor with error detection and recovery
This Master Thesis project has been based on a fork from the original Inkel Pentiun repository by Carlos Escuín, Marc Marí and Kevin Sala.

This repository contains the implementation of the error detection and recovery system applied to the Inkel Pentiun. The detection system covers all stages from the decode onwards.

# Tests
In the "codes" folder of this repository one can find all test codes used to verify functionality and performance of the system:
 - bench_mem, bench_mul, bench_sum and vector_sum were implemented as part of this project to test performance.
 - error_test_sum, error_test_branch, error_test_memory and error_test_mul were implemented as part of this project and used to test functionality.
 - The rest of codes, which were already present in the original repository, have also been used to further test functionality to ensure that no regressions occurred.
