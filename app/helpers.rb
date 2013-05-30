# Helper methods defined here can be accessed in any controller or view in the application

Sadnat::App.helpers do
  # To help us not dump scary stuff, but still autolink links.
  def h text
    # Clean out html
    out = Sanitize.clean text

    # Link links
    out = out.gsub( %r{http(s)?://[^\s<]+} ) { |url| "<a href='#{url}'>#{url}</a>" }

    # Link Twitter Handles
    out = out.gsub(/@(\w+)/) {|a| "<a href=\"http://twitter.com/#{a[1..-1]}\"/>#{a}</a>" }

    return out
  end
end
