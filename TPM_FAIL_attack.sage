import csv

def takeThird(elem):
    return elem[2]

def experiment(guess_, block_size_, d_):
	p256 = 0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF

		# Curve parameters for the curve equation: y^2 = x^3 + a256*x +b256
	a256 = p256 - 3
	b256 = 0x5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B

		# Base point (x, y)
	gx = 0x6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296
	gy = 0x4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5
			#0xce2000066c7c7c6a6d727b07bb01752e5cb15acbad4e8c837cbf7987754a03e0
		# Curve order
	q = 0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551

		# Create a finite field of order p256
	FF = GF(p256)

		# Define a curve over that field with specified Weierstrass a and b parameters
	EC = EllipticCurve([FF(a256), FF(b256)])

		# Since we know P-256's order we can skip computing it and set it explicitly
	EC.set_order(q)

		# Create a variable for the base point
	G = EC(FF(gx), FF(gy))

	#alpha = ZZ.random_element(1, q - 1) # alpha is the secret key
	alpha = 0xce2000066c7c7c6a6d727b07bb01752e5cb15acbad4e8c837cbf7987754a03e0
	Q = G * alpha # public key
	#hash of the message
	h = 0xb39eaeb437e33087132f01c2abc60c6a16904ee3771cd7b0d622d01061b40729
	
	num = 800
	print("number of used signatures is ",num)
	list = []
	subset_cnt = 0

	#choose index uniformly at random
	while 1:
		temp = ZZ.random_element(2, 383458)#383459
		if temp not in list:
			list.append(temp)
			subset_cnt = subset_cnt + 1
		if subset_cnt == num:
			break
	list.sort()

	count = 0
	hit = 0
	subset_rows = [] # to store randomly selected rows
	with open('data_tpmfail_stm.csv') as fd:
		reader = csv.reader(fd)
		for row in reader:
			count = count + 1
			if list == []:
				break
			elif count == list[0]:
				hit = hit + 1
				subset_rows.append(row)
				list.pop(0)
		fd.close()
	subset_rows.sort(key = takeThird)
	subset_rows.reverse()


	d = d_ # lattice dimension
	M = identity_matrix(d + 1)
	last_row = []
	v = []
	li = []
	for i in range(0, num):
		li.append(0)
	idx = 0
	temp = num
	temp_cnt = 0
	#start to assign leakage#
	while 1:
		temp_num = ceil(temp/2)
		for i in range(idx, (idx + temp_num)):
			li[i] = temp_cnt
		idx = idx + temp_num
		temp_cnt = temp_cnt + 1
		temp = floor(temp / 2)
		if temp == 0:
			break
	multi_factor = 2^guess_
	lsb = alpha % multi_factor
	#start to construct the basis matrix#
	for i in range(0, d):
		M[i,i] = M[i,i] * 2^(li[num - 1 -i] + 1) * q
	for i in range(num - 1, num - d -1, -1):
		l = li[i]
		r = Integer(subset_rows[i][0],16)
		s = Integer(subset_rows[i][1],16)
		s_inverse = (Integer(s).inverse_mod(q))
		ti = r * s_inverse
		ti_ = multi_factor * ti
		vi = - s_inverse * h 
		vi_ = -lsb * ti + vi
		ti = ti_
		vi = vi_
		ti = ti.powermod(1, q)
		vi = vi.powermod(1, q)
		last_row.append(ti * 2^(l + 1))
		v.append( vi * 2^(l + 1) + q)	
	last_row.append(multi_factor)
	v.append(0)
	v = vector(v)
	M[d] = last_row
	M = M.stack(v)
	aug = []
	for i in range(0, d + 2):
		aug.append(0)
	aug[d + 1] =  q
	aug = vector(aug)
	M = M.augment(aug)
	#lattice construction finished#

	#lattice reduction phase#
	C = M.BKZ(block_size = block_size_)
	
	#checking whether we find the secret key#
	for i in range(0, d + 2):
		for j in range(d, d + 2):
			temp = abs(C[i][j])
			if temp + lsb == alpha or q - temp + lsb == alpha:
				print("finding secret key successfully")
				return True
	return False

cnt = 0
for i in range(0, 200):
	print("round ", i)
	if experiment(100, 30, 90) == True:
		cnt = cnt + 1
	print("success ", cnt, "times")
print("success ", cnt, "times")
