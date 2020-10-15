# # con los users

class Subscription < Sequel::Model(:topics_users)
  many_to_one :topics
  many_to_one :users

end
