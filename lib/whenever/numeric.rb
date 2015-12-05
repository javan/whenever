class Numeric
  def respond_to?(method, include_private = false)
    super || Whenever::NumericSeconds.public_method_defined?(method)
  end

  def method_missing(method, *args, &block)
    if Whenever::NumericSeconds.public_method_defined?(method)
      Whenever::NumericSeconds.new(self).send(method)
    else
      super
    end
  end
end
