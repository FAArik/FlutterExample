abstract interface class IModel<T> {
  Map<String, Object?> toJson();
  T fromJson(Map<String, Object?> json);
}