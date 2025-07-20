$LOAD_PATH << './lib'

require 'tokenise'
require 'shunt'
require 'runner'
require 'query_resolver'

describe QueryResolver do
  def test_eq(text, data, expected_success, expected_value)
    a = Tokenise.process(text)
    b = Shunt.process(a)
    c = QueryResolver.resolve(data, b)

    actual_success, actual_value = Runner.run(c)

    expect(actual_success).to eq(expected_success), "Success expected=#{expected_success} got=#{actual_success}"
    expect(actual_value).to eq(expected_value), "Value expected=#{expected_value} got=#{actual_value}"
  end

  describe 'with an empty data structure' do
    it 'fails if it references something that is not there' do
      test_eq('.level = "error"', {}, false, nil)
    end
  end

  describe 'with an existing key' do
    it 'matches and returns true' do
      test_eq('.level = "error"', { "level" => "error" }, true, true)
    end

    it 'does not match and returns false' do
      test_eq('.level = "error"', { "level" => "info" }, true, false)
    end
  end

  describe 'boolean && fails' do
    it 'does not match and fails' do
      test_eq('.level = "error" && true', { "level" => "info" }, true, false)
    end

    it 'does match and succeeds' do
      test_eq('.level = "error" && true', { "level" => "error" }, true, true)
    end
  end

  describe 'boolean || succeeds if something succeeds (magical edge case)' do
    it 'passes because the rhs passes' do
      test_eq('.level = "error" || true', { }, true, true)
    end

    it 'fails because the rhs fails' do
      test_eq('.level = "error" || false', { }, true, false)
    end

    it 'fails because both fail' do
      test_eq('.level = "error" || .level = "info"', { }, true, false)
    end

    it 'checks that it fails correctly' do
      test_eq('"dummy" || 42', { }, false, nil)
    end
  end
end
