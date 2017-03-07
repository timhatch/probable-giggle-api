# Module  Perseus             - The namespace for all application code
# Class   SessionController   - Subclasses ApplicationController
#
# SessionController manages routes Requesting/Updating/Deleting session data
# Currently implements:
# - Fetching the session data
# - Updating wet_id and auth (separately)
# - Updating auth by connecting to eGroupware
#
module Perseus
  class SessionController < Perseus::ApplicationController
    # HELPERS
    helpers Perseus::LocalDBConnection
    helpers Perseus::EGroupwareSessionAPI

    # symbolize route paramaters (deliberately non-recursive)
    #
    before do
      params.keys.each { |k| params[k.to_sym] = params.delete(k) }
    end

    # Fetch session data a JSON object containing wet_id and auth parameters
    #
    get '/' do
      Perseus::LocalDBConnection::Session.data.to_json
    end

    # Update Session[:wet_id' with a provided parameter
    #
    post '/wet_id' do
      Perseus::LocalDBConnection::Session.competition(params) ? 200 : 501
    end

    # Update Session[:auth] with a provided parameter
    #
    post '/auth' do
      Perseus::LocalDBConnection::Session.authorisation(params) ? 200 : 501
    end

    # Update Session[:auth] by connecting to eGroupware with login credentials
    #
    post '/login' do
      sessionid = Perseus::EGroupwareSessionAPI.login(params)
      Perseus::LocalDBConnection::Session.authorisation(auth: sessionid) ? 200 : 501
    end

    # Reset the competition and authorisation parameters
    #
    delete '/' do
      Perseus::LocalDBConnection::Session.reset ? 200 : 501
    end
  end
end
