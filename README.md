# Lattice-Attacks-on-EC-DSA

This repository includes the implementation of Lattice Attacks on (EC)DSA, described in the following research paper:

Chao Sun,Thomas Espitau, Mehdi Tibouchi, and Masayuki Abe, "Guessing Bits: Improved Lattice Attacks on (EC)DSA with Nonce Leakage", to appear at
IACR Transactions on Cryptographic Hardware and Embedded Systems (TCHES), 2022/1. 

# How to Run the Script
- For example, use the "load" command: load("example.sage")
- or use the "attach" command: attach("example.sage")
- or directly copy the code into the sage terminal.
- Note that in order to use the "load" and "attach" command, check you are in the right path by "pwd".

# standard_lattice_attack.sage
This script implements the typical standard way to perform lattice attacks on (EC)DSA. Standard techniques such as Recentering are already implemented.

# guessing_secret_attack.sage
This is the code for Section 4 of the paper. By eumerating some bits of the secret key, we are able to improve the success rate.

# guess_nonce_attack.sage
This is the code for Section 5 of the paper. By eumerating more bits of nonces of some signatures, we are able to improve the success rate.

# utilize_more_data_attack.sage
This is the code for Section 6 of the paper. By eumerating more bits of nonces of some signatures, we are able to improve the success rate.

# data_tpmfail_stm.csv
This is the TPM-FAIL dataset. The first row of the dataset contains the
public key and the message being signed. Each of the other rows contains (r, s)  and  t, where (r, s) is the signature and t is the signing time.

# TPM_FAIL_attack.sage
This is the code for Section 9.4 of the paper. By combining our technique of guessing bits of the secret key with the geometric assignment of leakage in Minerva, we are able to recover the secret key.

# Further Reading
- https://eprint.iacr.org/2021/455
- https://eprint.iacr.org/2020/1540
- https://eprint.iacr.org/2020/728
- https://tpm.fail/
- https://ecc2017.cs.ru.nl/slides/ecc2017-tibouchi.pdf
- https://simons.berkeley.edu/talks/using-lattices-cryptanalysis
