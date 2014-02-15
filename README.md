# Witchcraft

You go to one link, but show up at another, Witchcraft!

## Description

Witchcraft is a tiny low profile link shortener written in Ruby on Sinatra.

## How to Use

Do a `git clone` into your desired code folder, and then run the site via
`ruby app.rb` or via passenger or equivalent.

It will immediately start serving links. Right now the root redirects to
`jakemask.com`, but you can change that easily in app.rb.

To add links to the list, you can either launch up an irb session via
`irb -r ./app.rb` and add them manually, e.g.
`Link.create(:long => "http://google.com", :short => "g00g")`, or you can use
the submit.rb file.

In order to use submit.rb, copy your rsa public key into a file named id_rsa.pub
in the app directory, and run submit.rb from your local machine. It will send
the url to the server and sign it with your private key, found in ~/.ssh/id_rsa,
and then the server will verify it using your public key.
