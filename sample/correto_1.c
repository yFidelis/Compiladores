int x;
int y;

int main() {
    int z;
    x = 10;
    y = 20;
    z = x + y;

    if (z > 25) {
        z = z - 5;
    } else {
        z = z + 5;
    }

    while (z < 50) {
        z = z + 1;
    }

    return z;
}
