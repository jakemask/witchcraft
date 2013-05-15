require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'haml'

require 'openssl'
require 'base64'

require './witchcraft.rb'

##
# Databse

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")

class Link
  include DataMapper::Resource

  property :id,    Serial
  property :long,  String
  property :short, String
end

Link.raise_on_save_failure = true

##
# Get Routes

# Main redirect
get '/' do
  redirect 'http://jakemask.com', 301
end

# Link redirect
get '/*' do
  short = params[:splat].first
  link = Link.last(:short => short)

  unless link.nil?
    redirect link.long, 301
  else
    redirect File.join('http://jakemask.com',short), 301
  end
end

##
# Post Routes

post '/new' do

  # Validate the Signature
  valid = Witchcraft.verify(Base64.decode64(params[:signature]), params[:url]) 
  
  # if invalid, return
  unless valid
    status 412
    return "Signature did not verify"
  end

  @long = params[:url]
  
  # Determine the short url
  if params[:short].nil?

    @short = Witchcraft.generate

    if @short.nil?
      status 412
      return "Unable to generate shortened link"
    end
  else # provided short url

    @short = params[:short]

    unless Witchcraft.valid?(@short)
      status 412
      return "Shortened link already exists"
    end
  end

  Link.create(:long => @long, :short => @short)
     
  status 201
  return @short

  
end

not_found { haml :'404' }

error { @error = request.env['sinatra_error']; haml :'500'; }

DataMapper.auto_upgrade!
