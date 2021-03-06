require_relative 'models/message'
require_relative 'models/contact_form_email'

Mail.defaults do
  delivery_method :smtp, { 
    :address => 'smtp.gmail.com',
    :port => '587',
    :user_name => ENV['GMAIL_SMTP_USER'],
    :password => ENV['GMAIL_SMTP_PASSWORD'],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end

class App < Sinatra::Base
  register Padrino::Helpers

  get "/" do
    @email_sent = params[:email] == "success"
    haml :home
  end

  get "/messages/new" do
    @message = Message.new
    haml :contact
  end

  post "/messages" do
    @message = Message.new params[:message]
    if @message.valid?
      Mail.deliver ContactFormEmail.new(@message, settings.environment).to_hash

      redirect "/?email=success"
    else
      haml :contact
    end
  end

  helpers do
    def partial template
      haml template, :layout => false
    end

    def is_home?
      request.path_info == "/"
    end

    def slider_arrow_class
      is_home? ? 'arrow_up' : 'arrow_down'
    end

    def slider_style
      'display: none' unless is_home?
    end

    def slider_container_style
      is_home? ? 'height: 404px' : 'height: 80px'
    end

    def gmap options={}
      src_params = {
        :q      => 'Bluerare,+Carleton,+London+Road,+Carlisle,+Cumbria',
        :hq     => 'Bluerare,+Carleton,+London+Road,+Carlisle,+Cumbria',
        :hnear  => 'Carleton,+CA1+3DP,+United+Kingdom',
        :sll    => '53.800651,-4.064941',
        :ll     => '54.880162,-2.906742',
        :spn    => '0.039502,0.102825',
        :sspn   => '10.196854,20.852051',
        :source => 's_q',
        :hl     => 'en',
        :t      => 'm',
        :z      => '13',
        :iwloc  => 'A',
        :ie     => 'UTF8',
        :output => 'embed'
      }.map { |k,v| "#{k}=#{v}" }.join('&')

      defaults = {
        :frameborder  => '0',
        :height       => '400',
        :marginheight => '0',
        :marginwidth  => '0',
        :scrolling    => 'no',
        :width        => '600',
        :src          => "https://maps.google.co.uk/maps?#{src_params}",
      }

      content_tag :iframe, nil, defaults.merge(options)
    end
  end
end
