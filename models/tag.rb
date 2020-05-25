class Tag < Sequel::Model(:documents_users)
 many_to_one :documents
 many_to_one :users
end