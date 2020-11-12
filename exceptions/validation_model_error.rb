class  Validation_model_error < StandardError
    attr_reader :errors

    def initialize(msg="Datos incorrectos",errors)
       super(msg)
       @errors = errors 
    end    
end