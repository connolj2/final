# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

vacation_table = DB.from(:vacation)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)


before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

get "/" do
    puts vacation_table.all
    @courses = vacation_table.all.to_a

    view "vacation"
end

get "/vacation/:id" do
    @vacation = vacation_table.where(id: params[:id]).to_a[0]
    @reviews = reviews_table.where(vacation_id: @vacation[:id])
    @users_table = users_table
    @location = vacation_table.where(id: params[:id]).to_a[0]
    
    results = Geocoder.search(@vacation[:location])
    @lat_long = results.first.coordinates
    @lat = "#{@lat_long [0]}"
    @long = "#{@lat_long [1]}"
    view "vacations"
end

get "/vacation/:id/reviews/new" do
    @course = courses_table.where(id: params[:id]).to_a[0]
    view "new_review"
end

get "/vacation/:id/reviews/create" do
    puts params
    @vacation = vacation_table.where(id: params["id"]).to_a[0]
    reviews_table.insert(vacation_id: params["id"],
                       user_id: session["user_id"],
                       going: params["going"],
                       comments: params["comments"])
    view "create_review"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts params
    hashed_password = BCrypt::Password.create(params["password"])
    users_table.insert(name: params["name"], email: params["email"], password: hashed_password)
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    user = users_table.where(email: params["email"]).to_a[0]
    puts BCrypt::Password::new(user[:password])
    if user && BCrypt::Password::new(user[:password]) == params["password"]
        session["user_id"] = user[:id]
        @current_user = user
        view "create_login"
    else
        view "create_login_failed"
    end
end

get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end