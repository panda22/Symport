module MockSelfHelpers
  def mock_class(klass, opts={})
    klass.methods(false).each do |method|
      stub_method = klass.stubs(method)
      if opts[:strict]
        stub_method.raises "unexpected invocation"
      end
    end
  end
end
