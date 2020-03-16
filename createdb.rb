# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :vacation do
  primary_key :id
  String :title
  String :description, text: true
  String : highlights
  String :location
end
DB.create_table! :reviews do
  primary_key :id
  foreign_key : vacation_id
  foreign_key :user_id
  String :name
  String :email
  Boolean :going 
  String :comments, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
vaction_table = DB.from(:vacation)

vacation_table.insert(title: "Drink Coffee in Colombia!", 
                    description: "Island Hop With Pablo Escobar",
                    highlights: "Coffee, Mojitos, and Unbelievable Beaches",
                    location: "Cartagena, Colombia")

vaction_table.insert(title: "Eat Steak in Argentina!", 
                    description: "Come Tango in the Vibrant South American City",
                    highlights: "Steak, Red Wine, and Beautiful Art",
                    location: "Buenos Aires, Argentina")