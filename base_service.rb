class BaseService
  attr_reader :result, :errors
  
  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs, &block).call
  end
  
  def initialize(*args, **kwargs)
    @result = nil
    @errors = []
  end
  
  def call
    raise NotImplementedError, "#{self.class} must implement #call"
  end
  
  def success?
    @errors.empty?
  end
  
  def failure?
    !success?
  end
  
  protected
  
  def add_error(message)
    @errors << message
  end
  
  def add_errors(messages)
    @errors.concat(Array(messages))
  end
  
  def succeed(result = nil)
    @result = result
    self
  end
  
  def fail_with(error)
    add_error(error)
    self
  end
end
