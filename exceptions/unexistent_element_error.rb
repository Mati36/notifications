class  Unexistent_element_error < StandardError
    attr_reader :errors

    def initialize(msg="El dato no existe",errors)
       super(msg)
       @errors = errors 
    end    
end