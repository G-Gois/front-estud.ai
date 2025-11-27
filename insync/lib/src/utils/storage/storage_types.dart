enum StorageType {
  secure,   // Criptografado (tokens, senhas)
  regular,  // SharedPreferences normal
  temp,     // Temporário (com prefixo 'temp_')
}
