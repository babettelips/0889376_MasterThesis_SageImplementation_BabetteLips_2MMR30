def numwords(a, wordsize):
	mu = ceil(len(bin(a - 1)[2:])/wordsize)
	return mu

def isprime(mod):
	if mod > 1:
		for i in range(2, mod//2):
			if (mod % i) == 0:
				return False
	return True

def gcd(a, b):
    while b != 0:
        a = b; b = a % b
    return x

def primroot(mod):
	assert(isprime(mod) == True), "this modulus is not a prime"
	coprimes = {num for num in range(1, mod) if gcd(num, mod) == 1}
	for g in range(1, mod):
		if coprimes == {pow(g, powers, mod) for powers in range(1, mod)}:
			return g
	return "no primitive root found for this modulus"

def findmod(n, s1, s2):
	#to find a big enough prime p for the NTT method when no prime is given.
	#with s1 and s2 we denote s_1 and s_2, the largest coefficients of polynomials a and b.
	
	k = 1
	q = k*n + 1
	while isprime(q) == False or q < (n*s1*s2 + 1):
		q = q + n; k += 1
	return [q, k]

def adding(a, b, begina, enda, beginb, endb, mod, wordsize):
	mu = numwords(mod, wordsize)
	c = []
	counta = []
	for i in range(begina, enda):
		counta += [i]
	countb = []
	for i in range(beginb, endb):
		countb += [i]
	if len(b) > len(a): 
		temp = b; b = a; a = temp
		temp2 = countb;	countb = counta; counta = temp2
	counter = [0, 0] 
	while len(a) > len(b):
		b = [0] + b
		countb = [i + 1 for i in countb]
	for i in range(len(a)):
		c = c + [(a[i] + b[i])%mod]
		if i in counta and i in countb:
			counter[0] += mu
	return [c, counter]

def add(a, b, mod, wordsize):
	return adding(a, b, 0, len(a), 0, len(b), mod, wordsize)

def subtracting(a, b, begina, enda, beginb, endb, mod, wordsize):
	mu = numwords(mod, wordsize)
	c = []
	counta = []
	for i in range(begina, enda):
		counta += [i]
	countb = []
	for i in range(beginb, endb):
		countb += [i]
	if len(b) > len(a):
		temp = b; b = [-1*i for i in a]; a = [-1*i for i in temp]
		temp2 = countb; countb = counta; counta = temp2
	counter = [0, 0]
	while len(a) > len(b):
		b = [0] + b
		countb = [i + 1 for i in countb]
	for i in range(len(a)):
		c = c + [(a[i] - b[i])%mod]
		if i in counta and i in countb:
			counter[0] += mu
	return [c, counter]

def subtract(a, b, mod, wordsize):
	return subtracting(a, b, 0, len(a), 0, len(b), mod, wordsize)

def school(a, b, begina, enda, beginb, endb, mod, wordsize):
	mu = numwords(mod, wordsize) 
	anew = []
	bnew = []
	for i in range(begina, enda):
		anew += [a[i]]
	for i in range(beginb, endb):
		bnew += [b[i]]
	a = anew
	b = bnew
	if len(b) > len(a):
		temp = b; b = a; a = temp
	counter = [0,0]
	c = [0]*(len(a) + len(b) - 1)
	zero = [0]*len(c)
	for i in range(len(c)):
		for j in range(max(i - len(a) + 1, 0), min(len(b), i+1)):
			if c[i] != 0 or zero[i] == 1:
				counter[0] += mu
				zero[i] = 0
			c[i] += (b[j]*a[i-j])%mod
			if (b[j]*a[i-j])%mod==0:
				zero[i] = 1
			counter[1]+= mu^2
		c[i] = c[i]%mod
	return [c, counter]

def schoolbook(a, b, mod, wordsize):
	return school(a, b, 0, len(a), 0, len(b), mod, wordsize)

def schoolbook2(a, b, mod, methods, it, wordsize):
	return school(a, b, 0, len(a), 0, len(b), mod, wordsize)

def karatsuba(a, b, mod, methods, it, wordsize):
	#with a0, a1, b0 and b1 we denote polynomials A_0, A_1, B_0 and B_1. 
	#with a2 and b2 we denote (A_0 + A_1) and (B_0 + B_1).
	#with c1ac we denote polynomial (A_0 + A_1)(B_0 + B_1).

	method = methods[it]
	lena = len(a); lenb = len(b)
	if lenb > lena:
		temp = b; b = a; a = temp
	counter = [0, 0]
	while lena > lenb:
		b = [0] + b
	a0 = a[lena//2:] 
	a1= a[:lena//2]
	b0 = b[lena//2:]
	if len(b0) <= lenb:
		beginb0 = 0
	if len(b0) > lenb:
		beginb0 = len(b0) - lenb
	lenb0 = len(b0) - beginb0
	b1 = b[:lena//2]
	beginb1 = len(b1) - (lenb - lenb0); lenb1 = len(b1) - beginb1

	[a2, temp] = add(a0, a1, mod, wordsize)
	counter[0] += temp[0]

	b2 = add(b0, b1, mod, wordsize)[0]
	beginb2 = min(beginb0, beginb1)
	lenb2 = len(b2) - beginb2
	counter[0] += adding(b0, b1, beginb0, len(b0), beginb1, len(b1), mod, wordsize)[1][0]

	[c0, temp] = method(a0, b0, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	beginc0 = len(c0) - (len(a0) + lenb0 - 1)

	[c2, temp] = method(a1, b1, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	beginc2 = len(c2) - (len(a1) + lenb1 - 1)

	[c1ac, temp] = method(a2, b2, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	beginc1ac = len(c1ac) - (len(a2) + lenb2 - 1)
	
	c1temp = add(c0, c2, mod, wordsize)[0]
	c1 = subtract(c1ac, c1temp, mod, wordsize)[0]
	beginc1 = min(beginc0, beginc2, beginc1ac)
	counter[0] += adding(c0, c2, beginc0, len(c0), beginc2, len(c2), mod, wordsize)[1][0]
	counter[0] += subtracting(c1ac, c1temp, beginc1ac, len(c1ac), min(beginc0, beginc2), len(c1temp), mod, wordsize)[1][0]
	
	q = add(c0, (c1+[0]*(ceil(lena/2))), mod, wordsize)[0]
	counter[0] += adding(c0, (c1+[0]*(ceil(lena/2))), beginc0, len(c0), beginc1, len(c1), mod, wordsize)[1][0]

	c = add(q, (c2+[0]*(ceil(lena/2)*2)), mod, wordsize)[0]
	counter[0] += adding(q, (c2+[0]*(ceil(lena/2)*2)), beginc1, len(q), beginc2, len(c2), mod, wordsize)[1][0]
	
	c = c[(len(c) - (lena + lenb - 1)):]
	return [c, counter]

def inpoltoom3(a, c_0, beginc_0, c_inf, beginc_inf, c_2, beginc_2, c_min1, beginc_min1, c_1, beginc_1, mod, wordsize):
	#with c0, c1, c2, c3 and c4 we denote polynomials C_0, C_1, C_2, C_3 and C_4. 

	counter = [0, 0]
	mu = numwords(mod, wordsize)
	temp1 = add(schoolbook([3], c_0, mod, wordsize)[0], schoolbook([2], c_min1, mod, wordsize)[0], mod, wordsize)[0]
	begintemp1 = min(beginc_0, beginc_min1)
	temp2 = add(temp1, c_2, mod, wordsize)[0]
	begintemp2 = min(begintemp1, beginc_2)
	for i in range(len(temp2)):
		temp2[i] = (temp2[i]/3)%mod; temp2[i] = temp2[i]/2
	counter[1] += mu*(len(temp2) - begintemp2)
	t_1 = subtract(temp2, schoolbook([2], c_inf, mod, wordsize)[0], mod, wordsize)[0]
	begint_1 = min(begintemp2, beginc_inf)
	counter[0] += adding(schoolbook([3],c_0, mod, wordsize)[0], schoolbook([2], c_min1, mod, wordsize)[0], beginc_0, len(c_0), beginc_min1, 
		      len(c_min1), mod, wordsize)[1][0]
	counter[0] += adding(temp1, c_2, begintemp1, len(temp1), beginc_2, len(c_2), mod, wordsize)[1][0]
	counter[0] += subtracting(temp2, schoolbook([2], c_inf, mod, wordsize)[0], begintemp2, len(temp2), beginc_inf, len(c_inf), mod, wordsize)[1][0]
	counter[1] += school([3], c_0, 0, 1, beginc_0, len(c_0), mod, wordsize)[1][1]
	
	t_2 = add(c_1, c_min1, mod, wordsize)[0]
	for i in range(len(t_2)):
		t_2[i] = (t_2[i]/2)
	begint_2 = min(beginc_1, beginc_min1)
	counter[0] += adding(c_1, c_min1, beginc_1, len(c_1), beginc_min1, len(c_min1), mod, wordsize)[1][0]
	
	c0 = c_0
	beginc0 = beginc_0
	
	c1 = subtract(c_1, t_1, mod, wordsize)[0]
	beginc1 = min(beginc_1, begint_1)
	counter[0] += subtracting(c_1, t_1, beginc_1, len(c_1), begint_1, len(t_1), mod, wordsize)[1][0]
	
	temp = add(c_0,c_inf, mod, wordsize)[0]
	c2 = subtract(t_2, temp, mod, wordsize)[0]
	beginc2 = min(begint_2, beginc_0, beginc_inf)
	counter[0] += adding(c_0, c_inf, beginc_0, len(c_0), beginc_inf, len(c_inf), mod, wordsize)[1][0] 
	counter[0] += subtracting(t_2, temp, begint_2, len(t_2), min(beginc_0, beginc_inf), len(temp), mod, wordsize)[1][0]
	
	c3 = subtract(t_1, t_2, mod, wordsize)[0]
	beginc3 = min(begint_1, begint_2)
	counter[0] += subtracting(t_1, t_2, begint_1, len(t_1), begint_2, len(t_2), mod, wordsize)[1][0]
	
	c4 = c_inf
	beginc4 = beginc_inf
	
	q1 = add(c0, c1 + [0]*(ceil(len(a)/3)), mod, wordsize)[0]
	counter[0] += adding(c0, c1 + [0]*(ceil(len(a)/3)), beginc0, len(c0), beginc1, len(c1), mod, wordsize)[1][0]
	
	q2 = add(q1, c2 + [0]*(ceil(len(a)/3)*2), mod, wordsize)[0]
	counter[0] += adding(q1, c2 + [0]*(ceil(len(a)/3)*2), beginc1, len(q1), beginc2, len(c2), mod, wordsize)[1][0]
	
	q3 = add(q2, c3 + [0]*(ceil(len(a)/3)*3), mod, wordsize)[0]
	counter[0] += adding(q2, c3 + [0]*(ceil(len(a)/3)*3), beginc2, len(q2), beginc3, len(c3), mod, wordsize)[1][0]
	
	c =  add(q3, c4 + [0]*(ceil(len(a)/3)*4), mod, wordsize)[0]
	counter[0] += adding(q3, c4 + [0]*(ceil(len(a)/3)*4), beginc3, len(q3), beginc4, len(c4), mod, wordsize)[1][0]
	return [c, counter]

def toom3(a, b, mod, methods, it, wordsize):
	#with a0, a1, a2, b0, b1 and b2 we denote polynomials A_0, A_1, A_2, B_0, B_1 and B_2. 

	method = methods[it]
	lena = len(a); lenb = len(b)
	lenc = lena + lenb - 1
	mu = numwords(mod, wordsize)
	if lenb > lena:
		temp = b, b = a, a = temp
	counter = [0, 0]
	while len(a)%3!=0:
		a = [0] + a
	while len(a) > len(b):
		b = [0] + b
	a0 = a[len(a)/3*2:]
	if len(a0) <= lena:
		begina0 = 0
	if len(a0) > lena:
		begina0 = len(a0) - lena
	lena0 = len(a0) - begina0
	a1 = a[len(a)/3:len(a)/3*2]
	if len(a1) <= lena - lena0:
		begina1 = 0
	if len(a1) > lena - lena0:
		begina1 = len(a1) - (lena - lena0)
	lena1 = len(a1) - begina1
	a2 = a[:len(a)/3]
	lena2 = lena - lena0 - lena1; begina2 = len(a2) - lena2

	b0 = b[len(a)/3*2:]
	if len(b0) <= lenb:
		beginb0 = 0
	if len(b0) > lenb:
		beginb0 = len(b0) - lenb
	lenb0 = len(b0) - beginb0
	b1 = b[len(a)/3:len(a)/3*2]
	if len(b1) <= lenb - lenb0:
		beginb1 = 0
	if len(b1) > lenb - lenb0:
		beginb1 = len(b1) - (lenb - lenb0)
	lenb1 = len(b1) - beginb1
	b2 = b[:len(a)/3]
	lenb2 = lenb - lenb0 - lenb1; beginb2 = len(b2) - lenb2
	[c_inf, temp] = method(a2,b2, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	beginc_inf = len(c_inf) - (lena2 + lenb2 - 1)

	[c_0, temp] = method(a0,b0, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	beginc_0 = len(c_0) - (lena0 + lenb0 - 1)
	
	tempa1 = add(a0, a1, mod, wordsize)[0]; tempa2 = add(tempa1, a2, mod, wordsize)[0]
	tempb1 = add(b0, b1, mod, wordsize)[0]; tempb2 = add(tempb1, b2, mod, wordsize)[0]
	[c_1, temp] = method(tempa2, tempb2, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	begintempa = min(begina0, begina1, begina2); lentempa = len(tempa2) - begintempa
	begintempb = min(beginb0, beginb1, beginb2); lentempb = len(tempb2) - begintempb
	beginc_1 = len(c_1) - (lentempa + lentempb - 1)
	counter[0] += adding(a0, a1, begina0, len(a0), begina1, len(a1), mod, wordsize)[1][0] 
	counter[0] += adding(tempa1, a2, min(begina0, begina1), len(tempa1), begina2, len(a2), mod, wordsize)[1][0]
	counter[0] += adding(b0, b1, beginb0, len(b0), beginb1, len(b1), mod, wordsize)[1][0] 
	counter[0] += adding(tempb1, b2, min(beginb0, beginb1), len(tempb1), beginb2, len(b2), mod, wordsize)[1][0]

	tempa1 = add(a0, a2, mod, wordsize)[0]; tempa2 = subtract(tempa1, a1, mod, wordsize)[0]
	tempb1 = add(b0, b2, mod, wordsize)[0]; tempb2 = subtract(tempb1, b1, mod, wordsize)[0]
	[c_min1, temp] = method(tempa2, tempb2, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	beginc_min1 = len(c_min1) - (lentempa + lentempb - 1)
	counter[0] += adding(a0, a2, begina0, len(a0), begina2, len(a2), mod, wordsize)[1][0] 
	counter[0] += subtracting(tempa1, a1, min(begina0, begina2), len(tempa1), begina1, len(a1), mod, wordsize)[1][0]
	counter[0] += adding(b0, b2, beginb0, len(b0), beginb2, len(b2), mod, wordsize)[1][0] 
	counter[0] += subtracting(tempb1, b1, min(beginb0, beginb2), len(tempb1), beginb1, len(b1), mod, wordsize)[1][0]

	tempa1 = schoolbook([2], a1, mod, wordsize)[0]; tempa2 = schoolbook([4], a2, mod, wordsize)[0]
	tempa3 = add(a0, tempa1, mod, wordsize)[0]; tempa4 = add(tempa3, tempa2, mod, wordsize)[0]
	tempb1 = schoolbook([2], b1, mod, wordsize)[0]; tempb2 = schoolbook([4], b2, mod, wordsize)[0]
	tempb3 = add(b0, tempb1, mod, wordsize)[0]; tempb4 = add(tempb3, tempb2, mod, wordsize)[0]
	[c_2, temp] = method(tempa4, tempb4, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	beginc_2 = len(c_2) - (lentempa + lentempb - 1)
	counter[0] += adding(a0, tempa1, begina0, len(a0), begina1, len(a1), mod, wordsize)[1][0] 
	counter[0] += adding(tempa3, tempa2, min(begina0, begina1), len(tempa3), begina2, len(a2), mod, wordsize)[1][0]
	counter[0] += adding(b0, tempb1, beginb0, len(b0), beginb1, len(b1), mod, wordsize)[1][0] 
	counter[0] += adding(tempb3, tempb2, min(beginb0, beginb1), len(tempb3), beginb2, len(b2), mod, wordsize)[1][0]
	
	[c, temp] = inpoltoom3(a, c_0, beginc_0, c_inf, beginc_inf, c_2, beginc_2, c_min1, beginc_min1, c_1, beginc_1, mod, wordsize)
	counter[0] += temp[0]
	counter[1] += temp[1]
	
	for i in range(len(c)):
		c[i] = c[i]%mod
	c = c[(len(c) - (lena + lenb - 1)):]
	return [c, counter]

def inpoltoom4(a, c0, beginc0, c1, beginc1, c2, beginc2, c3, beginc3, c4, beginc4, c5, beginc5, c6, beginc6, mod, wordsize):
	#with c0, c1, c2, c3, c4, c5 and c6 we denote polynomials C_0, C_1, C_2, C_3, C_4, C_5 and C_6. 

	counter = [0, 0]
	 
	mu = numwords(mod, wordsize)
	counter[0] += adding(c5, c2, beginc5, len(c5), beginc2, len(c2), mod, wordsize)[1][0]
	beginc5 = min(beginc5, beginc2)
	c5 = add(c5, c2, mod, wordsize)[0]
	
	counter[0] += subtracting(c1, c2, beginc1, len(c1), beginc2, len(c2), mod, wordsize)[1][0]
	beginc1 = min(beginc1, beginc2)
	c1 = subtract(c1, c2, mod, wordsize)[0]
	
	counter[0] += subtracting(c3, c4, beginc3, len(c3), beginc4, len(c4), mod, wordsize)[1][0]
	beginc3 = min(beginc3, beginc4)
	c3 = subtract(c3, c4, mod, wordsize)[0]
	for i in range(len(c3)):
		c3[i] = c3[i]/2
	
	tempc01 = schoolbook([64],c0, mod, wordsize)[0]
	tempc02 = add(c6, tempc01, mod, wordsize)[0]
	begintemp = min(beginc6, beginc0)
	counter[0] += adding(c6, tempc01, beginc6, len(c6), beginc0, len(c0), mod, wordsize)[1][0] 
	counter[0] += subtracting(c2, tempc02, beginc2, len(c2), begintemp, len(tempc02), mod, wordsize)[1][0]
	beginc2 = min(beginc6, beginc0, beginc2)
	c2 = subtract(c2, tempc02, mod, wordsize)[0]

	counter[0] += adding(c4, c3, beginc4, len(c4), beginc3, len(c3), mod, wordsize)[1][0]
	beginc4 = min(beginc4, beginc3)
	c4 = add(c4, c3, mod, wordsize)[0]

	counter[0] += adding(schoolbook([2], c2, mod, wordsize)[0], c1, beginc2, len(c2), beginc1, len(c1), mod, wordsize)[1][0]
	beginc2 = min(beginc2, beginc1)
	c2 = add(schoolbook([2], c2, mod, wordsize)[0], c1, mod, wordsize)[0]

	tempc51 = schoolbook([65],c4, mod, wordsize)[0]
	counter[0] += subtracting(c5, tempc51, beginc5, len(c5), beginc4, len(c4), mod, wordsize)[1][0]
	counter[1] += school([65], c4, 0, 1, beginc4, len(c4), mod, wordsize)[1][1]
	beginc5 = min(beginc5, beginc4)
	c5 = subtract(c5, tempc51, mod, wordsize)[0]
	
	tempc41 = add(c6, c0, mod, wordsize)[0]
	counter[0] += adding(c6, c0, beginc6, len(c6), beginc0, len(c0), mod, wordsize)[1][0] 
	counter[0] += subtracting(c4, tempc41, beginc4, len(c4), min(beginc6, beginc0), len(tempc41), mod, wordsize)[1][0]
	beginc4 = min(beginc4, beginc6, beginc0)
	c4 = subtract(c4, tempc41, mod, wordsize)[0]

	tempc51 = schoolbook([45],c4, mod, wordsize)[0]
	counter[0] += adding(c5, tempc51, beginc5, len(c5), beginc4, len(c4), mod, wordsize)[1][0]
	counter[1] += school([45], c4, 0, 1, beginc4, len(c4), mod, wordsize)[1][1]
	beginc5 = min(beginc5, beginc4)
	c5 = add(c5, tempc51, mod, wordsize)[0]

	tempc21 = schoolbook([8],c4, mod, wordsize)[0]
	counter[0] += subtracting(c2, tempc21, beginc2, len(c2), beginc4, len(c4), mod, wordsize)[1][0] 
	beginc2 = min(beginc2, beginc4)
	c2 = subtract(c2, tempc21, mod, wordsize)[0]
	for i in range(len(c2)):
		c2[i] = (c2[i]/3)%mod; c2[i] = c2[i]/8
	counter[1] += mu*(len(c2) - beginc2)
	
	counter[0] += adding(c1, c5, beginc1, len(c1), beginc5, len(c5), mod, wordsize)[1][0]
	beginc1 = min(beginc1, beginc5)
	c1 = add(c1, c5, mod, wordsize)[0]

	tempc51 = schoolbook([16],c3, mod, wordsize)[0]
	counter[0] += adding(c5, tempc51, beginc5, len(c5), beginc3, len(c3), mod, wordsize)[1][0]
	beginc5 = min(beginc5, beginc3)
	c5 = add(c5, tempc51, mod, wordsize)[0]
	for i in range(len(c5)):
		c5[i] = (c5[i]/9)%mod; c5[i] = c5[i]/2
	counter[1] += mu*(len(c5) - beginc5)

	counter[0] += subtracting(c4, c2, beginc4, len(c4), beginc2, len(c2), mod, wordsize)[1][0]
	beginc4 = min(beginc2, beginc4)
	c4 = subtract(c4, c2, mod, wordsize)[0]

	counter[0] += adding(c3, c5, beginc3, len(c3), beginc5, len(c5), mod, wordsize)[1][0]
	beginc3 = min(beginc3, beginc5)
	c3 = add(c3, c5, mod, wordsize)[0]
	for i in range(len(c3)):
		c3[i] = c3[i]*(-1)
	counter[1] += mu*(len(c3) - beginc3)

	tempc11 = schoolbook([30],c5, mod, wordsize)[0]
	counter[0] += subtracting(tempc11, c1, beginc5, len(c5), beginc1, len(c1), mod, wordsize)[1][0]
	counter[1] += school([30], c5, 0, 1, beginc5, len(c5), mod, wordsize)[1][1]
	beginc1 = min(beginc5, beginc1)
	c1 = subtract(tempc11, c1, mod, wordsize)[0]
	for i in range(len(c1)):
		c1[i] = (c1[i]/15)%mod; c1[i] = c1[i]/4
	counter[1] += mu*(len(c1) - beginc1)

	counter[0] += subtracting(c5, c1, mod, beginc5, len(c5), beginc1, len(c1), wordsize)[1][0]
	beginc5 = min(beginc5, beginc1)
	c5 = subtract(c5, c1, mod, wordsize)[0]

	q1 = add(c0, c1 + [0]*(ceil(len(a)/4)), mod, wordsize)[0]
	counter[0] += adding(c0, c1 + [0]*(ceil(len(a)/4)), beginc0, len(c0), beginc1, len(c1), mod, wordsize)[1][0]
	
	q2 = add(q1, c2 + [0]*(ceil(len(a)/4)*2), mod, wordsize)[0]
	counter[0] += adding(q1, c2 + [0]*(ceil(len(a)/4)*2), beginc1, len(q1), beginc2, len(c2), mod, wordsize)[1][0]
	
	q3 = add(q2, c3 + [0]*(ceil(len(a)/4)*3), mod, wordsize)[0]
	counter[0] += adding(q2, c3 + [0]*(ceil(len(a)/4)*3), beginc2, len(q2), beginc3, len(c3), mod, wordsize)[1][0]
	
	q4 = add(q3, c4 + [0]*(ceil(len(a)/4)*4), mod, wordsize)[0]
	counter[0] += adding(q3, c4 + [0]*(ceil(len(a)/4)*4), beginc3, len(q3), beginc4, len(c4), mod, wordsize)[1][0]
	
	q5 = add(q4, c5 + [0]*(ceil(len(a)/4)*5), mod, wordsize)[0]
	counter[0] += adding(q4, c5 + [0]*(ceil(len(a)/4)*5), beginc4, len(q4), beginc5, len(c5), mod, wordsize)[1][0]
	
	c =  add(q5, c6 + [0]*(ceil(len(a)/4)*6), mod, wordsize)[0]
	counter[0] += adding(q5, c6 + [0]*(ceil(len(a)/4)*6), beginc5, len(q5), beginc6, len(c6), mod, wordsize)[1][0]
	return [c, counter]

def toom4(a, b, mod, methods, it, wordsize):
	#with a0, a1, a2, a3, b0, b1, b2 and b3 we denote polynomials A_0, A_1, A_2, A_3, B_0, B_1, B_2 and B_3. 

	method = methods[it]
	lena = len(a); lenb = len(b)
	lenc = lena + lenb - 1
	mu = numwords(mod, wordsize)
	if lenb > lena:
		temp = b; b = a; a = temp
	counter = [0, 0]
	while len(a)%4!=0:
		a = [0] + a
	while len(a) > len(b):
		b = [0] + b

	a0 = a[len(a)/4*3:]
	if len(a0) <= lena:
		begina0 = 0
	if len(a0) > lena:
		begina0 = len(a0) - lena
	lena0 = len(a0) - begina0
	a1 = a[len(a)/4*2:len(a)/4*3]
	if len(a1) <= lena - lena0:
		begina1 = 0
	if len(a1) > lena - lena0:
		begina1 = len(a1) - (lena - lena0)
	lena1 = len(a1) - begina1
	a2 = a[len(a)/4:len(a)/4*2]
	if len(a2) <= lena - lena0 - lena1:
		begina2 = 0
	if len(a2) > lena - lena0 - lena1:
		begina2 = len(a2) - (lena - lena0 - lena1)
	lena2 = len(a2) - begina1
	a3 = a[:len(a)/4]
	lena3 = lena - lena0 - lena1 - lena2; begina3 = len(a3) - lena3

	b0 = b[len(a)/4*3:]
	if len(b0) <= lenb:
		beginb0 = 0
	if len(b0) > lenb:
		beginb0 = len(b0) - lenb
	lenb0 = len(b0) - beginb0
	b1 = b[len(a)/4*2:len(a)/4*3]
	if len(b1) <= lenb - lenb0:
		beginb1 = 0
	if len(b1) > lenb - lenb0:
		beginb1 = len(b1) - (lenb - lenb0)
	lenb1 = len(b1) - beginb1
	b2 = b[len(a)/4:len(a)/4*2]
	if len(b2) <= lenb - lenb0 - lenb1:
		beginb2 = 0
	if len(b2) > lenb - lenb0 - lenb1:
		beginb2 = len(b2) - (lenb - lenb0 - lenb1)
	lenb2 = len(b2) - beginb1
	b3 = b[:len(a)/4]
	lenb3 = lenb - lenb0 - lenb1 - lenb2; beginb3 = len(b3) - lenb3

	[c_inf, temp] = method(a3, b3, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	beginc_inf = len(c_inf) - (lena3 + lenb3 - 1)

	[c_0, temp] = method(a0, b0, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	beginc_0 = len(c_0) - (lena0 + lenb0 - 1)

	tempa1 = add(a0, a1, mod, wordsize)[0]; tempa2 = add(a2, a3, mod, wordsize)[0]; tempa3 = add(tempa1, tempa2, mod, wordsize)[0]
	begintempa1 = min(begina0, begina1); begintempa2 = min(begina2, begina3); begintempa = min(begintempa1, begintempa2)
	tempb1 = add(b0, b1, mod, wordsize)[0]; tempb2 = add(b2, b3, mod, wordsize)[0]; tempb3 = add(tempb1, tempb2, mod, wordsize)[0]
	begintempb1 = min(beginb0, beginb1); begintempb2 = min(beginb2, beginb3); begintempb = min(begintempb1, begintempb2)
	[c_1, temp] = method(tempa3, tempb3, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	lentempa = len(tempa3) - begintempa; lentempb = len(tempb3) - begintempb
	beginc_1 = len(c_1) - (lentempa + lentempb - 1)
	counter[0] += adding(a0, a1, begina0, len(a0), begina1, len(a1), mod, wordsize)[1][0] 
	counter[0] += adding(a2, a3, begina2, len(a2), begina3, len(a3), mod, wordsize)[1][0] 
	counter[0] += adding(b0, b1, beginb0, len(b0), beginb1, len(b1), mod, wordsize)[1][0] 
	counter[0] += adding(b2, b3, beginb2, len(b2), beginb3, len(b3), mod, wordsize)[1][0] 
	counter[0] += adding(tempa1, tempa2, begintempa1, len(tempa1), begintempa2, len(tempa2), mod, wordsize)[1][0] 
	counter[0] += adding(tempb1, tempb2, begintempb1, len(tempb1), begintempb2, len(tempb2), mod, wordsize)[1][0]
	
	tempa1 = add(a0, a2, mod, wordsize)[0]; tempa2 = add(a1, a3, mod, wordsize)[0]; tempa3 = subtract(tempa1, tempa2, mod, wordsize)[0]	
	begintempa1 = min(begina0, begina2); begintempa2 = min(begina1, begina3); begintempa = min(begintempa1, begintempa2)
	tempb1 = add(b0, b2, mod, wordsize)[0]; tempb2 = add(b1, b3, mod, wordsize)[0]; tempb3 = subtract(tempb1, tempb2, mod, wordsize)[0]
	begintempb1 = min(beginb0, beginb2); begintempb2 = min(beginb1, beginb3); begintempb = min(begintempb1, begintempb2)
	[c_min1, temp] = method(tempa3, tempb3, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	lentempa = len(tempa3) - begintempa; lentempb = len(tempb3) - begintempb
	beginc_min1 = len(c_min1) - (lentempa + lentempb - 1)
	counter[0] += adding(a0, a2, begina0, len(a0), begina2, len(a2), mod, wordsize)[1][0]
	counter[0] += adding(a1, a3, begina1, len(a1), begina3, len(a3), mod, wordsize)[1][0] 
	counter[0] += adding(b0, b2, beginb0, len(b0), beginb2, len(b2), mod, wordsize)[1][0] 
	counter[0] += adding(b1, b3, beginb1, len(b1), beginb3, len(b3), mod, wordsize)[1][0] 
	counter[0] += subtracting(tempa1, tempa2, begintempa1, len(tempa1), begintempa2, len(tempa2), mod, wordsize)[1][0]
	counter[0] += subtracting(tempb1, tempb2, begintempb1, len(tempa1), begintempb2, len(tempb2), mod, wordsize)[1][0]

	tempa1 = schoolbook([2], a2, mod, wordsize)[0]; tempa2 = schoolbook([4], a1, mod, wordsize)[0]; tempa3 = schoolbook([8], a0, mod, wordsize)[0]
	tempa4 = add(tempa2, tempa3, mod, wordsize)[0]; tempa5 = add(tempa1, tempa4, mod, wordsize)[0]
	begintempa4 = min(begina1, begina0); begintempa5 = min(begintempa4, begina2); begintempa = min(begina3, begintempa5)
	c_halfa = add(a3, tempa5, mod, wordsize)[0]	
	lentempa = len(c_halfa) - begintempa
	counter[0] += adding(tempa2, tempa3, begina1, len(a1), begina0, len(a0), mod, wordsize)[1][0] 
	counter[0] += adding(tempa1, tempa4, begina2, len(a2), begintempa4, len(tempa4), mod, wordsize)[1][0]
	counter[0] += adding(a3, tempa5, begina3, len(a3), begintempa5, len(tempa5), mod, wordsize)[1][0]
	
	tempb1 = schoolbook([2], b2, mod, wordsize)[0]; tempb2 = schoolbook([4], b1, mod, wordsize)[0]; tempb3 = schoolbook([8], b0, mod, wordsize)[0]
	tempb4 = add(tempb2, tempb3, mod, wordsize)[0]; tempb5 = add(tempb1, tempb4, mod, wordsize)[0]
	begintempb4 = min(beginb1, beginb0); begintempb5 = min(begintempb4, beginb2); begintempb = min(beginb3, begintempb5)
	c_halfb = add(b3, tempb5, mod, wordsize)[0]	
	lentempb = len(c_halfb) - begintempb
	counter[0] += adding(tempb2, tempb3, beginb1, len(b1), beginb0, len(b0), mod, wordsize)[1][0] 
	counter[0] += adding(tempb1, tempb4, beginb2, len(b2), begintempb4, len(tempb4), mod, wordsize)[1][0]
	counter[0] += adding(b3, tempb5, beginb3, len(b3), begintempb5, len(tempb5), mod, wordsize)[1][0]

	[c_half, temp] = method(c_halfa, c_halfb, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	beginc_half = len(c_half) - (lentempa + lentempb - 1)

	tempa1 = schoolbook([8], a0, mod, wordsize)[0]; tempa2 = schoolbook([4], a1, mod, wordsize)[0]; tempa3 = schoolbook([2], a2, mod, wordsize)[0]
	tempa4 = subtract(tempa3, a3, mod, wordsize)[0]; tempa5 = subtract(tempa1, tempa2, mod, wordsize)[0]
	begintempa4 = min(begina2, begina3); begintempa5 = min(begina0, begina1); begintempa = min(begintempa4, begintempa5)
	c_minhalfa = add(tempa5, tempa4, mod, wordsize)[0]
	lentempa = len(c_minhalfa) - begintempa
	counter[0] += subtracting(tempa1, tempa2, begina0, len(a0), begina1, len(a1), mod, wordsize)[1][0] 
	counter[0] += subtracting(tempa3, a3, begina2, len(a2), begina3, len(a3), mod, wordsize)[1][0]
	counter[0] += adding(tempa5, tempa4, begintempa4, len(tempa4), begintempa5, len(tempa5), mod, wordsize)[1][0]
	
	tempb1 = schoolbook([8], b0, mod, wordsize)[0]; tempb2 = schoolbook([4], b1, mod, wordsize)[0]; tempb3 = schoolbook([2], b2, mod, wordsize)[0]
	tempb4 = subtract(tempb3, b3, mod, wordsize)[0]; tempb5 = subtract(tempb1, tempb2, mod, wordsize)[0]
	begintempb4 = min(beginb2, beginb3); begintempb5 = min(beginb0, beginb1); begintempb = min(begintempb4, begintempb5)
	c_minhalfb = add(tempb5, tempb4, mod, wordsize)[0]
	lentempb = len(c_minhalfb) - begintempb
	counter[0] += subtracting(tempb1, tempb2, beginb0, len(b0), beginb1, len(b1), mod, wordsize)[1][0] 
	counter[0] += subtracting(tempb3, b3, beginb2, len(b2), beginb3, len(b3), mod, wordsize)[1][0]
	counter[0] += adding(tempb5, tempb4, begintempb4, len(tempb4), begintempb5, len(tempb5), mod, wordsize)[1][0]

	[c_minhalf, temp] = method(c_minhalfa, c_minhalfb, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	beginc_minhalf = len(c_minhalf) - (lentempa + lentempb - 1)

	tempa1 = schoolbook([8], a3, mod, wordsize)[0]; tempa2 = schoolbook([4], a2, mod, wordsize)[0]; tempa3 = schoolbook([2], a1, mod, wordsize)[0]
	tempa4 = add(tempa1, tempa2, mod, wordsize)[0]; tempa5 = add(tempa3, tempa4, mod, wordsize)[0]
	begintempa4 = min(begina2, begina3); begintempa5 = min(begintempa4, begina1); begintempa = min(begina0, begintempa5)
	c_2a = add(a0, tempa5, mod, wordsize)[0]
	lentempa = len(c_2a) - begintempa
	counter[0] += adding(tempa2, tempa1, begina2, len(a2), begina3, len(a3), mod, wordsize)[1][0]
	counter[0] += adding(tempa3, tempa4, begina1, len(a1), begintempa4, len(tempa4), mod, wordsize)[1][0]
	counter[0] += adding(a0, tempa5, begina0, len(a0), begintempa5, len(tempa5), mod, wordsize)[1][0]

	tempb1 = schoolbook([8], b3, mod, wordsize)[0]; tempb2 = schoolbook([4], b2, mod, wordsize)[0]; tempb3 = schoolbook([2], b1, mod, wordsize)[0]
	tempb4 = add(tempb1, tempb2, mod, wordsize)[0]; tempb5 = add(tempb3, tempb4, mod, wordsize)[0]
	begintempb4 = min(beginb2, beginb3); begintempb5 = min(begintempb4, beginb1); begintempb = min(beginb0, begintempb5)
	c_2b = add(b0, tempb5, mod, wordsize)[0]
	lentempb = len(c_2b) - begintempb
	counter[0] += adding(tempb2, tempb1, beginb2, len(b2), beginb3, len(b3), mod, wordsize)[1][0]
	counter[0] += adding(tempb3, tempb4, beginb1, len(b1), begintempb4, len(tempb4), mod, wordsize)[1][0]
	counter[0] += adding(b0, tempb5, beginb0, len(b0), begintempb5, len(tempb5), mod, wordsize)[1][0]

	[c_2, temp] = method(c_2a,c_2b, mod, methods, it + 1, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	beginc_2 = len(c_2) - (lentempa + lentempb - 1)

	[c, temp] = inpoltoom4(a, c_0, beginc_0, c_minhalf, beginc_minhalf, c_half, beginc_half, c_min1, beginc_min1, c_1, beginc_1, c_2, 
			       beginc_2, c_inf, beginc_inf, mod, wordsize)
	counter[0] += temp[0]
	counter[1] += temp[1]
	
	for i in range(len(c)):
		c[i] = c[i]%mod
	c = c[(len(c) - (lena + lenb - 1)):]
	return [c, counter]

def bestcombo(size, ratio, mod, wordsize):
	a = [random.randrange(0, mod) for k in range(size)]
	b = [random.randrange(0, mod) for k in range(size)]
	countt3 = 1; countt4 = 1
	if mod%2 == 0:
		countt3 = 2
		countt4 = 2^3

	counter = schoolbook(a, b, mod, wordsize)[1]
	efficiencyoutput1 = counter[0] + ratio*counter[1]; efficiencyoutput2 = efficiencyoutput1; efficiencyoutput3 = efficiencyoutput1
	methodsoutput1 = [schoolbook2]; methodsoutput2 = [schoolbook2]; methodsoutput3 = [schoolbook2]
	output1 = [schoolbook2]; output2 = [schoolbook2]; output3 = [schoolbook2]

	checkoutput1 = 0; checkoutput2 = 0; checkoutput3 = 0;

	for i in range(1, 11):
		if checkoutput1 < 2:
			counteroutput1 = karatsuba(a, b, mod, methodsoutput1, 0, wordsize)[1]
			efficiencytest = counteroutput1[0] + ratio*counteroutput1[1]
			if efficiencytest < efficiencyoutput1:
				efficiencyoutput1 = efficiencytest
				output1 = [karatsuba] + methodsoutput1
				checkoutput1 = 0
			if efficiencytest > efficiencyoutput1:
				checkoutput1 += 1
			methodsoutput1 = [karatsuba] + methodsoutput1
		
		if checkoutput2 < 2:
			counteroutput2 = toom3(a, b, mod*countt3^(i), methodsoutput2, 0, wordsize)[1]
			efficiencytest = counteroutput2[0] + ratio*counteroutput2[1]
			if efficiencytest < efficiencyoutput2:
				efficiencyoutput2 = efficiencytest
				output2 = [toom3] + methodsoutput2
				checkoutput2 = 0
			if efficiencytest > efficiencyoutput2:
				checkoutput2 += 1
			methodsoutput2 = [toom3] + methodsoutput2
		
		if checkoutput3 < 2:
			counteroutput3 = toom4(a, b, mod*countt4^(i), methodsoutput3, 0, wordsize)[1]
			efficiencytest = counteroutput3[0] + ratio*counteroutput3[1]
			if efficiencytest < efficiencyoutput3:
				efficiencyoutput3 = efficiencytest
				output3 = [toom4] + methodsoutput3
				checkoutput3 = 0
			if efficiencytest > efficiencyoutput3:
				checkoutput3 += 1
			methodsoutput3 = [toom4] + methodsoutput3
	
	u1 = output1; counteru1 = counteroutput1; efficiencyu1 = efficiencyoutput1; checku1 = 0; 
	u2 = output1; counteru2version1 = counteroutput1; efficiencyu2 = efficiencyoutput1; checku2 = 0; 
	wversion1 = output1[1:]; wversion2 = output1[2:]
	w = output1[2:]; mod2 = 0; count = 0

	for i in range(1, len(output1)):
		if checku1 < 2:
			counteru1 = toom4(a, b, mod*countt4^i, w, 0, wordsize)[1]
			efficiencytest = counteru1[0] + ratio*counteru1[1]
			if efficiencytest < efficiencyu1:
				efficiencyu1 = efficiencytest
				u1 = [toom4] + w
				count += 1
				checku1 = 0
				mod2 = mod*countt4^i
			if efficiencytest > efficiencyu1:
				checku1 += 1
			w = [toom4] + w[:(len(w) - 3)] + [schoolbook2]
		
		if checku2 < 2:
			counteru2version1 = toom3(a, b, mod*countt3^i, wversion1, 0, wordsize)[1]
			counteru2version2 = toom3(a, b, mod*countt3^i, wversion2, 0, wordsize)[1]
			efficiencytestversion1 = counteru2version1[0] + ratio*counteru2version1[1]
			efficiencytestversion2 = counteru2version2[0] + ratio*counteru2version2[1]
			temp = efficiencytestversion1
			temp2 = wversion1
			temp3 = u2

			if efficiencytestversion2 < efficiencytestversion1:
				temp = efficiencytestversion2
				temp2 = wversion2

			if temp < efficiencyu2:
				efficiencyu2 = temp
				u2 = [toom3] + temp2
				wversion1 = [toom3] + temp2[:(len(temp2) - 2)] + [schoolbook2]
				wversion2 = [toom3] + temp2[:(len(temp2) - 3)] + [schoolbook2]
				
			if temp > efficiencyu2:
				wversion1 = [toom3] + wversion1[:(len(wversion1) - 2)] + [schoolbook2]
				wversion2 = [toom3] + wversion1[:(len(wversion1) - 3)] + [schoolbook2]

			if u2 == temp3:
				checku2 += 1
	
	tooms = u1[:count]
	rest = u1[count:]	
	u3 = u1; efficiencyu3 = efficiencyu1; checku3 = 0; 
	wversion1 = [toom3] + rest; wversion2 = [toom3] + rest[1:]

	for i in range(1, len(u1)):	
		if checku3 < 2:
			counteru3version1 = toom4(a, b, mod2*countt3^i, tooms[1:] + wversion1, 0, wordsize)[1]
			counteru3version2 = toom4(a, b, mod2*countt3^i, tooms[1:] + wversion2, 0, wordsize)[1]
			efficiencytestversion1 = counteru3version1[0] + ratio*counteru3version1[1]
			efficiencytestversion2 = counteru3version2[0] + ratio*counteru3version2[1]
			temp = efficiencytestversion1
			temp2 = wversion1
			temp3 = u3
			if efficiencytestversion2 < efficiencytestversion1:
				temp = efficiencytestversion2
				temp2 = wversion2

			if temp < efficiencyu3:
				efficiencyu3 = temp
				u3 = tooms + temp2
				wversion1 = [toom3] + temp2[:(len(temp2) - 2)] + [schoolbook2]
				wversion2 = [toom3] + temp2[:(len(temp2) - 3)] + [schoolbook2]
			if temp > efficiencyu3:
				wversion1 = [toom3] + wversion1[:(len(wversion1) - 2)] + [schoolbook2]
				wversion2 = [toom3] + wversion1[:(len(wversion1) - 3)] + [schoolbook2]
			if u3 == temp3:
				checku3 += 1
		
	output4 = u1
	efficiencyoutput4 = efficiencyu1
	if efficiencyoutput1 < efficiencyoutput4:
		output4 = output1
		efficiencyoutput4 = efficiencyoutput1
	if efficiencyoutput2 < efficiencyoutput4:
		output4 = output2
		efficiencyoutput4 = efficiencyoutput2
	if efficiencyoutput3 < efficiencyoutput4:
		output4 = output3
		efficiencyoutput4 = efficiencyoutput3
	if efficiencyu2 < efficiencyoutput4:
		output4 = u2
		efficiencyoutput4 = efficiencyu2
	if efficiencyu3 < efficiencyoutput4:
		output4 = u3
		efficiencyoutput4 = efficiencyu3
	return [output1, output2, output3, output4]

def nttform(a, w, mod, wordsize, count):
	#with aeven, aodd, nttaeven, nttaodd and ntta we denote a_even, a_odd, NTTa_even, NTTa_odd and NTTa.

	mu = numwords(mod, wordsize)
	counter = [0, 0]
	m = len(a)
	if m == 1:
		return [a, counter]
	aeven = a[1::2]; aodd = a[0::2]
	begin = 1
	
	[nttaeven, temp] = nttform(aeven, (w^2)%mod, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[nttaodd, temp] = nttform(aodd, (w^2)%mod, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	ntta = [0]*m

	for k in range(m/2):
		mult = begin*nttaodd[k]%mod; counter[1] += count*mu^2
		ntta[k] = (nttaeven[k] + mult)%mod; counter[0] += mu
		ntta[k + (m/2)] = (nttaeven[k] - mult)%mod; counter[0] += mu
		begin = (begin*w)%mod
	return [ntta, counter]

def inttform(ntta, w, mod, wordsize, count):
	#with aeven, aodd, nttaeven, nttaodd and ntta we denote a_even, a_odd, NTTa_even, NTTa_odd and NTTa.

	mu = numwords(mod, wordsize)
	counter = [0, 0]
	m = len(ntta)
	if m == 1:
		return [ntta, counter]
	nttaeven = ntta[0::2]; nttaodd = ntta[1::2]
	begin = 1

	[aeven, temp] = inttform(nttaeven, (w^2)%mod, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[aodd, temp] = inttform(nttaodd, (w^2)%mod, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	a = [0]*m

	for k in range(m/2):	
		mult = begin*aodd[k]%mod; counter[1] += count*mu^2
		a[k] = (aeven[k] + mult)%mod; counter[0] += mu
		a[k + (m/2)] = (aeven[k] - mult)%mod; counter[0] += mu
		begin = (begin*w)%mod
	return [a, counter]

def ntt(a, b, w, mod, wordsize):	 
	#with nnta, nttb and nttc we denote NTTa, NTTb and NTTc.

	mu = numwords(mod, wordsize)
	if len(a) == 1 and len(b) == 1:
		c = [(a[0]*b[0])%mod]
		counter = [0, mu^2]
		return [c, counter]
	if len(b) > len(a):
		temp = b; b = a; a = temp
	while len(a) > len(b):
		b = [0] + b
	counter = [0, 0]
	count = 1; binw = bin(w)[2:]; po2 = binw.count('1')
	if po2 == 1:
		count = 0

	[ntta, temp] = nttform(a, w, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[nttb, temp] = nttform(b, w, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	nttc = [0]*len(a)

	for i in range(len(ntta)):
		nttc[i] = (ntta[i]*nttb[i])%mod 
		counter[1] += mu^2

	winv = (1/w)%mod
	[c, temp] = inttform(nttc, winv, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	
	m = len(c)
	for i in range(len(c)):
		c[i] = (c[i]/m)%mod
	c = c[::-1]	
	return [c, counter]

def nttsaber(a, b, mod, mod2, k, pr, wordsize):
	lenc = len(a) + len(b) - 1
	mu2 = numwords(mod2, wordsize)
	temp = a; a = [0]*(len(b) - 1) + a; b = [0]*(len(temp) - 1) + b

	count = 0; binlena = bin(len(a))[2:]; po2 = binlena.count('1')
	if po2 != 1:
		a = [0]*(2^(len(binlena)) - len(a)) + a
		b = [0]*(2^(len(binlena)) - len(b)) + b

	w = (pr^k)%mod2
	[c, counter] = ntt(a, b, w, mod2, wordsize)

	for i in range(len(c)):
		if c[i] > (mod2 - 1)/2:
			c[i] = c[i] - mod2
		c[i] = c[i]%mod
	return [c, counter]

def nttsaberred(a, b, mod, mod2, pr, wordsize): 
	#with aweighted, bweighted and cweighted we denote the weighted polynomials of a, b and c.

	if len(b) > len(a):
		temp = b; b = a; a = temp
	lenc = len(a) + len(b) - 1
	while len(a) > len(b):
		b = [0] + b
	counter = [0, 0]

	k = int(mod2/len(a))
	th = (pr^(k/2))%mod2
	mu2 = numwords(mod2, wordsize)
	w = th^2

	aweighted = [0]*len(a); bweighted = [0]*len(b)
	for i in range(len(a)):
		aweighted[i] = (a[i]*th^(len(a) - 1 - i))%mod2
		counter[1] += mu2^2
		bweighted[i] = (b[i]*th^(len(b) - 1 - i))%mod2	
		counter[1] += mu2^2
	[cweighted, temp] = ntt(aweighted, bweighted, w, mod2, wordsize); counter[0] += temp[0]; counter[1] += temp[1]

	c = [0]*len(cweighted)
	for i in range(len(c)):
		c[i] = (cweighted[i]/(th^(len(c) - 1 - i)))%mod2; counter[1] += mu2^2
		if c[i] > (mod2 - 1)/2:
			c[i] = c[i] - mod2
		c[i] = c[i]%mod
	return [c, counter]

def nttntrus(a, b, mod, mod2, pr, wordsize):
	lenc = len(a) + len(b) - 1
	lena = len(a); lenb = len(b)
	temp = a; a = [0]*(len(b) - 1) + a; b = [0]*(len(temp) - 1) + b
	mu2 = numwords(mod2, wordsize)

	count = 0; binlena = bin(len(a))[2:]; po2 = binlena.count('1')
	if po2 != 1:
		a = [0]*(2^(len(binlena)) - len(a)) + a
		b = [0]*(2^(len(binlena)) - len(b)) + b
	w = (pr^((mod2 - 1)/len(a)))%mod2
	[c, counter] = ntt(a, b, w, mod2, wordsize)

	c = c[(len(c) - (lena + lenb - 1)):]
	for i in range(len(c)):
		if c[i] > (mod2 - 1)/2:
			c[i] = c[i] - mod2
		c[i] = c[i]%mod

	c = c[(len(c) - (lena + lenb - 1)):]
	return [c, counter]

def nttformkyber(a, w, mod, wordsize, count):
	#with aeven, aodd, nttaeven, nttaodd and ntta we denote a_even, a_odd, NTTa_even, NTTa_odd and NTTa. 

	mu = numwords(mod, wordsize)
	counter = [0, 0]
	stepsize = (w^2)%mod; m = len(a)
	if m == 1:
		return [a, counter]

	aeven = a[1::2]; aodd = a[0::2]
	[nttaeven, temp] = nttformkyber(aeven, (w^2)%mod, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[nttaodd, temp] = nttformkyber(aodd, (w^2)%mod, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]

	ntta = [0]*m
	for k in range(m/2):
		mult = (w*nttaodd[k])%mod; counter[1] += count*mu^2
		ntta[k] = (nttaeven[k] + mult)%mod; counter[0] += mu
		ntta[k + (m/2)] = (nttaeven[k] - mult)%mod; counter[0] += mu
		w = (stepsize*w)%mod
	return [ntta, counter]

def inttformkyber(ntta, w, rou, mod, wordsize, count):	
	#with aeven, aodd, nttaeven, nttaodd and ntta we denote a_even, a_odd, NTTa_even, NTTa_odd and NTTa. 

	mu = numwords(mod, wordsize)
	counter = [0, 0]
	begin = 1; m = len(ntta)
	if m == 1:
		return [ntta, counter]

	nttaeven = ntta[0::2]; nttaodd = ntta[1::2]
	[aeven, temp] = inttformkyber(nttaeven, (w^2)%mod, rou[1:], mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[aodd, temp] = inttformkyber(nttaodd, (w^2)%mod, rou[1:], mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]

	a = [0]*m
	for k in range(m/2):
		mult = (begin*aodd[k])%mod; counter[1] += count*mu^2
		a[k] = ((aeven[k] + mult)/2)%mod; counter[0] += mu
		a[k + (m/2)] = ((aeven[k] - mult)/(2*rou[0]))%mod
		counter[0] += mu; counter[1] += count*mu^2
		begin = (begin*w)%mod
	return [a, counter]

def nttkyber(a, b, mod, w, count, wordsize):
	#with aeven, aodd, beven, bodd, ceven and codd we denote the polynomials a_even, a_odd, b_even, b_odd, c_even and c_odd. 
	#with nttaeven, nttaodd, nttbeven, nttbodd, nttceven and nttcodd we denote NTTa_even, NTTa_odd, NTTb_even, NTTb_odd, NTTc_even, NTTc_odd.
	#with ntta, nttb and nttc we denote NTTa, NTTb and NTTc.
	#with counter2 we denote the number of operations performed to transform the even and odd polynomials to their NTT forms.
	#with counter3 we denote the number of operations performed to transform the NTT forms of the even and odd polynomials back to coefficient forms.

	mu = numwords(mod, wordsize)
	counter = [0, 0]
	rou = [0]*256
	for i in range(len(rou)):
		rou[i] = (w^i)%mod
	
	aeven = a[1::2]; aodd = a[0::2]
	beven = b[1::2]; bodd = b[0::2]
	[nttaeven, temp] = nttformkyber(aeven, w, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[nttaodd, temp] = nttformkyber(aodd, w, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[nttbeven, temp] = nttformkyber(beven, w, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[nttbodd, temp] = nttformkyber(bodd, w, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	counter2 = temp

	ntta = [0]*128; nttb = [0]*128; nttc = [0]*128
	nttceven = [0]*128; nttcodd = [0]*128
	for i in range(len(ntta)):
		ntta[i] = [nttaodd[i], nttaeven[i]]
		nttb[i] = [nttbodd[i], nttbeven[i]]
		[nttc[i], temp] = schoolbook(ntta[i], nttb[i], mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
		nttc[i] = [nttc[i][1], (nttc[i][2] + rou[2*i + 1]*nttc[i][0])%mod]; counter[0] += mu; counter[1] += mu^2
		nttceven[i] = nttc[i][1]; nttcodd[i] = nttc[i][0]

	wkwinv = w^(-2)%mod
	rou2 = [0]*7
	for i in range(len(rou2)):
		rou2[i] = (w^(64/(2^i)))%mod
	[ceven, temp] = inttformkyber(nttceven, wkwinv, rou2, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[codd, temp] = inttformkyber(nttcodd, wkwinv, rou2, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	counter3 = temp

	ceven = ceven[::-1]; codd = codd[::-1]; c = [0]*256
	for i in range(128):
		c[2*i + 1] = ceven[i]
		c[2*i] = codd[i]
	return [c, counter, counter2, counter3]

def nttdilithium(a, b, mod, th, count, wordsize): 
	#with ntta, nttb and nttc we denote NTTa, NTTb and NTTc.
	#with counter2 we denote the number of operations performed to transform a polynomial to its NTT form.
	#with counter3 we denote the number of operations performed to transform the NTT forms of a polynomial back to its coefficient form.

	mu = numwords(mod, wordsize)
	counter = [0, 0]

	[ntta, temp] = nttformkyber(a, th, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[nttb, temp] = nttformkyber(b, th, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	counter2 = temp
	nttc = [0]*len(a)

	for i in range(len(ntta)):
		nttc[i] = (ntta[i]*nttb[i])%mod; counter[1] += mu^2

	thinv = th^(-2)%mod; rou2 = [0]*(len(bin(len(a))[2:]) - 1)
	for i in range(len(rou2)):
		rou2[i] = (th^(len(a)/(2^(i + 1))))%mod

	[c, temp] = inttformkyber(nttc, thinv, rou2, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	counter3 = temp
	c = c[::-1]	

	return [c, counter, counter2, counter3]

def nttformincomplete(a, w, mod, bound, wordsize, rou, count, count2):
	#with a1, a2, ntta1 and ntta2 we denote A_1, A_2, NTTA_1 and NTTA_2.

	mu = numwords(mod, wordsize)
	counter = [0, 0]
	m = len(a)
	if m <= bound:
		return [[a], counter]
	a1 = []; a2 = []
	for i in range(0,(len(a)/bound),2):
		a1 += a[(i + 1)*bound: (i + 2)*bound]
		a2 += a[i*bound: (i + 1)*bound]
	begin = rou[0]
	
	[ntta1, temp] = nttformincomplete(a1, (w^2)%mod, mod, bound, wordsize, rou[1:], count, count2); counter[0] += temp[0]; counter[1] += temp[1]
	[ntta2, temp] = nttformincomplete(a2, (w^2)%mod, mod, bound, wordsize, rou[1:], count, count2); counter[0] += temp[0]; counter[1] += temp[1]
	ntta = [0]*(m//bound)
	
	for k in range(len(ntta)/2):
		[tempntta, temp] = schoolbook([begin], ntta2[k], mod, wordsize); counter[1] += temp[1]*max(count, count2)
		[ntta[k], temp] = add(ntta1[k], tempntta, mod, wordsize); counter[0] += temp[0]
		[ntta[k + (len(ntta)/2)], temp] = subtract(ntta1[k], tempntta, mod, wordsize); counter[0] += temp[0]
		begin = (begin*w)%mod
	return [ntta, counter]

def inttformincomplete(ntta, w, mod, wordsize, rou, count, count2):
	#with a1, a2, ntta1 and ntta2 we denote A_1, A_2, NTTA_1 and NTTA_2.

	mu = numwords(mod, wordsize)
	counter = [0, 0]
	m = len(ntta)
	if len(ntta) == 1:
		return [ntta, counter]
	ntta1 = ntta[0::2]; ntta2 = ntta[1::2]
	begin = 1
	
	[a1, temp] = inttformincomplete(ntta1, (w^2)%mod, mod, wordsize, rou[1:], count, count2); counter[0] += temp[0]; counter[1] += temp[1]
	[a2, temp] = inttformincomplete(ntta2, (w^2)%mod, mod, wordsize, rou[1:], count, count2); counter[0] += temp[0]; counter[1] += temp[1]
	a = [0]*m;
	
	for k in range(len(a)/2):
		[tempa1, temp] = schoolbook([begin], a2[k], mod, wordsize); counter[1] += temp[1]*count
		[a[k], temp] = add(a1[k], tempa1, mod, wordsize); counter[0] += temp[0]
		[tempa2, temp] = subtract(a1[k], tempa1, mod, wordsize); counter[0] += temp[0]
		[a[k + (len(a)/2)], temp] = schoolbook([(1/rou[0])%mod], tempa2, mod, wordsize); counter[1] += temp[1]*count2
		begin = (begin*w)%mod
	return [a, counter]

def radix3form(a, w, mod, bound, wordsize, count):
	#with a1, a2, a3, ntta1, ntta2 and ntta3 we denote A_1, A_2, A_3, NTTA_1, NTTA_2 and NTTA_3.

	mu = numwords(mod, wordsize)
	counter = [0, 0]
	m = len(a)
	if m <= bound:
		return [[a], counter]
	a1 = []; a2 = []; a3 = []
	for i in range(0, (len(a)/bound), 3):
		a1 += a[(i + 2)*bound: (i + 3)*bound]
		a2 += a[(i + 1)*bound: (i + 2)*bound]
		a3 += a[i*bound: (i + 1)*bound]
	
	[ntta1, temp] = radix3form(a1, (w^3)%mod, mod, bound, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[ntta2, temp] = radix3form(a2, (w^3)%mod, mod, bound, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[ntta3, temp] = radix3form(a3, (w^3)%mod, mod, bound, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	ntta = [0]*(m//bound)
	
	for k in range(len(ntta)/3):
		[tempntta1, temp] = schoolbook(ntta2[k], [w^k%mod], mod, wordsize); counter[1] += temp[1]*count
		[tempntta2, temp] = schoolbook(ntta3[k], [w^(2*k)%mod], mod, wordsize); counter[1] += temp[1]*count
		[tempntta3, temp] = add(ntta1[k], tempntta1, mod, wordsize); counter[0] += temp[0]
		[ntta[k], temp] = add(tempntta3, tempntta2, mod, wordsize); counter[0] += temp[0]
		[tempntta4, temp] = schoolbook(ntta2[k], [w^(len(ntta)/3 + k)%mod], mod, wordsize); counter[1] += temp[1]*count
		[tempntta5, temp] = schoolbook(ntta3[k], [w^(2*(len(ntta)/3 + k))%mod], mod, wordsize); counter[1] += temp[1]*count
		[tempntta6, temp] = add(ntta1[k], tempntta4, mod, wordsize); counter[0] += temp[0]
		[ntta[k + (len(ntta)/3)], temp] = add(tempntta6, tempntta5, mod, wordsize); counter[0] += temp[0]
		[tempntta7, temp] = schoolbook(ntta2[k], [w^(2*len(ntta)/3 + k)%mod], mod, wordsize); counter[1] += temp[1]*count
		[tempntta8, temp] = schoolbook(ntta3[k], [w^(2*(2*len(ntta)/3 + k))%mod], mod, wordsize); counter[1] += temp[1]*count
		[tempntta9, temp] = add(ntta1[k], tempntta7, mod, wordsize); counter[0] += temp[0]
		[ntta[k + (2*len(ntta)/3)], temp] = add(tempntta9, tempntta8, mod, wordsize); counter[0] += temp[0]
	return [ntta, counter]

def invradix3form(a, w, mod, wordsize, count):
	#with a1, a2, a3, ntta1, ntta2 and ntta3 we denote A_1, A_2, A_3, NTTA_1, NTTA_2 and NTTA_3.

	mu = numwords(mod, wordsize)
	counter = [0, 0]
	m = len(a)
	if m == 1:
		return [a, counter]
	a1 = a[0::3]; a2 = a[1::3]; a3 = a[2::3]
	
	[ntta1, temp] = invradix3form(a1, (w^3)%mod, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[ntta2, temp] = invradix3form(a2, (w^3)%mod, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	[ntta3, temp] = invradix3form(a3, (w^3)%mod, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	ntta = [0]*(m)

	for k in range(m/3):
		[tempntta1, temp] = schoolbook(ntta2[k], [w^k%mod], mod, wordsize); counter[1] += temp[1]*count
		[tempntta2, temp] = schoolbook(ntta3[k], [w^(2*k)%mod], mod, wordsize); counter[1] += temp[1]*count
		[tempntta3, temp] = add(ntta1[k], tempntta1, mod, wordsize); counter[0] += temp[0]
		[ntta[k], temp] = add(tempntta3, tempntta2, mod, wordsize); counter[0] += temp[0]
		[tempntta4, temp] = schoolbook(ntta2[k], [w^(len(ntta)/3 + k)%mod], mod, wordsize); counter[1] += temp[1]*count
		[tempntta5, temp] = schoolbook(ntta3[k], [w^(2*(len(ntta)/3 + k))%mod], mod, wordsize); counter[1] += temp[1]*count
		[tempntta6, temp] = add(ntta1[k], tempntta4, mod, wordsize); counter[0] += temp[0]
		[ntta[k + (len(ntta)/3)], temp] = add(tempntta6, tempntta5, mod, wordsize); counter[0] += temp[0]
		[tempntta7, temp] = schoolbook(ntta2[k], [w^(2*len(ntta)/3 + k)%mod], mod, wordsize); counter[1] += temp[1]*count
		[tempntta8, temp] = schoolbook(ntta3[k], [w^(2*(2*len(ntta)/3 + k))%mod], mod, wordsize); counter[1] += temp[1]*count
		[tempntta9, temp] = add(ntta1[k], tempntta7, mod, wordsize); counter[0] += temp[0]
		[ntta[k + (2*len(ntta)/3)], temp] = add(tempntta9, tempntta8, mod, wordsize); counter[0] += temp[0]
	return [ntta, counter]

def radix2ntru821(a, b, w, count, mod, bound, rou, wordsize):
	#with ntta, nttb and nttc we denote NTTa, NTTb and NTTc.
	
	mu = numwords(mod, wordsize)
	counter = [0, 0]
	lenc = len(a) + len(b) - 1
	
	rou = rou[len(rou) - len(bin(len(a)/bound)[2:]) + 1:]
	count2 = 1; binrou = bin(rou[0])[2:]; po2 = binrou.count('1')
	if po2 == 1:
		count2 = 0

	[ntta, temp] = nttformincomplete(a, w, mod, bound, wordsize, rou, count, count2); counter[0] += temp[0]; counter[1] += temp[1]
	[nttb, temp] = nttformincomplete(b, w, mod, bound, wordsize, rou, count, count2); counter[0] += temp[0]; counter[1] += temp[1]
	nttc = [0]*len(ntta)

	for i in range(len(ntta)):
		[nttc[i], temp] = schoolbook(ntta[i], nttb[i], mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
		[tempnttc, temp] = schoolbook([rou[0]*w^(i)%mod], nttc[i][:(len(nttc[i]) - len(ntta[i]))], mod, wordsize)
		counter[1] += temp[1]*max(count, count2)
		[nttc[i], temp] = add(tempnttc, nttc[i][(len(nttc[i]) - len(ntta[i])):], mod, wordsize); counter[0] += temp[0]

	winv = (1/w)%mod; rou = rou[::-1]
	[c2, temp] = inttformincomplete(nttc, winv, mod, wordsize, rou, count, count2); counter[0] += temp[0]; counter[1] += temp[1]
	
	c = []
	for i in range(len(c2)):
		c += c2[len(c2) - 1 - i]
	m = len(c2)
	count3 = 1; binm = bin(m)[2:]; po2 = binm.count('1')
	if po2 == 1:
		count3 = 0

	for i in range(len(c)):
		c[i] = (c[i]/m)%mod; counter[1] += count3*mu
	return [c, counter]

def radix2ntru509(a, b, size, size2, mod, mod2, w, count, bound, wordsize):
	#with ntta, nttb and nttc we denote NTTa, NTTb and NTTc.

	lenc = len(a) + len(b) - 1
	a = [0]*(size2 - len(a)) + a; b = [0]*(size2 - len(b)) + b
	mu2 = numwords(mod2, wordsize)
	counter = [0, 0]
	rou = [1]*8; count2 = 0

	[ntta, temp] = nttformincomplete(a, w, mod2, bound, wordsize, rou, count, count2); counter[0] += temp[0]; counter[1] += temp[1]
	[nttb, temp] = nttformincomplete(b, w, mod2, bound, wordsize, rou, count, count2); counter[0] += temp[0]; counter[1] += temp[1]
	nttc = [0]*len(ntta)

	for i in range(len(ntta)):
		[nttc[i], temp] = schoolbook(ntta[i], nttb[i], mod2, wordsize); counter[0] += temp[0]; counter[1] += temp[1] 
		[tempnttc, temp] = schoolbook([w^i%mod2], nttc[i][:(len(nttc[i]) - len(ntta[i]))], mod2, wordsize)
		counter[1] += temp[1]*count
		[nttc[i], temp] = add(tempnttc, nttc[i][(len(nttc[i]) - len(ntta[i])):], mod2, wordsize); counter[0] += temp[0]

	w = (1/w)%mod2
	[c2, temp] = inttformincomplete(nttc, w, mod2, wordsize, rou, count, count2); counter[0] += temp[0]; counter[1] += temp[1]
	
	c = []
	for i in range(len(c2)):
		c += c2[len(c2) - 1 - i]
	m = len(c2)
	count2 = 1; binm = bin(m)[2:]; po2 = binm.count('1')
	if po2 == 1:
		count2 = 0

	for i in range(len(c)):
		c[i] = (c[i]/m)%mod2; counter[1] += count2*mu2
	c = c[(len(c) - lenc):]

	for i in range(len(c)):
		if c[i] > (mod2 - 1)/2:
			c[i] = c[i] - mod2
		c[i] = c[i]%mod
	return [c, counter]

def mixedradixntru(a, b, size, size2, mod, mod2, pr, w1, w2, count2, count3, bound2, bound3, wordsize):	
	#with ntta, nttb and nttc we denote NTTa, NTTb and NTTc.
	#with w1 and w2 we denote w_1 and w_2.

	prs = [0]*(int(size2/bound3))
	for i in range(len(prs)):
		prs[i] = pr^(((mod2 - 1)/len(prs)*i)/(bound3/bound2))%mod2
	rou = [0]*len(prs)
	for i in range(len(prs)):
		rou[i] = [0]*(len(bin(bound3/bound2)[2:])-1)
		for j in range(len(rou[i])):
			rou[i][j] = (prs[i])^(2^j)%mod2

	lenc = len(a) + len(b) - 1
	a = [0]*(size2 - len(a)) + a; b = [0]*(size2 - len(b)) + b
	mu2 = numwords(mod2, wordsize)
	counter = [0, 0]
	
	[ntta, temp] = radix3form(a, w2, mod2, bound3, wordsize, count3); counter[0] += temp[0]; counter[1] += temp[1]
	[nttb, temp] = radix3form(b, w2, mod2, bound3, wordsize, count3); counter[0] += temp[0]; counter[1] += temp[1]

	nttc = [0]*len(ntta)
	for i in range(len(ntta)):
		[nttc[i], temp] = radix2ntru821(ntta[i], nttb[i], w1, count2, mod2, bound2, rou[i], wordsize)
		counter[0] += temp[0]; counter[1] += temp[1]

	w2inv = (1/w2)%mod2
	[c2, temp] = invradix3form(nttc, w2inv, mod2, wordsize, count3); counter[0] += temp[0]; counter[1] += temp[1]

	c = []
	for i in range(len(c2)):
		c += c2[len(c2) - 1 - i]
	m = len(c2)
	count = 1; binm = bin(m)[2:]; po2 = binm.count('1')
	if po2 == 1:
		count = 0

	for i in range(len(c)):
		c[i] = (c[i]/m)%mod2; counter[1] += count*mu2
	c = c[(len(c) - lenc):]
	
	for i in range(len(c)):
		if c[i] > (mod2 - 1)/2:
			c[i] = c[i] - mod2
		c[i] = c[i]%mod
	return [c, counter]

def goodred(a, b, mod, wordsize): 
	#with anew and bnew we denote a = [A_(p0 - 1), ..., A_0] and b = [B_(p0 - 1), ..., B_0].
	#with ntta2, nttb2 and nttc2 we denote [NTTA_(p0 - 1), ..., NTTA_0], [NTTB_(p0 - 1), ..., NTTB_0] and [NTTC_(p0 - 1), ..., NTTC_0].
	#with ntta, nttb and nttc we denote NTTa, NTTb and NTTc.
	#with p0 and p1 we denote p_0 and p_1.
	
	lena = len(a); lenb = len(b)
	counter = [0, 0]
	mu = numwords(mod, wordsize)
	if len(b) > len(a):
		temp = b; b = a; a = temp
	count = 0; binlena = bin(len(a))[2:]; po2 = binlena.count('1')

	if po2 == 1:
		pr = primroot(mod); w = (pr^((mod - 1)/(lena + lenb - 1)))%mod
		[c, counter] = ntt(a, b, w, mod, wordsize)
		[c, temp] = add(c[(len(c) - lena):], c[:(len(c) - lena)], mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
		return [c, counter]
	
	if len(a) == 1 and len(b) == 1:
		c = [a[0]*b[0]]
		counter = [0, mu^2]
		return [c, counter]

	N = len(a)
	Nold = N
	if N%2!=0:
		N += 1
	p0 = N
	while p0%2 == 0:
		p0 = p0/2
	p0 = int(p0)
	while isprime(int(p0)) == False:
		N += 2
		p0 = N
		while p0%2 == 0:
			p0 = p0/2
	p1 = int(N/p0)
	s = max(max(a), max(b))
	m = lena + lenb - 1
	mod = m*s^3 + 1 
	while isprime(mod) == False or ceil((mod - 1)/p1) != floor((mod - 1)/p1):
		mod += 1
	mu = numwords(mod, wordsize)
	
	if Nold != N:
		return goodntruprime(a, b, mod, wordsize)

	a = [0]*(N-len(a))+a
	b = [0]*(N-len(b))+b
	anew = [0]*p0
	bnew = [0]*p0
	for i in range(p0):
		anew[i] = [0]*p1
		bnew[i] = [0]*p1
	for i in range(N):
		anew[i%p0][i%p1] = a[i]
		bnew[i%p0][i%p1] = b[i]
	
	pr = primroot(mod); w = (pr^((mod - 1)/p1))%mod
	count = 1; binw = bin(w)[2:]; po2 = binw.count('1')
	if po2 == 1:
		count = 0

	counter = [0, 0]
	ntta2 = [0]*p0
	nttb2 = [0]*p0
	for i in range(p0):
		[ntta2[i], temp] = nttform(anew[i], w, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
		[nttb2[i], temp] = nttform(bnew[i], w, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
	
	ntta = [0]*p1
	nttb = [0]*p1
	for i in range(p1):
		ntta[i] = [0]*p0
		nttb[i] = [0]*p0
		for j in range(p0):
			ntta[i][j] = ntta2[j][i]
			nttb[i][j] = nttb2[j][i]

	nttc2 = [0]*p1
	for i in range(p1):
		[nttc2[i], temp] = schoolbook(ntta[i], nttb[i], mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
		[nttc2[i], temp] = add(nttc2[i][(len(nttc2[i])-len(ntta[i])):], nttc2[i][:(len(nttc2[i])-len(ntta[i]))], mod, wordsize)
		counter[0] += temp[0]

	nttc = [0]*p0
	for i in range(p0):
		nttc[i] = [0]*p1
		for j in range(p1):
			nttc[i][j] = nttc2[j][i]

	winv = (1/w)%mod
	c2 = [0]*p0
	for i in range(p0):
		[c2[i], temp] = inttform(nttc[i], winv, mod, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
		for j in range(p1):
			c2[i][j] = (c2[i][j]/p1)%mod
		c2[i] = c2[i][::-1]

	c = [0]*N
	for i in range(N):
		c[i] = c2[i%p0][i%p1]
	return [c, counter]

def goodntrus(a, b, mod, mod2, pr, wordsize): 
	#with anew and bnew we denote a = [A_(p0 - 1), ..., A_0] and b = [B_(p0 - 1), ..., B_0].
	#with ntta2, nttb2 and nttc2 we denote [NTTA_(p0 - 1), ..., NTTA_0], [NTTB_(p0 - 1), ..., NTTB_0] and [NTTC_(p0 - 1), ..., NTTC_0].
	#with ntta, nttb and nttc we denote NTTa, NTTb and NTTc.
	#with p0 and p1 we denote p_0 and p_1.

	lena = len(a); lenb = len(b)
	lenc = lena + lenb - 1
	counter = [0, 0]
	mu2 = numwords(mod2, wordsize)
	if len(b) > len(a):
		temp = b; b = a; a = temp

	count = 0; binlena = bin(len(a))[2:]; po2 = binlena.count('1')
	if po2 == 1:
		[c, counter] = nttnoprime(a, b, wordsize)
		[c, temp] = add(c[(len(c) - lena):], c[:(len(c) - lena)], wordsize); counter[0] += temp[0]; counter[1] += temp[1]
		return [c, counter]
	
	if len(a) == 1 and len(b) == 1:
		c = [a[0]*b[0]]
		counter = [0, (mu2)^2]
		return [c, counter]

	N = len(a) + len(b) - 1
	if N%2!=0:
		N += 1
	p0 = N
	while p0%2 == 0:
		p0 = p0/2
	while isprime(int(p0)) == False or p0 > 10:
		N += 2
		p0 = N
		while p0%2 == 0:
			p0 = p0/2
	p0 = int(p0)
	p1 = int(N/p0)

	a = [0]*(N - len(a)) + a
	b = [0]*(N - len(b)) + b

	anew = [0]*p0
	bnew = [0]*p0
	for i in range(p0):
		anew[i] = [0]*p1
		bnew[i] = [0]*p1
	for i in range(N):
		anew[i%p0][i%p1] = a[i]
		bnew[i%p0][i%p1] = b[i]

	w = (pr^((mod2 - 1)/p1))%mod2
	count = 1; binw = bin(w)[2:]; po2 = binw.count('1')
	if po2 == 1:
		count = 0

	ntta2 = [0]*p0
	nttb2 = [0]*p0
	for i in range(p0):
		[ntta2[i], temp] = nttform(anew[i], w, mod2, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
		[nttb2[i], temp] = nttform(bnew[i], w, mod2, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]

	ntta = [0]*p1
	nttb = [0]*p1
	for i in range(p1):
		ntta[i] = [0]*p0
		nttb[i] = [0]*p0
		for j in range(p0):
			ntta[i][j] = ntta2[j][i]
			nttb[i][j] = nttb2[j][i]

	nttc2 = [0]*p1
	for i in range(p1):
		[nttc2[i], temp] = schoolbook(ntta[i], nttb[i], mod2, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
		[nttc2[i], temp] = add(nttc2[i][(len(nttc2[i]) - len(ntta[i])):], nttc2[i][:(len(nttc2[i]) - len(ntta[i]))], mod2, wordsize)
		counter[0] += temp[0]

	nttc = [0]*p0
	for i in range(p0):
		nttc[i] = [0]*p1
		for j in range(p1):
			nttc[i][j] = nttc2[j][i]

	winv = (1/w)%mod2
	c2 = [0]*p0
	for i in range(p0):
		[c2[i], temp] = inttform(nttc[i], winv, mod2, wordsize, count); counter[0] += temp[0]; counter[1] += temp[1]
		for j in range(p1):
			c2[i][j] = (c2[i][j]/p1)%mod2
		c2[i] = c2[i][::-1]
	c = [0]*N
	for i in range(N):
		c[i] = c2[i%p0][i%p1]
	c = c[(len(c) - (lena + lenb - 1)):]

	for i in range(len(c)):
		if c[i] > (mod2 - 1)/2:
			c[i] = c[i] - mod2
		c[i] = c[i]%mod
	return [c, counter]

def ssa(a, b, mod, var, wordsize): 
	#with inta, intb, intc and intd we denote int_a, int_b, int_c and int_d.
	#with anew, bnew and cnew we denote A, B and C.
	#with N1 and N2 we denote N_1 and N_2.

	lenc = len(a) + len(b) - 1
	mu = numwords(mod, wordsize)
	for i in range(len(a)):
		a[i] = a[i]%mod
		b[i] = b[i]%mod
	x = lenc*mod^2 + 1
	pow = len(bin(x)[2:])
	x = 2^(pow)
	inta = 0; intb = 0
	for i in range(len(a)):
		inta += a[i]*x^(len(a) - 1 - i)
	for i in range(len(b)):
		intb += b[i]*x^(len(b) - 1 - i)
	a = inta; b = intb

	bina = bin(a)[2:]; binw = bin(b)[2:]
	N1 = int(len(bina) + len(binw)); pow = len(bin(N1)[2:]); N1 = 2^pow
	k = pow//var; K = int(2^k); M = int((N1)/K)

	anew = [0]*K; bnew = [0]*K
	for i in range(K):
		d = a%(2^(M*(K - 1 - i)))
		anew[i] = ((a - d)/(2^(M*(K - 1 - i))))
		a = d	
		e = b%(2^(M*(K-1-i)))
		bnew[i] = ((b - e)/(2^(M*(K - 1 - i))))
		b = e
	
	N2 = 2*M + k
	pow = len(bin(N2)[2:])
	N2 = 2^pow
	while N2 < K:
		N2 = 2*(N2)
	mod2 = 2^(N2) + 1
	mu2 = numwords(mod2, wordsize)
	th = 2^((N2)/K)
	
	aweighted = [0]*len(anew); bweighted = [0]*len(bnew)
	for i in range(len(aweighted)):
		aweighted[i] = (anew[i]*th^(len(aweighted) - 1 - i))%mod2
		bweighted[i] = (bnew[i]*th^(len(bweighted) - 1 - i))%mod2

	w = th^2
	[cweighted, counter] = ntt(aweighted, bweighted, w, mod2, wordsize)
	
	cnew = [0]*len(cweighted)
	for i in range(len(cnew)):
		cnew[i] = (cweighted[i]/(th^(len(cnew) - 1 - i)))%mod2

	intc = 0
	for i in range(len(cnew)):
		intc += cnew[i]*2^(M*(len(cnew) - 1 - i))

	while abs(intc) > x^lenc:
		lenc += 1
	c = [0]*lenc
	for i in range(lenc):
		intd = intc%(x^(lenc - 1 - i))
		c[i] = ((intc - intd)/(x^(lenc - 1 - i)))
		intc = intd

	for i in range(lenc):
		if c[lenc - 1 - i] >= x//2:
			c[lenc - 1 - i] = c[lenc - 1 - i] - x;
			c[lenc - 2 - i] = c[lenc - 2 - i] + 1; 
		c[lenc - 1 - i] = c[lenc - 1 - i]%mod
	return [c, counter, M]

def ssared(a, b, mod, var, wordsize): 
	#with inta, intb, intc and intd we denote int_a, int_b, int_c and int_d.
	#with anew, bnew and cnew we denote A, B and C.
	#with N1 and N2 we denote N_1 and N_2.

	lena = len(a); lenb = len(b)
	lenc = lena + lenb - 1
	mu = numwords(mod, wordsize)
	for i in range(len(a)):
		a[i] = a[i]%mod
		b[i] = b[i]%mod
	x = lenc*mod^2+1
	pow = len(bin(x)[2:])
	x = 2^(pow)
	inta = 0; intb = 0
	for i in range(len(a)):
		inta += a[i]*x^(len(a) - 1 - i)
	for i in range(len(b)):
		intb += b[i]*x^(len(b) - 1 - i)
	a = inta; b = intb

	N1 = int(lena*log(x, 2)); M = int(N1); k = 0
	while M%2 == 0 and M > var:
		M = M/2
		k += 1
	K = int((N1)/M)

	anew = [0]*K; bnew = [0]*K
	for i in range(K):
		d = a%(2^(M*(K - 1 - i)))
		anew[i] = ((a - d)/(2^(M*(K - 1 - i))))
		a = d	
		e = b%(2^(M*(K - 1 - i)))
		bnew[i] = ((b - e)/(2^(M*(K - 1 - i))))
		b = e	

	N2 = 2*M + k
	pow = len(bin(N2)[2:]) - 1
	N2 = 2^pow
	while (N2) < K:
		N2 = 2*(N2)
	mod2 = 2^(N2) + 1
	mu2 = numwords(mod2, wordsize)
	th = 2^(N2/K)
	
	aweighted = [0]*len(anew); bweighted = [0]*len(bnew)
	for i in range(len(aweighted)):
		aweighted[i] = (anew[i]*th^(len(aweighted) - 1 - i))%mod2
		bweighted[i] = (bnew[i]*th^(len(bweighted) - 1 - i))%mod2

	w = th^2
	[cweighted, counter] = ntt(aweighted, bweighted, w, mod2, wordsize)

	cnew = [0]*len(cweighted)
	for i in range(len(cnew)):
		cnew[i] = (cweighted[i]/(th^(len(cnew) - 1 - i)))%mod2
		if cnew[i] >= 2^(N2/2):
			cnew[i] = cnew[i] - mod2

	intc = 0
	for i in range(len(cnew)):
		intc += cnew[i]*2^(M*(len(cnew) - 1 - i))
	
	lenc = lena
	while abs(intc) > x^lenc:
		lenc += 1
	c = [0]*(lenc)
	for i in range(lenc):
		intd = intc%(x^(lenc - 1 - i))
		c[i] = ((intc - intd)/(x^(lenc - 1 - i)))
		intc = intd

	for i in range(lenc):
		if c[lenc - 1 - i] >= x//2:
			c[lenc - 1 - i] = c[lenc - 1 - i] - x
			c[lenc - 2 - i] = c[lenc - 2 - i] + 1
		c[lenc - 1 - i] = c[lenc - 1 - i]%mod
	if lenc > lena:
		[c, temp] = subtract(c[(len(c) - lena):], c[:(len(c) - lena)], mod, wordsize)
		counter[0] += temp[0]	
	return [c, counter, M]

def fftformsymbolic(a, it, rou, mod, wordsize):
	#with aeven, aodd, fftaeven and fftaodd we denote a_even, a_odd, FFTa_even and FFTa_odd.

	counter = [0, 0]
	n = len(a)
	if n == 1:
		return [a, counter]

	aeven = a[1::2]; aodd = a[0::2]
	w = rou[0::2^it];
	[fftaeven, temp] = fftformsymbolic(aeven, it + 1, rou, mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	[fftaodd, temp] = fftformsymbolic(aodd, it + 1, rou, mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]

	ffta = [0]*n
	for k in range(n/2):
		if isinstance(fftaeven[k], list) == False:
			fftaeven[k] = [fftaeven[k]]
		if isinstance(fftaodd[k], list) == False:
			fftaodd[k] = [fftaodd[k]]	
		fftatemp = schoolbook(w[k], fftaodd[k], mod, wordsize)[0]
		[ffta[k], temp] = add(fftaeven[k], fftatemp, mod, wordsize); counter[0] += temp[0]
		[ffta[k + (n/2)], temp] = subtract(fftaeven[k], fftatemp, mod, wordsize); counter[0] += temp[0]
	return [ffta, counter]

def ifftformsymbolic(ffta, it, rou, mod, wordsize):
	#with aeven, aodd, fftaeven and fftaodd we denote a_even, a_odd, FFTa_even and FFTa_odd.

	counter = [0, 0]
	n = len(ffta)
	if n == 1:
		return [ffta, counter]

	fftaeven = ffta[0::2]; fftaodd = ffta[1::2]
	w = rou[0::2^it]
	[aeven, temp] = ifftformsymbolic(fftaeven, it + 1, rou, mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	[aodd, temp] = ifftformsymbolic(fftaodd, it + 1, rou, mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]

	a = [0]*n
	for k in range(n/2):
		if isinstance(aeven[k], list) == False:
			aeven[k] = [aeven[k]]
		if isinstance(aodd[k], list) == False:
			aodd[k] = [aodd[k]]	
		atemp = schoolbook(w[k], aodd[k], mod, wordsize)[0]
		[a[k], temp] = add(aeven[k], atemp, mod, wordsize); counter[0] += temp[0]
		[a[k + (n/2)], temp] = subtract(aeven[k], atemp, mod, wordsize); counter[0] += temp[0]
	return [a, counter]

def fft(a, b, mod, wordsize):
	#with ffta, fttb and fftc we denote FFTa, FFTb and FFTc.

	mu = numwords(mod, wordsize)
	counter = [0, 0]
	if len(a) == 1 and len(b) == 1:
		c = ([a[0]*b[0]])%mod; counter = [0, mu^2]
		return [c, counter]
	if len(b) > len(a):
		temp = b; b = a; a = temp
	temp = a; a = [0]*(len(b) - 1) + a; b = [0]*(len(temp) - 1) + b
	count = 0; binlena = bin(len(a))[2:]; po2 = binlena.count('1')
	if po2 != 1:
		a = [0]*(2^(len(binlena)) - len(a)) + a
		b = [0]*(2^(len(binlena)) - len(b)) + b

	rou = [0]*len(a)
	for i in range(len(a)):
		rou[i] = [1] + [0]*i
	[ffta, temp] = fftformsymbolic(a, 0, rou, mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	[fftb, temp] = fftformsymbolic(b, 0, rou, mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]

	fftc = [0]*len(a)
	for i in range(len(ffta)):
		[fftc[i], temp] = schoolbook(ffta[i], fftb[i], mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]

	rouinv = [[1]] + rou[::-1][0:-1]
	[c, temp] = ifftformsymbolic(fftc, 0, rouinv, mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]

	m = len(c)
	for i in range(m):
		while len(c[i]) > m:
			[c[i], temp] = add(c[i][(len(c[i]) - m):], c[i][:(len(c[i]) - m)], mod, wordsize)
			counter[0] += temp[0]; counter[1] += temp[1]
		while sum(c[i]) != c[i][-1]:
			[c[i], temp] = subtract(c[i][(len(c[i])//2):], c[i][:(len(c[i])//2)], mod, wordsize)
			counter[0] += temp[0]; counter[1] += temp[1]
		c[i] = ((c[i][-1])/m)%mod
	c = c[::-1]	
	return [c, counter]

def nussbau(a, b, mod, wordsize, v1, v2):
	#with anew and bnew we denote a = [A_(s - 1), ..., A_0] and b = [B_(s - 1), ..., B_0].
	#with ffta, fttb and fftc we denote FFTa, FFTb and FFTc.
	#with D we denote \check{c} and Z is used to transform D to c.

	counter = [0, 0]
	mu = numwords(mod, wordsize)
	if len(b) > len(a):
		temp = b; b = a; a = temp
	while len(a) > len(b):
		b = [0] + b
	if len(a) == 1 and len(b) == 1:
		c = ([a[0]*b[0]])%mod; counter = [0, mu^2]
		return [c, counter]
	n = len(a); k = len(bin(n)[2:]) - 1
	s = 2^v1 
	r = 2^v2	
	mrou = r/s

	anew = [0]*s; bnew = [0]*s; fftc = [0]*s
	for i in range(s):
		anew[len(anew) - 1 - i] = a[(len(anew) - 1 - i)::s]
		bnew[len(bnew) - 1 - i] = b[(len(anew) - 1 - i)::s]
		fftc[i] = [0]*r

	anew = [0]*s + anew
	bnew = [0]*s + bnew 
	fftc = [0]*s + fftc 
	for i in range(s):
		anew[i] = [0]*r
		bnew[i] = [0]*r
		fftc[i] = [0]*r

	rou = [0]*len(anew)
	for i in range(len(anew)):
		zeros = i*int(mrou)
		rou[i] = [1] + [0]*zeros

	[ffta, temp] = fftformsymbolic(anew, 0, rou, mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	[fftb, temp] = fftformsymbolic(bnew, 0, rou, mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]

	for i in range(len(ffta)):
		while len(ffta[i]) > r:
			[ffta[i], temp] = subtract(ffta[i][(len(ffta[i]) - r):], ffta[i][:(len(ffta[i]) - r)], mod, wordsize)
			counter[0] += temp[0]
		while len(fftb[i]) > r:
			[fftb[i], temp] = subtract(fftb[i][(len(fftb[i]) - r):], fftb[i][:(len(fftb[i]) - r)], mod, wordsize)
			counter[0] += temp[0]

	for i in range(2*s):
		[fftc[i], temp] = schoolbook(ffta[i], fftb[i], mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
		while len(fftc[i]) > r:
			[fftc[i], temp] = subtract(fftc[i][(len(fftc[i]) - len(ffta[i])):], fftc[i][:(len(fftc[i]) - len(ffta[i]))], mod, wordsize)
			counter[0] += temp[0]

	rouinv = [[1]] + rou[::-1][0:-1]
	[D, temp] = ifftformsymbolic(fftc, 0, rouinv, mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	n = len(D)
	for i in range(n):
		while len(D[i]) > r:
			[D[i], temp] = subtract(D[i][(len(D[i]) - r):], D[i][:(len(D[i]) - r)], mod, wordsize)
			counter[0] += temp[0]
		for j in range(len(D[i])):
			D[i][j] = ((D[i][j])/n)%mod
	D = D[::-1]

	Z = [0]*len(D)
	for i in range(len(D)):
		Z[i] = D[i]
	if len(Z) > s:
		for i in range(s):
			[Z[len(Z) - 1 - i], temp] = add(Z[len(Z) - 1 - i], schoolbook([1, 0], Z[s - 1 - i], mod, wordsize)[0], mod, wordsize)
			counter[0] += temp[0]
			while len(Z[len(Z) - 1 - i]) > r:
				[Z[len(Z) - 1 - i], temp] = subtract(Z[len(Z) - 1 - i][(len(Z[len(Z) - 1 - i]) - r):],
							    Z[len(Z) - 1 - i][:(len(Z[len(Z) - 1 - i]) - r)], mod, wordsize)
				counter[0] += temp[0]
			Z.remove(Z[s - 1 - i])	
	c = [0]*len(a)
	it = 0
	for i in range(len(c)/s):
		for j in range(s):
			c[i + j + it] = Z[j][i]
		it += s - 1
	return [c, counter]

def fftformfalcon(a, w, mod, wordsize):	 
	#with aeven, aodd, fftaeven and fftodd we denote a_even, a_odd, FFTa_even and FFTb_odd.

	mu = numwords(mod, wordsize)
	counter = [0, 0]
	stepsize = (w^2); m = len(a)
	if m == 1:
		return [a, counter]
	mucomplex = 2*numwords(2^64, wordsize)

	aeven = a[1::2]; aodd = a[0::2]
	[fftaeven, temp] = fftformfalcon(aeven, (w^2), mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	[fftaodd, temp] = fftformfalcon(aodd, (w^2), mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]

	ffta = [0]*m
	for k in range(m/2):
		mult = (w*fftaodd[k]); counter[1] += mu*mucomplex
		ffta[k] = (fftaeven[k] + mult); counter[0] += max(mu, mucomplex)
		ffta[k + (m/2)] = (fftaeven[k] - mult); counter[0] += max(mu, mucomplex)
		w = (stepsize*w)
	return [ffta, counter]

def ifftformfalcon(ffta, w, rou, mod, wordsize):
	#with aeven, aodd, fftaeven and fftodd we denote a_even, a_odd, FFTa_even and FFTb_odd.
	 
	mu = numwords(mod, wordsize)
	counter = [0, 0]
	begin = w^0; m = len(ffta)
	if m == 1:
		return [ffta, counter]
	mucomplex = 2*numwords(2^64, wordsize)

	fftaeven = ffta[0::2]; fftaodd = ffta[1::2]
	[aeven, temp] = ifftformfalcon(fftaeven, (w^2), rou[1:], mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	[aodd, temp] = ifftformfalcon(fftaodd, (w^2), rou[1:], mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]

	a = [0]*m
	for k in range(m/2):
		mult = (begin*aodd[k]); counter[1] += mu*mucomplex
		a[k] = ((aeven[k] + mult)/2); counter[0] += max(mu, mucomplex)
		a[k + (m/2)] = ((aeven[k] - mult)/(2*rou[0]))
		counter[0] += max(mu, mucomplex); counter[1] += mu*mucomplex
		begin = (begin*w)
	return [a, counter]

def fftfalcon(a, b, mod, wordsize):
	#with ffta, fttb and fftc we denote FFTa, FFTb and FFTc.
	#with counter2 we denote the number of operations performed to transform a polynomial to its FFT form.
	#with counter3 we denote the number of operations performed to transform the FFT forms of a polynomial back to its coefficient form.

	mu = numwords(mod, wordsize)
	mucomplex = 2*numwords(2^64, wordsize)
	counter = [0, 0]
	if len(a) == 1 and len(b) == 1:
		c = ([a[0]*b[0]])%mod; counter = [0, mu^2]
		return [c, counter]
	if len(b) > len(a):
		temp = b; b = a; a = temp

	w = cmath.exp(1j*math.pi/len(a))
	[ffta, temp] = fftformfalcon(a, w, mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	[fftb, temp] = fftformfalcon(b, w, mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	counter2 = temp

	fftc = [0]*len(a)
	for i in range(len(ffta)):
		fftc[i] = ffta[i]*fftb[i]; counter[1] += mucomplex^2

	wkwinv = w^(-2); rou2 = [0]*(len(bin(len(a))[2:]) - 1)
	for i in range(len(rou2)):
		rou2[i] = (w^(len(a)/(2^(i + 1))))
	[c, temp] = ifftformfalcon(fftc, wkwinv, rou2, mod, wordsize); counter[0] += temp[0]; counter[1] += temp[1]
	counter3 = temp

	c = c[::-1]
	for i in range(len(c)):
		c[i] = round(round(c[i].real, 0), 0)%mod
	return [c, counter, counter2, counter3]
