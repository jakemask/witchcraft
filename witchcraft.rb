module Witchcraft
  
  ALPHANUM = [*'0'..'9', *'a'..'z', *'A'..'Z']

  def Witchcraft.verify(signature, data, keypath="./id_rsa.pub")

    # Validate the Signature
    public_key = OpenSSL::PKey::RSA.new(File.read(keypath))
    digest = OpenSSL::Digest::SHA512.new
    signature = Base64.decode64(params[:signature])

    return public_key.verify(digest,signature,params[:url])
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
end
