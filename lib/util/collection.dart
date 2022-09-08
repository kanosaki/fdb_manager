List<List<T>> unflatten<T>(List<T> original, int numElem) {
  List<T> buffer = [];
  List<List<T>> ret = [];
  for (int i = 0; i < original.length; i++) {
    buffer.add(original[i]);
    if ((i + 1) % numElem == 0) {
      ret.add(buffer);
      buffer = <T>[];
    }
  }
  if (buffer.isNotEmpty) {
    ret.add(buffer);
  }
  return ret;
}

List<List<T?>> unflattenWithPadNull<T>(List<T> original, int numElem) {
  List<T?> buffer = [];
  List<List<T?>> ret = [];
  for (int i = 0; i < original.length; i++) {
    buffer.add(original[i]);
    if ((i + 1) % numElem == 0) {
      ret.add(buffer);
      buffer = <T?>[];
    }
  }
  for (int i = 0; i < buffer.length % numElem; i++) {
    buffer.add(null);
  }
  if (buffer.isNotEmpty) {
    ret.add(buffer);
  }
  return ret;
}
