if RUBY_VERSION < "3.0"
  appraise 'activesupport5.0' do
    gem "activesupport", "~> 5.0.0"
  end

  appraise 'activesupport5.1' do
    gem "activesupport", "~> 5.1.0"
  end

  appraise 'activesupport5.2' do
    gem "activesupport", "~> 5.2.0"
  end
end

appraise 'activesupport6.0' do
  gem "activesupport", "~> 6.0.0"

  # ruby 3.3+
  gem "base64"
  gem "bigdecimal"
  gem "mutex_m"
  # ruby 3.4+
  gem "benchmark"
  gem "logger"

  # Fix https://github.com/rails/rails/issues/54260
  gem 'concurrent-ruby', "1.3.4"
end

appraise 'activesupport6.1' do
  gem "activesupport", "~> 6.1.0"

  # ruby 3.3+
  gem "base64"
  gem "bigdecimal"
  gem "mutex_m"
  # ruby 3.4+
  gem "benchmark"
  gem "logger"

  # Fix https://github.com/rails/rails/issues/54260
  gem 'concurrent-ruby', "1.3.4"
end

if RUBY_VERSION >= "2.7"
  appraise 'activesupport7.0' do
    gem "activesupport", "~> 7.0.0"
  end
end

if RUBY_VERSION >= "3.1"
  appraise 'activesupport7.1' do
    gem "activesupport", "~> 7.1.0"
  end
end

if RUBY_VERSION >= "3.2"
  appraise 'activesupport7.2' do
    gem "activesupport", "~> 7.2.0"
  end

  appraise 'activesupport8.0' do
    gem "activesupport", "~> 8.0.0"
  end

  appraise 'activesupport8.1' do
    gem "activesupport", "~> 8.1.0"
  end
end
