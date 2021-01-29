class ScannedObject {
  String _imagePath;
  String _text;

  ScannedObject(this._imagePath, this._text);

  String getImagePath() {
    return this._imagePath;
  }

  String getText() {
    return this._text;
  }

  ScannedObject.fromJson(Map<String, String> json)
      : _imagePath = json['imagePath'],
        _text = json['text'];

  Map<String, String> toJson() =>
      {
        'imagePath': _imagePath,
        'text': _text,
      };
}