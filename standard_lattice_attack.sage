
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
# beta_: block size for BKZ
def experiment(qlen_, l_, d_, beta_):
	qlen = qlen_
	p, q = pq_gen(512, qlen)
	print ("modulus q is ", q)
	Kannan_embedding_factor = q # set the Kannan embedding factor to be q    
	alpha = ZZ.random_element(1, q) # sample the secret key alpha
	print("secret key is ", alpha)
	l = l_
	d = d_ 
	block_B = identity_matrix(d) * 2^(l + 1) * q
	block_C = matrix(ZZ, d, 2, [0]* 2* d )
	vector_t = matrix(ZZ, 1, d,  [ 2^(l + 1) * ZZ.random_element(1, q) for _ in range(d)])
	vector_v = alpha * vector_t - matrix(ZZ, 1, d, [2^(l + 1) * ZZ.random_element(1, floor(q/2^l)) for _ in range(d)]) + matrix(ZZ, 1, d, d * [q])
	block_D = block_matrix( [[vector_t],[vector_v]])
	block_E = matrix(ZZ, 2, 2, [1, 0, 0, Kannan_embedding_factor])
	M = block_matrix([ [block_B, block_C],[block_D, block_E] ])


	# lattice reduction phase
	C = M.BKZ(block_size = beta_)

	# in the literaturem it is typical to check every row of the reduced basis
	for i in range(0, d + 2):
		temp = abs(floor(C[i][d]))
		if temp == alpha or temp + alpha == q:
			print("finding secret key successfully in row(index from 0) ", i)
			return True
	return False	
	print ("failed to find the secret key")

success_cnt = 0
for i in range(0, 10):	
	if experiment(160, 3, 80, 20) == True:
		success_cnt = success_cnt + 1
print("among 10 experiments ", success_cnt, "times success")

