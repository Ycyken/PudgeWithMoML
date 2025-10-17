void use(int& x);

int one_bb_mem2reg(int x, int y) {
    int a = x + y;
    x *= y;
    use(x);
    a -= x;
    y *= a + x;
    use(a);
    return a + x + y;
}
