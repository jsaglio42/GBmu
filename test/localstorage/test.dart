
enum E {
  A, B, C, D,
}

class Info {
  final E e;
  final int i;
  final String s;

  const Info(this.e, this.i, this.s);

}

const List<Info> l = const <Info>[
  const Info(E.A, 42, 'ft'),
];



main() {
  print('Heelo World');

  print(l);
}