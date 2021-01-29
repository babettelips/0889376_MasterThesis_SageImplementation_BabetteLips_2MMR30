import random; import cmath; import pandas as pd
#load("Documents/Thesis/methods.sage")

def saber(ratio, wordsize):
	mod = 2^13; mod2 = 10484737; pr = 10; size = 256; ranges = [[-5, 6], [-4, 5], [-3, 4]]
	lbrange = ranges[0][0]; rbrange = ranges[0][1] #results are the same for each parameter set
	a = [random.randrange(0, mod) for i in range(size)]
	b = [random.randrange(lbrange, rbrange) for i in range(size)]
	[methodskaratsuba, methodstoom3, methodstoom4, bestmethod] = bestcombo(size, ratio, mod, wordsize)
	
	countmodt3 = 1; countmodt4 = 1; countmodbest = 1
	for i in range(len(methodstoom3)):
		if methodstoom3[i] == toom3:
			countmodt3 *= 2
	for i in range(len(methodstoom4)):
		if methodstoom4[i] == toom4:
			countmodt4 *= 2^3
	for i in range(len(bestmethod)):
		if bestmethod[i] == toom3:
			countmodbest *= 2
		if bestmethod[i] == toom4:
			countmodbest *= 2^3

	[sch, countsch] = schoolbook(a, b, mod, wordsize)
	[sch, countsch2] = subtract(sch[(len(sch) - len(a)):], sch[:(len(sch) - len(a))], mod, wordsize)
	countsch[0] += countsch2[0]
	[kar, countkar] = karatsuba(a, b, mod, methodskaratsuba[1:], 0, wordsize)
	[kar, countkar2] = subtract(kar[(len(kar) - len(a)):], kar[:(len(kar) - len(a))], mod, wordsize)
	countkar[0] += countkar2[0]
	assert (kar == sch), "kar not good"
	[to3, countto3] = toom3(a, b, mod*countmodt3, methodstoom3[1:], 0, wordsize)
	for i in range(len(to3)):
		to3[i] = to3[i]%mod
	[to3, countto32] = subtract(to3[(len(to3) - len(a)):], to3[:(len(to3) - len(a))], mod, wordsize)
	countto3[0] += countto32[0]
	assert (to3 == sch), "to3 not good"
	[to4, countto4] = toom4(a, b, mod*countmodt4, methodstoom4[1:], 0, wordsize)
	for i in range(len(to4)):
		to4[i] = to4[i]%mod
	[to4, countto42] = subtract(to4[(len(to4) - len(a)):], to4[:(len(to4) - len(a))], mod, wordsize)
	countto4[0] += countto42[0]
	assert (to4 == sch), "to4 not good"
	[sabersm, countsabersm] = toom4(a, b, mod*2^3, methodskaratsuba[2:], 0, wordsize)
	[sabersm, countsabersm2] = subtract(sabersm[(len(sabersm) - len(a)):], sabersm[:(len(sabersm) - len(a))], mod, wordsize)
	countsabersm[0] += countsabersm2[0]
	assert (sabersm == sch), "method saber not good"
	[best, countbest] = bestmethod[0](a, b, mod*countmodbest, bestmethod[1:], 0, wordsize)
	[best, countbest2] = subtract(best[(len(best) - len(a)):], best[:(len(best) - len(a))], mod, wordsize)
	countbest[0] += countbest2[0]
	assert (best == sch), "best not good"
	[ntred, countnttred] = nttsaberred(a, b, mod, mod2, pr, wordsize)
	assert (ntred == sch), "nttred not good"
	[ss, countssa, M] = ssared(a, b, mod, 2, wordsize) 
	assert (ss == sch), "ssa not good"
	finalm = M
	for var in [4, 8, 16, 32, 64]:
		[ss, countssa2, M] = ssared(a, b, mod, var, wordsize) 
		assert (ss == sch), "ssa not good"
		if countssa2[1] < countssa[1]:
			countssa = countssa2
			finalm = M
	[nus, countnus] = nussbau(a, b, 2^18, wordsize, floor((len(bin(size)[2:]) - 1)/2), ceil((len(bin(size)[2:]) - 1)/2))
	for i in range(len(nus)):
		nus[i] = nus[i]%mod
	assert (nus == sch), "nus not good"
	[nus2, countnus2] = nussbau(a, b, 2^16, wordsize, 2, 6)
	for i in range(len(nus)):
		nus2[i] = nus2[i]%mod
	assert (nus2 == sch), "nus2 not good"
	return [methodskaratsuba, methodstoom3, methodstoom4, bestmethod, "Saber's multiplication method:", countsabersm, "Schoolbook:", countsch, 
		"Karatsuba:", countkar, "Toom-3:", countto3, "Toom-4:", countto4, "Beste combination of iterative methods:", countbest, "NTT reduced:", 
		countnttred, "SSA reduced:", countssa, "Nussbaumer version 1:", countnus, "Nussbaumer version 2:", countnus2]

def kyber(ratio, wordsize):
	mod = 3329; size = 256
	a = [random.randrange(0, mod) for i in range(size)]
	b = [random.randrange(-2, 3) for i in range(size)]
	[methodskaratsuba, methodstoom3, methodstoom4, bestmethod] = bestcombo(size, ratio, mod, wordsize)

	[nttk, countntt, counttontt, countinv] = nttkyber(a, b, mod, 17, 1, wordsize)
	[sch, countsch] = schoolbook(a, b, mod, wordsize)
	[sch, countsch2] = subtract(sch[(len(sch) - len(a)):], sch[:(len(sch) - len(a))], mod, wordsize)
	countsch[0] += countsch2[0]
	assert (nttk == sch), "kyber not good"
	[kar, countkar] = karatsuba(a, b, mod, methodskaratsuba[1:], 0, wordsize)
	[kar, countkar2] = subtract(kar[(len(kar) - len(a)):], kar[:(len(kar) - len(a))], mod, wordsize)
	countkar[0] += countkar2[0]
	assert (kar == sch), "kar not good"
	[to3, countto3] = toom3(a, b, mod, methodstoom3[1:], 0, wordsize)
	[to3, countto32] = subtract(to3[(len(to3) - len(a)):], to3[:(len(to3) - len(a))], mod, wordsize)
	countto3[0] += countto32[0]
	assert (to3 == sch), "to3 not good"
	[to4, countto4] = toom4(a, b, mod, methodstoom4[1:], 0, wordsize)
	[to4, countto42] = subtract(to4[(len(to4) - len(a)):], to4[:(len(to4) - len(a))], mod, wordsize)
	countto4[0] += countto42[0]
	assert (to4 == sch), "to4 not good"
	[best, countbest] = bestmethod[0](a, b, mod, bestmethod[1:], 0, wordsize)
	[best, countbest2] = subtract(best[(len(best) - len(a)):], best[:(len(best) - len(a))], mod, wordsize)
	countbest[0] += countbest2[0]
	assert (best == sch), "best not good"
	[ss, countssa, no] = ssa(a, b, mod, 2, wordsize)
	[ss, countssa2] = subtract(ss[(len(ss) - len(a)):], ss[:(len(ss) - len(a))], mod, wordsize)
	finalvar = 2
	countssa[0] += countssa2[0]
	assert (ss == sch), "ssa not good"
	for var in [4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192]:
		[ss, countssa2, no] = ssa(a, b, mod, var, wordsize) 
		[ss, countssa3] = subtract(ss[(len(ss) - len(a)):], ss[:(len(ss) - len(a))], mod, wordsize)
		countssa2[0] += countssa3[0]
		assert (ss == sch), "ssa not good"
		if countssa2[1] < countssa[1]:
			countssa = countssa2
			finalvar = var
	[ssr, countssared, M] = ssared(a, b, mod, 2, wordsize) 
	assert (ssr == sch), "ssared not good"
	finalm = M
	for var in [4, 8, 16, 32, 64]:
		[ssr, countssared2, M] = ssared(a, b, mod, var, wordsize) 
		assert (ssr == sch), "ssared not good"
		if countssared2[1] < countssared[1]:
			countssared = countssared2
			finalm = M
	[nus, countnus] = nussbau(a, b, mod, wordsize, floor((len(bin(size)[2:]) - 1)/2), ceil((len(bin(size)[2:]) - 1)/2))
	assert (nus == sch), "nus not good"
	return [methodskaratsuba, methodstoom3, methodstoom4, bestmethod, "Kyber's NTT method:", countntt, "Schoolbook:", countsch, "Karatsuba:", 
		countkar, "Toom-3:", countto3, "Toom-4:", countto4, "Best combination of iterative methods:", countbest, "SSA:", countssa, 
		"countssared:", countssared, "Nussbaumer:", countnus, "Transform to NTT form:", counttontt, "Transform back to coefficient form:", 
		countinv]

def dilithium(ratio, wordsize):
	mod = 2^23 - 2^13 + 1; size = 256; ranges = [[-7, 8], [-6, 7], [-5, 6], [-3, 4]]
	lbrange = ranges[0][0]; rbrange = ranges[1][1] #results are the same for each parameter set
	a = [random.randrange(0, mod) for i in range(size)]
	b = [random.randrange(lbrange, rbrange) for i in range(size)]
	[methodskaratsuba, methodstoom3, methodstoom4, bestmethod] = bestcombo(size, ratio, mod, wordsize)

	[nttd3, countnttd3, counttontt, countinv] = nttdilithium(a, b, mod, 1753, 1, wordsize)
	[sch, countsch] = schoolbook(a, b, mod, wordsize)
	[sch, countsch2] = subtract(sch[(len(sch) - len(a)):], sch[:(len(sch) - len(a))], mod, wordsize)
	countsch[0] += countsch2[0]
	assert (nttd3 == sch), "dilithium not good"
	[kar, countkar] = karatsuba(a, b, mod, methodskaratsuba[1:], 0, wordsize)
	[kar, countkar2] = subtract(kar[(len(kar) - len(a)):], kar[:(len(kar) - len(a))], mod, wordsize)
	countkar[0] += countkar2[0]
	assert (kar == sch), "kar not good"
	[to3, countto3] = toom3(a, b, mod, methodstoom3[1:], 0, wordsize)
	[to3, countto32] = subtract(to3[(len(to3) - len(a)):], to3[:(len(to3) - len(a))], mod, wordsize)
	countto3[0] += countto32[0]
	assert (to3 == sch), "to3 not good"
	[to4, countto4] = toom4(a, b, mod, methodstoom4[1:], 0, wordsize)
	[to4, countto42] = subtract(to4[(len(to4) - len(a)):], to4[:(len(to4) - len(a))], mod, wordsize)
	countto4[0] += countto42[0]
	assert (to4 == sch), "to4 not good"
	[best, countbest] = bestmethod[0](a, b, mod, bestmethod[1:], 0, wordsize)
	[best, countbest2] = subtract(best[(len(best) - len(a)):], best[:(len(best) - len(a))], mod, wordsize)
	countbest[0] += countbest2[0]
	assert (best == sch), "best not good"
	[ss, countssa, no] = ssa(a, b, mod, 2, wordsize)
	[ss, countssa2] = subtract(ss[(len(ss) - len(a)):], ss[:(len(ss) - len(a))], mod, wordsize)
	finalvar = 2
	countssa[0] += countssa2[0]
	assert (ss == sch), "ssa not good"
	for var in [4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192]:
		[ss, countssa2, no] = ssa(a, b, mod, var, wordsize) 
		[ss, countssa3] = subtract(ss[(len(ss) - len(a)):], ss[:(len(ss) - len(a))], mod, wordsize)
		countssa2[0] += countssa3[0]
		assert (ss == sch), "ssa not good"
		if countssa2[1] < countssa[1]:
			countssa = countssa2
			finalvar = var
	[ssr, countssared, M] = ssared(a, b, mod, 2, wordsize) 
	assert (ssr == sch), "ssared not good"
	finalm = M
	for var in [4, 8, 16, 32, 64]:
		[ssr, countssared2, M] = ssared(a, b, mod, var, wordsize) 
		assert (ssr == sch), "ssared not good"
		if countssared2[1] < countssared[1]:
			countssared = countssared2
			finalm = M
	[nus, countnus] = nussbau(a, b, mod, wordsize, floor((len(bin(size)[2:]) - 1)/2), ceil((len(bin(size)[2:]) - 1)/2))
	assert (nus == sch), "nus not good"
	return [methodskaratsuba, methodstoom3, methodstoom4, bestmethod, "Dilithium's NTT method:", countnttd3, "Schoolbook:", countsch, "Karatsuba:", 
		countkar, "Toom-3:", countto3, "Toom-4:", countto4, "Best combination of iterative methods:", countbest, "SSA:", countssa, 
		"SSA reduced:", countssared, "Nussbaumer:", countnus, "Transform to NTT form:", counttontt, "Transform back to coefficient form:", 
		countinv]

def ntruprime(ratio, wordsize, parameterset):
	mods = [4621, 4591, 5167, 6343, 7177, 7879]; sizes = [653, 761, 857, 953, 1013, 1277]  
	assert(wordsize >= 16), "implementation not optimal"
	mod2 = 20144129; pr = 3; mod = mods[parameterset - 1]; size = sizes[parameterset - 1]

	a = [random.randrange(0, mod) for i in range(size)]
	b = [random.randrange(-1, 2) for i in range(size)]
	[methodskaratsuba, methodstoom3, methodstoom4, bestmethod] = bestcombo(size, ratio, mod, wordsize)

	[ntrupr, countntruprime] = goodntrus(a, b, mod, mod2, pr, wordsize)
	[sch, countsch] = schoolbook(a, b, mod, wordsize)
	assert (ntrupr == sch), "ntruprime not good"
	[kar, countkar] = karatsuba(a, b, mod, methodskaratsuba[1:], 0, wordsize)
	assert (kar == sch), "kar not good"
	[to3, countto3] = toom3(a, b, mod, methodstoom3[1:], 0, wordsize)
	assert (to3 == sch), "to3 not good"
	[to4, countto4] = toom4(a, b, mod, methodstoom4[1:], 0, wordsize)
	assert (to4 == sch), "to4 not good"
	[best, countbest] = bestmethod[0](a, b, mod, bestmethod[1:], 0, wordsize)
	assert (best == sch), "best not good"
	[nt, countntt] = nttntrus(a, b, mod, mod2, pr, wordsize) 
	assert (nt == sch), "ntt not good"
	[ss, countssa, M] = ssa(a, b, mod, 2, wordsize) 
	assert (ss == sch), "ssa not good"
	finalm = M
	for var in [4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192]:
		[ss, countssa2, M] = ssa(a, b, mod, var, wordsize) 
		assert (ss == sch), "ssa not good"
		if countssa2[1] < countssa[1]:
			countssa = countssa2
			finalm = M
	schtemp = [0]*(len(sch) - (len(a) - 1))
	for i in range(len(schtemp) - 1):
		schtemp[i] = sch[i]
	[part1, count1] = add(sch[(len(sch) - len(a)):], sch[:(len(sch) - len(a))], mod, wordsize)
	[sch, count2] = add(part1, schtemp, mod, wordsize)
	countsch[0] += count1[0] + count2[0]; countkar[0] += count1[0] + count2[0]
	countto3[0] += count1[0] + count2[0]; countto4[0] += count1[0] + count2[0]; countbest[0] += count1[0] + count2[0]
	countntt[0] += count1[0] + count2[0]; countssa[0] += count1[0] + count2[0]; countntruprime[0] += count1[0] + count2[0]

	return [methodskaratsuba, methodstoom3, methodstoom4, bestmethod, "NTRUPrime's polynomial multiplication method:", countntruprime, 
		"Schoolbook:", countsch, "Karatsuba:", countkar, "Toom-3:", countto3, "Toom-4:", countto4, "Best combination of iterative methods:", 
		countbest, "countntt:", countntt, "SSA:", countssa]

def ntru(ratio, wordsize, parameterset):
	mods = [2^11, 2^11, 2^13, 2^12]; sizes = [509, 677, 701, 821]; sizes2 = [1024, 1536, 1536, 1728]
	mod2 = 6635521; pr = 19; mod = mods[parameterset - 1]; size = sizes[parameterset - 1]
	
	a = [random.randrange(-mod/2, mod/2) for i in range(size)]
	b = [random.randrange(-1, 2) for i in range(size)]
	[methodskaratsuba, methodstoom3, methodstoom4, bestmethod] = bestcombo(size, ratio, mod, wordsize)
	
	countmodt3 = 1; countmodt4 = 1; countmodbest = 1
	for i in range(len(methodstoom3)):
		if methodstoom3[i] == toom3:
			countmodt3 *= 2
	for i in range(len(methodstoom4)):
		if methodstoom4[i] == toom4:
			countmodt4 *= 2^3
	for i in range(len(bestmethod)):
		if bestmethod[i] == toom3:
			countmodbest *= 2
		if bestmethod[i] == toom4:
			countmodbest *= 2^3

	[sch, countsch] = schoolbook(a, b, mod, wordsize)
	[ntrusm2, countntrusm2] = [sch, [0, 0]]

	if size == 677 or size == 701:
		[ntrusm2, countntrusm2] = goodntrus(a, b, mod, mod2, pr, wordsize)

	if size == 509:
		w = pr^((mod2 - 1)/256)%mod2; bound = 4
		count = 1; binw = bin(w)[2:]; po2 = binw.count('1')
		if po2 == 1:
			count = 0

		[ntrusm2, countntrusm2] = radix2ntru509(a, b, size, size2, mod, mod2, w, count, bound, wordsize)
		
	if size == 821:
		w2 = pr^((mod2 - 1)/64)%mod2; w3 = pr^((mod2 - 1)/9)%mod2; bound2 = 3; bound3 = 192
		count2 = 1; count3 = 1; binw2 = bin(w2)[2:]; binw3 = bin(w3)[2:]; po2w2 = binw2.count('1'); po2w3 = binw3.count('1')
		if po2w2 == 1:
			count2 = 0
		if po2w3 == 1:
			count3 = 0
		[ntrusm2, countntrusm2] = mixedradixntru(a, b, size, size2, mod, mod2, pr, w2, w3, count2, count3, bound2, bound3, wordsize)
		 
	[kar, countkar] = karatsuba(a, b, mod, methodskaratsuba[1:], 0, wordsize)
	[to3, countto3] = toom3(a, b, mod*countmodt3, methodstoom3[1:], 0, wordsize)
	for i in range(len(to3)):
		to3[i] = to3[i]%mod
	[to4, countto4] = toom4(a, b, mod*countmodt4, methodstoom4[1:], 0, wordsize)
	for i in range(len(to4)):
		to4[i] = to4[i]%mod
	[ntrusm, countntrusm] = toom4(a, b, mod*2^3, methodskaratsuba[2:], 0, wordsize)
	[best, countbest] = bestmethod[0](a, b, mod*countmodbest, bestmethod[1:], 0, wordsize)
	[nt, countntt] = nttntrus(a, b, mod, mod2, pr, wordsize)	
	[ss, countssa, M] = ssa(a, b, mod, 2, wordsize) 
	assert (ss == sch), "ssa not good"
	finalm = M
	for var in [4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192]:
		[ss, countssa2, M] = ssa(a, b, mod, var, wordsize) 
		assert (ss == sch), "ssa not good"
		if countssa2[1] < countssa[1]:
			countssa = countssa2 
			finalm = M

	for i in range(len(sch)):
		to3[i] = to3[i]%mod; to4[i] = to4[i]%mod; ntrusm[i] = ntrusm[i]%mod
		best[i] = best[i]%mod; nt[i] = nt[i]%mod
	
	assert (kar == sch), "kar not good"
	assert (to3 == sch), "to3 not good"
	assert (to4 == sch), "to4 not good"
	assert (ntrusm == sch), "method ntru not good"
	assert (best == sch), "best not good"
	assert (nt == sch), "ntt not good"
	assert (ntrusm2 == sch), "method ntru2 not good"

	[sch, count1] = add(sch[(len(sch) - len(a)):], sch[:(len(sch) - len(a))], mod, wordsize)
	countsch[0] += count1[0]; countkar[0] += count1[0]; countntrusm[0] += count1[0]
	countto3[0] += count1[0]; countto4[0] += count1[0]; countbest[0] += count1[0]
	countntt[0] += count1[0]; countssa[0] += count1[0]; countntrusm2[0] += count1[0]

	return [methodskaratsuba, methodstoom3, methodstoom4, bestmethod, "NTRU's polynomial multiplication method:", countntrusm, 
		"NTRU's NTT method:", countntrusm2, "Schoolbook:", countsch, "Karatsuba:", countkar, "Toom-3:", countto3, "Toom-4:", 
		countto4, "Best combination of iterative methods:", countbest, "countntt:", countntt, "SSA:", countssa]

def falcon(ratio, wordsize, parameterset):
	mod = 12289; pr = 11; ths = [10302, 1945]; sizes = [512, 1024]
	th = ths[parameterset - 1]; size = sizes[parameterset - 1]

	a = [random.randrange(0, mod) for i in range(size)]
	b = [random.randrange(-127, 128) for i in range(size)]
	[methodskaratsuba, methodstoom3, methodstoom4, bestmethod] = bestcombo(size, ratio, mod, wordsize)

	[fftf, countfalcon, counttofft, countinv] = fftfalcon(a, b, mod, wordsize)
	[sch, countsch] = schoolbook(a, b, mod, wordsize)
	[sch, countsch2] = subtract(sch[(len(sch) - len(a)):], sch[:(len(sch) - len(a))], mod, wordsize)
	countsch[0] += countsch2[0]
	assert (fftf == sch), "falcon not good"
	[kar, countkar] = karatsuba(a, b, mod, methodskaratsuba[1:], 0, wordsize)
	[kar, countkar2] = subtract(kar[(len(kar) - len(a)):], kar[:(len(kar) - len(a))], mod, wordsize)
	countkar[0] += countkar2[0]
	assert (kar == sch), "kar not good"
	[to3, countto3] = toom3(a, b, mod, methodstoom3[1:], 0, wordsize)
	[to3, countto32] = subtract(to3[(len(to3) - len(a)):], to3[:(len(to3) - len(a))], mod, wordsize)
	countto3[0] += countto32[0]
	assert (to3 == sch), "to3 not good"
	[to4, countto4] = toom4(a, b, mod, methodstoom4[1:], 0, wordsize)
	[to4, countto42] = subtract(to4[(len(to4) - len(a)):], to4[:(len(to4) - len(a))], mod, wordsize)
	countto4[0] += countto42[0]
	assert (to4 == sch), "to4 not good"
	[best, countbest] = bestmethod[0](a, b, mod, bestmethod[1:], 0, wordsize)
	[best, countbest2] = subtract(best[(len(best) - len(a)):], best[:(len(best) - len(a))], mod, wordsize)
	countbest[0] += countbest2[0]
	assert (best == sch), "best not good"
	[ntred, countnttred, no, no] = nttdilithium(a, b, mod, th, 1, wordsize)
	assert (ntred == sch), "nttdil not good"
	[ss, countssa, no] = ssa(a, b, mod, 2, wordsize)
	[ss, countssa2] = subtract(ss[(len(ss) - len(a)):], ss[:(len(ss) - len(a))], mod, wordsize)
	finalvar = 2
	countssa[0] += countssa2[0]
	assert (ss == sch), "ssa not good"
	for var in [4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192]:
		[ss, countssa2, no] = ssa(a, b, mod, var, wordsize) 
		[ss, countssa3] = subtract(ss[(len(ss) - len(a)):], ss[:(len(ss) - len(a))], mod, wordsize)
		countssa2[0] += countssa3[0]
		assert (ss == sch), "ssa not good"
		if countssa2[1] < countssa[1]:
			countssa = countssa2
			finalvar = var
	[ssr, countssared, M] = ssared(a, b, mod, 2, wordsize) 
	assert (ssr == sch), "ssared not good"
	finalm = M
	for var in [4, 8, 16, 32, 64, 128]:
		[ssr, countssared2, M] = ssared(a, b, mod, var, wordsize) 
		assert (ssr == sch), "ssared not good"
		if countssared2[1] < countssared[1]:
			countssared = countssared2
			finalm = M
	[nus, countnus] = nussbau(a, b, mod, wordsize, floor((len(bin(size)[2:]) - 1)/2), ceil((len(bin(size)[2:]) - 1)/2))
	assert (nus == sch), "nus not good"
	return [methodskaratsuba, methodstoom3, methodstoom4, bestmethod, "Falcon's FFT method:", countfalcon, "Falcon's NTT method:", countnttred, 
		"Schoolbook:", countsch, "Karatsuba:", countkar, "Toom-3:", countto3, "Toom-4:", countto4, "Best combination of iterative methods:", 
		countbest, "SSA:", countssa, "SSA reduced:", countssared, "Nussbaumer:", countnus, "Transform to FFT form:", counttofft, 
		"Transform back to coefficient form:", countinv]

def efficiency(algorithm, ratio):
	names = algorithm[4::2]
	counters = algorithm[5::2]
	eff = [0]*len(counters); output = []
	for i in range(len(counters)):
		eff[i] = ceil(counters[i][0] + ratio*counters[i][1])
		output += [["Efficiency", names[i], eff[i]]]
	return output

def all(algorithms, ratio, wordsize):
	output = []
	for i in range(len(algorithms)):
		if algorithms[i] == saber:
			addmul = saber(ratio, wordsize, 1)
			eff = efficiency(addmul, ratio)
			name = "SABER:"
			output += [name, addmul, eff]

		if algorithms[i] == kyber:
			addmul = kyber(ratio, wordsize)
			eff = efficiency(addmul, ratio)
			name = "KYBER:"
			output += [name, addmul, eff]

		if algorithms[i] == dilithium:
			addmul = dilithium(ratio, wordsize, 1)
			eff = efficiency(addmul, ratio)
			name = "DILITHIUM:"
			output += [name, addmul, eff]

		if algorithms[i] == ntruprime:
			addmul = ntruprime(ratio, wordsize, algorithms[i + 1])
			eff = efficiency(addmul, ratio)
			name = "NTRUPRIME PARAMETER SET "+"{}".format(algorithms[i + 1])+":"
			output += [name, addmul, eff]

		if algorithms[i] == ntru:
			addmul = ntru(ratio, wordsize, algorithms[i + 1])
			eff = efficiency(addmul, ratio)
			name = "NTRU PARAMETER SET "+"{}".format(algorithms[i + 1])+":"
			output += [name, addmul, eff]

		if algorithms[i] == falcon:
			addmul = falcon(ratio, wordsize, algorithms[i + 1])
			eff = efficiency(addmul, ratio)
			name = "FALCON PARAMETER SET "+"{}".format(algorithms[i + 1])+":"
			output += [name, addmul, eff]

	return output
