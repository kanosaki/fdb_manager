import 'dart:ui';

class RichString {
  const RichString(this.elements);

  final List<RichStringElement> elements;

  factory RichString.build(List<dynamic> args) {
    final ret = RichString(args.map((e) {
      if (e == null) {
        return const NullSpan();
      }
      if (e is String) {
        return StringSpan(e);
      } else if (e is RichStringElement) {
        return e;
      } else {
        throw Exception('Invalid Link element ${e.toString()}');
      }
    }).toList());
    return ret;
  }

  RichString concat(RichString other) {
    return RichString(elements + other.elements);
  }

  @override
  String toString() {
    return elements.join("");
  }
}

abstract class RichStringElement {
  const RichStringElement();
}

class NullSpan extends RichStringElement {
  const NullSpan();

  @override
  String toString() {
    return "";
  }
}

class StringSpan extends RichStringElement {
  const StringSpan(this.s);

  final String s;

  @override
  String toString() {
    return s;
  }
}

class MachineLink extends RichStringElement {
  const MachineLink(this.machineID);

  final String machineID;

  @override
  String toString() {
    return 'MachineID($machineID)';
  }
}

class ProcessLink extends RichStringElement {
  const ProcessLink(this.processID);

  final String processID;

  @override
  String toString() {
    return 'ProcessID($processID)';
  }
}

class ProcessAddressLink extends RichStringElement {
  const ProcessAddressLink(this.address);

  final String address;

  @override
  String toString() {
    return 'ProcessAddress($address)';
  }
}

class DatacenterLink extends RichStringElement {
  const DatacenterLink(this.name);

  final String name;

  @override
  String toString() {
    return 'DataCenter($name)';
  }
}
