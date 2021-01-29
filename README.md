## The efficiency of polynomial multiplication methods for ring-based PQC algorithms of Round 3 of the NIST PQC competition.
This repository contains the implementation (in SageMath version 9.1) of functions used to perform the analysis of my master graduation project.
It consists of two programs, ```algorithms.sage``` and ```methods.sage```. 

## Table of contents
* [General information](#general-information)
* [Setup](#setup)
* [Code examples](#code-examples)

## General information
### The program ```methods.sage```
This program exists of functions that either support or perform one of the polynomial multiplication methods. Common input parameters are:
- ```a```: the first input polynomial, given as a list ```a = [a_{m-1}, ..., a_1, a_0]```.
- ```b```: the second input polynomial, given as a list ```b = [b_{m-1}, ..., b_1, b_0]```.
- ```m```: the size of a and b, given as an integer.
- ```mod```: the modulus of the ring, given as an integer.
- ```w```: a desired primitive root of unity of the ring. This parameter can be given as either an integer or a list.
- ```rou```: the desired roots of unity of the ring, given as a list.
- ```wordsize```: the word size of the platform, given as an integer.

Furthermore, common output parameters are:
- ```c```: the multiplication of polynomials a and b, given as a list ```c = [c_{n-1}, ..., c_1, c_0]```.
- ```counter```: the number of additions and multiplications performed by the function, given as a list ```counter = [add, mult]```.

### The program ```algorithms.sage```
This program exists of functions that perform the applicable polynomial multiplication methods for the ring-based PQC algorithms of Round 3 of the NIST 
PQC competition. 
One can find two more functions in this file, namely:
- ```efficiency(algorithm, ratio)```, which computes the efficiency of the polynomial multiplication methods for a given a ring-based PQC algorithm of Round 3 of 
the NIST PQC competition and a certain ratio
- ```all(algorithms, ratio, wordsize)```, wich can be used to find immediately find the results for a subset of the parameter sets of the ring-based PQC algorithms 
of Round 3 of the NIST PQC competition given a certain ratio and word size.

Furthermore, common input parameters are:
- ```ratio```: the ratio between the costs of additions and multiplications of a platform.
- ```wordsize```: the word size of the platform, given as an integer.
- ```parameterset```: the parameter set we want to find results for.

## Setup
To run the programs of this repository, perform the following steps:

- Download SageMath version 9.1 via [this link](https://github.com/sagemath/sage-windows/releases/tag/0.6.0-9.1).
- Download the programs ```methods.sage``` and ```algorithms.sage``` from this repository.
- Run the following script in Sage: 
```
load("methods.sage")
load("algorithms.sage")
```
We are now able to use the functions of both programs. Make sure to load both programs, because we cannot find results of the functions of program ```algorithms.sage``` 
without loading the program ```method.sage``` first.

## Code examples
To for example find the results for parameter set 2 of Falcon on a platform with word size 64 and ratio 1.0, running the following script gives the desired results:
```
falcon(1.0, 64, 2)
```

To for example find the results for Saber and Kyber on a platform with word size 16 and ratio 3.0, running the following script gives the desired results:

```
all([saber, kyber], 3.0, 16)
```

Note that for NTRUPrime, NTRU and Falcon the results differ per parameter set. We should also input for which parameter set we want to optain the results if we want to use 
the last function. This means that if we for example want to find the results for all parameter sets of NTRU on a platform with word size 128 and ratio 2.0, 
running the following script gives the desired results:

```
all([ntru, 1, ntru, 2, ntru, 3, ntru, 4], 2.0, 128)
```
