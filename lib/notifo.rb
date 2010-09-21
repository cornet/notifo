require 'httparty'
require 'cgi'
require 'digest/sha1'

class Notifo
  cattr_accessor :service, :api_key
  
  include HTTParty
  base_uri 'https://api.notifo.com/v1'

  # Convenience method for configuration
  def Notifo.setup(&block)
    yield self
  end

  # Required Parameters
  #   username - notifo service username
  #   apikey - notifo service apisecret
  def initialize(params={})
    Notifo.username ||= params[:username]
    Notifo.secret ||= params[:secret]
    @auth = {:username => Notifo.username, :password => Notifo.secret}
  end

  # Required Parameters
  #   username - notifo username to subscribe to your service
  def subscribe_user(username)
    options = {:body => {:username => username}, :basic_auth => @auth}
    self.class.post("/subscribe_user", options)
  end
  
  # Required Parameters
  #   to - notifo username of recipient
  #   msg - message being sent; must be url encoded
  # Optional Parameters
  #   title - name of "notification event"
  #   uri - the uri that will be loaded when the notification is opened; if specified, must be urlencoded; if a web address, must start with http:// or https://
  #   label - label describing the "application" (used only if being sent from a User account; the Service label is automatically applied if being sent from a Service account) 
  def send_notification(params)
    options = {:body => params, :basic_auth => @auth}
    self.class.post('/send_notification', options)
  end

  # Require Parameters
  #   params - the hash of params the webhook passed to you. All keys must be *Strings*, not symbols.
  def verify_webhook_signature(params)
    signature = params['notifo_signature']
    other_notifo_params = params.reject {|key,val| !(key =~ /\Anotifo_/ && key != "notifo_signature")}
    str = other_notifo_params.keys.sort.map do |key|
      params[key]
    end.join
    str << @auth[:password]
    signature == Digest::SHA1.hexdigest(CGI::escape(str))
  end
end
