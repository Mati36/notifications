class  File_not_found < StandardError
  attr_reader :errors

  def initialize(msg = "Archivo no encontrado",errors)
     super(msg)
     @errors = errors 
  end    
end