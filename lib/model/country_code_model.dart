class CountryCode {
  String? name;
  String? code;
  String? dialCode;
  String? flagUri;

  CountryCode({this.name, this.code, this.dialCode, this.flagUri});

  String toCountryStringOnly() => name ?? '';
  @override
  String toString() => '$name ($dialCode)';
}