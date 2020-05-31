# a documentos 

class Document_topic < Sequel::Model(:documents_topics)
    many_to_one :topics
    many_to_one :documents
end