#include <stdio.h>

float find_max_range(float v, float alpha);

int main() {

	float v, alpha;
	scanf_s("\n%f", &v);
	scanf_s("\n%f", &alpha);

	float wynik = find_max_range(v, alpha);
	printf("%f", wynik);

	return 0;
}
