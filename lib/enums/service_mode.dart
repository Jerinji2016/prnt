enum ServiceMode {
  foreground,
  background;

  static fromIndex(int index) => ServiceMode.values.elementAt(index);
}
