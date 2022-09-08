
List<List<T>> unflatten<T>(List<T> original, int numElem) {
  List<T> buffer = [];
  List<List<T>> ret = [];
  for (int i = 0; i < original.length; i++) {
    if ((i+1) % numElem == 0) {
      ret.add(buffer);
      buffer = <T>[];
    }
    buffer.add(original[i]);
  }
  if (buffer.isNotEmpty) {
    ret.add(buffer);
  }
  return ret;
}
