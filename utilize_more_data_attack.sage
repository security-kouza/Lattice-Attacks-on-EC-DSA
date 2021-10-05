
# generate the p,q pairs for DSA.
def pq_gen(plen, qlen):
	q = random_prime(2^qlen - 1, False, 2^(qlen - 1))
	#S = GF(2^plen - 1)
	while 1:
		s = (2^plen - 1)/q
		k = ZZ.random_element(0, s.round())
		p = q * k  + 1
		if is_prime(p) and is_prime(q) and (p - 1) % (q * q) != 0:
			return p,q

# qlen_: length of the modulus q
# l_: number of nonce leakage
# d_: number of signatures
# c_: t is upperbounded by 2^c_
# beta_: block size for BKZ
def experiment(qlen_, l_, d_, c_, beta_):
	qlen = qlen_
	p, q = pq_gen(512, qlen)
	print ("modulus q is ", q)
	c = c_
	Kannan_embedding_factor = q # set the Kannan embedding factor to be q    
	alpha = ZZ.random_element(1, q) # sample the secret key alpha
	print("secret key is ", alpha)
	l = l_
	d = d_
	multi_factor = 2^(qlen - 10 - c) 
	block_B = identity_matrix(d) * 2^(l + 1) * q
	block_C = matrix(ZZ, d, 2, [0]* 2* d )
	vector_t = matrix(ZZ, 1, d,  [ 2^(l + 1) * ZZ.random_element(1, 2^c) for _ in range(d)])
	vector_v = alpha * vector_t - matrix(ZZ, 1, d, [2^(l + 1) * ZZ.random_element(1, floor(q/2^l)) for _ in range(d)]) + matrix(ZZ, 1, d, d * [q])
	vector_t = vector_t * multi_factor
	block_D = block_matrix( [[vector_t],[vector_v]])
	block_E = matrix(ZZ, 2, 2, [multi_factor, 0, 0, Kannan_embedding_factor])
	M = block_matrix([ [block_B, block_C],[block_D, block_E] ])
	# lattice reduction phase
	C = M.BKZ(block_size = beta_)

	print("binary notation of alpha  is ", bin(alpha))
	s_alpha = bin(alpha)
	# in the literature it is typical to check every row of the reduced basis
	for i in range(0, d + 2):
		temp = abs(floor(C[i][d]))
		temp = temp.powermod(1,q)
		s_temp = bin(temp)
		s_q_temp = bin(q - temp)
		cnt_temp = 0
		cnt_q_temp = 0
		for j in range(0, 150):
			if s_q_temp[j] == s_alpha[j]:
				cnt_q_temp = cnt_q_temp + 1
			else:
				break
		for j in range(0, 150):
			if s_temp[j] == s_alpha[j]:
				cnt_temp = cnt_temp + 1
			else:
				break
		#print("cnt_temp is ", cnt_temp)
		#print("cnt_q_temp is ",cnt_q_temp)
		if cnt_temp > 30 or cnt_q_temp > 30:
			print("finding secret key successfully ")
			print("binary notation of temp is ", bin(temp))
			print("binary notation of q - temp is ", bin(q - temp))
			return True
	print ("failed to find the secret key")
	return False	
	
success_cnt = 0
for i in range(0, 20):	
	print("round ", i)
	if experiment(160, 2, 90, 120, 30) == True:
		success_cnt = success_cnt + 1
	print(success_cnt, "times success")
print("among 10 experiments ", success_cnt, "times success")

