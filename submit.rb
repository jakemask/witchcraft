#!/usr/bin/env ruby

##
# Libraries
require 'openssl'
require 'base64'
require 'uri'
require 'net/http'

##
# Helper Functions
def print_usage(msg="")
  $stderr.puts msg
  $stderr.puts "Usage: #{$0} target long_url [short_uri]"

  exit(1)
end

def valid?(url)
  uri = URI.parse(url)
  uri.kind_of?(URI::HTTP)
rescue URI::InvalidURIError
  false
end

def alpha?(str)
  !!str.match(/^[[:alnum:]]+$/)
end

##
# Start of Execution

# Verify arguments
target,long,short = ARGV


print_usage "Invalid number of args" if target.nil? || long.nil?

print_usage "Not a valid target" unless valid?(target)
 
print_usage "Not a valid link" unless valid?(long)

print_usage "Invalid shortening" unless short.nil? or alpha?(short)


# Encode the long link to create a signature 

priv_key = OpenSSL::PKey::RSA.new(File.read(File.join(Dir.home,"/.ssh/id_rsa")))
digest = OpenSSL::Digest::SHA512.new

signature = priv_key.sign(digest, long)

sig64 = Base64.encode64(signature)

# Post dat request

uri = URI.join(target,"new")
res = Net::HTTP.post_form(uri, :url => long, :signature => sig64, :short => short )

unless res.code == '201'
  puts res.body
  exit(2)
end

exit(0)
