#include <stdio.h>
#include <xmmintrin.h>
__m128 mul_at_once(int one, int two);

int main() {

	int one[4] = { 1, -2, 5, -7 };
	int two[4] = { -3, 2, -4, -3 };

	__m128 wynik = mul_at_once(one, two);


	for (int i = 0; i < 4; i++)
		printf("\n%d", wynik.m128_i32[i]);


	return 0;
}
