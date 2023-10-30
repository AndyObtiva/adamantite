module PWManager
  module PWUtils

    def make_pw_info(username, pw, master_pw, master_pw_salt)
      cipher = OpenSSL::Cipher::AES256.new(:CBC)
      cipher.encrypt
      iv = cipher.random_iv
      cipher.key = Digest::MD5.hexdigest(master_pw + master_pw_salt)
      cipher_text = cipher.update(pw) + cipher.final
      utf8_cipher_text = Base64.encode64(cipher_text).encode('utf-8')
      utf8_iv = Base64.encode64(iv).encode('utf-8')

      {username: username, password: utf8_cipher_text, iv: utf8_iv}
    end

    def decrypt_pw(iv, pw_hash, master_pw, master_pw_salt)
      decrypt_cipher = OpenSSL::Cipher::AES256.new(:CBC)
      decrypt_cipher.decrypt
      iv = Base64.decode64(iv.encode('ascii-8bit'))
      decrypt_cipher.iv = iv
      decrypt_cipher.key = Digest::MD5.hexdigest(master_pw + master_pw_salt)
      decrypt_text = Base64.decode64(pw_hash.encode('ascii-8bit'))
      decrypt_cipher.update(decrypt_text) + decrypt_cipher.final
    end
  end
end