int a;
float b;
char c;
string s;

int main() {
    int resultado;
    a = 10;
    b = 20;

    if (a < b) {
        resultado = a + b;
    } else {
        resultado = a - b;
    }

    while (resultado < 100) {
        resultado = resultado + 10;
    }

    return resultado;
}
