  $ clang++-18  -emit-llvm -Xclang -disable-O0-optnone -c 1.cpp -O0 -S -o fO0.ll
$ clang++-18  -emit-llvm -c 1.cpp -O1 -o fO1.bc
$ clang++-18  -emit-llvm -c 1.cpp -O2 -o fO2.bc
$ clang++-18  -emit-llvm -c 1.cpp -O2 -o fO3.bc
$ export SHORT=""

  $ cat fO0.ll | grep -v -e datalay -e attributes -e '!{i32' -e triple -e source_filename -e '!llvm.' -e  '^;' -e '^$' -e 'clang version'
  define dso_local noundef i32 @_Z14one_bb_mem2regii(i32 noundef %0, i32 noundef %1) #0 {
    %3 = alloca i32, align 4
    %4 = alloca i32, align 4
    %5 = alloca i32, align 4
    store i32 %0, ptr %3, align 4
    store i32 %1, ptr %4, align 4
    %6 = load i32, ptr %3, align 4
    %7 = load i32, ptr %4, align 4
    %8 = add nsw i32 %6, %7
    store i32 %8, ptr %5, align 4
    %9 = load i32, ptr %4, align 4
    %10 = load i32, ptr %3, align 4
    %11 = mul nsw i32 %10, %9
    store i32 %11, ptr %3, align 4
    call void @_Z3useRi(ptr noundef nonnull align 4 dereferenceable(4) %3)
    %12 = load i32, ptr %3, align 4
    %13 = load i32, ptr %5, align 4
    %14 = sub nsw i32 %13, %12
    store i32 %14, ptr %5, align 4
    %15 = load i32, ptr %5, align 4
    %16 = load i32, ptr %3, align 4
    %17 = add nsw i32 %15, %16
    %18 = load i32, ptr %4, align 4
    %19 = mul nsw i32 %18, %17
    store i32 %19, ptr %4, align 4
    call void @_Z3useRi(ptr noundef nonnull align 4 dereferenceable(4) %5)
    %20 = load i32, ptr %5, align 4
    %21 = load i32, ptr %3, align 4
    %22 = add nsw i32 %20, %21
    %23 = load i32, ptr %4, align 4
    %24 = add nsw i32 %22, %23
    ret i32 %24
  }
  declare void @_Z3useRi(ptr noundef nonnull align 4 dereferenceable(4)) #1


  $ opt-18 -passes=mem2reg fO0.ll -S -o - | grep -v -e datalay -e attributes  -e triple -e source_filename -e '!llvm.' -e  '^;' -e '^$' -e 'clang version' -e lifetime -e ' = !{!' -e ' = !{'
  define dso_local noundef i32 @_Z14one_bb_mem2regii(i32 noundef %0, i32 noundef %1) #0 {
    %3 = alloca i32, align 4
    %4 = alloca i32, align 4
    store i32 %0, ptr %3, align 4
    %5 = load i32, ptr %3, align 4
    %6 = add nsw i32 %5, %1
    store i32 %6, ptr %4, align 4
    %7 = load i32, ptr %3, align 4
    %8 = mul nsw i32 %7, %1
    store i32 %8, ptr %3, align 4
    call void @_Z3useRi(ptr noundef nonnull align 4 dereferenceable(4) %3)
    %9 = load i32, ptr %3, align 4
    %10 = load i32, ptr %4, align 4
    %11 = sub nsw i32 %10, %9
    store i32 %11, ptr %4, align 4
    %12 = load i32, ptr %4, align 4
    %13 = load i32, ptr %3, align 4
    %14 = add nsw i32 %12, %13
    %15 = mul nsw i32 %1, %14
    call void @_Z3useRi(ptr noundef nonnull align 4 dereferenceable(4) %4)
    %16 = load i32, ptr %4, align 4
    %17 = load i32, ptr %3, align 4
    %18 = add nsw i32 %16, %17
    %19 = add nsw i32 %18, %15
    ret i32 %19
  }
  declare void @_Z3useRi(ptr noundef nonnull align 4 dereferenceable(4)) #1

$ opt-18 -passes=mem2reg fO0.bc -S -o - | grep -v -e datalay -e attributes  -e triple -e source_filename -e '!llvm.' -e  '^;' -e '^$' -e 'clang version' -e lifetime -e ' = !{!' -e ' = !{i32'

$ llvm-dis-18 fO1.bc -o - | grep -v -e datalay -e attributes  -e triple -e source_filename -e '!llvm.' -e  '^;' -e '^$' -e 'clang version' -e lifetime -e ' = !{!' -e ' = !{i32'

$ llvm-dis-18 fO2.bc -o - | grep -v -e datalay -e attributes  -e triple -e source_filename -e '!llvm.' -e  '^;' -e '^$' -e 'clang version' -e lifetime -e ' = !{!' -e ' = !{i32'
