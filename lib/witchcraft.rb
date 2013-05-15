module Witchcraft
  
  ALPHANUM = [*'0'..'9', *'a'..'z', *'A'..'Z']

  def Witchcraft.verify(signature, data, keypath="public.pem")

    # Make keys if there are none
    Witchcraft.makeKeys unless File.exists?(keypath)

    # Validate the Signature
    public_key = OpenSSL::PKey::RSA.new(File.read(keypath))
    digest = OpenSSL::Digest::SHA512.new

    return public_key.verify(digest,signature,data)
  end

  def Witchcraft.generate(len=3, set=ALPHANUM)

    valid = false

    until valid  
      # generate a random alphanum and see if it's been use
      short = Array.new(len){set.sample}.join
      valid = Witchcraft.valid?(short)
      break if valid

      # if we have to try again, try a longer one
      len += 1
      if len > 6 # billions of possible shorts
        return nil
      end

    end
  end

  def Witchcraft.valid?(short)
    return Link.all(:short => short).length == 0
  end

  def Witchcraft.makeKeys(passphrase="witchcraft")
    rsa_key = OpenSSL::PKey::RSA.new(2048)

    cipher =  OpenSSL::Cipher::Cipher.new('des3')

    private_key = rsa_key.to_pem(cipher,passphrase)
    public_key = rsa_key.public_key.to_pem

    File.open('public.pem', 'w') {|f| f.write(public_key) }
    File.open('private.pem', 'w') {|f| f.write(private_key) }
  end
end
