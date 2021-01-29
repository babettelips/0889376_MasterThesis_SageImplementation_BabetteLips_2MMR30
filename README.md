## The efficiency of polynomial multiplication methods for ring-based PQC algorithms of Round 3 of the NIST PQC competition.
B.A.M. (Babette) Lips - 0889376 - b.a.m.lips@student.tue.nl

This repository contains the implementation (in SageMath version 9.1) of functions used to perform the analysis of my graduation project for the master IAM at TU/e.
It consists of two programs: ```algorithms.sage``` and ```methods.sage```. 

## Table of contents
* [General information](#general-information)
* [Setup](#setup)
* [Code examples](#code-examples)

## General information
### The program ```methods.sage```
This program exists of functions that either support or perform one of the polynomial multiplication methods presented in my master thesis. Common input parameters are:
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
PQC competition. Common input parameters are:
- ```ratio```: the ratio between the costs of performing an addition and a multiplication of the platform, given as an integer.
- ```wordsize```: the word size of the platform, given as an integer.
- ```parameterset```: the parameter set we want to find results for, given as an integer.

Furthermore, common output parameters are:
- ```methodskaratsuba```: the optimal number of iterations of the Karatsuba method that should be performed before transferring to the schoolbook method, given as a list ```methodskaratsuba = [karatsuba, karatsuba, ..., karatsuba, schoolbook2]```.
- ```methodstoom3```: the optimal number of iterations of the Toom-3 method that should be performed before transferring to the schoolbook method, given as a list ```methodstoom3 = [toom3, toom3, ..., toom3, schoolbook2]```.
- ```methodstoom4```: the optimal number of iterations of the Karatsuba method that should be performed before transferring to the schoolbook method, given as a list ```methodstoom4 = [toom4, toom4, ..., toom4, schoolbook2]```.
- ```bestmethod```: the best combination of the methods Toom-4, Toom-3 and Karatsuba before transferring to the schoolbook method, again given as a list. This time the list may include all iterative methods.
- ```countsch```:  the number of additions and multiplications performed by the Schoolbook method, given as a list ```countsch = [add, mult]```. Similar outputs refer to the the number of additions and multiplications performed by other polynomial multiplication methods. For example, ```countnus``` refers to the number of additions and multiplications performed by the Nussbaumer method. One can always find a string element in front of such a list, which tells which polynomial multiplication method the counter belongs to.

Note that the program ```algorithms.sage``` consists of two more functions, namely:
- ```efficiency(algorithm, ratio)```, which computes the efficiency of the applicable polynomial multiplication methods for a given ratio and ring-based PQC algorithm of Round 3 of the NIST PQC competition. Here, the parameter ```algorithm``` is given as the name of the algorithm we want to find results for.
- ```all(algorithms, ratio, wordsize)```, wich can be used to find all results of the applicable polynomial multiplication methods (efficiencies and performed number of additions and multiplication) for a subset of the parameter sets of the ring-based PQC algorithms of Round 3 of the NIST PQC competition, given a certain ratio and word size. Here, the parameter ```algorithms``` is given as a list consisting of the names of the algorithms we want to find results for. Sometimes a name is followed by an integer. This integer element refers to the parameter set of the algorithm mentioned in the previous element. For example, if ```algorithms``` is given as ```[dilithium, falcon, 1]```, we want to find all results for the applicable polynomial multiplication methods of Dilithium and parameter set 1 of Falcon.

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
To find the efficiencies of the applicable polynomial multiplication methods of Dilithium's parameter sets on a platform with word size 32 and ratio 4.0, run the following script:

```
efficiency(dilithium(4.0, 32), 4.0)
```

To find the number of additions and multiplication performed by the applicable polynomial multiplication methods of parameter set 2 of Falcon on a platform with word size 64 and ratio 1.0, run the following script:

```
falcon(1.0, 64, 2)
```

To find all results for the applicable polynomial multiplication methods of Saber and Kyber on a platform with word size 16 and ratio 3.0, runn the following script:

```
all([saber, kyber], 3.0, 16)
```

Note that for NTRUPrime, NTRU and Falcon the results differ per parameter set. This means we should also input for which parameter set we want to optain the desired results. 

To find the number of additions and multiplication performed by the applicable polynomial multiplication methods of parameter set 4 of NTRUPrime on a platform with word size 128 and ratio 2.0, run the following script:

```
ntruprime(2.0, 128, 4)
```

Furthermore, to find all results for the applicable polynomial multiplication methods of each parameter set of NTRU on a platform with word size 128 and ratio 2.0, run the following script:

```
all([ntru, 1, ntru, 2, ntru, 3, ntru, 4], 2.0, 128)
```
