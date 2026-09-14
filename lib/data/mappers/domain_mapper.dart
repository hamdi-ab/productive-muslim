abstract class DomainMapper<T, R> {
  T toDomain(R row);
  R toRow(T domain);
}
