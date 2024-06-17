class ApplicationController < ActionController::API

    def authorize_request
        bearer = request.headers[:Authorization]
        uri = URI.parse("http://127.0.0.1:3000/api/v1/users/check_logged_user")
        request = Net::HTTP::Post.new(uri)
        request.content_type = "application/json"
        
        request['Authorization'] = bearer
        req_options = {
          use_ssl: uri.scheme == "https",
        }
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
    
        return render json: { errors: 'PLease login' }, status: :unauthorized if response.body != 'ok'
    end

end
